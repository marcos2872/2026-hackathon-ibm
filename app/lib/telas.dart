// Telas do app: Missões, Admin, Evolução, Tesouro, Tela e Meta, mais as folhas de diálogo.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'ds.dart';
import 'estado.dart';

const _abas = {
  'hoje': ('Missões', 'vassoura'),
  'admin': ('Admin', 'check'),
  'evolucao': ('Evolução', 'trofeu'),
  'premios': ('Tesouro', 'bau'),
  'tela': ('Tela', 'tela'),
  'meta': ('Meta', 'casa'),
};
const _horiz = {'curto': 'Curto prazo', 'medio': 'Médio prazo', 'longo': 'Longo prazo'};

Widget av(Membro m, [double s = 28]) => PixelAvatar(cor: m.cor, cabelo: m.cabelo, pele: m.pele, size: s);
Widget pad(Widget w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: w);

class Home extends StatelessWidget {
  const Home({super.key, required this.s});
  final AppState s;

  @override
  Widget build(BuildContext context) {
    final m = s.eu;
    final abas = s.abas(m);
    final fila = s.filaDe(m.id).length;
    final corpo = switch (s.tab) {
      'admin' => _admin(context),
      'evolucao' => _evolucao(),
      'premios' => _tesouro(context),
      'tela' => _tela(),
      'meta' => _meta(),
      _ => _missoes(context),
    };
    return Scaffold(
      backgroundColor: P.s000,
      body: Column(children: [
        // cabeçalho do app
        Container(
          color: K.blueShade,
          padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 8, 12, 8),
          child: Row(children: [
            SvgPicture.asset('assets/logos/casa-quest-app-icon.svg', width: 32, height: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.familia, style: disp(10, c: K.onBlue), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(s.temporadaNome, style: txt(13, c: const Color(0xFFC9D0EE))),
              ]),
            ),
            Semantics(
              button: true,
              label: 'Trocar perfil',
              child: GestureDetector(
                onTap: () => _perfil(context),
                child: Container(decoration: BoxDecoration(boxShadow: moldura(2, const Color(0xFF0E0F1A))), child: av(m, 36)),
              ),
            ),
          ]),
        ),
        Container(height: 4, color: P.outline),
        Expanded(
          child: Stack(children: [
            ListView(padding: const EdgeInsets.only(bottom: 96), children: corpo),
            if (s.tab == 'hoje')
              Positioned(right: 8, bottom: 8, child: CQButton('', variant: 'danger', icon: 'vassoura', onTap: () => _novaMissao(context))),
            if (s.aviso != null)
              Positioned(left: 8, right: 8, bottom: 8, child: DialogBox(titulo: s.aviso!.titulo, texto: s.aviso!.texto, icone: s.aviso!.icone)),
          ]),
        ),
        // TabBar do DS
        Container(
          decoration: BoxDecoration(color: P.s100, border: Border(top: BorderSide(color: P.outline, width: 4))),
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          child: Row(children: [
            for (final t in abas)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: s.tab == t,
                  child: GestureDetector(
                    onTap: () => s.setTab(t),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: s.tab == t ? P.s200 : Colors.transparent,
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
                      child: Stack(clipBehavior: Clip.none, alignment: Alignment.topCenter, children: [
                        if (s.tab == t) Positioned(top: -8, child: Container(width: 32, height: 4, color: K.gold)),
                        Column(children: [
                          CQIcon(_abas[t]!.$2, apagado: false, size: 24),
                          const SizedBox(height: 4),
                          Text(_abas[t]!.$1, style: txt(12, c: s.tab == t ? P.ink : P.inkMuted)),
                        ]),
                        if (fila > 0 && (t == 'admin' || (t == 'hoje' && !m.admin)))
                          Positioned(
                            top: -4,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(color: K.red, border: Border.all(color: P.outline, width: 2)),
                              child: Text('$fila', style: disp(7, c: K.onRed)),
                            ),
                          ),
                      ]),
                    ),
                  ),
                ),
              ),
          ]),
        ),
      ]),
    );
  }

  // ------------------------------------------------------------------ HeroHeader
  Widget _hero(Membro m) {
    final atual = m.semanas.last, ant = m.semanas[m.semanas.length - 2];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: P.s100, border: Border(bottom: BorderSide(color: P.outline, width: 4))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(boxShadow: moldura()), child: av(m, 64)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.nome, style: disp(13)),
            const SizedBox(height: 6),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), color: K.gold, child: Text('NV ${m.nivel}', style: disp(7, c: K.onGold))),
              const SizedBox(width: 6),
              Flexible(child: Text(m.classe, style: txt(13, c: P.inkMuted), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 8),
            StatBar(tipo: 'xp', valor: m.xpNoNivel.toDouble(), max: 200, display: '${m.xpNoNivel}/200', label: 'XP'),
            if (!s.simples(m)) ...[
              const SizedBox(height: 6),
              StatBar(tipo: 'temporada', valor: atual, max: max(max(ant, atual), 1), display: '${fmt(atual)}/${fmt(ant)}', label: 'Semana'),
            ],
            if (m.crianca) ...[
              const SizedBox(height: 6),
              StatBar(tipo: 'tela', valor: m.minutos.toDouble(), max: s.limiteDiario.toDouble(), display: '${m.minutos} min', label: 'Tempo de tela'),
            ],
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              CounterChip('moeda', fmt(m.cred)),
              CounterChip('trofeu', fmt(m.pts)),
              if (m.streak > 0) CounterChip('xp', '${m.streak}d', sufixo: 'sequência'),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ------------------------------------------------------------------ Missões
  List<Widget> _missoes(BuildContext context) {
    final m = s.eu;
    const ordem = {'a_fazer': 0, 'rejeitado': 1, 'contestado': 2, 'pendente': 3, 'aprovado': 4};
    final atrs = s.atribuicoes.where((a) => a.membroId == m.id && a.status != 'nao_feita').toList()
      ..sort((a, b) => (ordem[a.status] ?? 5).compareTo(ordem[b.status] ?? 5));
    final feitas = atrs.where((a) => a.status == 'aprovado').length;
    final avaliar = m.admin ? <Registro>[] : s.filaDe(m.id);
    final feed = s.registros.where((r) => r.status == 'aprovado').toList()..sort((a, b) => b.quando.compareTo(a.quando));
    return [
      _hero(m),
      if (s.simples(m)) pad(Padding(padding: const EdgeInsets.only(top: 8), child: Text('Visão simplificada para quem tem menos de ${s.idadeSimples} anos.', style: txt(13, c: P.inkMuted)))),
      if (avaliar.isNotEmpty) ...[pad(const SecLabel('Para você aprovar', extra: 'quem cria a missão aprova')), for (final r in avaliar) pad(_regCard(context, r))],
      pad(SecLabel('Missões de hoje', extra: '$feitas de ${atrs.length} concluídas')),
      if (atrs.isEmpty) pad(Text('Nenhuma missão para você hoje. Use o botão vermelho para criar uma.', style: txt(14, c: P.inkMuted))),
      for (final a in atrs) pad(_questItem(context, a)),
      if (!s.simples(m)) ...[
        pad(const SecLabel('Feed da família')),
        for (final r in feed.take(4))
          pad(Bloco(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              SizedBox(width: 48, height: 36, child: r.depois != null ? FotoView(r.depois!) : av(s.membro(r.membroId))),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(TextSpan(style: txt(14), children: [
                  TextSpan(text: s.membro(r.membroId).nome, style: txt(14, w: FontWeight.w600)),
                  TextSpan(text: ' concluiu ${s.ativ(r.atividadeId).nome} '),
                  TextSpan(text: '+${fmt(r.pontos)}', style: disp(8, c: P.goldInk)),
                  TextSpan(text: '  ${quando(r.quando)}', style: txt(12, c: P.inkMuted)),
                ])),
              ),
            ]),
          )),
      ],
    ];
  }

  Widget _questItem(BuildContext context, Atribuicao a) {
    final atv = s.ativ(a.atividadeId);
    final r = s.registroDe(a);
    final aberta = a.status == 'a_fazer';
    final pts = a.status == 'aprovado' && r != null ? r.pontos : calcPts(atv.peso, atv.evid);
    final corBotao = !aberta
        ? (a.status == 'aprovado' ? K.success : P.s200)
        : atv.peso <= .5
            ? K.cyan
            : atv.peso >= 2
                ? K.red
                : K.gold;
    final origem = switch (a.origem) {
      'avulsa' => 'criada por ${s.membro(a.criadoPor!).nome}',
      'sorteio' => 'sorteada',
      'redistribuida' => 'redistribuída',
      _ => '',
    };
    final item = Container(
      margin: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minHeight: 64),
      decoration: caixa(P.s100),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Semantics(
            button: aberta,
            label: aberta ? 'Registrar ${atv.nome}' : 'Registrada',
            child: GestureDetector(
              onTap: aberta ? () => _registrar(context, a) : null,
              child: Container(
                width: 56,
                decoration: BoxDecoration(color: corBotao, border: Border(right: BorderSide(color: P.outline, width: 4))),
                alignment: Alignment.center,
                child: CQIcon(a.status == 'aprovado' ? 'check' : aberta || a.status == 'rejeitado' ? 'camera' : 'ampulheta'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Row(children: [
                  CQIcon(atv.icone, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(atv.nome + (a.rotulo != null ? ' · ${a.rotulo}' : ''),
                        style: txt(16, w: FontWeight.w600, c: a.status == 'aprovado' ? P.inkMuted : P.ink)
                            .copyWith(decoration: a.status == 'aprovado' ? TextDecoration.lineThrough : null, decorationThickness: 2)),
                  ),
                ]),
                const SizedBox(height: 2),
                Wrap(spacing: 10, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Text('Peso ${fmt(atv.peso)}', style: txt(13, c: P.inkMuted)),
                  Text(evidLabel[atv.evid]!, style: txt(13, c: P.inkMuted)),
                  if (aberta) Text('até ${atv.prazo}', style: txt(13, c: P.inkMuted)),
                  if (origem.isNotEmpty) Text(origem, style: txt(13, c: P.inkMuted)),
                  if (!aberta) StatusBadge(a.status),
                ]),
              ]),
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: Center(child: Text('+${fmt(pts)}', style: disp(10, c: P.goldInk)))),
        ]),
      ),
    );
    if (r == null || aberta || a.status == 'aprovado') return item;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      item,
      Container(
        margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        color: P.s200,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (a.status == 'pendente') Text('Com ${s.quemAvalia(r)}', style: txt(14)),
          if (a.status == 'contestado') Text('Em contestação com ${s.quemAvalia(r)}', style: txt(14)),
          if (a.status == 'rejeitado') ...[
            Text.rich(TextSpan(style: txt(14), children: [
              TextSpan(text: 'Motivo: ', style: txt(14, w: FontWeight.w600)),
              TextSpan(text: '${r.motivo}${r.decisaoFinal ? ' (decisão final)' : ''}'),
            ])),
            Wrap(children: [
              if (!r.decisaoFinal) CQButton('Contestar', small: true, onTap: () => _contestar(context, r)),
              CQButton('Refazer', small: true, variant: 'blue', onTap: () {
                s.refazer(a.id);
                _registrar(context, a);
              }),
            ]),
          ],
        ]),
      ),
    ]);
  }

  Widget _regCard(BuildContext context, Registro r) {
    final m = s.membro(r.membroId);
    final atv = s.ativ(r.atividadeId);
    final est = s.estrelas[r.id] ?? estrelaPadrao;
    final pts = calcPts(atv.peso, r.evid, multEstrelas(est));
    final cont = r.status == 'contestado';
    return Bloco(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          av(m),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${m.nome} · ${atv.nome}', style: txt(15, w: FontWeight.w600)),
              Text('${quando(r.quando)} · ${evidLabel[r.evid]}', style: txt(13, c: P.inkMuted)),
            ]),
          ),
          StatusBadge(cont ? 'contestado' : 'pendente'),
        ]),
        const SizedBox(height: 10),
        if (r.antes == null && r.depois == null)
          Container(padding: const EdgeInsets.all(12), color: P.s200, alignment: Alignment.center, child: Text('Registro sem foto', style: txt(14, c: P.inkMuted)))
        else
          Row(children: [
            if (r.antes != null) Expanded(child: _fotoRotulo(r.antes!, 'Antes', 'pendente')),
            if (r.antes != null && r.depois != null) const SizedBox(width: 8),
            if (r.depois != null) Expanded(child: _fotoRotulo(r.depois!, 'Depois', 'aprovado')),
          ]),
        if (r.obs.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('“${r.obs}”', style: txt(14, c: P.inkMuted))),
        if (cont)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            color: P.s200,
            child: Text('Motivo da rejeição: ${r.motivo}\n${m.nome} contestou: ${r.contestacao}', style: txt(14)),
          ),
        const SizedBox(height: 8),
        Estrelas(valor: est, onChanged: (n) => s.setEstrelas(r.id, n)),
        const SizedBox(height: 4),
        Text.rich(TextSpan(style: txt(14, c: P.inkMuted), children: [
          TextSpan(text: '${fmt(atv.peso)} × 10 × ${fmt(evidMult[r.evid]!)} × ${fmt(multEstrelas(est))} ($est ${est == 1 ? 'estrela' : 'estrelas'}) = '),
          TextSpan(text: '+${fmt(pts)}', style: disp(10, c: P.goldInk)),
        ])),
        const SizedBox(height: 4),
        Wrap(children: [
          CQButton('Aprovar', variant: 'primary', small: true, icon: 'check', onTap: () => s.aprovar(r.id)),
          CQButton(cont ? 'Manter' : 'Rejeitar', variant: 'danger', small: true, onTap: () => _rejeitar(context, r)),
        ]),
      ]),
    );
  }

  Widget _fotoRotulo(Foto f, String rot, String st) => Stack(children: [
        AspectRatio(aspectRatio: 4 / 3, child: FotoView(f)),
        Positioned(left: 4, top: 4, child: StatusBadge(st, texto: rot)),
      ]);

  // ------------------------------------------------------------------ Admin
  List<Widget> _admin(BuildContext context) {
    final m = s.eu;
    final fila = s.filaDe(m.id);
    final filhos = s.membros.where((x) => x.crianca).toList();
    return [
      pad(SecLabel('Painel dos admins', extra: nomes(s.admins.map((a) => a.nome).toList()))),
      pad(CQPanel(
        titulo: 'Aprovações (${fila.length})',
        icone: 'ampulheta',
        tom: 'gold',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (fila.isEmpty) Text('Fila vazia. Missões leves são aprovadas automaticamente e entram na auditoria por amostragem.', style: txt(14, c: P.inkMuted)),
          for (final r in fila) _regCard(context, r),
        ]),
      )),
      pad(CQPanel(
        titulo: 'Mesada da semana',
        icone: 'moeda',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _seg(['Valor fixo', 'Por pontos'], s.mesadaFixa ? 0 : 1, (i) => s.setMesadaFixa(i == 0)),
          const SizedBox(height: 8),
          Text(
              s.mesadaFixa
                  ? '${brl(s.mesadaValor)} por semana para quem cumprir ${s.mesadaMinPct}% das missões. O pagamento é feito por fora, por Pix ou dinheiro (RN20).'
                  : '${brl(s.mesadaTaxa)} por ponto ganho na semana. O pagamento é feito por fora, por Pix ou dinheiro (RN20).',
              style: txt(14, c: P.inkMuted)),
          const SizedBox(height: 8),
          for (final x in filhos) _linhaMesada(x),
        ]),
      )),
      pad(CQPanel(
        titulo: 'Sorteio do dia',
        icone: 'd20',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final x in s.membros) _linhaSorteio(x),
          const SizedBox(height: 8),
          Text('Diferença entre a maior e a menor carga da semana: ${fmt(s.sorteio.diff)}% (limite ${s.limiteSorteio}%) · ${s.sorteio.repeticoes} repetições evitadas.',
              style: txt(14, c: P.inkMuted)),
          Wrap(children: [
            CQButton('Sortear', variant: 'blue', small: true, icon: 'd20', onTap: s.sortearDeNovo),
            CQButton('Pesos', small: true, onTap: () => _pesos(context)),
          ]),
        ]),
      )),
      pad(CQPanel(
        titulo: 'Tempo de tela',
        icone: 'tela',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final x in filhos)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Expanded(child: Text(x.nome, style: txt(15))),
                Text('${x.minutos} min', style: txt(15, c: P.cyanInk)),
                SizedBox(width: 110, child: Text('usou ${x.usadoHoje} min', textAlign: TextAlign.right, style: txt(14, c: P.inkMuted))),
              ]),
            ),
          const SizedBox(height: 8),
          Text('Limite por dia', style: txt(14, w: FontWeight.w600)),
          _seg(['1 h', '2 h', '3 h', '4 h'], [60, 120, 180, 240].indexOf(s.limiteDiario), (i) => s.setLimite([60, 120, 180, 240][i])),
          const SizedBox(height: 8),
          Text('${s.credBloco} créditos valem', style: txt(14, w: FontWeight.w600)),
          _seg(['10 min', '20 min', '30 min'], [10, 20, 30].indexOf(s.minBloco), (i) => s.setMinBloco([10, 20, 30][i])),
          const SizedBox(height: 4),
          Align(alignment: Alignment.centerLeft, child: CQButton('Emergência', small: true, icon: 'ampulheta', onTap: () => _emergencia(context))),
        ]),
      )),
      pad(CQPanel(
        titulo: 'Auditoria',
        icone: 'casa',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final e in s.auditoria.take(8))
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(8),
              color: P.s200,
              child: Text.rich(TextSpan(style: txt(14), children: [
                TextSpan(text: '${e.tipo.toUpperCase()}  ', style: disp(7, c: P.goldInk)),
                TextSpan(text: e.texto),
                TextSpan(text: '  ${quando(e.quando)}', style: txt(12, c: P.inkMuted)),
              ])),
            ),
        ]),
      )),
    ];
  }

  Widget _linhaMesada(Membro x) {
    final p = s.pagamento(x.id, s.semana);
    final v = s.mesadaDevida(x);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: P.s200, width: 2))),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(x.nome, style: txt(15, w: FontWeight.w600)),
            Text(s.mesadaFixa ? 'cumpriu ${(s.cumprimento(x) * 100).round()}%' : '${fmt(x.semanas.last)} pontos', style: txt(13, c: P.inkMuted)),
          ]),
        ),
        Text(brl(p?.valor ?? v), style: txt(15, w: FontWeight.w600, c: P.goldInk)),
        const SizedBox(width: 10),
        if (p != null)
          const StatusBadge('aprovado', texto: 'Pago')
        else if (v > 0) ...[
          CQButton('Pix', variant: 'ghost', onTap: () => s.pagarMesada(x.id, 'Pix')),
          const SizedBox(width: 10),
          CQButton('Dinheiro', variant: 'ghost', onTap: () => s.pagarMesada(x.id, 'dinheiro')),
        ] else
          Text('ainda não', style: txt(13, c: P.inkMuted)),
      ]),
    );
  }

  Widget _linhaSorteio(Membro x) {
    final doDia = s.atribuicoes.where((a) => a.membroId == x.id && a.status != 'nao_feita').toList();
    const rot = {'aprovado': 'feita', 'pendente': 'pendente', 'rejeitado': 'rejeitada', 'contestado': 'contestada'};
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: P.s200, width: 2))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 64, child: Text(x.nome, style: txt(15, w: FontWeight.w600))),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final a in doDia)
              Row(children: [
                Expanded(child: Text(s.ativ(a.atividadeId).nome + (a.rotulo != null ? ' (${a.rotulo})' : ''), style: txt(14))),
                if (a.status == 'a_fazer')
                  CQButton('não feita', variant: 'ghost', onTap: () => s.naoFeita(a.id))
                else
                  Text(rot[a.status] ?? '', style: txt(13, c: P.inkMuted)),
              ]),
            if (doDia.isEmpty) Text('—', style: txt(14, c: P.inkMuted)),
          ]),
        ),
        SizedBox(width: 40, child: Text(fmt(s.sorteio.carga[x.id] ?? 0), textAlign: TextAlign.right, style: disp(8))),
      ]),
    );
  }

  Widget _seg(List<String> opcoes, int ativo, ValueChanged<int> onTap) => Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(4),
        decoration: caixa(P.s000, w: 2),
        child: Row(children: [
          for (var i = 0; i < opcoes.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == ativo,
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: i == ativo ? K.gold : Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(opcoes[i].toUpperCase(), style: disp(7, c: i == ativo ? K.onGold : P.inkMuted)),
                  ),
                ),
              ),
            ),
        ]),
      );

  // ------------------------------------------------------------------ Evolução + ranking de equipes
  List<Widget> _evolucao() {
    final m = s.eu;
    final sem = m.semanas;
    final atual = sem.last, ant = sem[sem.length - 2];
    final diff = atual - ant;
    final melhor = sem.sublist(0, sem.length - 1).reduce(max);
    final escala = ((max(10.0, sem.reduce(max)) / 20).ceil() * 20).toDouble();
    final eqs = s.equipes.map((e) {
      final ms = s.membros.where((x) => x.equipe == e.id).toList();
      return (e, ms, ms.fold(0.0, (a, x) => a + x.pts), ms.fold(0, (a, x) => a + x.tarefasTemp));
    }).where((x) => x.$2.isNotEmpty).toList()
      ..sort((a, b) => b.$3 != a.$3 ? b.$3.compareTo(a.$3) : b.$4.compareTo(a.$4));
    final dias = s.temporadaFim.difference(soDia(DateTime.now())).inDays;
    return [
      pad(const SecLabel('Sua evolução', extra: 'você contra você mesmo')),
      pad(Bloco(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Wrap(crossAxisAlignment: WrapCrossAlignment.end, spacing: 8, runSpacing: 6, children: [
            Text(fmt(atual), style: disp(22)),
            Text('pontos nesta semana', style: txt(14, c: P.inkMuted)),
            Text(diff >= 0 ? '+${fmt(diff)} sobre a semana passada' : 'faltam ${fmt(-diff)} para igualar a semana passada',
                style: txt(14, w: FontWeight.w600, c: diff >= 0 ? P.greenInk : P.inkMuted)),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              for (var i = 0; i < sem.length; i++)
                Expanded(
                  child: Tooltip(
                    message: 'Semana de ${ddmm(s.semana.subtract(Duration(days: 7 * (sem.length - 1 - i))))}: ${fmt(sem[i])} pontos',
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      if (i >= sem.length - 2) Text(fmt(sem[i]), style: disp(7)),
                      const SizedBox(height: 4),
                      Container(
                        width: 24,
                        height: max(2, sem[i] / escala * 100),
                        decoration: BoxDecoration(color: i == sem.length - 1 ? K.blueBright : P.s200, border: Border.all(color: P.outline, width: 2)),
                      ),
                    ]),
                  ),
                ),
            ]),
          ),
          Container(height: 4, color: P.outline),
          const SizedBox(height: 4),
          Row(children: [
            for (var i = 0; i < sem.length; i++)
              Expanded(
                child: Text(i == sem.length - 1 ? 'esta' : ddmm(s.semana.subtract(Duration(days: 7 * (sem.length - 1 - i)))),
                    textAlign: TextAlign.center, style: txt(11, c: P.inkMuted)),
              ),
          ]),
          const SizedBox(height: 8),
          Text(atual > melhor ? 'Esta já é a sua melhor semana!' : 'Sua melhor semana teve ${fmt(melhor)} pontos. A semana fecha no domingo.',
              style: txt(13, c: P.inkMuted)),
        ]),
      )),
      pad(Row(children: [
        Expanded(child: _tile('Sequência', '${m.streak}d')),
        Expanded(child: _tile('Missões', '${m.tarefasSemana}')),
        Expanded(child: _tile('Nível', '${m.nivel}')),
      ])),
      pad(SecLabel('Ranking de equipes', extra: '$dias dias de temporada')),
      pad(Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(boxShadow: moldura()),
        child: Column(children: [
          for (var i = 0; i < eqs.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: eqs[i].$1.id == m.equipe ? P.s200 : P.s100, border: Border(bottom: BorderSide(color: P.s000, width: i < eqs.length - 1 ? 4 : 0))),
              child: Row(children: [
                SizedBox(width: 24, child: Text('${i + 1}', style: disp(10, c: i == 0 ? P.goldInk : P.inkMuted))),
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: eqs[i].$1.cor, border: Border.all(color: P.outline, width: 2)),
                  child: Text(eqs[i].$1.nome.split(' ').last[0], style: disp(11, c: K.onBlue)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${eqs[i].$1.nome}${eqs[i].$1.id == m.equipe ? ' (sua)' : ''}', style: txt(15, w: FontWeight.w600)),
                    Text(nomes(eqs[i].$2.map((y) => y.nome).toList()), style: txt(13, c: P.inkMuted)),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(fmt(eqs[i].$3), style: disp(10, c: P.goldInk)),
                  Text('${eqs[i].$4} missões', style: txt(12, c: P.inkMuted)),
                ]),
              ]),
            ),
        ]),
      )),
      if (eqs.isNotEmpty) pad(DialogBox(titulo: 'Prêmio da temporada', texto: 'A equipe vencedora ${eqs.first.$1.premio}.', icone: 'trofeu')),
      pad(Text('O ranking soma os pontos de temporada de cada equipe e não compara pessoas.', style: txt(13, c: P.inkMuted))),
    ];
  }

  Widget _tile(String k, String v) => Bloco(
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k, style: txt(13, c: P.inkMuted)),
          const SizedBox(height: 4),
          Text(v, style: disp(11)),
        ]),
      );

  // ------------------------------------------------------------------ Tesouro
  List<Widget> _tesouro(BuildContext context) {
    final m = s.eu;
    final pago = s.pagamento(m.id, s.semana);
    Widget grupo(String h) => LayoutBuilder(builder: (context, c) {
          final w = (c.maxWidth - 8) / 2;
          return Wrap(spacing: 8, runSpacing: 8, children: [
            for (final r in s.recompensas.where((r) => r.horizonte == h)) SizedBox(width: w, child: _reward(context, m, r)),
          ]);
        });
    final ext = s.extrato.where((x) => x.membroId == m.id).take(8).toList();
    return [
      pad(Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
        child: Row(children: [Expanded(child: Text('TESOURO', style: disp(9, c: P.goldInk))), CounterChip('moeda', fmt(m.cred), sufixo: 'créditos')]),
      )),
      if (m.crianca)
        pad(Bloco(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text('Mesada da semana', style: txt(15, w: FontWeight.w600))),
              Text(brl(pago?.valor ?? s.mesadaDevida(m)), style: disp(10, c: P.goldInk)),
            ]),
            const SizedBox(height: 4),
            Text(
                '${s.mesadaFixa ? '${brl(s.mesadaValor)} se cumprir ${s.mesadaMinPct}% das missões. Você está em ${(s.cumprimento(m) * 100).round()}%.' : '${brl(s.mesadaTaxa)} por ponto da semana.'} ${pago != null ? 'Paga via ${pago.metodo}.' : 'Os admins pagam no fim da semana, por Pix ou em dinheiro.'}',
                style: txt(14, c: P.inkMuted)),
          ]),
        )),
      for (final h in ['curto', 'medio', 'longo']) ...[pad(SecLabel(_horiz[h]!)), pad(grupo(h))],
      pad(Padding(
        padding: const EdgeInsets.all(4),
        child: Text('Resgatar gasta só créditos: seu XP e sua evolução continuam iguais (RN08).', style: txt(13, c: P.inkMuted)),
      )),
      pad(const SecLabel('Extrato', extra: 'movimentos de pontos')),
      pad(Bloco(
        child: Column(children: [
          Row(children: [
            Expanded(child: Text('MOVIMENTO', style: disp(7, c: P.inkMuted))),
            SizedBox(width: 48, child: Text('XP', textAlign: TextAlign.right, style: disp(7, c: P.inkMuted))),
            SizedBox(width: 56, child: Text('CRÉD.', textAlign: TextAlign.right, style: disp(7, c: P.inkMuted))),
          ]),
          const SizedBox(height: 6),
          Container(height: 4, color: P.outline),
          for (final x in ext)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: P.s200, width: 2))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(x.desc, style: txt(14)),
                    Text('${quando(x.quando)} · ${x.cred < 0 ? 'débito' : 'crédito'}', style: txt(12, c: P.inkMuted)),
                  ]),
                ),
                SizedBox(width: 48, child: Text(x.xp > 0 ? '+${fmt(x.xp)}' : '—', textAlign: TextAlign.right, style: disp(8))),
                SizedBox(
                    width: 56,
                    child: Text('${x.cred > 0 ? '+' : ''}${fmt(x.cred)}', textAlign: TextAlign.right, style: disp(8, c: x.cred < 0 ? P.inkMuted : P.goldInk))),
              ]),
            ),
        ]),
      )),
    ];
  }

  Widget _reward(BuildContext context, Membro m, Recompensa r) {
    final b = s.bloqueio(m, r);
    final est = r.estoque == null ? null : max(0, r.estoque! - s.resgatesNaSemana(r.id));
    final (Color tagBg, Color tagFg) = switch (r.horizonte) { 'medio' => (K.blue, K.onBlue), 'longo' => (K.gold, K.onGold), _ => (K.cyan, K.onCyan) };
    return Semantics(
      button: true,
      enabled: b == null,
      label: '${r.nome}, ${r.custo} créditos',
      child: GestureDetector(
        onTap: b == null ? () => _resgatar(context, r) : null,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: caixa(P.s100),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(3),
              color: tagBg,
              child: Text(_horiz[r.horizonte]!.toUpperCase(), textAlign: TextAlign.center, style: disp(6, c: tagFg)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
              child: Column(children: [
                CQIcon(r.icone, size: 48, apagado: b != null),
                const SizedBox(height: 6),
                Text(r.nome, textAlign: TextAlign.center, style: txt(14, w: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CQIcon('moeda', size: 16, apagado: b != null),
                  const SizedBox(width: 4),
                  Text(fmt(r.custo), style: disp(9, c: b != null ? P.inkMuted : P.goldInk)),
                ]),
                if (est != null) Text(est == 0 ? 'Esgotado' : '$est restantes', style: txt(12, c: P.inkMuted)),
                if (b != null && b != 'esgotado na semana') Text(b, style: txt(12, c: P.inkMuted)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ Tela (computador simulado)
  List<Widget> _tela() {
    final m = s.eu;
    final rodando = s.pcDono == m.id;
    Widget tela;
    if (rodando) {
      tela = Stack(children: [
        Container(color: K.blue),
        Positioned(
          left: 12,
          top: 12,
          width: 190,
          height: 100,
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFFF4F4F4), boxShadow: moldura(2, const Color(0xFF0E0F1A))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(color: const Color(0xFF94B0C2), padding: const EdgeInsets.all(3), child: Text('Trabalho de geografia.doc', style: txt(12, w: FontWeight.w600, c: K.onGold))),
              Padding(padding: const EdgeInsets.all(6), child: Text('Os biomas brasileiros são...', style: txt(12, c: K.onGold))),
            ]),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            color: m.minutos <= 5 ? K.gold : K.dialogBg,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const CQIcon('tela', size: 12),
              const SizedBox(width: 4),
              Text('${m.minutos} min', style: disp(8, c: m.minutos <= 5 ? K.onGold : const Color(0xFF73D4FF))),
            ]),
          ),
        ),
        if (m.minutos <= 5 && s.pcSuave == 0)
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Container(padding: const EdgeInsets.all(6), color: K.gold, child: Text('Faltam ${m.minutos} min. Salve o que estiver fazendo.', style: txt(13, w: FontWeight.w600, c: K.onGold))),
          ),
        if (s.pcSuave > 0)
          Container(
            color: K.dialogBg,
            alignment: Alignment.center,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('TEMPO ESGOTADO', style: disp(10, c: K.dialogAccent)),
              const SizedBox(height: 8),
              Text('Salvando seu trabalho. Bloqueia em ${s.pcSuave} s.', style: txt(14, c: K.dialogInk)),
            ]),
          ),
      ]);
    } else {
      tela = Container(
        color: K.blueShade,
        padding: const EdgeInsets.all(12),
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CQIcon(m.minutos > 0 ? 'tela' : 'ampulheta', size: 48),
          const SizedBox(height: 8),
          Text(m.minutos > 0 ? 'PRONTO PARA USAR' : 'BLOQUEADO', style: disp(10, c: K.onBlue)),
          const SizedBox(height: 6),
          Text(
            m.minutos > 0
                ? 'Você tem ${m.minutos} min liberados.'
                : m.cred >= s.credBloco
                    ? 'Troque ${s.credBloco} créditos por ${s.minBloco} min ou conclua uma missão.'
                    : 'Faltam ${fmt(s.credBloco - m.cred)} créditos para liberar ${s.minBloco} min.',
            textAlign: TextAlign.center,
            style: txt(14, c: const Color(0xFFC9D0EE)),
          ),
          if (m.minutos > 0) CQButton('Desbloquear', variant: 'primary', small: true, onTap: s.pcLigar),
        ]),
      );
    }
    return [
      pad(const SecLabel('Tempo de computador', extra: 'simulado no app')),
      pad(Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        decoration: BoxDecoration(color: K.dialogBg, boxShadow: moldura()),
        child: Column(children: [
          AspectRatio(aspectRatio: 16 / 10, child: ClipRect(child: tela)),
          Container(width: 90, height: 12, color: const Color(0xFF333C57)),
        ]),
      )),
      pad(Wrap(children: [
        if (rodando) CQButton('Desligar', small: true, onTap: s.pcDesligar),
        CQButton('Trocar ${s.credBloco} por ${s.minBloco} min', variant: 'blue', small: true, icon: 'moeda', onTap: m.cred >= s.credBloco ? s.converter : null),
      ])),
      pad(Bloco(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          StatBar(tipo: 'tela', valor: m.minutos.toDouble(), max: s.limiteDiario.toDouble(), display: '${m.minutos} min', label: 'Saldo de tela'),
          const SizedBox(height: 8),
          StatBar(tipo: 'creditos', valor: m.usadoHoje.toDouble(), max: s.limiteDiario.toDouble(), display: '${m.usadoHoje}/${s.limiteDiario}', label: 'Usado hoje'),
          const SizedBox(height: 8),
          Text(
              'Aqui 1 segundo vale 1 minuto. Limite de ${s.limiteDiario ~/ 60} h por dia, agenda ${s.agenda}, aviso nos 5 minutos finais e bloqueio suave para salvar o trabalho. Só o tempo de uso é medido.',
              style: txt(13, c: P.inkMuted)),
        ]),
      )),
    ];
  }

  // ------------------------------------------------------------------ Meta coletiva (GoalProgress)
  List<Widget> _meta() {
    final ms = s.metaMembros.map(s.membro).toList();
    final tot = ms.fold(0.0, (a, x) => a + (s.metaContrib[x.id] ?? 0));
    final minimo = (s.metaAlvo * s.metaMinPct / 100).round();
    final hoje = soDia(DateTime.now());
    final dias = max(0, s.metaPrazo.difference(hoje).inDays);
    final decorr = hoje.difference(s.metaInicio).inDays;
    final falta = max(0.0, s.metaAlvo - tot);
    final ritmo = dias == 0 ? falta.ceil() : (falta / dias).ceil();
    final ritmoAtual = decorr == 0 ? 0 : (tot / decorr).round();
    const cores = [K.gold, K.cyan, K.rose, K.success];
    final fora = s.membros.where((x) => !s.metaMembros.contains(x.id)).map((x) => x.nome).toList();
    return [
      pad(SecLabel('Meta coletiva', extra: '$dias dias restantes')),
      pad(Bloco(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const CQIcon('bau', size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.metaNome, style: disp(10)),
                const SizedBox(height: 4),
                Text('${fmt(tot)}/${fmt(s.metaAlvo)} pontos · até ${ddmm(s.metaPrazo)}', style: txt(14, c: P.inkMuted)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            height: 20,
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(2),
            decoration: caixa(P.barEmpty),
            child: LayoutBuilder(
              builder: (context, c) => Row(children: [
                for (var i = 0; i < ms.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Container(width: max(0, c.maxWidth * min(1, (s.metaContrib[ms[i].id] ?? 0) / s.metaAlvo) - 2), color: cores[i % 4]),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < ms.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: cores[i % 4], border: Border.all(color: P.outline, width: 2))),
                const SizedBox(width: 8),
                Expanded(child: Text(ms[i].nome, style: txt(15))),
                Text(fmt(s.metaContrib[ms[i].id] ?? 0), style: disp(8)),
                SizedBox(
                  width: 110,
                  child: Text(
                    (s.metaContrib[ms[i].id] ?? 0) >= minimo ? 'mínimo ok' : 'faltam ${fmt(minimo - (s.metaContrib[ms[i].id] ?? 0))}',
                    textAlign: TextAlign.right,
                    style: txt(14, c: (s.metaContrib[ms[i].id] ?? 0) >= minimo ? P.greenInk : P.redInk),
                  ),
                ),
              ]),
            ),
        ]),
      )),
      pad(Bloco(
        child: Text(
          'Cada um precisa de ${fmt(minimo)} pontos (${s.metaMinPct}% do alvo) para o prêmio sair. Faltam ${fmt(falta)} no total: $ritmo por dia a partir de hoje. Ritmo atual: $ritmoAtual por dia${ritmoAtual >= ritmo ? ', dentro do prazo.' : ', abaixo do necessário.'}'
          '${fora.isNotEmpty ? ' Nesta meta jogam os filhos; ${nomes(fora)} acompanham e combinam o prêmio.' : ''}',
          style: txt(14, c: P.inkMuted),
        ),
      )),
    ];
  }

  // ------------------------------------------------------------------ folhas
  Future<void> _folha(BuildContext context, Widget Function(BuildContext) corpo) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: P.s100,
        shape: const RoundedRectangleBorder(),
        builder: (ctx) => ListenableBuilder(
          listenable: s,
          builder: (ctx, _) => Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: P.outline, width: 4))),
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(ctx).bottom + MediaQuery.paddingOf(ctx).bottom),
            child: SingleChildScrollView(child: corpo(ctx)),
          ),
        ),
      );

  void _perfil(BuildContext context) => _folha(
        context,
        (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('TROCAR PERFIL', style: disp(11)),
          const SizedBox(height: 4),
          Text('Simulação: veja o app como cada pessoa da família.', style: txt(14, c: P.inkMuted)),
          const SizedBox(height: 8),
          for (final m in s.membros)
            GestureDetector(
              onTap: () {
                s.setWho(m.id);
                Navigator.pop(ctx);
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(8),
                decoration: caixa(m.id == s.who ? K.gold : P.s200, w: 2),
                child: Row(children: [
                  av(m, 32),
                  const SizedBox(width: 10),
                  Expanded(child: Text('${m.nome}, ${m.idade} anos', style: txt(16, w: FontWeight.w600, c: m.id == s.who ? K.onGold : P.ink))),
                  if (m.admin) Text('ADMIN', style: disp(7, c: m.id == s.who ? K.onGold : P.goldInk)),
                ]),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(children: [
            CQButton(s.temaDia ? 'Tema noite' : 'Tema dia', small: true, onTap: s.alternarTema),
            CQButton('Restaurar exemplo', small: true, onTap: () {
              s.seed();
              Navigator.pop(ctx);
              s.avisar('Exemplo restaurado', 'A família da Ana voltou ao começo do dia.', 'casa');
            }),
          ]),
        ]),
      );

  void _registrar(BuildContext context, Atribuicao a) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: P.s100,
        shape: const RoundedRectangleBorder(),
        builder: (ctx) => _RegistrarFolha(s: s, a: a),
      );

  void _rejeitar(BuildContext context, Registro r) {
    final ctrl = TextEditingController();
    String? erro;
    _folha(
      context,
      (ctx) => StatefulBuilder(
        builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(r.status == 'contestado' ? 'MANTER REJEIÇÃO' : 'REJEITAR REGISTRO', style: disp(11)),
          const SizedBox(height: 6),
          Text('${s.membro(r.membroId).nome} · ${s.ativ(r.atividadeId).nome}. O motivo é obrigatório e aparece para quem fez a missão.', style: txt(14, c: P.inkMuted)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final t in ['A foto não mostra o resultado', 'Faltou parte da missão', 'Foto repetida de outro dia'])
              GestureDetector(
                onTap: () => ctrl.text = t,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: P.s000, border: Border.all(color: P.outline, width: 2)),
                  child: Text(t, style: txt(14)),
                ),
              ),
          ]),
          const SizedBox(height: 10),
          TextField(controller: ctrl, maxLines: 3, style: txt(16), decoration: campo('Motivo')),
          if (erro != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(erro!, style: txt(14, w: FontWeight.w600, c: P.redInk))),
          Wrap(alignment: WrapAlignment.end, children: [
            CQButton('Cancelar', small: true, onTap: () => Navigator.pop(ctx)),
            CQButton('Rejeitar', variant: 'danger', small: true, onTap: () {
              if (ctrl.text.trim().isEmpty) return set(() => erro = 'Escreva o motivo da rejeição.');
              Navigator.pop(ctx);
              s.rejeitar(r.id, ctrl.text.trim());
            }),
          ]),
        ]),
      ),
    );
  }

  void _contestar(BuildContext context, Registro r) {
    final ctrl = TextEditingController();
    String? erro;
    _folha(
      context,
      (ctx) => StatefulBuilder(
        builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('CONTESTAR', style: disp(11)),
          const SizedBox(height: 6),
          Text('Motivo dado: “${r.motivo}”. Os admins decidem em última instância.', style: txt(14, c: P.inkMuted)),
          const SizedBox(height: 10),
          TextField(controller: ctrl, maxLines: 3, style: txt(16), decoration: campo('Ex.: as panelas estavam de molho, lavei depois.')),
          if (erro != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(erro!, style: txt(14, w: FontWeight.w600, c: P.redInk))),
          Wrap(alignment: WrapAlignment.end, children: [
            CQButton('Cancelar', small: true, onTap: () => Navigator.pop(ctx)),
            CQButton('Contestar', variant: 'blue', small: true, onTap: () {
              if (ctrl.text.trim().isEmpty) return set(() => erro = 'Explique por que a missão foi feita.');
              Navigator.pop(ctx);
              s.contestar(r.id, ctrl.text.trim());
            }),
          ]),
        ]),
      ),
    );
  }

  void _resgatar(BuildContext context, Recompensa r) {
    final m = s.eu;
    _folha(
      context,
      (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('RESGATAR TESOURO', style: disp(11)),
        const SizedBox(height: 8),
        DialogBox(titulo: r.nome, icone: r.icone, seta: false, texto: 'Créditos: ${fmt(m.cred)} para ${fmt(m.cred - r.custo)}. Seu XP e sua evolução continuam iguais.'),
        const SizedBox(height: 6),
        Text(r.minutos != null ? 'Os ${r.minutos} minutos entram no saldo do computador na hora.' : '${s.membro(r.por).nome} recebe o pedido para entregar.',
            style: txt(14, c: P.inkMuted)),
        Wrap(alignment: WrapAlignment.end, children: [
          CQButton('Cancelar', small: true, onTap: () => Navigator.pop(ctx)),
          CQButton('Resgatar por ${r.custo}', variant: 'primary', small: true, icon: 'moeda', onTap: () {
            Navigator.pop(ctx);
            s.resgatar(r);
          }),
        ]),
      ]),
    );
  }

  void _novaMissao(BuildContext context) {
    final ctrl = TextEditingController();
    var para = s.who;
    var peso = 1.0;
    var evid = Evid.depois;
    String? erro;
    _folha(
      context,
      (ctx) => StatefulBuilder(
        builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('CRIAR MISSÃO', style: disp(11)),
          const SizedBox(height: 6),
          Text('Para você ou para alguém. Quem cria aprova a conclusão.', style: txt(14, c: P.inkMuted)),
          const SizedBox(height: 10),
          TextField(controller: ctrl, style: txt(16), decoration: campo('Ex.: Regar as plantas da varanda')),
          const SizedBox(height: 10),
          Text('Para', style: txt(14, w: FontWeight.w600)),
          Wrap(spacing: 4, runSpacing: 4, children: [
            for (final m in s.membros) _chip(m.id == s.who ? 'Eu' : m.nome, para == m.id, () => set(() => para = m.id)),
          ]),
          const SizedBox(height: 10),
          Text('Peso', style: txt(14, w: FontWeight.w600)),
          Wrap(spacing: 4, runSpacing: 4, children: [
            for (final p in [.5, 1.0, 1.5, 2.0, 3.0]) _chip('${fmt(p)} (+${fmt(p * 10)})', peso == p, () => set(() => peso = p)),
          ]),
          const SizedBox(height: 10),
          Text('Evidência', style: txt(14, w: FontWeight.w600)),
          Wrap(spacing: 4, runSpacing: 4, children: [
            for (final e in Evid.values) _chip(evidLabel[e]!, evid == e, () => set(() => evid = e)),
          ]),
          if (erro != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(erro!, style: txt(14, w: FontWeight.w600, c: P.redInk))),
          Wrap(alignment: WrapAlignment.end, children: [
            CQButton('Cancelar', small: true, onTap: () => Navigator.pop(ctx)),
            CQButton('Criar', variant: 'primary', small: true, onTap: () {
              if (ctrl.text.trim().isEmpty) return set(() => erro = 'Dê um nome para a missão.');
              Navigator.pop(ctx);
              s.criarMissao(ctrl.text.trim(), para, peso, evid);
            }),
          ]),
        ]),
      ),
    );
  }

  Widget _chip(String t, bool on, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: on ? K.gold : P.s000, border: Border.all(color: P.outline, width: 2)),
          child: Text(t, style: txt(14, w: on ? FontWeight.w600 : FontWeight.w400, c: on ? K.onGold : P.ink)),
        ),
      );

  void _pesos(BuildContext context) => _folha(
        context,
        (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('PESOS DAS MISSÕES', style: disp(11)),
          const SizedBox(height: 6),
          Text('O peso novo vale para os próximos registros e fica na auditoria.', style: txt(14, c: P.inkMuted)),
          for (final a in s.atividades.where((a) => !a.avulsa))
            Bloco(
              padding: const EdgeInsets.all(8),
              w: 2,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [CQIcon(a.icone, size: 16), const SizedBox(width: 6), Text(a.nome, style: txt(15, w: FontWeight.w600))]),
                const SizedBox(height: 6),
                Wrap(spacing: 4, runSpacing: 4, children: [
                  for (final p in [.5, 1.0, 1.5, 2.0, 2.5, 3.0]) _chip(fmt(p), a.peso == p, () => s.setPeso(a.id, p)),
                ]),
              ]),
            ),
          Align(alignment: Alignment.centerRight, child: CQButton('Pronto', variant: 'primary', small: true, onTap: () => Navigator.pop(ctx))),
        ]),
      );

  void _emergencia(BuildContext context) {
    final just = TextEditingController(), pin = TextEditingController();
    var para = s.membros.firstWhere((m) => m.crianca).id;
    var minutos = 30;
    String? erro;
    _folha(
      context,
      (ctx) => StatefulBuilder(
        builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('EMERGÊNCIA', style: disp(11)),
          const SizedBox(height: 6),
          Text('Para prova on-line ou trabalho escolar. Fica na auditoria e pode passar do limite diário.', style: txt(14, c: P.inkMuted)),
          const SizedBox(height: 10),
          Wrap(spacing: 4, runSpacing: 4, children: [
            for (final m in s.membros.where((m) => m.crianca)) _chip(m.nome, para == m.id, () => set(() => para = m.id)),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 4, children: [for (final v in [15, 30, 60]) _chip('$v min', minutos == v, () => set(() => minutos = v))]),
          const SizedBox(height: 10),
          TextField(controller: just, style: txt(16), decoration: campo('Justificativa (ex.: prova de matemática on-line)')),
          const SizedBox(height: 8),
          TextField(controller: pin, obscureText: true, keyboardType: TextInputType.number, style: txt(16), decoration: campo('PIN dos admins (no protótipo: 1234)')),
          if (erro != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(erro!, style: txt(14, w: FontWeight.w600, c: P.redInk))),
          Wrap(alignment: WrapAlignment.end, children: [
            CQButton('Cancelar', small: true, onTap: () => Navigator.pop(ctx)),
            CQButton('Liberar', variant: 'blue', small: true, onTap: () {
              final e = s.emergencia(para, minutos, just.text, pin.text);
              if (e != null) return set(() => erro = e);
              Navigator.pop(ctx);
            }),
          ]),
        ]),
      ),
    );
  }
}

