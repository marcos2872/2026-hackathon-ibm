# Protótipo navegável do CasaQuest

Protótipo de UI e roteiro do pitch para a equipe. É uma página HTML só, com dados fictícios, sem backend e sem etapa de build.

## Como abrir

Abra `prototipo/index.html` direto no navegador. A página usa o design system do repositório pelo caminho relativo: estilos em `design-system/project/components/bundle.css`, ícones em `design-system/project/assets/Icones/` e logos em `design-system/project/assets/Logos/`. Por isso, mantenha a estrutura de pastas.

Os dados ficam no `localStorage` do navegador. Use **Restaurar exemplo** para voltar ao estado inicial.

## Duas formas de ver

- **Padrão:** o simulador de celular à esquerda e, à direita, o roteiro do pitch: dor, tese, demo, escala e plano de validação, além do corte para 40 minutos e das perguntas em aberto.
- **Só o app:** o botão **Abrir só o app** (ou o endereço terminado em `#app`) mostra apenas o celular. No telefone, ele ocupa a tela inteira. Para trocar de pessoa, mudar o tema ou sair desse modo, toque no avatar no topo do app.

## Design system

- Tokens dos temas Noite (padrão) e Dia, copiados de `tokens.json`. O botão **Tema dia/noite** alterna entre eles.
- Os componentes de `bundle.js` dependem de React. Para manter a página sem build, o protótipo monta em JavaScript puro o mesmo HTML que eles geram, com as mesmas classes `cq-*`: HeroHeader, StatBar, CounterChip, QuestItem, StatusBadge, RewardCard, RankingRow, GoalProgress, DialogBox, Panel, Button e TabBar.
- O vocabulário segue o DS: missão, registrar, tesouro, temporada, nível e sequência.
- Peças que o DS ainda não tem e foram feitas com os mesmos tokens e a mesma moldura pixel: campos de formulário, tabelas, gráfico semanal da evolução, simulador do computador e avatares em pixel art.

## Regras implementadas

- Pontos = `peso × 10 × evidência × qualidade`, arredondados para meio ponto (RN01).
- XP, pontos de temporada e créditos separados; resgatar só gasta créditos (RN08).
- Ninguém aprova o próprio registro (RN03). Na família, os pais aprovam; no casal, um aprova o outro. Quem cria uma missão aprova a conclusão (diagrama).
- Evolução individual por semana e ranking só entre equipes.
- Missão não feita é redistribuída, sem dívida (RN07).
- Mesada com valor fixo ou por pontos; o app calcula e registra o pagamento (RN20).
- Tempo de computador simulado: 10 créditos = 20 min, limite diário, aviso aos 5 minutos e liberação de emergência com PIN `1234` (RN10, RN11).
- Sorteio balanceado por peso, sem repetir a missão do dia anterior (RN06).
- Meta coletiva dos filhos com contribuição mínima de 20% por pessoa (RN16).

## Fora do protótipo

Login, servidor, banco, notificações, instalação como PWA (manifest e service worker), bloqueio de foto repetida (RN12), validação por IA e agente desktop real.
