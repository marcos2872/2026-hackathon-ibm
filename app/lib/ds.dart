// Design system Casa Quest em Flutter.
// Fonte da verdade: design-system/project/tokens.json e components/bundle.css.
// Regras do DS: moldura pixel de 4 px em cruz, sem border-radius, sem gradiente e sem sombra com desfoque.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Superfícies, texto e versões "-ink": mudam entre os temas Noite e Dia.
class Paleta {
  const Paleta({
    required this.s000, required this.s100, required this.s200, required this.ink, required this.inkMuted,
    required this.outline, required this.goldInk, required this.blueInk, required this.redInk,
    required this.cyanInk, required this.greenInk, required this.barEmpty, required this.escuro,
  });
  final Color s000, s100, s200, ink, inkMuted, outline, goldInk, blueInk, redInk, cyanInk, greenInk, barEmpty;
  final bool escuro;
}

const noite = Paleta(
  s000: Color(0xFF20223A), s100: Color(0xFF2B2E4A), s200: Color(0xFF3A3F63), ink: Color(0xFFF4F4F4),
  inkMuted: Color(0xFFB4C0D4), outline: Color(0xFF0E0F1A), goldInk: Color(0xFFFFCD75), blueInk: Color(0xFF8FB3FF),
  redInk: Color(0xFFFF8A9D), cyanInk: Color(0xFF73D4FF), greenInk: Color(0xFF7FE0A0), barEmpty: Color(0xFF14152A), escuro: true,
);
const dia = Paleta(
  s000: Color(0xFFF2E8D5), s100: Color(0xFFFBF5E9), s200: Color(0xFFE6D7B9), ink: Color(0xFF1A1C2C),
  inkMuted: Color(0xFF5A5470), outline: Color(0xFF1A1C2C), goldInk: Color(0xFF8A4F10), blueInk: Color(0xFF2C47A8),
  redInk: Color(0xFF9C2F45), cyanInk: Color(0xFF17648F), greenInk: Color(0xFF186B3B), barEmpty: Color(0xFFD8C8A6), escuro: false,
);

/// Paleta ativa. O app inteiro é reconstruído quando o tema muda.
Paleta P = noite;

/// Preenchimentos de identidade: iguais nos dois temas.
class K {
  static const gold = Color(0xFFFFCD75), goldShade = Color(0xFFEF7D57), onGold = Color(0xFF1A1C2C);
  static const blue = Color(0xFF3B5DC9), blueShade = Color(0xFF29366F), blueBright = Color(0xFF5B8CF0), onBlue = Color(0xFFF4F4F4);
  static const red = Color(0xFFB13E53), onRed = Color(0xFFF4F4F4), rose = Color(0xFFE26D84);
  static const cyan = Color(0xFF41A6F6), onCyan = Color(0xFF1A1C2C);
  static const success = Color(0xFF38B764), onSuccess = Color(0xFF1A1C2C);
  static const dispute = Color(0xFF7A4A9E), onDispute = Color(0xFFF4F4F4);
  static const dialogBg = Color(0xFF1A1C2C), dialogInk = Color(0xFFF4F4F4), dialogAccent = Color(0xFFFFCD75);
}

/// Press Start 2P: títulos curtos, números e selos. Nunca em frases.
TextStyle disp(double size, {Color? c}) =>
    TextStyle(fontFamily: 'PressStart2P', fontSize: size, height: size <= 8 ? 1.5 : 1.34, color: c ?? P.ink);

/// Pixelify Sans: todo o texto corrido.
TextStyle txt(double size, {FontWeight w = FontWeight.w400, Color? c, double h = 1.45}) => TextStyle(
      fontFamily: 'PixelifySans', fontSize: size, fontWeight: w, height: h, color: c ?? P.ink,
      fontVariations: [FontVariation('wght', w.value.toDouble())],
    );

/// A moldura pixel: contorno de [w] px em cruz, com os cantos vazios, como num sprite.
List<BoxShadow> moldura([double w = 4, Color? cor]) => [
      BoxShadow(color: cor ?? P.outline, offset: Offset(0, -w)),
      BoxShadow(color: cor ?? P.outline, offset: Offset(0, w)),
      BoxShadow(color: cor ?? P.outline, offset: Offset(-w, 0)),
      BoxShadow(color: cor ?? P.outline, offset: Offset(w, 0)),
    ];

