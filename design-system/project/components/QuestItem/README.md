# QuestItem

Uma missão do dia: botão de registrar com foto à esquerda, nome, peso, evidência exigida e pontos.

- A cor do botão lateral indica o peso: ciano = leve (0,5), ouro = normal (1), vermelho = pesada (2 ou mais).
- `status`: `aberta` (padrão), `pendente`, `aprovado`, `rejeitado` ou `contestado`. Depois de registrada, o botão vira um check verde e aparece o `StatusBadge`.
- Os pontos são sempre "+N", em ouro. Nunca mostre pontos negativos: o jogo não pune.
