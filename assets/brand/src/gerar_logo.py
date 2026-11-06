"""Gera o logo do Casa Quest em pixel art (SVG + PNG).

Uso:  python assets/brand/src/gerar_logo.py
Saída: assets/brand/*.svg e assets/brand/png/*.png

Tudo é desenhado numa grade de pixels; o SVG usa um <rect> por trecho
horizontal de mesma cor, com shape-rendering="crispEdges".
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageColor

RAIZ = Path(__file__).resolve().parents[1]

# ---------------------------------------------------------------- paleta
PAL = {
    "K": "#1a1c2c",  # contorno
    "W": "#f4f4f4",  # branco
    "L": "#e4ecf2",  # louça clara
    "G": "#94b0c2",  # cinza metal
    "g": "#566c86",  # cinza escuro
    "B": "#3b5dc9",  # azul heráldico
    "b": "#29366f",  # azul escuro
    "c": "#41a6f6",  # água
    "R": "#b13e53",  # vermelho heráldico
    "r": "#7a2840",  # vermelho escuro
    "Y": "#ffcd75",  # ouro
    "O": "#ef7d57",  # ouro sombra / laranja
    "M": "#a0603a",  # madeira
    "m": "#6b3a26",  # madeira escura
    "P": "#e8c170",  # palha
    "p": "#b8873e",  # palha sombra
    "s": "#e26d84",  # vermelho claro (face do d20)
}


class Tela:
    def __init__(self, w: int, h: int):
        self.w, self.h = w, h
        self.px: dict[tuple[int, int], str] = {}

    def put(self, x: int, y: int, c: str):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.px[(x, y)] = c

    def camada(self, forma: dict[tuple[int, int], str], contorno: bool = True):
        """Pinta uma forma por cima, com contorno de 1 px (4-vizinhança)."""
        if contorno:
            for (x, y) in forma:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    v = (x + dx, y + dy)
                    if v not in forma:
                        self.put(*v, "K")
        for (x, y), c in forma.items():
            self.put(x, y, c)

    def sprite(self, linhas: list[str], ox: int, oy: int):
        for j, linha in enumerate(linhas):
            for i, c in enumerate(linha):
                if c != ".":
                    self.put(ox + i, oy + j, c)

    # ------------------------------------------------------------ saída
    def svg(self, escala: int = 1, fundo: str | None = None) -> str:
        partes = [
            f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {self.w} {self.h}" '
            f'width="{self.w * escala}" height="{self.h * escala}" shape-rendering="crispEdges">'
        ]
        if fundo:
            partes.append(f'<rect width="{self.w}" height="{self.h}" fill="{fundo}"/>')
        for y in range(self.h):
            x = 0
            while x < self.w:
                c = self.px.get((x, y))
                if c is None:
                    x += 1
                    continue
                ini = x
                while x < self.w and self.px.get((x, y)) == c:
                    x += 1
                partes.append(f'<rect x="{ini}" y="{y}" width="{x - ini}" height="1" fill="{PAL[c]}"/>')
        partes.append("</svg>")
        return "\n".join(partes)

    def png(self, escala: int, fundo: str | None = None) -> Image.Image:
        img = Image.new("RGBA", (self.w, self.h), fundo or (0, 0, 0, 0))
        for (x, y), c in self.px.items():
            img.putpixel((x, y), ImageColor.getrgb(PAL[c]) + (255,))
        return img.resize((self.w * escala, self.h * escala), Image.NEAREST)


# ------------------------------------------------------- objetos em diagonal
def objeto_diagonal(p0, p1, perfil) -> dict[tuple[int, int], str]:
    """Desenha um objeto ao longo do eixo p0->p1.

    perfil(u, v) recebe u = distância ao longo do eixo (0 em p0) e
    v = distância perpendicular com sinal; devolve uma cor ou None.
    """
    (x0, y0), (x1, y1) = p0, p1
    dx, dy = x1 - x0, y1 - y0
    comp = math.hypot(dx, dy)
    ux, uy = dx / comp, dy / comp
    forma = {}
    for y in range(64):
        for x in range(64):
            px, py = x + 0.5 - x0, y + 0.5 - y0
            u = px * ux + py * uy
            v = -px * uy + py * ux
            c = perfil(u, v, comp)
            if c:
                forma[(x, y)] = c
    return forma


def vassoura(u, v, comp):
    if u < 0 or u > comp:
        return None
    cerdas = 12
    if u > comp - cerdas:  # cerdas abrem em leque
        t = (u - (comp - cerdas)) / cerdas
        meia = 1.8 + 3.6 * t
        if abs(v) <= meia:
            if t < 0.18:
                return "R"  # amarração
            return "p" if (int(v + 10) % 2 == 0 and t > 0.35) else "P"
        return None
    if abs(v) <= 1.0:
        return "M" if v < 0.1 else "m"
    return None


def espada(u, v, comp):
    if u < 0 or u > comp:
        return None
    if u < 3.2:  # pomo
        return "Y" if abs(v) <= 1.6 else None
    if u < 8:  # empunhadura
        return ("m" if int(u) % 2 else "M") if abs(v) <= 1.0 else None
    if u < 10.2:  # guarda
        return ("Y" if v < 0.5 else "O") if abs(v) <= 5.2 else None
    resto = comp - u
    meia = min(1.6, 0.35 + resto * 0.4)  # afina na ponta
    if abs(v) <= meia:
        return "W" if v < 0 else "G"
    return None


# ---------------------------------------------------------------- ícones
CASA = [
    "....K....",
    "...KRK.KK",
    "..KRRRKYK",
    ".KRRRRRKK",
    "KRRRRRRRK",
    "KKWWWWWKK",
    ".KcWWmWK.",
    ".KWWWmWK.",
    ".KKKKKKK.",
]
BALDE = [
    "..KKKKK..",
    ".K.....K.",
    "KKKKKKKKK",
    "KccccccWK",
    "KGGGGGGgK",
    ".KGGGGgK.",
    ".KgggggK.",
    ".KGGGGgK.",
    "..KKKKK..",
]
PRATOS = [
    "..KKKKKKK..",
    ".KLLBBBLLK.",
    "KLLBWWWBLLK",
    "KLBWWWWWBLK",
    "KLBWWWWWBLK",
    "KLLBWWWBGLK",
    ".KGLBBBLGK.",
    "..KKKKKKK..",
]
D20 = [
    "....KKK....",
    "..KKRKRKK..",
    ".KRRKsKRRK.",
    "KRRKsssKRRK",
    "KRKsssssKrK",
    "KRKsWsssKrK",
    "KKKKKKKKKKK",
    "..KKrrrKK..",
    "....KKK....",
]
BRILHO = [".Y.", "YWY", ".Y."]


def brasao() -> Tela:
    t = Tela(48, 48)

    # 1) vassoura e espada cruzadas atrás do escudo
    t.camada(objeto_diagonal((44.5, 44.5), (5.0, 5.0), vassoura))
    t.camada(objeto_diagonal((3.5, 44.5), (45, 3), espada))

    # 2) escudo heráldico
    topo, base_reta, ponta = 7, 28, 45
    cx = 24.0
    escudo = {}
    for y in range(topo, ponta + 1):
        if y <= base_reta:
            meia = 15.0
        else:
            k = (y - base_reta) / (ponta - base_reta)
            meia = 15.0 * (1 - k ** 1.8)
        for x in range(48):
            if abs(x + 0.5 - cx) <= meia:
                escudo[(x, y)] = "Y"

    def dentro(x, y, margem):
        return all((x + dx, y + dy) in escudo for dx in range(-margem, margem + 1)
                   for dy in range(-margem, margem + 1))

    for (x, y) in list(escudo):
        if dentro(x, y, 2):
            esq, cima = x < 24, y < 25
            cor = "B" if esq == cima else "R"
            escudo[(x, y)] = cor
        elif dentro(x, y, 1):
            escudo[(x, y)] = "O" if x >= 24 else "Y"
        # cruz dourada separando os quartéis
    for (x, y) in list(escudo):
        if dentro(x, y, 2) and (x in (23, 24) or y in (24, 25)):
            escudo[(x, y)] = "Y" if (x == 23 or y == 24) else "O"
    # brilho no canto superior esquerdo da moldura
    for x in range(10, 16):
        escudo[(x, topo)] = "W"
    t.camada(escudo)

    # 3) ícones nos quartéis
    t.sprite(CASA, 12, 12)
    t.sprite(BALDE, 27, 12)
    t.sprite(PRATOS, 12, 28)
    t.sprite(BRILHO, 19, 27)
    t.sprite(D20, 25, 28)
    return t


# ---------------------------------------------------------------- fonte
FONTE = {
    "C": [".####", "##...", "##...", "##...", "##...", "##...", ".####"],
    "A": [".###.", "##.##", "##.##", "#####", "##.##", "##.##", "##.##"],
    "S": [".####", "##...", "##...", ".###.", "...##", "...##", "####."],
    "Q": [".###..", "##.##.", "##.##.", "##.##.", "##.##.", "##.##.", ".#####"],
    "U": ["##.##", "##.##", "##.##", "##.##", "##.##", "##.##", ".###."],
    "E": ["#####", "##...", "##...", "####.", "##...", "##...", "#####"],
    "T": ["#####", ".##..", ".##..", ".##..", ".##..", ".##..", ".##.."],
    " ": ["...", "...", "...", "...", "...", "...", "..."],
}
# corrige T centralizado em 5 colunas
FONTE["T"] = ["######", "..##..", "..##..", "..##..", "..##..", "..##..", "..##.."]


def texto(t: Tela, s: str, ox: int, oy: int, claro: str, escuro: str, esc: int = 1):
    """Escreve com contorno, sombra de 1 px e degradê em duas faixas."""
    forma = {}
    x = ox
    for ch in s:
        g = FONTE[ch]
        for j, linha in enumerate(g):
            for i, c in enumerate(linha):
                if c == "#":
                    for a in range(esc):
                        for b in range(esc):
                            cor = claro if j < 4 else escuro
                            forma[(x + i * esc + a, oy + j * esc + b)] = cor
        x += (len(g[0]) + 1) * esc
    sombra = {(x + 1, y + 1): "K" for (x, y) in forma}
    t.camada({**sombra}, contorno=False)
    t.camada(forma)
    return x


def largura_texto(s: str, esc: int = 1) -> int:
    return sum((len(FONTE[c][0]) + 1) * esc for c in s) - esc


# ---------------------------------------------------------------- logos
def logo_horizontal() -> Tela:
    b = brasao()
    w_casa = largura_texto("CASA", 2)
    w_quest = largura_texto("QUEST", 2)
    w = 48 + 4 + max(w_casa, w_quest) + 4
    t = Tela(w, 48)
    t.px.update(b.px)
    texto(t, "CASA", 53, 7, "W", "L", 2)
    texto(t, "QUEST", 53, 26, "Y", "O", 2)
    return t


def logo_empilhado() -> Tela:
    b = brasao()
    w_txt = largura_texto("CASA QUEST", 1)
    w = max(48, w_txt + 6)
    t = Tela(w, 48 + 12)
    off = (w - 48) // 2
    for (x, y), c in b.px.items():
        t.put(x + off, y, c)
    x = (w - w_txt) // 2
    x = texto(t, "CASA ", x, 50, "W", "L", 1)
    texto(t, "QUEST", x, 50, "Y", "O", 1)
    return t


def favicon() -> Tela:
    """Versão de 16 px: escudo com a casa, sem os detalhes."""
    t = Tela(16, 16)
    t.sprite([
        ".KKKKKKKKKKKKKK.",
        ".KYYYYYYYYYYYYK.",
        ".KYBBBBBBBBBBOK.",
        ".KYBBBBKBBBBBOK.",
        ".KYBBBKRKBBBBOK.",
        ".KYBBKRRRKBBBOK.",
        ".KYBKRRRRRKBBOK.",
        ".KYBKWWWWWKBBOK.",
        ".KYBKWWmWWKBBOK.",
        ".KYBKWWmWWKBBOK.",
        ".KYBBKKKKKBBBOK.",
        "..KYBBBBBBBBOK..",
        "..KKYBBBBBBOKK..",
        "...KKYBBBBOKK...",
        ".....KKOOKK.....",
        ".......KK.......",
    ], 0, 0)
    return t


def main():
    png_dir = RAIZ / "png"
    png_dir.mkdir(exist_ok=True)
    saidas = {
        "casa-quest-brasao": (brasao(), 10),
        "casa-quest-logo-horizontal": (logo_horizontal(), 8),
        "casa-quest-logo-empilhado": (logo_empilhado(), 8),
        "casa-quest-favicon": (favicon(), 16),
    }
    for nome, (tela, esc) in saidas.items():
        (RAIZ / f"{nome}.svg").write_text(tela.svg(), encoding="utf-8")
        tela.png(esc).save(png_dir / f"{nome}.png")
        tela.png(esc, "#2b2d42").save(png_dir / f"{nome}-fundo-escuro.png")
    # ícone de app: brasão sobre fundo escuro, quadrado
    app = Tela(56, 56)
    for (x, y), c in brasao().px.items():
        app.put(x + 4, y + 4, c)
    (RAIZ / "casa-quest-app-icon.svg").write_text(app.svg(fundo="#29366f"), encoding="utf-8")
    app.png(16, "#29366f").save(png_dir / "casa-quest-app-icon.png")
    print("ok")


if __name__ == "__main__":
    main()