BoxDecoration caixa(Color cor, {double w = 4}) => BoxDecoration(color: cor, boxShadow: moldura(w));

/// Ícone pixel 12×12 do DS (assets/icones). Use 12, 24, 36 ou 48 (ou 16 e 32).
class CQIcon extends StatelessWidget {
  const CQIcon(this.nome, {super.key, this.size = 24, this.apagado = false});
  final String nome;
  final double size;
  final bool apagado;
  @override
  Widget build(BuildContext context) {
    final img = SvgPicture.asset('assets/icones/$nome.svg', width: size, height: size);
    if (!apagado) return img;
    return Opacity(
      opacity: .35,
      child: ColorFiltered(colorFilter: const ColorFilter.matrix(<double>[
        .33, .33, .33, 0, 0, .33, .33, .33, 0, 0, .33, .33, .33, 0, 0, 0, 0, 0, 1, 0,
      ]), child: img),
    );
  }
}

/// Bloco com a moldura pixel e a margem de 4 px que ela ocupa.
class Bloco extends StatelessWidget {
  const Bloco({super.key, required this.child, this.cor, this.padding = const EdgeInsets.all(12), this.w = 4});
  final Widget child;
  final Color? cor;
  final EdgeInsets padding;
  final double w;
  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.all(w),
        padding: padding,
        decoration: caixa(cor ?? P.s100, w: w),
        child: child,
      );
}

/// Button do DS: primary (ouro), secondary, blue, danger e ghost. Desce 4 px ao pressionar.
class CQButton extends StatefulWidget {
  const CQButton(this.label, {super.key, this.onTap, this.variant = 'secondary', this.small = false, this.icon});
  final String label;
  final VoidCallback? onTap;
  final String variant;
  final bool small;
  final String? icon;
  @override
  State<CQButton> createState() => _CQButtonState();
}

class _CQButtonState extends State<CQButton> {
  bool down = false;
  @override
  Widget build(BuildContext context) {
    final off = widget.onTap == null;
    final ghost = widget.variant == 'ghost';
    final (Color bg, Color fg) = off
        ? (P.s100, P.inkMuted)
        : switch (widget.variant) {
            'primary' => (K.gold, K.onGold),
            'blue' => (K.blue, K.onBlue),
            'danger' => (K.red, K.onRed),
            'ghost' => (Colors.transparent, P.goldInk),
            _ => (P.s200, P.ink),
          };
    final h = widget.small ? 32.0 : 48.0;
    final conteudo = Row(mainAxisSize: MainAxisSize.min, children: [
      if (widget.icon != null) ...[CQIcon(widget.icon!, size: widget.small ? 16 : 24), if (widget.label.isNotEmpty) const SizedBox(width: 8)],
      if (widget.label.isNotEmpty)
        Text(ghost ? widget.label : widget.label.toUpperCase(),
            style: ghost
                ? txt(15, w: FontWeight.w600, c: fg).copyWith(decoration: TextDecoration.underline, decorationColor: fg)
                : disp(widget.small ? 9 : 11, c: fg)),
    ]);
    if (ghost) {
      return Semantics(button: true, child: GestureDetector(onTap: widget.onTap, behavior: HitTestBehavior.opaque,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: conteudo)));
    }
    return Semantics(
      button: true,
      enabled: !off,
      child: GestureDetector(
        onTapDown: off ? null : (_) => setState(() => down = true),
        onTapCancel: () => setState(() => down = false),
        onTapUp: off ? null : (_) => setState(() => down = false),
        onTap: widget.onTap,
        child: Transform.translate(
          offset: down ? const Offset(4, 4) : Offset.zero,
          child: Container(
            height: h,
            margin: const EdgeInsets.fromLTRB(4, 4, 12, 12),
            padding: EdgeInsets.symmetric(horizontal: widget.small ? 12 : 20),
            decoration: BoxDecoration(color: bg, boxShadow: [
              ...moldura(),
              if (!down && !off) ...[BoxShadow(color: P.outline, offset: const Offset(4, 8)), BoxShadow(color: P.outline, offset: const Offset(8, 4))],
            ]),
            foregroundDecoration: off
                ? null
                : BoxDecoration(
                    border: down
                        ? const Border(top: BorderSide(color: Color(0x47000000), width: 4), left: BorderSide(color: Color(0x47000000), width: 4))
                        : const Border(
                            top: BorderSide(color: Color(0x59FFFFFF), width: 4), left: BorderSide(color: Color(0x59FFFFFF), width: 4),
                            bottom: BorderSide(color: Color(0x47000000), width: 4), right: BorderSide(color: Color(0x47000000), width: 4)),
                  ),
            alignment: Alignment.center,
            child: conteudo,
          ),
        ),
      ),
    );
  }
}

