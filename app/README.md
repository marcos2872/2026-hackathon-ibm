# CasaQuest em Flutter

Versão Flutter do protótipo navegável (`prototipo/index.html`), para Android, iOS e web. Usa o design system de `design-system/`: os tokens Noite e Dia, os 13 ícones pixel, as fontes Press Start 2P e Pixelify Sans e a moldura pixel de 4 px.

Os dados são fictícios e ficam só na memória. Ao reabrir o app, a família de exemplo volta ao começo do dia. Toque no avatar no topo para trocar de pessoa, mudar o tema ou restaurar o exemplo.

## Estrutura

| Arquivo | Conteúdo |
|---|---|
| `lib/ds.dart` | Tokens e componentes do DS: CQButton, CQPanel, StatusBadge, CounterChip, StatBar, DialogBox, avatar 8 bits e estrelas de qualidade |
| `lib/estado.dart` | Regras do jogo (RN01 a RN20), sorteio balanceado, mesada, tempo de tela e dados de exemplo |
| `lib/telas.dart` | Telas Missões, Admin, Evolução, Tesouro, Tela e Meta, e as folhas de registro, rejeição, contestação, resgate, nova missão, pesos e emergência |
| `test/app_test.dart` | Testes das regras e do fluxo da demo, e um teste que abre todas as abas |
| `assets/` | Ícones e logos copiados de `design-system/project/assets/`, e as fontes com as licenças OFL |

## Como rodar

```bash
cd app
flutter pub get
flutter test
flutter run -d chrome        # web
flutter run -d <id-do-celular>
```

### iPhone

1. No Xcode, entre com o seu Apple ID em **Settings > Accounts**.
2. Abra `ios/Runner.xcworkspace`, escolha o seu time em **Signing & Capabilities** e rode no aparelho. Se preferir a linha de comando, rode `flutter run --release` com o celular conectado.
3. No iPhone, ative **Ajustes > Privacidade e Segurança > Modo de Desenvolvedor**. Depois confie no seu perfil em **Ajustes > Geral > VPN e Gerenciamento de Dispositivo**.

O time de assinatura não fica no repositório: cada pessoa usa o seu. Com uma conta gratuita da Apple, o app instalado vale por 7 dias.

## Próximos passos

- Persistência e backend (PWA ou app, API serverless, Postgres e storage de fotos, com isolamento por família).
- Cadastro do zero (família ou casal), que hoje só existe no protótipo web.
- Gerar os tokens em Dart a partir de `tokens.json`, para o DS não ser mantido em dois lugares.
