"""Gera project/tokens.json e confere o contraste dos textos nos dois temas."""

import json
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]


def c(name, noite, dia, usage):
    v = noite if dia is None else {"noite": noite, "dia": dia}
    return {"name": name, "value": v, "usage": usage}


CORES = [
    c("surface-000", "#20223a", "#f2e8d5", "Fundo da página. Noite = masmorra azul-escura; Dia = pergaminho."),
    c("surface-100", "#2b2e4a", "#fbf5e9", "Painéis, linhas de missão, cartas de recompensa, barra de abas."),
    c("surface-200", "#3a3f63", "#e6d7b9", "Elevado: hover, aba ativa, linha do próprio usuário no ranking, botão secundário."),
    c("ink", "#f4f4f4", "#1a1c2c", "Texto principal sobre surface-000/100/200 (9:1 ou mais nos dois temas)."),
    c("ink-muted", "#b4c0d4", "#5a5470", "Texto de apoio: metadados, legendas, abas inativas (5:1 ou mais em surface-000/100/200)."),
    c("outline", "#0e0f1a", "#1a1c2c", "O contorno de pixel: moldura de 4px de toda caixa, botão e barra. Não use outra cor de borda."),
    c("gold", "#ffcd75", None, "Cor da marca: moldura do brasão, botão primário, barra de XP, aba ativa. É preenchimento: o texto sobre ela é on-gold."),
    c("gold-shade", "#ef7d57", None, "Sombra do ouro (lado direito do brasão, faixa de baixo do QUEST); barra de créditos."),
    c("on-gold", "#1a1c2c", None, "Texto e ícones sobre gold (11:1) e gold-shade."),
    c("gold-ink", "#ffcd75", "#8a4f10", "Texto dourado: pontos, preços, rótulos de seção. 4.6:1 ou mais em surface-000/100/200."),
    c("heraldic-blue", "#3b5dc9", None, "Azul heráldico do brasão: título de painel, avatar, botão azul."),
    c("heraldic-blue-shade", "#29366f", None, "Fundo do ícone de app; sombra do azul."),
    c("heraldic-blue-bright", "#5b8cf0", None, "Barra de pontos de temporada (precisa se destacar de bar-empty nos dois temas)."),
    c("on-blue", "#f4f4f4", None, "Texto sobre heraldic-blue (5.3:1)."),
    c("blue-ink", "#8fb3ff", "#2c47a8", "Texto azul (links, informação) sobre as superfícies."),
    c("heraldic-red", "#b13e53", None, "Vermelho heráldico: telhado, d20, missão pesada (peso 2 ou mais), rejeitado, botão perigoso."),
    c("heraldic-red-shade", "#7a2840", None, "Sombra do vermelho."),
    c("on-red", "#f4f4f4", None, "Texto sobre heraldic-red (5.2:1)."),
    c("red-ink", "#ff8a9d", "#9c2f45", "Texto vermelho (falta, erro) sobre as superfícies."),
    c("rose", "#e26d84", None, "Face clara do d20; terceira cor de membro na meta coletiva."),
    c("cyan", "#41a6f6", None, "Tempo de tela e água do balde: barra de tela, missão leve (peso 0,5), recompensa de curto prazo."),
    c("on-cyan", "#1a1c2c", None, "Texto sobre cyan (6.4:1). Nunca branco."),
    c("cyan-ink", "#73d4ff", "#17648f", "Texto ciano (minutos de tela) sobre as superfícies."),
    c("success", "#38b764", None, "Aprovado / missão concluída. Preenchimento: texto em on-success."),
    c("on-success", "#1a1c2c", None, "Texto sobre success (6.5:1). Nunca branco."),
    c("green-ink", "#7fe0a0", "#186b3b", "Texto verde (mínimo atingido) sobre as superfícies."),
    c("dispute", "#7a4a9e", None, "Contestado: registro em disputa, aguardando o admin."),
    c("on-dispute", "#f4f4f4", None, "Texto sobre dispute (5.8:1)."),
    c("bar-empty", "#14152a", "#d8c8a6", "Fundo vazio das barras (XP, tela, meta)."),
    c("dialog-bg", "#1a1c2c", None, "Caixa de diálogo estilo RPG: sempre escura, nos dois temas."),
    c("dialog-ink", "#f4f4f4", None, "Texto da caixa de diálogo (17:1 sobre dialog-bg)."),
    c("dialog-accent", "#ffcd75", None, "Título e seta piscante da caixa de diálogo (11:1 sobre dialog-bg)."),
    c("focus", "#73eff7", "#2c47a8", "Anel de foco do teclado: contorno de 4px, afastado 6px."),
]


