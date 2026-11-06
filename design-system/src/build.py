"""Monta project/: bundle.js, ícones SVG, prévias e READMEs dos componentes."""

import json
from pathlib import Path

from icones import ICONES, PAL, svg

RAIZ = Path(__file__).resolve().parents[1]
P = RAIZ / "project"
COMP = P / "components"


def w(rel, txt):
    f = P / rel
    f.parent.mkdir(parents=True, exist_ok=True)
    f.write_text(txt, encoding="utf-8")


# ---------------------------------------------------------------- bundle
src = (RAIZ / "src" / "bundle.src.js").read_text(encoding="utf-8")
src = src.replace("__PAL__", json.dumps(PAL)).replace("__SPRITES__", json.dumps(ICONES))
assert "</script" not in src and "<!--" not in src
w("components/bundle.js", src)

# ---------------------------------------------------------------- ícones
for nome, linhas in ICONES.items():
    w(f"assets/Icones/{nome}.svg", svg(linhas) + "\n")

DESC_ICONES = {
    "moeda": "Créditos (saldo gastável).", "xp": "XP (experiência, nunca reseta).",
    "trofeu": "Pontos de temporada e ranking.", "tela": "Tempo de computador.",
    "camera": "Registrar com foto / prova visual.", "check": "Aprovado / concluído.",
    "ampulheta": "Pendente de avaliação.", "bau": "Recompensa / Tesouro.",
    "vassoura": "Missões (tarefas da casa).", "casa": "Família / lar.",
    "balde": "Limpeza pesada, banheiro.", "louca": "Louça, cozinha.", "d20": "Sorteio balanceado.",
}
w("assets/Icones/README.md", "# Ícones\n\nPixel art 12×12, multicolor, com contorno `#1a1c2c`. Use em 12, 24, 36 ou 48 px "
  "(múltiplos inteiros da grade) e nunca em tamanhos quebrados, que borram os pixels. "
  "Em código, prefira o componente `Icon name=\"…\"`, que desenha o mesmo sprite.\n\n"
  + "\n".join(f"- `{n}.svg` — {d}" for n, d in DESC_ICONES.items()) + "\n")
w("assets/Logos/README.md", "# Logos\n\nPixel art multicolor; não recolorir. Ampliar só em escala inteira, com `image-rendering: pixelated`.\n\n"
  "- `casa-quest-logo-horizontal.svg` — brasão + CASA/QUEST em duas linhas. Cabeçalhos, slides, README.\n"
  "- `casa-quest-logo-empilhado.svg` — brasão com o nome embaixo. Tela de abertura e capa.\n"
  "- `casa-quest-brasao.svg` — só o símbolo: escudo esquartelado (casa, balde, louça, d20) com vassoura e espada cruzadas.\n"
  "- `casa-quest-app-icon.svg` — o brasão sobre `heraldic-blue-shade`. Ícone de app e PWA.\n"
  "- `casa-quest-favicon.svg` — 16 px, só o escudo com a casa.\n\n"
  "Área de respiro: 4 pixels de jogo (16 px a 4×) em volta. Fundo preferido: `surface-000` do tema Noite.\n")

# -------------------------------------------------------------- prévias
def preview(nome, group, height, corpo, width=None):
    extra = f" width={width}" if width else ""
    return (f'<!-- @dsCard group="{group}" height={height}{extra} -->\n<!doctype html>\n<html>\n<head><meta charset="utf-8">'
            f'<title>{nome} — prévia</title></head>\n<body>\n<div id="root"></div>\n<script>\n'
            "  var C = window.CasaQuest, h = React.createElement;\n"
            f"  ReactDOM.createRoot(document.getElementById('root')).render({corpo});\n</script>\n</body>\n</html>\n")


