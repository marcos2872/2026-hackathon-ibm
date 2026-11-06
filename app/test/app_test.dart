import 'package:casaquest/estado.dart';
import 'package:casaquest/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pontuação, estrelas e sorteio seguem as regras da ideia.md', () {
    expect(calcPts(2, Evid.antesDepois), 20);
    expect(calcPts(.5, Evid.depois), 4);
    expect(multEstrelas(1), .8);
    expect(multEstrelas(3), 1.0);
    expect(multEstrelas(5), 1.2);
    expect(calcPts(2, Evid.antesDepois, multEstrelas(5)), 24);
    expect(fmt(1590), '1.590');
    expect(fmt(92.5), '92,5');
    expect(brl(20), 'R\$ 20,00');

    final s = AppState();
    final banheiro = s.atribuicoes.firstWhere((a) => a.atividadeId == 'banheiro');
    expect(banheiro.membroId, 'm3', reason: 'o banheiro vai para quem tem menor carga e não fez ontem');
    expect(s.sorteio.diff, lessThanOrEqualTo(s.limiteSorteio));
  });

  test('fluxo da demo: registrar, aprovar com estrelas, resgatar sem cair na evolução', () {
    final s = AppState();
    final bruno = s.membro('m3');
    final a = s.atribuicoes.firstWhere((x) => x.membroId == 'm3' && x.atividadeId == 'banheiro');
    s.registrar(a.id, const Foto.exemplo('antes', 'b', 1), const Foto.exemplo('depois', 'b', 2), '');
    final r = s.registroDe(a)!;
    expect(r.status, 'pendente');
    expect(s.filaDe('m1'), contains(r));
    expect(s.filaDe('m3'), isNot(contains(r)));
    s.setWho('m1');
    s.setEstrelas(r.id, 5);
    s.aprovar(r.id);
    expect(r.pontos, 24);
    expect(bruno.nivel, 9);
    expect(bruno.cred, 84);
    final semana = bruno.semanas.last;
    s.setWho('m3');
    s.resgatar(s.recompensas.first);
    expect(bruno.cred, 69);
    expect(bruno.minutos, 30);
    expect(bruno.semanas.last, semana);
  });

  testWidgets('o app abre em Missões e troca de aba sem erros', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final s = AppState();
    await tester.pumpWidget(CasaQuestApp(estado: s));
    await tester.pump();
    expect(find.text('Bruno'), findsWidgets);
    expect(find.text('MISSÕES DE HOJE'), findsOneWidget);
    for (final t in ['evolucao', 'premios', 'tela', 'meta']) {
      s.setTab(t);
      await tester.pump();
    }
    s.setWho('m1');
    s.setTab('admin');
    await tester.pump();
    expect(find.text('APROVAÇÕES (1)'), findsOneWidget);
    s.alternarTema();
    await tester.pump();
    s.dispose();
  });
}