def lum(hx):
    hx = hx.lstrip("#")
    r, g, b = [int(hx[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    f = lambda x: x / 12.92 if x <= 0.03928 else ((x + 0.055) / 1.055) ** 2.4
    return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b)


def cr(a, b):
    a, b = sorted([lum(a), lum(b)], reverse=True)
    return (a + 0.05) / (b + 0.05)


VAL = {t["name"]: t["value"] for t in CORES}


def get(n, th):
    v = VAL[n]
    return v if isinstance(v, str) else v[th]


def checar():
    ok = True
    for th in ("noite", "dia"):
        for txt in ("ink", "ink-muted", "gold-ink", "blue-ink", "red-ink", "green-ink", "cyan-ink"):
            m = min(cr(get(txt, th), get(s, th)) for s in ("surface-000", "surface-100", "surface-200"))
            if m < 4.5:
                ok = False
            print(f"{th:6} {txt:10} {m:5.2f}{'  <-- FALHA' if m < 4.5 else ''}")
        for fill, on in (("gold", "on-gold"), ("heraldic-blue", "on-blue"), ("heraldic-red", "on-red"),
                         ("cyan", "on-cyan"), ("success", "on-success"), ("dispute", "on-dispute")):
            m = cr(get(fill, th), get(on, th))
            if m < 4.5:
                ok = False
            print(f"{th:6} {on:10} sobre {fill}: {m:5.2f}")
        print(f"{th:6} focus vs surface-000: {cr(get('focus', th), get('surface-000', th)):.2f}")
    return ok


TOKENS = {
    "name": "Casa Quest", "version": 1,
    "color": {"themes": [{"id": "noite", "name": "Noite"}, {"id": "dia", "name": "Dia"}], "tokens": CORES},
    "type": {
        "fonts": [],
        "families": {
            "display": "\"Press Start 2P\", ui-monospace, monospace",
            "text": "\"Pixelify Sans\", system-ui, sans-serif",
        },
        "groups": [
            {"name": "Display", "family": "display", "styles": [
                {"name": "title-xl", "fontSize": "24px", "lineHeight": "32px", "fontWeight": 400, "sample": "CASA QUEST",
                 "usage": "Telas de abertura e de fim de temporada. No máximo uma por tela."},
                {"name": "title-lg", "fontSize": "16px", "lineHeight": "24px", "fontWeight": 400, "sample": "Ranking da semana",
                 "usage": "Título de tela."},
                {"name": "title-md", "fontSize": "12px", "lineHeight": "16px", "fontWeight": 400, "sample": "MISSÕES DE HOJE",
                 "usage": "Título de painel, botões, rótulos de seção (caixa alta)."},
                {"name": "label", "fontSize": "10px", "lineHeight": "16px", "fontWeight": 400, "sample": "+20 XP",
                 "usage": "Números de jogo: pontos, preços, níveis, posição."},
                {"name": "micro", "fontSize": "8px", "lineHeight": "12px", "fontWeight": 400, "sample": "APROVADO",
                 "usage": "Selos de status e legenda numérica de barras. Nunca para frases."},
            ]},
            {"name": "Texto", "family": "text", "styles": [
                {"name": "body-lg", "fontSize": "18px", "lineHeight": "26px", "fontWeight": 500, "sample": "Limpe o banheiro e ganhe 20 pontos.",
                 "usage": "Destaques e texto de diálogo em telas grandes."},
                {"name": "body", "fontSize": "16px", "lineHeight": "24px", "fontWeight": 400, "sample": "O admin vai avaliar sua foto antes/depois.",
                 "usage": "Texto corrido; tamanho mínimo para frases."},
                {"name": "body-strong", "fontSize": "16px", "lineHeight": "24px", "fontWeight": 600, "sample": "Lavar a louça",
                 "usage": "Nome de missão, de recompensa e de membro."},
                {"name": "caption", "fontSize": "13px", "lineHeight": "16px", "fontWeight": 400, "sample": "Peso 2 · Antes/depois · até 21h",
                 "usage": "Metadados, em ink-muted."},
            ]},
        ],
    },
    "spacing": {"tokens": [
        {"name": "space-1", "value": "4px", "usage": "1 pixel de jogo. Toda medida é múltiplo dele."},
        {"name": "space-2", "value": "8px", "usage": "Ícone ↔ texto; espaço dentro de selos e chips."},
        {"name": "space-3", "value": "12px", "usage": "Espaço entre itens de lista; padding lateral de linhas."},
        {"name": "space-4", "value": "16px", "usage": "Padding de painéis e da tela."},
        {"name": "space-5", "value": "24px", "usage": "Padding horizontal de botões; espaço entre seções."},
        {"name": "space-6", "value": "32px", "usage": "Respiro entre blocos grandes."},
        {"name": "space-8", "value": "48px", "usage": "Altura de botão e alvo de toque mínimo."},
    ]},
    "radius": {
        "note": "Pixel art não tem raio: os cantos são comidos pelo contorno de 4px (box-shadow em cruz).",
        "tokens": [
            {"name": "radius-none", "value": "0px", "usage": "Todo componente. Arredondamento suave quebra a estética 8 bits."},
            {"name": "notch", "value": "4px", "usage": "Tamanho do canto comido e espessura do contorno (= space-1)."},
            {"name": "notch-lg", "value": "8px", "usage": "Canto em degrau duplo, para molduras grandes (tela, cartaz)."},
        ]},
    "shadow": {"tokens": [
        {"name": "shadow-bevel", "value": "inset -4px -4px 0 0 rgba(0,0,0,0.28), inset 4px 4px 0 0 rgba(255,255,255,0.35)",
         "usage": "Relevo 8 bits de botões: luz em cima e à esquerda, sombra embaixo e à direita."},
        {"name": "shadow-pressed", "value": "inset 4px 4px 0 0 rgba(0,0,0,0.28)",
         "usage": "Botão pressionado (junto com um translate de 4px)."},
        {"name": "shadow-drop", "value": {"noite": "4px 4px 0 0 #0e0f1a", "dia": "4px 4px 0 0 #1a1c2c"},
         "usage": "Sombra dura, sem desfoque, para o que flutua (diálogos, botão flutuante)."},
    ]},
}

if __name__ == "__main__":
    ok = checar()
    (RAIZ / "project" / "tokens.json").write_text(json.dumps(TOKENS, ensure_ascii=False, indent=1), encoding="utf-8")
    print("contraste ok" if ok else "HÁ FALHAS DE CONTRASTE")