PREVIEWS = {
    "Icon": ("Fundamentos", 150, """h('div', { className: 'cq-col', style: { maxWidth: 'none' } },
    h('div', { className: 'cq-row', style: { padding: 0 } }, Object.keys(C.sprites).map(function (n) { return h(C.Icon, { key: n, name: n, size: 36, title: n }); })),
    h('div', { className: 'cq-row', style: { padding: 0 } }, [12, 24, 36, 48].map(function (s) { return h(C.Icon, { key: s, name: 'moeda', size: s }); })))"""),
    "Button": ("Ações", 120, """h('div', { className: 'cq-row' },
    h(C.Button, { variant: 'primary', icon: 'camera' }, 'Registrar'),
    h(C.Button, null, 'Detalhes'),
    h(C.Button, { variant: 'blue' }, 'Sortear'),
    h(C.Button, { variant: 'danger', size: 'sm' }, 'Rejeitar'),
    h(C.Button, { variant: 'primary', disabled: true }, 'Sem saldo'),
    h(C.Button, { variant: 'ghost' }, 'Contestar'))"""),
    "Panel": ("Layout", 220, """h('div', { className: 'cq-row', style: { alignItems: 'flex-start' } },
    h('div', { style: { width: 300 } }, h(C.Panel, { title: 'Missões de hoje', icon: 'vassoura' }, 'Três missões, 35 pontos em jogo.')),
    h('div', { style: { width: 300 } }, h(C.Panel, { title: 'Tesouro', icon: 'bau', tone: 'gold' }, 'Você tem 85 créditos.')))"""),
    "StatusBadge": ("Status", 64, """h('div', { className: 'cq-row' },
    h(C.StatusBadge, { status: 'pendente' }), h(C.StatusBadge, { status: 'aprovado' }),
    h(C.StatusBadge, { status: 'rejeitado' }), h(C.StatusBadge, { status: 'contestado' }))"""),
    "CounterChip": ("Status", 64, """h('div', { className: 'cq-row' },
    h(C.CounterChip, { kind: 'creditos', value: 85 }), h(C.CounterChip, { kind: 'xp', value: 1340 }),
    h(C.CounterChip, { kind: 'temporada', value: 210 }), h(C.CounterChip, { kind: 'tela', value: '60m' }))"""),
    "StatBar": ("Progresso", 230, """h('div', { className: 'cq-col' },
    h(C.StatBar, { kind: 'xp', value: 140, max: 200 }),
    h(C.StatBar, { kind: 'temporada', value: 210, max: 400 }),
    h(C.StatBar, { kind: 'creditos', value: 85, max: 100 }),
    h(C.StatBar, { kind: 'tela', value: 60, max: 180, display: '60 min' }))"""),
    "HeroHeader": ("Perfil", 210, """h('div', { style: { maxWidth: 400 } }, h(C.HeroHeader, { name: 'Ana', level: 7, role: 'Guardiã da Cozinha', xp: 140, credits: 85, season: 210, screen: 60, streak: 5 }))"""),
    "QuestItem": ("Missões", 330, """h('div', { className: 'cq-col' },
    h(C.QuestItem, { title: 'Tirar o lixo', icon: 'vassoura', weight: 0.5, points: 5, evidence: 'depois', due: '22h' }),
    h(C.QuestItem, { title: 'Lavar a louça', icon: 'louca', weight: 1, points: 10, evidence: 'depois', due: '20h' }),
    h(C.QuestItem, { title: 'Limpar o banheiro', icon: 'balde', weight: 2, points: 20, evidence: 'antes-depois', status: 'pendente' }),
    h(C.QuestItem, { title: 'Arrumar a cama', icon: 'casa', weight: 0.5, points: 5, evidence: 'depois', status: 'aprovado' }))"""),
    "RewardCard": ("Recompensas", 230, """h('div', { className: 'cq-row', style: { alignItems: 'stretch' } },
    h(C.RewardCard, { title: '30 min de tela', icon: 'tela', cost: 15, horizon: 'curto', balance: 85 }),
    h(C.RewardCard, { title: 'Escolher o filme', icon: 'd20', cost: 30, horizon: 'curto', balance: 85, stock: 2 }),
    h(C.RewardCard, { title: 'Passeio no parque', icon: 'casa', cost: 250, horizon: 'medio', balance: 85 }),
    h(C.RewardCard, { title: 'Viagem em família', icon: 'bau', cost: 5000, horizon: 'longo' }))"""),
    "RankingRow": ("Ranking", 220, """h('div', { style: { maxWidth: 400, padding: 16 } },
    h(C.RankingRow, { position: 1, name: 'Carla', level: 9, points: 320 }),
    h(C.RankingRow, { position: 2, name: 'Ana', level: 7, points: 210, me: true }),
    h(C.RankingRow, { position: 3, name: 'Bruno', level: 6, points: 185 }),
    h(C.RankingRow, { position: 4, name: 'Pai', level: 4, points: 90 }))"""),
    "GoalProgress": ("Progresso", 250, """h('div', { style: { maxWidth: 400, padding: 16 } }, h(C.GoalProgress, { title: 'Viagem para a praia', target: 5000, minShare: 0.2, deadline: 'até 30/01', members: [{ name: 'Ana', value: 1400 }, { name: 'Bruno', value: 1150 }, { name: 'Carla', value: 640 }] }))"""),
    "DialogBox": ("Feedback", 220, """h('div', { className: 'cq-col' },
    h(C.DialogBox, { icon: 'check', title: 'Missão aprovada!' }, 'Lavar a louça rendeu +10 XP e +10 créditos.'),
    h(C.DialogBox, { icon: 'tela', title: 'Tela liberada' }, 'Você tem 60 minutos de computador hoje.'))"""),
    "TabBar": ("Navegação", 100, """h('div', { style: { maxWidth: 400, padding: 16 } }, h(C.TabBar, { active: 'missoes', items: [
    { id: 'missoes', label: 'Missões', icon: 'vassoura', badge: 3 }, { id: 'feed', label: 'Feed', icon: 'camera' },
    { id: 'ranking', label: 'Ranking', icon: 'trofeu' }, { id: 'tesouro', label: 'Tesouro', icon: 'bau' }, { id: 'tela', label: 'Tela', icon: 'tela' }] }))"""),
    "QuestScreen": ("Telas", 700, "h(C.QuestScreen)"),
}
for nome, (grupo, altura, corpo) in PREVIEWS.items():
    html = preview(nome, grupo, altura, corpo)
    w(f"components/{nome}/preview.html", html)