/// Folha de registro: fotos de antes e depois (câmera, galeria ou exemplo) e o valor da missão.
class _RegistrarFolha extends StatefulWidget {
  const _RegistrarFolha({required this.s, required this.a});
  final AppState s;
  final Atribuicao a;
  @override
  State<_RegistrarFolha> createState() => _RegistrarFolhaState();
}

class _RegistrarFolhaState extends State<_RegistrarFolha> {
  Foto? antes, depois;
  final obs = TextEditingController();

  Future<void> _foto(bool eAntes, ImageSource fonte) async {
    try {
      final x = await ImagePicker().pickImage(source: fonte, maxWidth: 960, imageQuality: 72);
      if (x == null) return;
      final b = await x.readAsBytes();
      setState(() => eAntes ? antes = Foto.bytes(b) : depois = Foto.bytes(b));
    } catch (_) {
      if (mounted) ScaffoldMessenger.maybeOf(context);
    }
  }

  Widget _slot(String rotulo, bool eAntes, bool obrig) {
    final f = eAntes ? antes : depois;
    final atv = widget.s.ativ(widget.a.atividadeId);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text.rich(TextSpan(children: [
        TextSpan(text: rotulo, style: txt(14, w: FontWeight.w600)),
        TextSpan(text: obrig ? '  obrigatória' : '  opcional', style: txt(13, c: P.inkMuted)),
      ])),
      const SizedBox(height: 4),
      AspectRatio(
        aspectRatio: 4 / 3,
        child: f != null
            ? FotoView(f)
            : GestureDetector(
                onTap: () => _foto(eAntes, ImageSource.camera),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: caixa(P.s000, w: 2),
                  alignment: Alignment.center,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const CQIcon('camera', size: 36),
                    const SizedBox(height: 4),
                    Text('Tirar foto', style: txt(14, w: FontWeight.w600, c: P.goldInk)),
                  ]),
                ),
              ),
      ),
      if (f != null)
        CQButton('Trocar foto', variant: 'ghost', onTap: () => setState(() => eAntes ? antes = null : depois = null))
      else ...[
        CQButton('Da galeria', variant: 'ghost', onTap: () => _foto(eAntes, ImageSource.gallery)),
        CQButton('Foto de exemplo', variant: 'ghost',
            onTap: () => setState(() => eAntes ? antes = Foto.exemplo('antes', atv.nome, 41) : depois = Foto.exemplo('depois', atv.nome, 42))),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final atv = s.ativ(widget.a.atividadeId);
    final req = atv.evid;
    final evid = antes != null && depois != null ? Evid.antesDepois : (antes ?? depois) != null ? Evid.depois : Evid.nenhuma;
    final ok = switch (req) { Evid.antesDepois => antes != null && depois != null, Evid.depois => depois != null, Evid.nenhuma => true };
    final pts = calcPts(atv.peso, evid);
    final avr = s.avaliadorPara(widget.a);
    final quem = avr == 'auto'
        ? 'aprovação automática'
        : 'quem aprova: ${avr != null ? s.membro(avr).nome : nomes(s.admins.where((x) => x.id != widget.a.membroId).map((x) => x.nome).toList())}';
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: P.outline, width: 4))),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(atv.nome.toUpperCase(), style: disp(11)),
          const SizedBox(height: 6),
          Text('Peso ${fmt(atv.peso)} · evidência: ${evidLabel[req]!.toLowerCase()} · $quem', style: txt(14, c: P.inkMuted)),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _slot('Antes', true, req == Evid.antesDepois)),
            const SizedBox(width: 10),
            Expanded(child: _slot('Depois', false, req != Evid.nenhuma)),
          ]),
          const SizedBox(height: 8),
          TextField(controller: obs, style: txt(16), decoration: campo('Comentário (opcional)')),
          const SizedBox(height: 8),
          DialogBox(
            titulo: 'Esta missão vale +${fmt(pts)}',
            icone: 'xp',
            seta: false,
            texto: '${fmt(atv.peso)} × 10 × ${fmt(evidMult[evid]!)} (${evidLabel[evid]!.toLowerCase()})'
                '${req == Evid.depois && antes == null ? '. Com a foto do antes, vale +${fmt(calcPts(atv.peso, Evid.antesDepois))}.' : '.'}',
          ),
          const SizedBox(height: 6),
          Text('Data, hora e autor entram no registro. A foto fica só com a família e é apagada em 90 dias (RN18).', style: txt(13, c: P.inkMuted)),
          Wrap(alignment: WrapAlignment.end, children: [
            CQButton('Cancelar', small: true, onTap: () => Navigator.pop(context)),
            CQButton('Registrar', variant: 'primary', small: true, icon: 'camera', onTap: ok
                ? () {
                    Navigator.pop(context);
                    s.registrar(widget.a.id, antes, depois, obs.text.trim());
                  }
                : null),
          ]),
        ]),
      ),
    );
  }
}

