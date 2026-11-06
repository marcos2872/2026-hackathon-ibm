"""Ícones pixel art 12x12 do Casa Quest.

Gera os SVGs de project/assets/Icones/ e o mapa de sprites que o bundle
usa no componente Icon, para que os dois nunca divirjam.
"""

PAL = {
    "K": "#1a1c2c", "W": "#f4f4f4", "L": "#e4ecf2", "G": "#94b0c2", "g": "#566c86",
    "B": "#3b5dc9", "c": "#41a6f6", "R": "#b13e53", "r": "#7a2840", "s": "#e26d84",
    "Y": "#ffcd75", "O": "#ef7d57", "M": "#a0603a", "m": "#6b3a26",
    "P": "#e8c170", "p": "#b8873e", "V": "#38b764", "v": "#1f7a45",
}


def pad(linhas, n=12):
    """Centraliza um sprite menor numa grade n x n."""
    h, w = len(linhas), len(linhas[0])
    top, left = (n - h) // 2, (n - w) // 2
    vazio = "." * n
    out = [vazio] * top
    for l in linhas:
        out.append("." * left + l + "." * (n - w - left))
    out += [vazio] * (n - len(out))
    return out


ICONES = {
    "moeda": [
        "...KKKKKK...",
        "..KYYYYYYK..",
        ".KYWYYYYYOK.",
        "KYWYYYOYYYOK",
        "KYYYYYOYYYOK",
        "KYYYYYOYYYOK",
        "KYYYYYOYYYOK",
        "KYYYYYOYYYOK",
        "KYYYYYYYYOOK",
        ".KYYYYYYOOK.",
        "..KOOOOOOK..",
        "...KKKKKK...",
    ],
    "xp": [
        ".....KK.....",
        "....KYYK....",
        "....KYYK....",
        "KKKKYYYYKKKK",
        "KYYYYWYYYYOK",
        ".KYYYYYYYOK.",
        "..KYYYYYYK..",
        "..KYYOOYYK..",
        ".KYYOKKOYOK.",
        ".KYOK..KOOK.",
        ".KKK....KKK.",
        "............",
    ],
    "trofeu": [
        "..KKKKKKKK..",
        "KKKYYYYYOKKK",
        "KYKYWYYYOKOK",
        "KYKYWYYYOKOK",
        ".KKYYYYYOKK.",
        "...KYYYOK...",
        "....KYOK....",
        "....KYOK....",
        "...KYYYOK...",
        "...KKKKKK...",
        "...KMMMmK...",
        "...KKKKKK...",
    ],
    "tela": [
        "KKKKKKKKKKKK",
        "KGGGGGGGGGgK",
        "KGccccccccgK",
        "KGcWccccccgK",
        "KGccccccccgK",
        "KGccccccccgK",
        "KGccccccccgK",
        "KGGGGGGGGGgK",
        "KKKKKKKKKKKK",
        "....KggK....",
        "...KGGGgK...",
        "..KKKKKKKK..",
    ],
    "camera": [
        "............",
        "..KKKK......",
        "KKKggKKKKKKK",
        "KGGGGKKKGGYK",
        "KGGGKcccKGGK",
        "KGGKccWccKGK",
        "KGGKcccccKGK",
        "KGGKcccccKGK",
        "KGGGKcccKGGK",
        "KggggKKKgggK",
        "KKKKKKKKKKKK",
        "............",
    ],
    "check": [
        "............",
        "..........KK",
        ".........KVK",
        "........KVvK",
        ".KK....KVvK.",
        "KVVK..KVvK..",
        "KVVVKKVvK...",
        ".KVVVVvK....",
        "..KVVvK.....",
        "...KvK......",
        "....K.......",
        "............",
    ],
    "ampulheta": [
        "KKKKKKKKKKKK",
        "KMMMMMMMMMmK",
        "KKKKKKKKKKKK",
        ".KWPPPPPPWK.",
        "..KWPPPPWK..",
        "...KWPPWK...",
        "...KWWPWK...",
        "..KWWWPWWK..",
        ".KWWWPPPWWK.",
        "KKKKKKKKKKKK",
        "KMMMMMMMMMmK",
        "KKKKKKKKKKKK",
    ],
    "bau": [
        "............",
        "..KKKKKKKK..",
        ".KMMMMMMMmK.",
        "KMMMMMMMMMmK",
        "KYYYYYYYYYOK",
        "KKKKKKKKKKKK",
        "KMMMMKYKMMmK",
        "KMMMMKOKMMmK",
        "KMMMMMKMMMmK",
        "KYMMMMMMMMOK",
        "KmmmmmmmmmmK",
        "KKKKKKKKKKKK",
    ],
    "vassoura": [
        ".........KK.",
        "........KMK.",
        ".......KMK..",
        "......KMK...",
        ".....KMK....",
        "..KKKRK.....",
        ".KPPRRK.....",
        "KPpPPK......",
        "KPPpPK......",
        "KpPPK.......",
        "KPPK........",
        "KKK.........",
    ],
    "casa": pad([
        "....K....",
        "...KRK.KK",
        "..KRRRKYK",
        ".KRRRRRKK",
        "KRRRRRRRK",
        "KKWWWWWKK",
        ".KcWWmWK.",
        ".KWWWmWK.",
        ".KKKKKKK.",
    ]),
    "balde": pad([
        "..KKKKK..",
        ".K.....K.",
        "KKKKKKKKK",
        "KccccccWK",
        "KGGGGGGgK",
        ".KGGGGgK.",
        ".KgggggK.",
        ".KGGGGgK.",
        "..KKKKK..",
    ]),
    "louca": pad([
        "..KKKKKKK..",
        ".KLLBBBLLK.",
        "KLLBWWWBLLK",
        "KLBWWWWWBLK",
        "KLBWWWWWBLK",
        "KLLBWWWBGLK",
        ".KGLBBBLGK.",
        "..KKKKKKK..",
    ]),
    "d20": pad([
        "....KKK....",
        "..KKRKRKK..",
        ".KRRKsKRRK.",
        "KRRKsssKRRK",
        "KRKsssssKrK",
        "KRKsWsssKrK",
        "KKKKKKKKKKK",
        "..KKrrrKK..",
        "....KKK....",
    ]),
}

for nome, s in ICONES.items():
    assert len(s) == 12 and all(len(l) == 12 for l in s), nome


def svg(linhas):
    partes = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12" width="48" height="48" shape-rendering="crispEdges">']
    for y, l in enumerate(linhas):
        x = 0
        while x < 12:
            c = l[x]
            if c == ".":
                x += 1
                continue
            ini = x
            while x < 12 and l[x] == c:
                x += 1
            partes.append(f'<rect x="{ini}" y="{y}" width="{x - ini}" height="1" fill="{PAL[c]}"/>')
    partes.append("</svg>")
    return "".join(partes)
