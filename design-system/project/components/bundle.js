/* @ds-bundle: {"format":4,"namespace":"CasaQuest","components":[{"name":"Icon"},{"name":"Button"},{"name":"Panel"},{"name":"StatusBadge"},{"name":"CounterChip"},{"name":"StatBar"},{"name":"HeroHeader"},{"name":"QuestItem"},{"name":"RewardCard"},{"name":"RankingRow"},{"name":"GoalProgress"},{"name":"DialogBox"},{"name":"TabBar"},{"name":"QuestScreen"}]} */
(function () {
  var React = window.React;
  var h = React.createElement;
  var PAL = {"K": "#1a1c2c", "W": "#f4f4f4", "L": "#e4ecf2", "G": "#94b0c2", "g": "#566c86", "B": "#3b5dc9", "c": "#41a6f6", "R": "#b13e53", "r": "#7a2840", "s": "#e26d84", "Y": "#ffcd75", "O": "#ef7d57", "M": "#a0603a", "m": "#6b3a26", "P": "#e8c170", "p": "#b8873e", "V": "#38b764", "v": "#1f7a45"};
  var SPRITES = {"moeda": ["...KKKKKK...", "..KYYYYYYK..", ".KYWYYYYYOK.", "KYWYYYOYYYOK", "KYYYYYOYYYOK", "KYYYYYOYYYOK", "KYYYYYOYYYOK", "KYYYYYOYYYOK", "KYYYYYYYYOOK", ".KYYYYYYOOK.", "..KOOOOOOK..", "...KKKKKK..."], "xp": [".....KK.....", "....KYYK....", "....KYYK....", "KKKKYYYYKKKK", "KYYYYWYYYYOK", ".KYYYYYYYOK.", "..KYYYYYYK..", "..KYYOOYYK..", ".KYYOKKOYOK.", ".KYOK..KOOK.", ".KKK....KKK.", "............"], "trofeu": ["..KKKKKKKK..", "KKKYYYYYOKKK", "KYKYWYYYOKOK", "KYKYWYYYOKOK", ".KKYYYYYOKK.", "...KYYYOK...", "....KYOK....", "....KYOK....", "...KYYYOK...", "...KKKKKK...", "...KMMMmK...", "...KKKKKK..."], "tela": ["KKKKKKKKKKKK", "KGGGGGGGGGgK", "KGccccccccgK", "KGcWccccccgK", "KGccccccccgK", "KGccccccccgK", "KGccccccccgK", "KGGGGGGGGGgK", "KKKKKKKKKKKK", "....KggK....", "...KGGGgK...", "..KKKKKKKK.."], "camera": ["............", "..KKKK......", "KKKggKKKKKKK", "KGGGGKKKGGYK", "KGGGKcccKGGK", "KGGKccWccKGK", "KGGKcccccKGK", "KGGKcccccKGK", "KGGGKcccKGGK", "KggggKKKgggK", "KKKKKKKKKKKK", "............"], "check": ["............", "..........KK", ".........KVK", "........KVvK", ".KK....KVvK.", "KVVK..KVvK..", "KVVVKKVvK...", ".KVVVVvK....", "..KVVvK.....", "...KvK......", "....K.......", "............"], "ampulheta": ["KKKKKKKKKKKK", "KMMMMMMMMMmK", "KKKKKKKKKKKK", ".KWPPPPPPWK.", "..KWPPPPWK..", "...KWPPWK...", "...KWWPWK...", "..KWWWPWWK..", ".KWWWPPPWWK.", "KKKKKKKKKKKK", "KMMMMMMMMMmK", "KKKKKKKKKKKK"], "bau": ["............", "..KKKKKKKK..", ".KMMMMMMMmK.", "KMMMMMMMMMmK", "KYYYYYYYYYOK", "KKKKKKKKKKKK", "KMMMMKYKMMmK", "KMMMMKOKMMmK", "KMMMMMKMMMmK", "KYMMMMMMMMOK", "KmmmmmmmmmmK", "KKKKKKKKKKKK"], "vassoura": [".........KK.", "........KMK.", ".......KMK..", "......KMK...", ".....KMK....", "..KKKRK.....", ".KPPRRK.....", "KPpPPK......", "KPPpPK......", "KpPPK.......", "KPPK........", "KKK........."], "casa": ["............", ".....K......", "....KRK.KK..", "...KRRRKYK..", "..KRRRRRKK..", ".KRRRRRRRK..", ".KKWWWWWKK..", "..KcWWmWK...", "..KWWWmWK...", "..KKKKKKK...", "............", "............"], "balde": ["............", "...KKKKK....", "..K.....K...", ".KKKKKKKKK..", ".KccccccWK..", ".KGGGGGGgK..", "..KGGGGgK...", "..KgggggK...", "..KGGGGgK...", "...KKKKK....", "............", "............"], "louca": ["............", "............", "..KKKKKKK...", ".KLLBBBLLK..", "KLLBWWWBLLK.", "KLBWWWWWBLK.", "KLBWWWWWBLK.", "KLLBWWWBGLK.", ".KGLBBBLGK..", "..KKKKKKK...", "............", "............"], "d20": ["............", "....KKK.....", "..KKRKRKK...", ".KRRKsKRRK..", "KRRKsssKRRK.", "KRKsssssKrK.", "KRKsWsssKrK.", "KKKKKKKKKKK.", "..KKrrrKK...", "....KKK.....", "............", "............"]};

  function cx() {
    var out = [];
    for (var i = 0; i < arguments.length; i++) if (arguments[i]) out.push(arguments[i]);
    return out.join(' ');
  }

  /* ---------------------------------------------------------------- Icon */
  function Icon(props) {
    var name = props.name, size = props.size || 24;
    var rows = SPRITES[name];
    if (!rows) return null;
    var rects = [];
    for (var y = 0; y < rows.length; y++) {
      var row = rows[y], x = 0;
      while (x < row.length) {
        var c = row.charAt(x);
        if (c === '.') { x++; continue; }
        var ini = x;
        while (x < row.length && row.charAt(x) === c) x++;
        rects.push(h('rect', { key: y + '-' + ini, x: ini, y: y, width: x - ini, height: 1, fill: PAL[c] }));
      }
    }
    var a11y = props.title ? { role: 'img', 'aria-label': props.title } : { 'aria-hidden': 'true' };
    return h('svg', Object.assign({
      className: cx('cq-icon', props.className), viewBox: '0 0 12 12', width: size, height: size,
      shapeRendering: 'crispEdges'
    }, a11y), props.title ? h('title', null, props.title) : null, rects);
  }

  /* -------------------------------------------------------------- Button */
  function Button(props) {
    var variant = props.variant || 'secondary', size = props.size || 'md';
    var rest = Object.assign({}, props);
    delete rest.variant; delete rest.size; delete rest.icon; delete rest.className; delete rest.children;
    return h('button', Object.assign({ type: 'button' }, rest, {
      className: cx('cq-btn', 'cq-btn-' + variant, 'cq-btn-' + size, props.className)
    }), props.icon ? h(Icon, { name: props.icon, size: size === 'sm' ? 16 : 24 }) : null,
      props.children != null ? h('span', null, props.children) : null);
  }

  /* --------------------------------------------------------------- Panel */
  function Panel(props) {
    return h('section', { className: cx('cq-panel', props.tone && 'cq-panel-' + props.tone, props.className) },
      props.title ? h('header', { className: 'cq-panel-title' },
        props.icon ? h(Icon, { name: props.icon, size: 24 }) : null,
        h('h3', null, props.title),
        props.action || null) : null,
      h('div', { className: 'cq-panel-body' }, props.children));
  }

  /* --------------------------------------------------------- StatusBadge */
  var STATUS = {
    pendente: { label: 'Pendente', icon: 'ampulheta' },
    aprovado: { label: 'Aprovado', icon: 'check' },
    rejeitado: { label: 'Rejeitado', icon: null },
    contestado: { label: 'Contestado', icon: null }
  };
  function StatusBadge(props) {
    var s = STATUS[props.status] || STATUS.pendente;
    return h('span', { className: 'cq-badge cq-badge-' + (props.status || 'pendente') },
      s.icon ? h(Icon, { name: s.icon, size: 12 }) : h('span', { className: 'cq-badge-dot', 'aria-hidden': 'true' }),
      props.children || s.label);
  }

  /* --------------------------------------------------------- CounterChip */
  var COUNTER = {
    creditos: { icon: 'moeda', label: 'créditos' },
    xp: { icon: 'xp', label: 'XP' },
    temporada: { icon: 'trofeu', label: 'pontos de temporada' },
    tela: { icon: 'tela', label: 'minutos de tela' }
  };
  function CounterChip(props) {
    var k = COUNTER[props.kind] || COUNTER.creditos;
    return h('span', { className: 'cq-chip', title: k.label },
      h(Icon, { name: k.icon, size: 16 }),
      h('span', { className: 'cq-num' }, props.value),
      h('span', { className: 'cq-sr' }, ' ' + k.label));
  }

  /* ------------------------------------------------------------- StatBar */
  var BARS = {
    xp: { icon: 'xp', label: 'XP' },
    temporada: { icon: 'trofeu', label: 'Temporada' },
    creditos: { icon: 'moeda', label: 'Créditos' },
    tela: { icon: 'tela', label: 'Tempo de tela' }
  };
  function StatBar(props) {
    var kind = props.kind || 'xp', b = BARS[kind];
    var max = props.max || 100, value = Math.max(0, Math.min(props.value || 0, max));
    var segs = props.segments || 20, cheios = Math.round(value / max * segs);
    var cells = [];
    for (var i = 0; i < segs; i++) cells.push(h('i', { key: i, className: i < cheios ? 'on' : '' }));
    return h('div', { className: 'cq-stat cq-stat-' + kind },
      h(Icon, { name: b.icon, size: 16 }),
      h('div', { className: 'cq-stat-main' },
        h('div', {
          className: 'cq-stat-track', role: 'progressbar', 'aria-label': props.label || b.label,
          'aria-valuemin': 0, 'aria-valuemax': max, 'aria-valuenow': value
        }, cells),
        h('div', { className: 'cq-stat-legend' },
          h('span', { className: 'cq-num' }, (props.display || (value + '/' + max))),
          h('span', null, props.label || b.label))));
  }

  /* ---------------------------------------------------------- HeroHeader */
  function HeroHeader(props) {
    var inicial = (props.name || '?').charAt(0).toUpperCase();
    return h('header', { className: 'cq-hero' },
      h('div', { className: 'cq-hero-avatar', 'aria-hidden': 'true' },
        props.avatar ? h(Icon, { name: props.avatar, size: 48 }) : h('span', null, inicial)),
      h('div', { className: 'cq-hero-info' },
        h('div', { className: 'cq-hero-name' }, props.name),
        h('div', { className: 'cq-hero-class' },
          h('span', { className: 'cq-level' }, 'NV ' + (props.level || 1)), ' ', props.role || 'Aventureiro'),
        h(StatBar, { kind: 'xp', value: props.xp, max: props.xpMax || 200 }),
        h(StatBar, { kind: 'tela', value: props.screen, max: props.screenMax || 180, display: (props.screen || 0) + ' min' }),
        h('div', { className: 'cq-hero-counters' },
          h(CounterChip, { kind: 'creditos', value: props.credits || 0 }),
          h(CounterChip, { kind: 'temporada', value: props.season || 0 }),
          props.streak ? h('span', { className: 'cq-chip' }, h('span', { className: 'cq-num' }, props.streak + 'd'), ' sequência') : null)));
  }

  /* ----------------------------------------------------------- QuestItem */
  var EVID = { 'antes-depois': 'Antes/depois', depois: 'Foto', nenhuma: 'Sem foto' };
  function QuestItem(props) {
    var status = props.status || 'aberta';
    var feito = status !== 'aberta';
    return h('article', { className: cx('cq-quest', 'cq-quest-' + status, 'cq-peso-' + String(props.weight || 1).replace('.', '_')) },
      h('button', {
        type: 'button', className: 'cq-quest-go', disabled: feito, onClick: props.onRegister,
        'aria-label': feito ? 'Registrada' : 'Registrar ' + props.title
      }, h(Icon, { name: feito ? 'check' : 'camera', size: 24 })),
      h('div', { className: 'cq-quest-main' },
        h('div', { className: 'cq-quest-title' },
          props.icon ? h(Icon, { name: props.icon, size: 16 }) : null, props.title),
        h('div', { className: 'cq-quest-meta' },
          h('span', null, 'Peso ' + String(props.weight || 1).replace('.', ',')),
          h('span', null, EVID[props.evidence || 'depois']),
          props.due && !feito ? h('span', null, 'até ' + props.due) : null,
          feito ? h(StatusBadge, { status: status }) : null)),
      h('div', { className: 'cq-quest-side' },
        h('span', { className: 'cq-quest-pts cq-num' }, '+' + props.points)));
  }

  /* ---------------------------------------------------------- RewardCard */
  var HORIZ = { curto: 'Curto prazo', medio: 'Médio prazo', longo: 'Longo prazo' };
  function RewardCard(props) {
    var semSaldo = props.balance != null && props.balance < props.cost;
    return h('button', {
      type: 'button', className: cx('cq-reward', 'cq-reward-' + (props.horizon || 'curto')),
      disabled: semSaldo || props.stock === 0, onClick: props.onRedeem
    },
      h('span', { className: 'cq-reward-tag' }, HORIZ[props.horizon || 'curto']),
      h(Icon, { name: props.icon || 'bau', size: 48 }),
      h('span', { className: 'cq-reward-title' }, props.title),
      h('span', { className: 'cq-reward-cost' }, h(Icon, { name: 'moeda', size: 16 }), h('span', { className: 'cq-num' }, props.cost)),
      props.stock != null ? h('span', { className: 'cq-reward-stock' }, props.stock === 0 ? 'Esgotado' : props.stock + ' restantes') : null);
  }

  /* ---------------------------------------------------------- RankingRow */
  function RankingRow(props) {
    var pos = props.position;
    return h('div', { className: cx('cq-rank', pos <= 3 && 'cq-rank-top' + pos, props.me && 'cq-rank-me') },
      h('span', { className: 'cq-rank-pos cq-num' }, pos),
      h('span', { className: 'cq-rank-avatar', 'aria-hidden': 'true' }, (props.name || '?').charAt(0).toUpperCase()),
      h('span', { className: 'cq-rank-name' }, props.name, props.me ? h('em', null, ' (você)') : null),
      h('span', { className: 'cq-rank-lvl' }, 'NV ' + props.level),
      h('span', { className: 'cq-rank-pts cq-num' }, props.points));
  }

  /* -------------------------------------------------------- GoalProgress */
  function GoalProgress(props) {
    var members = props.members || [], target = props.target || 1;
    var total = members.reduce(function (s, m) { return s + m.value; }, 0);
    var minimo = Math.round(target * (props.minShare || 0.2));
    var cores = ['cq-m0', 'cq-m1', 'cq-m2', 'cq-m3'];
    return h('div', { className: 'cq-goal' },
      h('div', { className: 'cq-goal-head' },
        h(Icon, { name: props.icon || 'bau', size: 32 }),
        h('div', null,
          h('div', { className: 'cq-goal-title' }, props.title),
          h('div', { className: 'cq-goal-sub' }, h('span', { className: 'cq-num' }, total + '/' + target), ' pontos · ', props.deadline || ''))),
      h('div', { className: 'cq-goal-track', role: 'progressbar', 'aria-valuemin': 0, 'aria-valuemax': target, 'aria-valuenow': total, 'aria-label': props.title },
        members.map(function (m, i) {
          return h('i', { key: m.name, className: cores[i % 4], style: { width: Math.min(100, m.value / target * 100) + '%' } });
        })),
      h('ul', { className: 'cq-goal-members' },
        members.map(function (m, i) {
          var ok = m.value >= minimo;
          return h('li', { key: m.name },
            h('i', { className: cores[i % 4], 'aria-hidden': 'true' }),
            h('span', null, m.name),
            h('span', { className: 'cq-num' }, m.value),
            h('span', { className: ok ? 'cq-goal-ok' : 'cq-goal-falta' }, ok ? 'mínimo ok' : 'faltam ' + (minimo - m.value)));
        })));
  }

  /* ----------------------------------------------------------- DialogBox */
  function DialogBox(props) {
    return h('div', { className: cx('cq-dialog', props.tone && 'cq-dialog-' + props.tone), role: 'status' },
      props.icon ? h('div', { className: 'cq-dialog-icon' }, h(Icon, { name: props.icon, size: 48 })) : null,
      h('div', { className: 'cq-dialog-text' },
        props.title ? h('div', { className: 'cq-dialog-title' }, props.title) : null,
        h('div', null, props.children)),
      props.action || h('span', { className: 'cq-dialog-next', 'aria-hidden': 'true' }, '▼'));
  }

  /* -------------------------------------------------------------- TabBar */
  var TABS_PADRAO = [
    { id: 'missoes', label: 'Missões', icon: 'vassoura' },
    { id: 'feed', label: 'Feed', icon: 'camera' },
    { id: 'ranking', label: 'Ranking', icon: 'trofeu' },
    { id: 'tesouro', label: 'Tesouro', icon: 'bau' },
    { id: 'tela', label: 'Tela', icon: 'tela' }
  ];
  function TabBar(props) {
    var items = props.items || TABS_PADRAO;
    return h('nav', { className: 'cq-tabbar', 'aria-label': 'Navegação principal' },
      items.map(function (t) {
        var ativo = t.id === props.active;
        return h('button', {
          key: t.id, type: 'button', className: cx('cq-tab', ativo && 'is-active'),
          'aria-current': ativo ? 'page' : undefined, onClick: props.onChange ? function () { props.onChange(t.id); } : undefined
        }, h(Icon, { name: t.icon, size: 24 }), h('span', null, t.label), t.badge ? h('b', { className: 'cq-tab-badge' }, t.badge) : null);
      }));
  }

  /* --------------------------------------------------------- QuestScreen */
  function QuestScreen() {
    var _s = React.useState('aberta'), status = _s[0], setStatus = _s[1];
    var _t = React.useState('missoes'), tab = _t[0], setTab = _t[1];
    return h('div', { className: 'cq-screen' },
      h(HeroHeader, { name: 'Ana', level: 7, role: 'Guardiã da Cozinha', xp: 140, credits: 85, season: 210, screen: 60, streak: 5 }),
      h('div', { className: 'cq-screen-body' },
        status === 'pendente' ? h(DialogBox, { icon: 'camera', title: 'Missão enviada!' }, 'O admin vai avaliar "Limpar o banheiro". +20 quando aprovada.') : null,
        h('div', { className: 'cq-section-label' }, 'Missões de hoje'),
        h(QuestItem, { title: 'Limpar o banheiro', icon: 'balde', weight: 2, points: 20, evidence: 'antes-depois', due: '21h', status: status, onRegister: function () { setStatus('pendente'); } }),
        h(QuestItem, { title: 'Lavar a louça', icon: 'louca', weight: 1, points: 10, evidence: 'depois', due: '20h', status: 'aprovado' }),
        h(QuestItem, { title: 'Tirar o lixo', icon: 'vassoura', weight: 0.5, points: 5, evidence: 'depois', due: '22h' })),
      h(TabBar, { active: tab, onChange: setTab }));
  }

  window.CasaQuest = Object.assign(window.CasaQuest || {}, {
    Icon: Icon, Button: Button, Panel: Panel, StatusBadge: StatusBadge, CounterChip: CounterChip,
    StatBar: StatBar, HeroHeader: HeroHeader, QuestItem: QuestItem, RewardCard: RewardCard,
    RankingRow: RankingRow, GoalProgress: GoalProgress, DialogBox: DialogBox, TabBar: TabBar,
    QuestScreen: QuestScreen, sprites: SPRITES
  });
})();
