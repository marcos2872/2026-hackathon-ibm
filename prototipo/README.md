# Protótipo navegável do CasaQuest

Protótipo de UI para discutir a ideia em equipe. É uma página HTML só, com dados fictícios, sem backend e sem etapa de build.

## Como abrir

Abra `prototipo/index.html` direto no navegador. O logo e os ícones vêm de `assets/brand/`, então mantenha a estrutura de pastas do repositório.

Os dados ficam no `localStorage` do navegador. Use **Restaurar exemplo** para voltar ao estado inicial.

## O que tem

- Simulador de celular: escolha em "Ver o app como" a pessoa da família (Ana e Paulo são os admins; Bruno, Carla e Davi são os filhos).
- Abas: Missões, Admin, Evolução, Prêmios, Tela e Meta.
- Painel lateral com o roteiro de demonstração de 2 minutos (seção 11 da `docs/ideia.md`), as mudanças em relação à versão anterior da ideia, o corte para 40 minutos e as perguntas em aberto.

## Regras implementadas

- Pontos = `peso × 10 × evidência × qualidade`, arredondados para meio ponto (RN01).
- XP, pontos de temporada e créditos separados; resgatar só gasta créditos (RN08).
- Ninguém aprova o próprio registro (RN03). Na família, os pais aprovam; no casal, um aprova o outro. Quem cria uma tarefa aprova a conclusão (diagrama).
- Evolução individual por semana e ranking só entre equipes.
- Tarefa não feita é redistribuída, sem dívida (RN07).
- Mesada com valor fixo ou conversão de pontos; o app calcula e registra o pagamento (RN20).
- Tempo de computador simulado: 10 créditos = 20 min, limite diário, aviso aos 5 minutos e liberação de emergência com PIN `1234` (RN10, RN11).
- Sorteio balanceado por peso, sem repetir a tarefa do dia anterior (RN06).
- Meta coletiva com contribuição mínima por pessoa (RN16).

## Fora do protótipo

Login, servidor, banco, notificações, bloqueio de foto repetida (RN12), validação por IA e agente desktop real.

O visual usa a identidade de `assets/brand/`. Ainda não usa os componentes de `design-system/`.
