# Casa Quest — design system

Casa Quest transforma as tarefas da casa num jogo cooperativo: cada tarefa é uma **missão**, cada foto é a **prova**, cada ponto vira **XP**, **ranking**, **tesouro** e **tempo de tela**. O visual mistura a casa (vassoura, balde, louça) com pixel art 8 bits e um pouco de RPG de mesa (escudo, espada, d20).

Este sistema nasceu do logo (o brasão esquartelado em `assets/Logos/`) e da referência de gamificação de hábitos que a equipe juntou: um cabeçalho de herói com barras, uma lista de tarefas com botão lateral, uma loja de recompensas em grade com preço em moedas e uma barra de abas embaixo. A referência deu a estrutura. A identidade vem do brasão.

## Princípios

1. **Pixel de verdade.** Tudo se mede em pixels de jogo de 4 px (`space-1`). Os contornos têm 4 px, os cantos são "comidos" em degrau e não existe `border-radius`, gradiente nem sombra com desfoque.
2. **O brasão manda na cor.** Ouro para a marca e o que se ganha, azul e vermelho heráldicos para estrutura e peso, e contorno quase preto em tudo.
3. **Celebrar, nunca punir.** O app mostra só pontos positivos ("+20"), o que falta ("faltam 360") e caixas de diálogo de conquista. Não há saldo negativo, vermelho de culpa nem ranking fora da família.
4. **Cada contador tem um rosto fixo.** Créditos = moeda (`gold-shade`), XP = estrela (`gold`), temporada = troféu (`heraldic-blue-bright`), tela = monitor (`cyan`). Nunca troque.
5. **Legível antes de bonito.** A fonte pixel de display (Press Start 2P) fica para títulos curtos, números e selos. Frases usam Pixelify Sans com 16 px ou mais.

## Voz e conteúdo

- Fale como mestre de jogo gentil: frases curtas e na segunda pessoa, com o ganho concreto. "Missão aprovada! Lavar a louça rendeu +10 XP."
- Vocabulário do jogo: **missão** (tarefa), **registrar** (enviar prova), **tesouro** (loja de recompensas), **temporada** (ciclo do ranking), **nível**, **sequência**.
- Os nomes das tarefas ficam como a família fala: "Lavar a louça", "Tirar o lixo". Não invente nomes épicos para as tarefas. O épico fica no entorno.
- Botões usam um verbo no infinitivo: Registrar, Resgatar, Aprovar, Contestar, Sortear.
- Não use emoji: os ícones pixel fazem esse papel.
- Números de jogo (pontos, preços, nível, posição) vão sempre na fonte display (`label`).

## Fundamentos visuais

**Temas.** *Noite* (padrão) é a masmorra azul-escura, onde o pixel art brilha. *Dia* é o pergaminho, para uso diurno e impressão. As duas usam as mesmas cores de preenchimento. Só mudam as superfícies, o texto e as versões "-ink" das cores.

**Cor.**
- Superfícies em três níveis: `surface-000` para a página, `surface-100` para painéis e linhas, `surface-200` para elevado e ativo.
- Preenchimentos de identidade: `gold`, `heraldic-blue` e `heraldic-red`, cada um com sua sombra (`-shade`).
- O texto sobre cada preenchimento usa o par `on-*`: `on-gold` (escuro), `on-blue` (branco), `on-red` (branco), `on-cyan` (escuro), `on-success` (escuro) e `on-dispute` (branco).
- Texto colorido sobre as superfícies usa as versões `-ink` (`gold-ink`, `red-ink`, `green-ink` etc.). Todas passam de 4,5:1 nos dois temas.
- Estados de registro: pendente = `gold`, aprovado = `success`, rejeitado = `heraldic-red`, contestado = `dispute`. O estado aparece sempre com texto também, nunca só com a cor.

**A moldura pixel.** O contorno de toda caixa é um `box-shadow` em cruz de 4 px na cor `outline`, o que deixa o canto vazio, como num sprite. Os botões somam o relevo `shadow-bevel` e uma sombra dura deslocada. Ao pressionar, o botão desce 4 px e usa `shadow-pressed`.

**Tipografia.**
- **Press Start 2P** (display): `title-xl` 24, `title-lg` 16, `title-md` 12 em caixa alta, `label` 10 para números e `micro` 8 para selos.
- **Pixelify Sans** (texto): `body-lg` 18, `body` 16, `body-strong` 16/600 e `caption` 13.
- Nunca use Press Start 2P em frases.

**Espaço.** Use os passos 4, 8, 12, 16, 24, 32 e 48 (`space-1` … `space-8`). A tela do celular tem `space-4` de margem. Os botões têm 48 px de altura (alvo de toque).

**Movimento.** Nada de transição suave. As mudanças são em degrau (`steps()`), como num jogo. A única animação é a seta da caixa de diálogo, desligada com `prefers-reduced-motion`.

**Peso da missão.** A cor do botão lateral da `QuestItem` diz o esforço: ciano para leve (0,5), ouro para normal (1) e vermelho para pesada (2 ou mais).

## Iconografia

São 13 sprites de 12×12 em `assets/Icones/`, desenhados com a mesma paleta e o mesmo contorno do brasão: moeda, xp, troféu, tela, câmera, check, ampulheta, baú, vassoura, casa, balde, louça e d20. Use em 12, 24, 36 ou 48 px (escala inteira) com `image-rendering: pixelated`. Em React, use `<CasaQuest.Icon name="moeda" size={24} />`. Os ícones são multicoloridos e não seguem `color`.

## Logos

O brasão esquartelado, com casa, balde, louça e d20 e com vassoura e espada cruzadas atrás, mais o letreiro CASA (branco) / QUEST (ouro sobre faixa laranja). Há versões horizontal, empilhada, só o símbolo, ícone de app e favicon de 16 px em `assets/Logos/`. Não recolorir, não girar e ampliar só em escala inteira.

## Usando este sistema

- Os tokens viram variáveis CSS (`var(--gold)`, `var(--space-4)`). O primeiro tema (`noite`) é o padrão, e `data-theme="dia"` troca para o pergaminho.
- As fontes são do Google Fonts. `components/bundle.css` já as importa: Press Start 2P e Pixelify Sans 400–700.
- Os componentes estão em `components/bundle.js` como `window.CasaQuest` e esperam React 18 na página. Os tipos ficam em `components/index.d.ts`.
- A tela `QuestScreen` mostra a composição de referência das missões do dia.