/// Panel do DS: faixa de título azul, vermelha ou dourada.
class CQPanel extends StatelessWidget {
  const CQPanel({super.key, required this.titulo, this.icone, this.tom = 'blue', required this.child});
  final String titulo;
  final String? icone;
  final String tom;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tom) { 'red' => (K.red, K.onRed), 'gold' => (K.gold, K.onGold), _ => (K.blue, K.onBlue) };
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: caixa(P.s100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: bg, border: Border(bottom: BorderSide(color: P.outline, width: 4))),
          child: Row(children: [
            if (icone != null) ...[CQIcon(icone!), const SizedBox(width: 8)],
            Expanded(child: Text(titulo.toUpperCase(), style: disp(11, c: fg))),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(14), child: child),
      ]),
    );
  }
}

/// StatusBadge: pendente (ouro), aprovado (verde), rejeitado (vermelho), contestado (roxo). Sempre com texto.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.texto});
  final String status;
  final String? texto;
  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String? ic, String lbl) = switch (status) {
      'aprovado' => (K.success, K.onSuccess, 'check', 'Aprovado'),
      'rejeitado' => (K.red, K.onRed, null, 'Rejeitado'),
      'contestado' => (K.dispute, K.onDispute, null, 'Contestado'),
      _ => (K.gold, K.onGold, 'ampulheta', 'Pendente'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, border: Border.all(color: P.outline, width: 2)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (ic != null) CQIcon(ic, size: 12) else Container(width: 8, height: 8, color: fg),
        const SizedBox(width: 4),
        Text((texto ?? lbl).toUpperCase(), style: disp(7, c: fg)),
      ]),
    );
  }
}

/// CounterChip: cada contador tem um rosto fixo (créditos = moeda, temporada = troféu...).
class CounterChip extends StatelessWidget {
  const CounterChip(this.icone, this.valor, {super.key, this.sufixo});
  final String icone, valor;
  final String? sufixo;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: P.s000, border: Border.all(color: P.outline, width: 2)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CQIcon(icone, size: 16),
          const SizedBox(width: 4),
          Text(valor, style: disp(9)),
          if (sufixo != null) ...[const SizedBox(width: 4), Text(sufixo!, style: txt(13))],
        ]),
      );
}

/// StatBar: barra segmentada; a cor segue o contador (xp ouro, temporada azul, créditos laranja, tela ciano).
class StatBar extends StatelessWidget {
  const StatBar({super.key, required this.tipo, required this.valor, required this.max, required this.display, required this.label});
  final String tipo, display, label;
  final double valor, max;
  @override
  Widget build(BuildContext context) {
    final (String ic, Color cor) = switch (tipo) {
      'temporada' => ('trofeu', K.blueBright),
      'creditos' => ('moeda', K.goldShade),
      'tela' => ('tela', K.cyan),
      _ => ('xp', K.gold),
    };
    const segs = 20;
    final cheios = max <= 0 ? 0 : (valor.clamp(0, max) / max * segs).round();
    return Semantics(
      label: '$label: $display',
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CQIcon(ic, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              height: 16,
              margin: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              padding: const EdgeInsets.all(2),
              decoration: caixa(P.barEmpty),
              child: Row(children: [
                for (var i = 0; i < segs; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Expanded(child: Container(color: i < cheios ? cor : Colors.transparent)),
                ],
              ]),
            ),
            const SizedBox(height: 8),
            Row(children: [Text(display, style: disp(7)), const Spacer(), Text(label, style: txt(12, c: P.inkMuted))]),
          ]),
        ),
      ]),
    );
  }
}

/// Avatar 8 bits desenhado a partir de uma matriz de texto (o = contorno, h = cabelo, s = pele, e = olho, m = boca, c = camiseta).
const _avMapa = [
  '...oooooo...', '..ohhhhhho..', '.ohhhhhhhho.', '.ohssssssho.', '.osessssesso', '.ossssssssoo',
  '..ossmmsso..', '...oooooo...', '..occcccco..', '.occcccccco.', '.occcccccco.', '.oooooooooo.',
];

