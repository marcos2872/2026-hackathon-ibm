# Protótipo navegável do CasaQuest

Protótipo de UI com pitch integrado para a equipe. Usa dados fictícios, sem backend. Abra [index.html](index.html) diretamente no navegador, sem etapa de build para usar.

## Como abrir

A página usa estilos em `design-system/project/components/bundle.css`, ícones em `design-system/project/assets/Icones/`, logos em `design-system/project/assets/Logos/` e os scripts e fontes locais de `presentation/`. Mantenha a estrutura de pastas. Para transportar apenas um arquivo, use [casa-quest-pitch.html](../presentation/casa-quest-pitch.html), que incorpora os assets, o protótipo e a apresentação e funciona offline.

Opcionalmente, execute `node presentation/serve.cjs` na raiz do projeto e abra <http://127.0.0.1:4173/prototipo/index.html>. Os dados ficam no `localStorage` do navegador. Use **Restaurar exemplo** para voltar ao estado inicial; mudar de modo não restaura os dados.

## Modo demo e Modo apresentação

A barra superior permanece disponível nos dois modos. **Modo demo** mostra o próprio app; **Modo apresentação** mostra o pitch de seis slides. Alternar preserva o estado do app e o slide em que a apresentação parou. Os botões de demonstração nos slides 3 e 4 levam ao app; volte pelo **Modo apresentação** para continuar a fala.

No Modo demo, o seletor guia a sequência **Missões de Bruno → Registrar com fotos → Ana aprova → Evolução e equipes → Tesouro → Tempo de tela → Meta coletiva**, usando as telas e ações nativas. Registre **Limpar o banheiro** com antes e depois, envie e aprove como Ana com três estrelas: Bruno passa de **1.590 XP / 85 pontos de temporada / 60 créditos** para **1.610 / 105 / 80**. Resgatar 30 minutos por 15 créditos deixa **65 créditos**, mantendo XP e temporada. **Restaurar exemplo** reinicia explicitamente o cenário; a opção também permanece nas configurações do app.

O pitch reserva 90 segundos para esse fluxo dentro dos três minutos. Veja os [controles, fontes e regeneração](../presentation/README.md) e o [roteiro de fala](../presentation/ROTEIRO.md).

## Duas formas de ver o app

- **Padrão do Modo demo:** o simulador de celular à esquerda e, à direita, o guia conceitual original: dor, tese, demo, escala e plano de validação, além do corte para 40 minutos e das perguntas em aberto.
- **Só o app:** o botão **Abrir só o app** (ou o endereço terminado em `#app`) mostra apenas o celular, mantendo a barra de modos. No telefone, ele ocupa a área disponível. Para trocar de pessoa, mudar o tema ou sair desse modo, toque no avatar no topo do app. Os atalhos da demonstração também abrem essa visualização.

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

Login, servidor, banco, sincronização entre dispositivos, notificações, instalação como PWA (manifest e service worker), bloqueio de foto repetida (RN12), validação por IA e agente desktop real. As fotos e os registros são locais; o computador não é bloqueado de verdade. O piloto com famílias e o modelo freemium continuam como propostas a validar, sem resultados de validação já obtidos.
