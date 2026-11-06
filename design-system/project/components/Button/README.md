# Button

Botão 8 bits com relevo e sombra dura; ao pressionar, desce 4px e perde a sombra.

- **primary** (ouro): a ação principal da tela, no máximo um por vista ("Registrar", "Resgatar").
- **secondary** (padrão): ações comuns. **blue**: ações de sistema ("Sortear"). **danger**: rejeitar ou remover, sempre com confirmação.
- **ghost**: ação terciária em texto sublinhado ("Contestar").
- Rótulo em verbo no infinitivo, curto, em caixa alta automática. `icon` opcional à esquerda.
- Altura de 48 px (`md`) é o alvo de toque padrão; `sm` (32 px) só em linhas densas no desktop.
