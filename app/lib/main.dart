// CasaQuest: tarefas da casa como missões de um jogo.
// Versão Flutter do protótipo (prototipo/index.html), com o design system de design-system/.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ds.dart';
import 'estado.dart';
import 'telas.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(CasaQuestApp(estado: AppState()));
}

class CasaQuestApp extends StatelessWidget {
  const CasaQuestApp({super.key, required this.estado});
  final AppState estado;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: estado,
        builder: (context, _) {
          P = estado.temaDia ? dia : noite;
          SystemChrome.setSystemUIOverlayStyle(estado.temaDia ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light);
          return MaterialApp(
            title: 'CasaQuest',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: P.escuro ? Brightness.dark : Brightness.light,
              scaffoldBackgroundColor: P.s000,
              fontFamily: 'PixelifySans',
              colorScheme: ColorScheme.fromSeed(seedColor: K.blue, brightness: P.escuro ? Brightness.dark : Brightness.light, surface: P.s100),
              textSelectionTheme: const TextSelectionThemeData(cursorColor: K.gold),
              tooltipTheme: TooltipThemeData(
                decoration: const BoxDecoration(color: K.dialogBg),
                textStyle: txt(13, c: K.dialogInk),
              ),
            ),
            home: Home(s: estado),
          );
        },
      );
}
