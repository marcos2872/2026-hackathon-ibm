// Roteiro de demonstração automatizado: roda o app de verdade no simulador ou no aparelho,
// com pausas para gravar o vídeo da demo. Cada passo imprime "PASSO|<ms desde o início>|<legenda>".
import 'package:casaquest/estado.dart';
import 'package:casaquest/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('demo do CasaQuest', (t) async {
    final sem = t.ensureSemantics();
    final s = AppState();
    await t.pumpWidget(CasaQuestApp(estado: s));

    Future<void> pausa([int ms = 1800]) async {
      await Future<void>.delayed(Duration(milliseconds: ms));
      await t.pump();
    }

    void passo(String legenda) => debugPrint('PASSO|${DateTime.now().millisecondsSinceEpoch}|$legenda');

    Future<void> toque(Finder f, {int depois = 900}) async {
      await t.ensureVisible(f);
      await pausa(350);
      await t.tap(f);
      await pausa(depois);
    }

    Future<void> rolar(double dy, {int ms = 900}) async {
      await t.timedDrag(find.byType(ListView).first, Offset(0, dy), Duration(milliseconds: ms));
      await pausa(600);
    }

    Future<void> perfil(String nome) async {
      await toque(find.bySemanticsLabel('Trocar perfil'), depois: 700);
      await toque(find.textContaining('$nome,'), depois: 900);
    }

    passo('Bruno abre as missões do dia');
    await pausa(2600);

    passo('Registra “Limpar o banheiro” com foto de antes e depois');
    await toque(find.bySemanticsLabel('Registrar Limpar o banheiro'), depois: 1200);
    await toque(find.text('Foto de exemplo').first, depois: 800);
    await toque(find.text('Foto de exemplo').first, depois: 1400);
    await toque(find.text('REGISTRAR'), depois: 2800);

    passo('Ana, admin, avalia com estrelas e aprova');
    await perfil('Ana');
    await toque(find.text('Admin').last, depois: 1200);
    final cincoEstrelas = find.bySemanticsLabel('5 estrelas');
    await t.ensureVisible(cincoEstrelas.last);
    await pausa(1200);
    await toque(cincoEstrelas.last, depois: 1200);
    await toque(find.text('APROVAR').last, depois: 3200);
    await pausa(1800);

    passo('Bruno sobe de nível e vê a evolução da semana');
    await perfil('Bruno');
    await pausa(1500);
    await toque(find.text('Evolução').last, depois: 2200);
    await rolar(-420, ms: 1400);
    await pausa(2200);

    passo('Resgata 30 min de computador no Tesouro');
    await toque(find.text('Tesouro').last, depois: 1600);
    await toque(find.text('30 min de computador'), depois: 1400);
    await toque(find.text('RESGATAR POR 15'), depois: 2600);

    passo('Desbloqueia o computador com o saldo');
    await toque(find.text('Tela').last, depois: 1400);
    await toque(find.text('DESBLOQUEAR'), depois: 5000);

    passo('Meta coletiva da família');
    await toque(find.text('Meta').last, depois: 3500);

    passo('fim');
    s.pcDesligar();
    await pausa(300);
    sem.dispose();
  });
}