# ------------------------------------------------------------ guidelines
GUIAS = {
    "Icon": """Desenha um dos sprites pixel art 12×12 do sistema (`moeda`, `xp`, `trofeu`, `tela`, `camera`, `check`, `ampulheta`, `bau`, `vassoura`, `casa`, `balde`, `louca`, `d20`).

- Tamanhos só em múltiplos de 12: **12, 24, 36, 48**. Outros tamanhos borram os pixels.
- Ícones são multicoloridos e não seguem `color`; não tente recolorir.
- Sem `title`, o ícone é decorativo (`aria-hidden`). Passe `title` quando ele for a única informação, como num botão só de ícone.
- Cada contador do jogo tem um ícone fixo: créditos = `moeda`, XP = `xp`, temporada = `trofeu`, tela = `tela`.""",
    "Button": """Botão 8 bits com relevo e sombra dura; ao pressionar, desce 4px e perde a sombra.

- **primary** (ouro): a ação principal da tela, no máximo um por vista ("Registrar", "Resgatar").
- **secondary** (padrão): ações comuns. **blue**: ações de sistema ("Sortear"). **danger**: rejeitar ou remover, sempre com confirmação.
- **ghost**: ação terciária em texto sublinhado ("Contestar").
- Rótulo em verbo no infinitivo, curto, em caixa alta automática. `icon` opcional à esquerda.
- Altura de 48 px (`md`) é o alvo de toque padrão; `sm` (32 px) só em linhas densas no desktop.""",
    "Panel": """Caixa com moldura de pixel e faixa de título, para agrupar conteúdo de uma tela.

- A faixa de título é azul heráldico por padrão; `tone="red"` ou `tone="gold"` só para dar identidade a seções fixas (Tesouro = ouro).
- `action` recebe um elemento para o canto direito da faixa (ex.: um `Button size="sm"`).
- Não aninhe painéis dentro de painéis.""",
    "StatusBadge": """Selo do estado de um registro: `pendente`, `aprovado`, `rejeitado` ou `contestado`.

- Cada estado tem uma cor fixa e também um texto, nunca só cor: pendente = ouro + ampulheta, aprovado = verde + check, rejeitado = vermelho, contestado = roxo.
- Use só para o estado do registro; não para categorias ou peso.""",
    "CounterChip": """Mostra o valor de um dos contadores do jogo, com o ícone fixo de cada um.

- `kind`: `creditos`, `xp`, `temporada` ou `tela`. O nome completo vai para leitores de tela.
- Nunca troque o ícone de um contador: as pessoas aprendem que a moeda é o que se gasta e a estrela é o que só cresce.""",
    "StatBar": """Barra segmentada estilo RPG para XP, pontos de temporada, créditos ou tempo de tela.

- Cada contador tem sua cor: XP = `gold`, temporada = `heraldic-blue-bright`, créditos = `gold-shade`, tela = `cyan`.
- A barra enche em blocos (`segments`, padrão 20), nunca de forma contínua.
- `display` substitui o texto "valor/máximo" (ex.: "60 min").""",
    "HeroHeader": """O cabeçalho do membro: avatar, nome, nível, classe, barras de XP e de tela e os contadores.

- Fica no topo das telas do membro, como o personagem num jogo.
- `role` é a "classe" escolhida pela família (ex.: "Guardiã da Cozinha") e não substitui o papel do sistema (admin/membro).
- O nível compara a pessoa com ela mesma; não mostre posição de ranking aqui.""",
    "QuestItem": """Uma missão do dia: botão de registrar com foto à esquerda, nome, peso, evidência exigida e pontos.

- A cor do botão lateral indica o peso: ciano = leve (0,5), ouro = normal (1), vermelho = pesada (2 ou mais).
- `status`: `aberta` (padrão), `pendente`, `aprovado`, `rejeitado` ou `contestado`. Depois de registrada, o botão vira um check verde e aparece o `StatusBadge`.
- Os pontos são sempre "+N", em ouro. Nunca mostre pontos negativos: o jogo não pune.""",
    "RewardCard": """Uma recompensa da loja (Tesouro), com o horizonte, o ícone, o nome e o preço em créditos.

- Faixa do horizonte: curto = ciano, médio = azul, longo = ouro.
- Passe `balance` para desabilitar automaticamente quando faltar saldo; `stock` mostra o estoque restante, e 0 desabilita.
- Use em grade de 2 ou 3 colunas no celular.""",
    "RankingRow": """Uma linha do ranking da temporada: posição, avatar, nome, nível e pontos.

- O 1º lugar recebe o avatar dourado; a linha do próprio usuário (`me`) fica destacada com "(você)".
- O ranking é sempre da família; não use para comparar casas.
- Se o admin ocultar o ranking para crianças pequenas, não renderize a lista: mostre só o `HeroHeader`.""",
    "GoalProgress": """Meta coletiva: barra dividida por membro e lista de quem já atingiu a contribuição mínima.

- `minShare` é a fração do alvo que cada membro precisa contribuir (padrão 0,2).
- Mostre quanto falta para cada um ("faltam 360") em vez de destacar quem está atrás.
- Use até quatro membros por meta; as cores dos membros são ouro, ciano, rosa e verde.""",
    "DialogBox": """Caixa de texto de RPG, sempre escura nos dois temas, para avisos do jogo: missão aprovada, tempo liberado, nível novo.

- Título curto em caixa alta, texto em uma ou duas frases, com o ganho concreto ("+10 XP").
- A seta ▼ pisca só se o sistema permitir animação (`prefers-reduced-motion`).
- Não use para erros técnicos; esses ficam em texto simples.""",
    "TabBar": """Barra de abas inferior do app, com ícone e rótulo em cada aba.

- Abas padrão: Missões, Feed, Ranking, Tesouro e Tela.
- A aba ativa ganha fundo elevado e um traço dourado no topo; `badge` mostra uma contagem (ex.: missões pendentes).
- No máximo cinco abas.""",
    "QuestScreen": """Tela de exemplo das missões do dia, que junta HeroHeader, DialogBox, QuestItem e TabBar.

- Toque em "Limpar o banheiro" para ver o registro entrar como pendente e a caixa de diálogo aparecer.
- Serve de referência de composição: 16 px de margem, 8 px entre linhas, rótulo de seção em ouro.""",
}
for nome, txt in GUIAS.items():
    w(f"components/{nome}/README.md", f"# {nome}\n\n{txt}\n")

