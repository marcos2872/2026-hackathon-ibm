# Casa Quest — Identidade visual

## Conceito

O logo é um **brasão de aventureiro da casa**: a ideia de que cada família é uma guilda e cada tarefa é uma missão.

| Elemento | Origem | Significado |
|---|---|---|
| Escudo heráldico esquartelado | D&D / heráldica | A família como guilda; o escudo protege o lar |
| Vassoura × espada cruzadas | Doméstico + D&D | A tarefa da casa vale tanto quanto uma missão épica |
| Casa | Doméstico | O lar é o reino que se cuida junto |
| Balde | Doméstico | O esforço do dia a dia |
| Prato com brilho | Doméstico | A louça lavada: tarefa concluída, prova visual |
| d20 vermelho | D&D | O sorteio balanceado e o espírito de jogo |
| "CASA" branco / "QUEST" dourado | 8 bits | Tela de título de jogo clássico |

## Arquivos

| Arquivo | Uso |
|---|---|
| `casa-quest-logo-horizontal.svg` | Cabeçalho, slides, README |
| `casa-quest-logo-empilhado.svg` | Tela de abertura (splash), capa |
| `casa-quest-brasao.svg` | Só o símbolo |
| `casa-quest-app-icon.svg` | Ícone de app / PWA (fundo azul) |
| `casa-quest-favicon.svg` | Favicon e tamanhos de 16 a 32 px |
| `png/` | Versões PNG ampliadas, com fundo transparente e escuro |

Os SVGs usam `shape-rendering="crispEdges"`. Ao ampliar um PNG, use escala inteira (2×, 4×, 8×) e interpolação *nearest neighbor* para não borrar os pixels.

## Paleta

| Cor | Hex | Uso |
|---|---|---|
| Contorno | `#1a1c2c` | Contornos e sombra |
| Azul heráldico | `#3b5dc9` | Quartéis, fundo do ícone (`#29366f`) |
| Vermelho heráldico | `#b13e53` | Quartéis, telhado, d20 |
| Ouro | `#ffcd75` | Moldura, "QUEST" |
| Ouro sombra | `#ef7d57` | Sombra da moldura e do texto |
| Branco | `#f4f4f4` | "CASA", louça |

## Como editar

Tudo é gerado por `src/gerar_logo.py` (Python 3 + Pillow). Os ícones dos quartéis e a fonte são matrizes de texto, fáceis de ajustar pixel a pixel:

```bash
python assets/brand/src/gerar_logo.py
```
