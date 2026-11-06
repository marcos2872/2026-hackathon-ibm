# Casa Quest · Pitch de 3 minutos dentro do protótipo

Abra [o protótipo](../prototipo/index.html) e alterne pela barra superior entre **Modo demo** e **Modo apresentação**. O app permanece em execução: trocar de modo preserva os dados da demonstração e o slide atual. Para levar a entrega em um único arquivo, abra [casa-quest-pitch.html](casa-quest-pitch.html), que incorpora o protótipo, os dois modos, as fontes e os SVGs e funciona offline.

Não é necessário servidor. Como alternativa, execute `node presentation/serve.cjs` na raiz do projeto e abra <http://127.0.0.1:4173/prototipo/index.html>.

## Apresentar e demonstrar

São seis slides, com 90 segundos reservados à demonstração dentro dos três minutos. A navegação é manual; os tempos orientam a fala.

| Slide | Trecho | Duração |
|---|---|---|
| 1 | A dor · 0:00–0:20 | 20 s |
| 2 | A ideia · 0:20–0:40 | 20 s |
| 3 | Registrar e aprovar · 0:40–1:25 | 45 s |
| 4 | Evoluir e resgatar · 1:25–2:10 | 45 s |
| 5 | Viabilidade · 2:10–2:35 | 25 s |
| 6 | Próxima missão · 2:35–3:00 | 25 s |

Nos slides 3 e 4, **Demonstrar o MVP** ou **Continuar a demo** abre o app real no Modo demo. Use o seletor da barra para seguir: **Missões de Bruno → Registrar com fotos → Ana aprova → Evolução e equipes → Tesouro → Tempo de tela → Meta coletiva**. Volte pelo **Modo apresentação** para retomar o mesmo slide. O [ROTEIRO.md](ROTEIRO.md) contém as falas e as ações.

No cenário inicial, Bruno tem **1.590 XP, 85 pontos de temporada e 60 créditos**. Registre **Limpar o banheiro** com antes e depois (fotos de exemplo ou selecionadas no app), envie e use **Ana aprova**, mantendo as três estrelas. A aprovação concede 20 em cada contador: **1.610 XP, 105 pontos de temporada e 80 créditos**. No Tesouro, resgate **30 min de computador por 15 créditos**: o saldo fica em **65 créditos**, mantendo XP e temporada. O tempo de computador é simulado. **Restaurar exemplo** é uma ação explícita para reiniciar; alternar os modos não reinicia o cenário.

| Controle da apresentação | Ação |
|---|---|
| Setas ou botões anterior/próximo | Navegar pelos slides |
| Home / End | Ir ao primeiro / último slide |
| N ou **Roteiro** | Mostrar ou ocultar as notas de fala |
| F ou **Tela cheia** | Alternar tela cheia |
| **Ver slides** | Abrir a visão geral e escolher um slide |
| Escape | Fechar a visão geral |

## Conteúdo e limites

O conceito manuscrito integra a narrativa: famílias com ou sem filhos, sobrecarga e conflitos cotidianos, divisão gamificada das tarefas e uma versão beta avaliada pelas próprias famílias. O piloto é uma proposta, sem fixar cinco famílias ou sete dias e sem resultados de validação já obtidos. Freemium é hipótese de negócio. Contas, sincronização entre dispositivos e agente de computador com bloqueio real são próximos passos.

A demo executa as funções e regras do próprio protótipo, com dados fictícios e persistência local no navegador, sem backend. O [README do protótipo](../prototipo/README.md) detalha as regras implementadas e o que está fora do MVP.

## Fontes e regeneração

A apresentação estende o universo visual existente: brasão doméstico, pixel art, molduras em degraus e superfícies do tema Noite. A paleta vem de [tokens.json](../design-system/project/tokens.json); fontes, contadores e linguagem seguem o [design system](../design-system/project/README.md). Os logos são os SVGs originais descritos na [identidade visual](../assets/brand/README.md); os ícones vêm de `design-system/project/assets/Icones/`. Tipografia e composição dos slides são adaptações para apresentação, sem substituir as regras globais. As licenças SIL OFL estão em [fonts/](fonts/) e acompanham o HTML portátil.

| Arquivo | Papel |
|---|---|
| [build-pitch.cjs](build-pitch.cjs) | Composição, falas, tempos e empacotamento |
| [prototype-mode.src.js](prototype-mode.src.js) | Fonte editável da barra e da alternância dos modos |
| [prototype-mode.js](prototype-mode.js) | Controlador gerado com o deck incorporado; não editar diretamente |
| [mvp-bridge.js](mvp-bridge.js) | Atalhos que usam o estado e as ações nativas do protótipo |
| [deck-player.js](deck-player.js) | Abertura da demo a partir dos slides e retorno ao pitch |
| [pitch-deck.html](pitch-deck.html) | Deck interno gerado; aberto sozinho, oferece o app incorporado com **Retomar o pitch** |
| [casa-quest-pitch.html](casa-quest-pitch.html) | Protótipo portátil gerado com os dois modos |
| [pitch-scenes.json](pitch-scenes.json) | Modelo compartilhado de cenas, cores e assets para correspondência com o Figma |

Edite as fontes e execute, na raiz do projeto:

```sh
node presentation/build-pitch.cjs
```

O comando regenera os HTMLs, o controlador de modos, o modelo de cenas, as fontes CSS e o roteiro. No [Figma](https://www.figma.com/design/wb5MO7HmVcTB1cyphAnv5e/Untitled?node-id=2-12327), os seis frames existentes foram atualizados; a versão anterior está na página **Pitch · antes do MVP**.

## Verificação da entrega

[review/mvp-checks.json](review/mvp-checks.json) registra execução offline, fontes disponíveis, zero erros JavaScript e imagens carregadas. Os seis slides foram conferidos em desktop e a 390 px, sem rolagem horizontal; a revisão visual também conferiu recortes de texto. O fluxo com fotos, aprovação e resgate confirmou os saldos acima e o retorno ao slide 3. O app incorporado do deck avulso também foi carregado.

[check-mvp.cjs](check-mvp.cjs) exporta uma função que recebe uma instância de navegador do ambiente de QA; não é uma dependência para abrir a entrega nem um comando autônomo. `review/` reúne evidências internas. Esses testes registram o escopo verificado, sem constituir certificação geral de acessibilidade ou ausência de todo recorte.