# ----------------------------------------------------------------- tipos
w("components/index.d.ts", """import type * as React from 'react';
export type IconName = 'moeda' | 'xp' | 'trofeu' | 'tela' | 'camera' | 'check' | 'ampulheta' | 'bau' | 'vassoura' | 'casa' | 'balde' | 'louca' | 'd20';
export type Counter = 'creditos' | 'xp' | 'temporada' | 'tela';
export type RecordStatus = 'pendente' | 'aprovado' | 'rejeitado' | 'contestado';
export interface IconProps { name: IconName; size?: 12 | 24 | 36 | 48 | 16 | 32; title?: string; className?: string }
export declare function Icon(props: IconProps): React.ReactElement;
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> { variant?: 'primary' | 'secondary' | 'blue' | 'danger' | 'ghost'; size?: 'md' | 'sm'; icon?: IconName }
export declare function Button(props: ButtonProps): React.ReactElement;
export interface PanelProps { title?: string; icon?: IconName; tone?: 'blue' | 'red' | 'gold'; action?: React.ReactNode; children?: React.ReactNode }
export declare function Panel(props: PanelProps): React.ReactElement;
export interface StatusBadgeProps { status: RecordStatus; children?: React.ReactNode }
export declare function StatusBadge(props: StatusBadgeProps): React.ReactElement;
export interface CounterChipProps { kind: Counter; value: number | string }
export declare function CounterChip(props: CounterChipProps): React.ReactElement;
export interface StatBarProps { kind: Counter; value: number; max: number; segments?: number; label?: string; display?: string }
export declare function StatBar(props: StatBarProps): React.ReactElement;
export interface HeroHeaderProps { name: string; level: number; role?: string; avatar?: IconName; xp: number; xpMax?: number; screen?: number; screenMax?: number; credits?: number; season?: number; streak?: number }
export declare function HeroHeader(props: HeroHeaderProps): React.ReactElement;
export interface QuestItemProps { title: string; icon?: IconName; weight: 0.5 | 1 | 2 | 3 | number; points: number; evidence?: 'antes-depois' | 'depois' | 'nenhuma'; due?: string; status?: 'aberta' | RecordStatus; onRegister?: () => void }
export declare function QuestItem(props: QuestItemProps): React.ReactElement;
export interface RewardCardProps { title: string; icon?: IconName; cost: number; horizon?: 'curto' | 'medio' | 'longo'; balance?: number; stock?: number; onRedeem?: () => void }
export declare function RewardCard(props: RewardCardProps): React.ReactElement;
export interface RankingRowProps { position: number; name: string; level: number; points: number; me?: boolean }
export declare function RankingRow(props: RankingRowProps): React.ReactElement;
export interface GoalProgressProps { title: string; target: number; minShare?: number; deadline?: string; icon?: IconName; members: { name: string; value: number }[] }
export declare function GoalProgress(props: GoalProgressProps): React.ReactElement;
export interface DialogBoxProps { title?: string; icon?: IconName; action?: React.ReactNode; children?: React.ReactNode }
export declare function DialogBox(props: DialogBoxProps): React.ReactElement;
export interface TabBarProps { items?: { id: string; label: string; icon: IconName; badge?: number }[]; active: string; onChange?: (id: string) => void }
export declare function TabBar(props: TabBarProps): React.ReactElement;
export declare function QuestScreen(): React.ReactElement;
declare global { interface Window { CasaQuest: { Icon: typeof Icon; Button: typeof Button; Panel: typeof Panel; StatusBadge: typeof StatusBadge; CounterChip: typeof CounterChip; StatBar: typeof StatBar; HeroHeader: typeof HeroHeader; QuestItem: typeof QuestItem; RewardCard: typeof RewardCard; RankingRow: typeof RankingRow; GoalProgress: typeof GoalProgress; DialogBox: typeof DialogBox; TabBar: typeof TabBar; QuestScreen: typeof QuestScreen; sprites: Record<IconName, string[]> } } }
""")
print("ok")