/// Mostra a foto da câmera ou desenha a ilustração de exemplo (antes = sujo, depois = limpo).
class FotoView extends StatelessWidget {
  const FotoView(this.f, {super.key});
  final Foto f;
  @override
  Widget build(BuildContext context) =>
      f.bytes != null ? Image.memory(f.bytes!, fit: BoxFit.cover) : ClipRect(child: CustomPaint(painter: _FotoExemplo(f), child: const SizedBox.expand()));
}

class _FotoExemplo extends CustomPainter {
  _FotoExemplo(this.f);
  final Foto f;
  @override
  void paint(Canvas c, Size s) {
    final antes = f.tipo == 'antes';
    final r = Random(f.semente);
    c.drawRect(Offset.zero & s, Paint()..color = antes ? const Color(0xFFC7C0AE) : const Color(0xFFE4ECF2));
    final linha = Paint()
      ..color = antes ? const Color(0xFFA39A84) : const Color(0xFF94B0C2)
      ..strokeWidth = 1;
    final passo = s.width / 8;
    for (var x = 0.0; x <= s.width; x += passo) {
      c.drawLine(Offset(x, 0), Offset(x, s.height), linha);
    }
    for (var y = 0.0; y <= s.height; y += passo) {
      c.drawLine(Offset(0, y), Offset(s.width, y), linha);
    }
    if (antes) {
      for (var i = 0; i < 22; i++) {
        c.drawOval(
          Rect.fromCenter(center: Offset(r.nextDouble() * s.width, r.nextDouble() * s.height), width: 6 + r.nextDouble() * s.width / 7, height: 4 + r.nextDouble() * s.height / 8),
          Paint()..color = Color.fromRGBO(90 + r.nextInt(40), 70 + r.nextInt(30), 40 + r.nextInt(20), .25 + r.nextDouble() * .35),
        );
      }
    } else {
      final b = Paint()..color = Colors.white;
      for (var i = 0; i < 8; i++) {
        final x = r.nextDouble() * s.width, y = r.nextDouble() * s.height * .8, t = 3 + r.nextInt(3) * 2.0;
        c.drawRect(Rect.fromCenter(center: Offset(x, y), width: t * 2, height: 3), b);
        c.drawRect(Rect.fromCenter(center: Offset(x, y), width: 3, height: t * 2), b);
      }
    }
    final faixa = s.height * .18;
    c.drawRect(Rect.fromLTWH(0, s.height - faixa, s.width, faixa), Paint()..color = const Color(0xFF1A1C2C));
    final tp = TextPainter(
      text: TextSpan(text: '${antes ? 'ANTES' : 'DEPOIS'} · ${f.nome}', style: TextStyle(fontFamily: 'PixelifySans', fontSize: max(8, faixa * .45), color: const Color(0xFFF4F4F4))),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: s.width - 8);
    tp.paint(c, Offset(4, s.height - faixa + (faixa - tp.height) / 2));
  }

  @override
  bool shouldRepaint(_FotoExemplo old) => old.f != f;
}