class PixelAvatar extends StatelessWidget {
  const PixelAvatar({super.key, required this.cor, required this.cabelo, required this.pele, this.size = 28, this.fundo = K.blue});
  final Color cor, cabelo, pele, fundo;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size, color: fundo,
        child: CustomPaint(painter: _AvatarPainter(cor, cabelo, pele)),
      );
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter(this.cor, this.cabelo, this.pele);
  final Color cor, cabelo, pele;
  @override
  void paint(Canvas canvas, Size size) {
    final px = size.width / 14;
    final mapa = {'o': const Color(0xFF1A1C2C), 'h': cabelo, 's': pele, 'e': const Color(0xFF1A1C2C), 'm': K.red, 'c': cor};
    final p = Paint()..isAntiAlias = false;
    for (var y = 0; y < _avMapa.length; y++) {
      for (var x = 0; x < 12; x++) {
        final c = mapa[_avMapa[y][x]];
        if (c == null) continue;
        p.color = c;
        canvas.drawRect(Rect.fromLTWH((x + 1) * px, (y + 1) * px, px + .5, px + .5), p);
      }
    }
  }

  @override
  bool shouldRepaint(_AvatarPainter old) => old.cor != cor || old.cabelo != cabelo || old.pele != pele;
}

/// DialogBox: caixa de RPG sempre escura, para avisos do jogo.
class DialogBox extends StatelessWidget {
  const DialogBox({super.key, required this.titulo, required this.texto, this.icone = 'check', this.seta = true});
  final String titulo, texto, icone;
  final bool seta;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: K.dialogBg, boxShadow: moldura(4, const Color(0xFF0E0F1A))),
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(border: Border.all(color: K.dialogInk.withValues(alpha: .5), width: 2)),
          child: Row(children: [
            CQIcon(icone, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(titulo.toUpperCase(), style: disp(9, c: K.dialogAccent)),
                const SizedBox(height: 4),
                Text(texto, style: txt(15, c: K.dialogInk, h: 1.4)),
              ]),
            ),
            if (seta) Padding(padding: const EdgeInsets.only(left: 6), child: Text('▼', style: txt(10, c: K.dialogAccent))),
          ]),
        ),
      );
}

/// Rótulo de seção (title-md dourado) com um complemento à direita.
class SecLabel extends StatelessWidget {
  const SecLabel(this.titulo, {super.key, this.extra});
  final String titulo;
  final String? extra;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
        child: Row(children: [
          Expanded(child: Text(titulo.toUpperCase(), style: disp(9, c: P.goldInk))),
          if (extra != null) Text(extra!, style: txt(13, c: P.inkMuted)),
        ]),
      );
}

/// Estrela de qualidade (o sprite de XP do DS é a estrela).
class Estrelas extends StatelessWidget {
  const Estrelas({super.key, required this.valor, required this.onChanged});
  final int valor;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text.rich(TextSpan(children: [
          TextSpan(text: 'Qualidade  ', style: txt(14, w: FontWeight.w600)),
          TextSpan(text: '$valor de 5${valor == 3 ? ' (padrão)' : ''}', style: txt(13, c: P.inkMuted)),
        ])),
        Row(children: [
          for (var n = 1; n <= 5; n++)
          Semantics(
            button: true,
            selected: n == valor,
            label: '$n ${n == 1 ? 'estrela' : 'estrelas'}',
            child: GestureDetector(
              onTap: () => onChanged(n),
              behavior: HitTestBehavior.opaque,
              child: Padding(padding: const EdgeInsets.all(4), child: CQIcon('xp', size: 24, apagado: n > valor)),
            ),
          ),
        ]),
      ]);
}

/// Campo de texto com a moldura pixel (o DS ainda não tem campos).
InputDecoration campo(String? dica) => InputDecoration(
      hintText: dica,
      hintStyle: txt(15, c: P.inkMuted),
      filled: true,
      fillColor: P.s000,
      isDense: true,
      contentPadding: const EdgeInsets.all(10),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: P.outline, width: 2)),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: K.gold, width: 3)),
      border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: P.outline, width: 2)),
    );
