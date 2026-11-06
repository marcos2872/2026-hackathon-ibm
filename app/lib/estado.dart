// Regras do jogo e dados de exemplo. Espelha a lógica do protótipo web (prototipo/index.html)
// e as regras da docs/ideia.md (RN01 a RN20).
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

enum Evid { antesDepois, depois, nenhuma }

const evidMult = {Evid.antesDepois: 1.0, Evid.depois: 0.8, Evid.nenhuma: 0.5};
const evidLabel = {Evid.antesDepois: 'Antes/depois', Evid.depois: 'Foto', Evid.nenhuma: 'Sem foto'};

const estrelaPadrao = 3;
double r05(double x) => (x * 2).round() / 2;

/// RN14: 1 a 5 estrelas viram o multiplicador de qualidade de 0,8 a 1,2.
double multEstrelas(int n) => ((0.8 + (n - 1) * 0.1) * 10).round() / 10;

/// RN01: pontos = peso × 10 × evidência × qualidade, arredondados para meio ponto.
double calcPts(double peso, Evid e, [double q = 1]) => r05(peso * 10 * evidMult[e]! * q);

String fmt(num v) {
  final neg = v < 0;
  final x = (v.abs() * 10).round();
  final inteiro = (x ~/ 10).toString();
  final frac = x % 10;
  final b = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    if (i > 0 && (inteiro.length - i) % 3 == 0) b.write('.');
    b.write(inteiro[i]);
  }
  return '${neg ? '-' : ''}$b${frac > 0 ? ',$frac' : ''}';
}

String brl(double v) {
  final c = (v * 100).round();
  return 'R\$ ${fmt(c ~/ 100)},${(c % 100).toString().padLeft(2, '0')}';
}

String ddmm(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
String hhmm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
DateTime soDia(DateTime d) => DateTime(d.year, d.month, d.day);
String quando(DateTime d) => soDia(d) == soDia(DateTime.now()) ? 'hoje, ${hhmm(d)}' : '${ddmm(d)} ${hhmm(d)}';
String nomes(List<String> l) => l.isEmpty ? '' : l.length == 1 ? l.first : '${l.sublist(0, l.length - 1).join(', ')} e ${l.last}';
const _meses = ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'];
const _semana = ['segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira', 'sexta-feira', 'sábado', 'domingo'];
String dataLonga(DateTime d) => '${_semana[d.weekday - 1]}, ${d.day} de ${_meses[d.month - 1]}';

class Atividade {
  Atividade({required this.id, required this.nome, required this.icone, required this.peso, required this.freq, required this.evid,
      required this.prazo, this.auto = false, this.pessoal = false, this.avulsa = false, this.semanal = false, this.idadeMin = 0,
      this.vezes = 1, this.rotulos, this.ativo = true});
  final String id, nome, icone, freq, prazo;
  double peso;
  Evid evid;
  final bool auto, pessoal, avulsa, semanal;
  final int idadeMin, vezes;
  final List<String>? rotulos;
  bool ativo;
}

List<Atividade> modelos() => [
      Atividade(id: 'cama', nome: 'Arrumar a cama', icone: 'casa', peso: .5, freq: 'Diária', evid: Evid.depois, prazo: '09h', auto: true, pessoal: true),
      Atividade(id: 'quarto', nome: 'Organizar o quarto', icone: 'casa', peso: 1, freq: 'Diária', evid: Evid.antesDepois, prazo: '19h', pessoal: true),
      Atividade(id: 'lixo', nome: 'Tirar o lixo', icone: 'vassoura', peso: .5, freq: 'Diária', evid: Evid.nenhuma, prazo: '20h', auto: true),
      Atividade(id: 'louca', nome: 'Lavar a louça', icone: 'louca', peso: 1, freq: '2× ao dia', evid: Evid.depois, prazo: '21h', idadeMin: 7, vezes: 2, rotulos: ['almoço', 'jantar']),
      Atividade(id: 'jantar', nome: 'Preparar o jantar', icone: 'louca', peso: 1.5, freq: 'Diária', evid: Evid.depois, prazo: '19h30', idadeMin: 16),
      Atividade(id: 'banheiro', nome: 'Limpar o banheiro', icone: 'balde', peso: 2, freq: 'Diária', evid: Evid.antesDepois, prazo: '21h', idadeMin: 10),
    ];

class Membro {
  Membro({required this.id, required this.nome, required this.idade, required this.equipe, required this.admin, required this.classe,
      required this.cor, required this.cabelo, required this.pele, required this.xp, required this.pts, required this.cred,
      required this.streak, required this.tarefasTemp, required this.pesoTemp, required this.pesoSemana, required this.ontem,
      required this.semanas, required this.tarefasSemana, required this.atribSemana, this.minutos = 0});
  final String id, nome, equipe, classe;
  final int idade;
  final bool admin;
  final Color cor, cabelo, pele;
  double xp, pts, cred, pesoTemp, pesoSemana;
  int streak, tarefasTemp, tarefasSemana, atribSemana, minutos, usadoHoje = 0;
  List<String> ontem;
  List<double> semanas;
  bool get crianca => idade < 18;
  int get nivel => xp ~/ 200 + 1;
  int get xpNoNivel => (xp % 200).floor();
}

class Atribuicao {
  Atribuicao({required this.id, required this.atividadeId, required this.membroId, required this.origem, this.status = 'a_fazer', this.rotulo, this.criadoPor});
  final String id, atividadeId, origem;
  String membroId, status;
  final String? rotulo, criadoPor;
  String? registroId;
}

/// Foto do registro: bytes da câmera ou uma ilustração de exemplo desenhada no app.
class Foto {
  const Foto.exemplo(this.tipo, this.nome, this.semente) : bytes = null;
  const Foto.bytes(this.bytes)
      : tipo = '',
        nome = '',
        semente = 0;
  final Uint8List? bytes;
  final String tipo, nome;
  final int semente;
}

class Registro {
  Registro({required this.id, required this.atribId, required this.atividadeId, required this.membroId, required this.avaliador,
      required this.auto, required this.antes, required this.depois, required this.evid, required this.obs, required this.quando});
  final String id, atividadeId, membroId;
  final String? atribId;
  String? avaliador, motivo, contestacao;
  final bool auto;
  final Foto? antes, depois;
  final Evid evid;
  final String obs;
  String status = 'pendente';
  double pontos = 0;
  int estrelas = estrelaPadrao;
  bool decisaoFinal = false;
  DateTime quando;
}

class Recompensa {
  const Recompensa(this.id, this.nome, this.icone, this.custo, this.horizonte, this.por, {this.minutos, this.estoque});
  final String id, nome, icone, horizonte, por;
  final int custo;
  final int? minutos, estoque;
}

class Movimento {
  Movimento(this.membroId, this.desc, this.xp, this.cred, this.quando);
  final String membroId, desc;
  final double xp, cred;
  final DateTime quando;
}

class Evento {
  Evento(this.tipo, this.texto) : quando = DateTime.now();
  final String tipo, texto;
  final DateTime quando;
}

class Pagamento {
  Pagamento(this.membroId, this.semana, this.valor, this.metodo);
  final String membroId, metodo;
  final DateTime semana;
  final double valor;
}

class Equipe {
  const Equipe(this.id, this.nome, this.cor, this.premio);
  final String id, nome, premio;
  final Color cor;
}

class Aviso {
  const Aviso(this.titulo, this.texto, this.icone);
  final String titulo, texto, icone;
}

class Sorteio {
  Sorteio(this.semente, this.carga, this.diff, this.repeticoes);
  final int semente, repeticoes;
  final Map<String, double> carga;
  final double diff;
}

class AppState extends ChangeNotifier {
  AppState() {
    seed();
  }

  // ---------------------------------------------------------------- dados
  final familia = 'Casa da Ana';
  late List<Membro> membros;
  late List<Atividade> atividades;
  List<Atribuicao> atribuicoes = [];
  List<Registro> registros = [];
  final List<Recompensa> recompensas = const [
    Recompensa('r1', '30 min de computador', 'tela', 15, 'curto', 'm1', minutos: 30),
    Recompensa('r2', 'Escolher o filme da sexta', 'd20', 20, 'curto', 'm1', estoque: 1),
    Recompensa('r3', 'Sobremesa especial', 'louca', 25, 'curto', 'm2', estoque: 2),
    Recompensa('r4', 'Dormir 15 min mais tarde', 'ampulheta', 30, 'curto', 'm2'),
    Recompensa('r5', 'Passeio no parque', 'casa', 150, 'medio', 'm1'),
    Recompensa('r6', 'Dia sem tarefas', 'vassoura', 250, 'medio', 'm2', estoque: 1),
    Recompensa('r7', 'Jogo novo', 'd20', 400, 'medio', 'm1'),
    Recompensa('r8', 'Console', 'trofeu', 1500, 'longo', 'm2'),
  ];
  final List<Equipe> equipes = const [
    Equipe('raposa', 'Time Raposa', Color(0xFFB13E53), 'escolhe a pizza e o filme do sábado'),
    Equipe('coruja', 'Time Coruja', Color(0xFF3B5DC9), 'escolhe a pizza e o filme do sábado'),
  ];
  List<String> resgates = []; // "membro:recompensa"
  List<Movimento> extrato = [];
  List<Evento> auditoria = [];
  List<Pagamento> pagamentos = [];
  late Sorteio sorteio;

  // meta coletiva dos filhos (GoalProgress aceita até 4 membros)
  final metaNome = 'Viagem para a praia';
  final metaAlvo = 5000.0;
  final metaMinPct = 20;
  late DateTime metaInicio, metaPrazo;
  List<String> metaMembros = [];
  Map<String, double> metaContrib = {};

  // regras configuráveis
  final credBloco = 10;
  int minBloco = 20;
  int limiteDiario = 180;
  final agenda = '18h às 21h';
  final pin = '1234';
  final idadeSimples = 9;
  final limiteSorteio = 15;
  bool mesadaFixa = true;
  final mesadaValor = 20.0, mesadaMinPct = 80, mesadaTaxa = .10;

  late DateTime semana, temporadaFim;
  late String temporadaNome;

  // ---------------------------------------------------------------- interface
  String who = 'm3';
  String tab = 'hoje';
  bool temaDia = false;
  final Map<String, int> estrelas = {};
  Aviso? aviso;
  Timer? _avisoT;
  String? pcDono;
  int pcSuave = 0;
  Timer? _pcT;
  final _rnd = Random();
  int _seq = 0;
  String uid(String p) => '$p${_seq++}';

  Membro membro(String id) => membros.firstWhere((m) => m.id == id);
  Membro get eu => membro(who);
  Atividade ativ(String id) => atividades.firstWhere((a) => a.id == id);
  List<Membro> get admins => membros.where((m) => m.admin).toList();
  bool simples(Membro m) => m.idade < idadeSimples;
  Equipe equipe(String id) => equipes.firstWhere((e) => e.id == id);

  List<String> abas(Membro m) => ['hoje', if (m.admin) 'admin', 'evolucao', 'premios', if (m.crianca) 'tela', 'meta'].take(5).toList();

  void avisar(String t, String x, String icone) {
    aviso = Aviso(t, x, icone);
    _avisoT?.cancel();
    _avisoT = Timer(const Duration(seconds: 3), () {
      aviso = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void audit(String tipo, String texto) {
    auditoria.insert(0, Evento(tipo, texto));
    if (auditoria.length > 80) auditoria.removeLast();
  }

  void setWho(String id) {
    pcParar('desligado ao trocar de usuário');
    who = id;
    if (!abas(eu).contains(tab)) tab = 'hoje';
    notifyListeners();
  }

  void setTab(String t) {
    if (t != 'tela') pcParar('desligado ao sair da tela');
    tab = t;
    notifyListeners();
  }

  void alternarTema() {
    temaDia = !temaDia;
    notifyListeners();
  }

  // ---------------------------------------------------------------- semente
  void seed() {
    pcParar();
    final hoje = soDia(DateTime.now());
    semana = hoje.subtract(Duration(days: hoje.weekday - 1));
    temporadaFim = DateTime(hoje.year, hoje.month + 1, 0);
    temporadaNome = 'Temporada de ${_meses[hoje.month - 1]}';
    metaInicio = hoje.subtract(const Duration(days: 36));
    metaPrazo = hoje.add(const Duration(days: 54));
    atividades = modelos();
    atribuicoes = [];
    registros = [];
    resgates = [];
    extrato = [];
    auditoria = [];
    pagamentos = [];
    estrelas.clear();
    Membro mk(String id, String nome, int idade, String eq, bool adm, String classe, int cor, int cab, int pele, double xp, double pts,
            double cred, int streak, int tar, double peso, double sem, List<String> ontem, List<double> semanas, int ts, int as, [int min = 0]) =>
        Membro(id: id, nome: nome, idade: idade, equipe: eq, admin: adm, classe: classe, cor: Color(cor), cabelo: Color(cab), pele: Color(pele),
            xp: xp, pts: pts, cred: cred, streak: streak, tarefasTemp: tar, pesoTemp: peso, pesoSemana: sem, ontem: ontem, semanas: semanas,
            tarefasSemana: ts, atribSemana: as, minutos: min);
    membros = [
      mk('m1', 'Ana', 41, 'raposa', true, 'Guardiã da Cozinha', 0xFFB13E53, 0xFF7A2840, 0xFFE8C170, 1180, 70, 45, 9, 13, 11, 8, ['jantar'], [48, 55, 52, 60, 58, 46], 9, 10),
      mk('m2', 'Paulo', 43, 'coruja', true, 'Mestre do Jantar', 0xFF3B5DC9, 0xFF1A1C2C, 0xFFA0603A, 1050, 64, 30, 4, 11, 10, 7.5, ['louca'], [40, 44, 50, 47, 52, 41], 8, 9),
      mk('m3', 'Bruno', 14, 'raposa', false, 'Cavaleiro do Banheiro', 0xFF38B764, 0xFF6B3A26, 0xFFE8C170, 1590, 85, 60, 6, 14, 12.5, 5.5, ['louca'], [52, 60, 58, 66, 71, 63], 10, 10),
      mk('m4', 'Carla', 11, 'coruja', false, 'Arqueira da Arrumação', 0xFFEF7D57, 0xFFB8873E, 0xFFE8C170, 1290, 92.5, 35, 11, 16, 13, 6, ['banheiro'], [70, 66, 72, 75, 68, 59], 12, 12, 20),
      mk('m5', 'Davi', 8, 'raposa', false, 'Escudeiro do Lixo', 0xFF41A6F6, 0xFF1A1C2C, 0xFFA0603A, 610, 40, 20, 2, 8, 6, 5.5, ['lixo'], [18, 22, 25, 24, 30, 27], 7, 10),
    ];
    metaMembros = ['m3', 'm4', 'm5'];
    metaContrib = {'m3': 1420, 'm4': 1180, 'm5': 640};
    sortear(20261106, silencioso: true);

    final agora = DateTime.now();
    final cama = atribuicoes.firstWhere((a) => a.membroId == 'm4' && a.atividadeId == 'cama');
    final rc = _novoRegistro(cama, null, const Foto.exemplo('depois', 'Arrumar a cama', 3), 'Antes da escola!');
    rc
      ..status = 'aprovado'
      ..pontos = calcPts(.5, Evid.depois)
      ..quando = agora.subtract(const Duration(hours: 6));
    cama.status = 'aprovado';
    final quarto = atribuicoes.firstWhere((a) => a.membroId == 'm4' && a.atividadeId == 'quarto');
    _novoRegistro(quarto, const Foto.exemplo('antes', 'Organizar o quarto', 11), const Foto.exemplo('depois', 'Organizar o quarto', 12),
            'Guardei os livros na estante nova.')
        .quando = agora.subtract(const Duration(minutes: 40));
    quarto.status = 'pendente';
    final louca = atribuicoes.firstWhere((a) => a.membroId == 'm5' && a.atividadeId == 'louca');
    final rl = _novoRegistro(louca, null, const Foto.exemplo('depois', 'Lavar a louça', 21), '');
    rl
      ..status = 'rejeitado'
      ..motivo = 'Ficaram as panelas do almoço na pia.'
      ..quando = agora.subtract(const Duration(hours: 3));
    louca.status = 'rejeitado';
    registros.add(Registro(id: uid('rg'), atribId: null, atividadeId: 'jantar', membroId: 'm1', avaliador: null, auto: false, antes: null,
        depois: const Foto.exemplo('depois', 'Preparar o jantar', 31), evid: Evid.depois, obs: 'Escondidinho de abóbora', quando: agora.subtract(const Duration(hours: 20)))
      ..status = 'aprovado'
      ..pontos = calcPts(1.5, Evid.depois));
    for (final m in membros.where((m) => m.crianca)) {
      pagamentos.add(Pagamento(m.id, semana.subtract(const Duration(days: 7)), 20, 'Pix'));
    }
    for (final m in membros) {
      extrato
        ..add(Movimento(m.id, 'Limpar o banheiro aprovado', 20, 20, agora.subtract(const Duration(hours: 26))))
        ..add(Movimento(m.id, 'Resgate: Sobremesa especial', 0, -25, agora.subtract(const Duration(hours: 50))))
        ..add(Movimento(m.id, 'Lavar a louça aprovado', 8, 8, agora.subtract(const Duration(hours: 52))));
    }
    audit('mesada', 'Mesada da semana passada registrada como paga via Pix.');
    audit('rejeição', 'Paulo rejeitou “Lavar a louça” de Davi: ficaram as panelas do almoço na pia.');
    audit('sorteio', 'Sorteio balanceado do dia publicado (semente 20261106).');
    who = 'm3';
    tab = 'hoje';
    notifyListeners();
  }

  // ---------------------------------------------------------------- sorteio (RN06)
  void sortear(int semente, {bool silencioso = false}) {
    final r = Random(semente);
    final manter = atribuicoes.where((a) => a.status != 'a_fazer' || a.origem == 'avulsa' || ativ(a.atividadeId).pessoal).toList();
    for (final a in atividades.where((a) => a.ativo && a.pessoal)) {
      for (final m in membros.where((m) => m.crianca)) {
        if (!manter.any((x) => x.membroId == m.id && x.atividadeId == a.id)) {
          manter.add(Atribuicao(id: uid('at'), atividadeId: a.id, membroId: m.id, origem: 'fixa'));
        }
      }
    }
    final sabado = DateTime.now().weekday == DateTime.saturday;
    var pool = <(Atividade, String)>[];
    for (final a in atividades.where((a) => a.ativo && !a.pessoal && !a.avulsa && (!a.semanal || sabado))) {
      for (var i = 0; i < a.vezes; i++) {
        pool.add((a, a.rotulos?[i] ?? ''));
      }
    }
    for (final x in manter.where((x) => x.origem != 'avulsa' && !ativ(x.atividadeId).pessoal)) {
      final k = pool.indexWhere((p) => p.$1.id == x.atividadeId && p.$2 == (x.rotulo ?? ''));
      if (k >= 0) pool.removeAt(k);
    }
    pool.shuffle(r);
    final idx = {for (var i = 0; i < pool.length; i++) pool[i]: i};
    pool.sort((p, q) => q.$1.peso.compareTo(p.$1.peso) != 0 ? q.$1.peso.compareTo(p.$1.peso) : idx[p]!.compareTo(idx[q]!));
    final carga = {
      for (final m in membros) m.id: m.pesoSemana + manter.where((x) => x.membroId == m.id).fold(0.0, (s, x) => s + ativ(x.atividadeId).peso)
    };
    final ordem = [...membros]..shuffle(r);
    final novos = <Atribuicao>[];
    var repeticoes = 0;
    for (final it in pool) {
      bool jaHoje(String id) => [...manter, ...novos].any((x) => x.membroId == id && x.atividadeId == it.$1.id);
      var eleg = ordem.where((m) => m.idade >= it.$1.idadeMin).toList();
      if (eleg.isEmpty) continue;
      final semRep = eleg.where((m) => !m.ontem.contains(it.$1.id) && !jaHoje(m.id)).toList();
      if (semRep.isNotEmpty && semRep.length < eleg.length) repeticoes++;
      if (semRep.isNotEmpty) eleg = semRep;
      eleg.sort((p, q) => carga[p.id]!.compareTo(carga[q.id]!) != 0 ? carga[p.id]!.compareTo(carga[q.id]!) : ordem.indexOf(p).compareTo(ordem.indexOf(q)));
      final m = eleg.first;
      carga[m.id] = carga[m.id]! + it.$1.peso;
      novos.add(Atribuicao(id: uid('at'), atividadeId: it.$1.id, membroId: m.id, origem: 'sorteio', rotulo: it.$2.isEmpty ? null : it.$2));
    }
    double spread() {
      final v = carga.values;
      final mx = v.reduce(max);
      return mx == 0 ? 0 : (mx - v.reduce(min)) / mx * 100;
    }

    for (var it = 0; it < 8 && spread() > limiteSorteio; it++) {
      final ids = carga.keys.toList()..sort((a, b) => carga[b]!.compareTo(carga[a]!));
      final mx = ids.first, mn = ids.last;
      final cand = novos
          .where((x) => x.membroId == mx && membro(mn).idade >= ativ(x.atividadeId).idadeMin && !membro(mn).ontem.contains(x.atividadeId))
          .where((x) => ((carga[mx]! - ativ(x.atividadeId).peso) - (carga[mn]! + ativ(x.atividadeId).peso)).abs() < carga[mx]! - carga[mn]!)
          .toList();
      if (cand.isEmpty) break;
      cand.sort((a, b) => ativ(b.atividadeId).peso.compareTo(ativ(a.atividadeId).peso));
      final p = ativ(cand.first.atividadeId).peso;
      carga[mx] = carga[mx]! - p;
      carga[mn] = carga[mn]! + p;
      cand.first.membroId = mn;
    }
    atribuicoes = [...manter, ...novos];
    sorteio = Sorteio(semente, carga, spread(), repeticoes);
    if (!silencioso) audit('sorteio', 'Novo sorteio balanceado (semente $semente): diferença de ${fmt(spread())}% entre a maior e a menor carga.');
  }

  void sortearDeNovo() {
    sortear(_rnd.nextInt(999999) + 1);
    avisar('Sorteio feito!', 'Diferença de carga de ${fmt(sorteio.diff)}% entre os membros.', 'd20');
  }

  // ---------------------------------------------------------------- aprovação (RN02, RN03, RN05)
  /// Quem cria a missão aprova; senão um admin que não seja o executor.
  String? avaliadorPara(Atribuicao a) {
    if (ativ(a.atividadeId).auto) return 'auto';
    if (a.criadoPor != null && a.criadoPor != a.membroId) return a.criadoPor;
    if (admins.any((x) => x.id != a.membroId)) return null;
    final outros = membros.where((x) => x.id != a.membroId).toList()..sort((p, q) => q.idade.compareTo(p.idade));
    return outros.isEmpty ? null : outros.first.id;
  }

  String quemAvalia(Registro r) =>
      r.avaliador != null ? membro(r.avaliador!).nome : nomes(admins.where((a) => a.id != r.membroId).map((a) => a.nome).toList());

  bool podeAvaliar(String id, Registro r) => r.membroId != id && (r.avaliador != null ? r.avaliador == id : membro(id).admin);
  List<Registro> filaDe(String id) => registros.where((r) => (r.status == 'pendente' || r.status == 'contestado') && podeAvaliar(id, r)).toList();

  Registro _novoRegistro(Atribuicao a, Foto? antes, Foto? depois, String obs) {
    final av = avaliadorPara(a);
    final evid = antes != null && depois != null ? Evid.antesDepois : (antes ?? depois) != null ? Evid.depois : Evid.nenhuma;
    final r = Registro(id: uid('rg'), atribId: a.id, atividadeId: a.atividadeId, membroId: a.membroId, avaliador: av == 'auto' ? null : av,
        auto: av == 'auto', antes: antes, depois: depois, evid: evid, obs: obs, quando: DateTime.now());
    registros.add(r);
    a.registroId = r.id;
    return r;
  }

  Atribuicao atrib(String id) => atribuicoes.firstWhere((a) => a.id == id);
  Registro? registroDe(Atribuicao a) => a.registroId == null ? null : registros.firstWhere((r) => r.id == a.registroId);

  void registrar(String atribId, Foto? antes, Foto? depois, String obs) {
    final a = atrib(atribId);
    final atv = ativ(a.atividadeId);
    final m = membro(a.membroId);
    final r = _novoRegistro(a, antes, depois, obs);
    audit('registro', '${m.nome} registrou “${atv.nome}” (${evidLabel[r.evid]!.toLowerCase()}).');
    if (r.auto) {
      _aplicarAprovacao(r, estrelaPadrao, auto: true);
      avisar('Missão concluída!', '${atv.nome} rendeu +${fmt(r.pontos)} XP.', 'check');
    } else {
      a.status = 'pendente';
      avisar('Missão enviada!', '${quemAvalia(r)} vai avaliar “${atv.nome}”. +${fmt(calcPts(atv.peso, r.evid))} quando aprovada.', 'camera');
    }
  }

  void _aplicarAprovacao(Registro r, int nEstrelas, {bool auto = false}) {
    final atv = ativ(r.atividadeId);
    final m = membro(r.membroId);
    final pts = calcPts(atv.peso, r.evid, multEstrelas(nEstrelas));
    final antes = m.nivel;
    r
      ..status = 'aprovado'
      ..pontos = pts
      ..estrelas = nEstrelas;
    final a = r.atribId == null ? null : atrib(r.atribId!);
    a?.status = 'aprovado';
    m
      ..xp += pts
      ..pts += pts
      ..cred += pts
      ..tarefasTemp += 1
      ..pesoTemp += atv.peso
      ..tarefasSemana += 1;
    m.semanas[m.semanas.length - 1] += pts;
    if (metaMembros.contains(m.id)) metaContrib[m.id] = (metaContrib[m.id] ?? 0) + pts;
    extrato.insert(0, Movimento(m.id, '${atv.nome} aprovado', pts, pts, DateTime.now()));
    audit('aprovação', '${auto ? 'Sistema' : eu.nome} aprovou “${atv.nome}” de ${m.nome}: +${fmt(pts)}${auto ? '' : ' ($nEstrelas ${nEstrelas == 1 ? 'estrela' : 'estrelas'})'}.');
    if (m.nivel > antes) {
      Timer(const Duration(milliseconds: 3200), () => avisar('Nível novo!', '${m.nome} chegou ao nível ${m.nivel}.', 'xp'));
    }
  }

  void setEstrelas(String regId, int n) {
    estrelas[regId] = n;
    notifyListeners();
  }

  void aprovar(String regId) {
    final r = registros.firstWhere((x) => x.id == regId);
    _aplicarAprovacao(r, estrelas[regId] ?? estrelaPadrao);
    avisar('Missão aprovada!', '${ativ(r.atividadeId).nome} rendeu +${fmt(r.pontos)} XP para ${membro(r.membroId).nome}.', 'check');
  }

  void rejeitar(String regId, String motivo) {
    final r = registros.firstWhere((x) => x.id == regId);
    final fin = r.status == 'contestado';
    r
      ..status = 'rejeitado'
      ..motivo = motivo
      ..decisaoFinal = fin;
    if (r.atribId != null) atrib(r.atribId!).status = 'rejeitado';
    audit('rejeição', '${eu.nome} ${fin ? 'manteve a rejeição de' : 'rejeitou'} “${ativ(r.atividadeId).nome}” de ${membro(r.membroId).nome}: $motivo');
    avisar('Registro devolvido', '${membro(r.membroId).nome} vê o motivo e pode ${fin ? 'refazer' : 'contestar ou refazer'}.', 'ampulheta');
  }

  void contestar(String regId, String texto) {
    final r = registros.firstWhere((x) => x.id == regId);
    r
      ..status = 'contestado'
      ..contestacao = texto
      ..avaliador = null;
    if (r.atribId != null) atrib(r.atribId!).status = 'contestado';
    audit('contestação', '${membro(r.membroId).nome} contestou a rejeição de “${ativ(r.atividadeId).nome}”.');
    avisar('Contestação enviada', '${quemAvalia(r)} decide em última instância.', 'ampulheta');
  }

  /// Refazer: a atribuição volta para "a fazer" e o registro antigo fica no histórico.
  void refazer(String atribId) {
    final a = atrib(atribId);
    a
      ..status = 'a_fazer'
      ..registroId = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------- missão avulsa (diagrama)
  void criarMissao(String nome, String para, double peso, Evid evid) {
    final a = Atividade(id: uid('a'), nome: nome, icone: 'vassoura', peso: peso, freq: 'Avulsa', evid: evid, prazo: 'hoje', avulsa: true, ativo: false);
    atividades.add(a);
    atribuicoes.add(Atribuicao(id: uid('at'), atividadeId: a.id, membroId: para, origem: 'avulsa', criadoPor: who));
    audit('missão', '${eu.nome} criou “$nome” (peso ${fmt(peso)}) para ${para == who ? 'si' : membro(para).nome}.');
    avisar('Missão criada!', para == who ? '“$nome” entrou na sua lista.' : '“$nome” foi para ${membro(para).nome}. Você aprova a conclusão.', 'vassoura');
  }

  // ---------------------------------------------------------------- tesouro (RN08, RN09, RN10)
  int resgatesNaSemana(String recId) => resgates.where((x) => x.endsWith(':$recId')).length;

  String? bloqueio(Membro m, Recompensa r) {
    if (m.cred < r.custo) return 'faltam ${fmt(r.custo - m.cred)}';
    if (r.estoque != null && resgatesNaSemana(r.id) >= r.estoque!) return 'esgotado na semana';
    if (r.minutos != null && m.minutos + m.usadoHoje + r.minutos! > limiteDiario) return 'limite de ${limiteDiario ~/ 60} h/dia';
    return null;
  }

  void resgatar(Recompensa r) {
    final m = eu;
    if (bloqueio(m, r) != null) return;
    m.cred -= r.custo;
    if (r.minutos != null) m.minutos += r.minutos!;
    resgates.add('${m.id}:${r.id}');
    extrato.insert(0, Movimento(m.id, 'Resgate: ${r.nome}', 0, -r.custo.toDouble(), DateTime.now()));
    audit('resgate', '${m.nome} resgatou “${r.nome}” por ${r.custo} créditos.');
    if (r.minutos != null) {
      avisar('Tempo liberado!', '+${r.minutos} min no computador. Seu XP continua igual.', 'tela');
    } else {
      avisar('Tesouro resgatado!', '${membro(r.por).nome} vai entregar “${r.nome}”.', 'bau');
    }
  }

  void converter() {
    final m = eu;
    if (m.cred < credBloco) return avisar('Ainda não', 'Você precisa de $credBloco créditos.', 'moeda');
    if (m.minutos + m.usadoHoje + minBloco > limiteDiario) return avisar('Limite do dia', 'O máximo é ${limiteDiario ~/ 60} h por dia (RN10).', 'tela');
    m
      ..cred -= credBloco
      ..minutos += minBloco;
    extrato.insert(0, Movimento(m.id, 'Troca por $minBloco min de computador', 0, -credBloco.toDouble(), DateTime.now()));
    audit('tempo', '${m.nome} trocou $credBloco créditos por $minBloco min.');
    avisar('Tempo liberado!', '+$minBloco min de computador.', 'tela');
  }

  // ---------------------------------------------------------------- mesada (RN20)
  double cumprimento(Membro m) {
    final hojeN = atribuicoes.where((a) => a.membroId == m.id && a.status != 'nao_feita').length;
    final tot = m.atribSemana + hojeN;
    return tot == 0 ? 0 : m.tarefasSemana / tot;
  }

  double mesadaDevida(Membro m) => mesadaFixa
      ? (cumprimento(m) * 100 >= mesadaMinPct ? mesadaValor : 0)
      : (m.semanas.last * mesadaTaxa * 100).round() / 100;

  Pagamento? pagamento(String mid, DateTime sem) {
    for (final p in pagamentos) {
      if (p.membroId == mid && p.semana == sem) return p;
    }
    return null;
  }

  void pagarMesada(String mid, String metodo) {
    final m = membro(mid);
    final v = mesadaDevida(m);
    pagamentos.add(Pagamento(mid, semana, v, metodo));
    audit('mesada', '${eu.nome} registrou a mesada de ${m.nome} (${brl(v)}) como paga via $metodo.');
    avisar('Mesada registrada', '${brl(v)} para ${m.nome}, pagos via $metodo.', 'moeda');
  }

  void setMesadaFixa(bool v) {
    mesadaFixa = v;
    notifyListeners();
  }

  // ---------------------------------------------------------------- descumprimento (RN07)
  void naoFeita(String atribId) {
    final a = atrib(atribId);
    final atv = ativ(a.atividadeId);
    final m = membro(a.membroId);
    a.status = 'nao_feita';
    m.streak = 0;
    final outros = membros.where((x) => x.id != m.id && x.idade >= atv.idadeMin).toList()
      ..sort((p, q) => (sorteio.carga[p.id] ?? 0).compareTo(sorteio.carga[q.id] ?? 0));
    if (outros.isEmpty) return notifyListeners();
    final o = outros.first;
    atribuicoes.add(Atribuicao(id: uid('at'), atividadeId: a.atividadeId, membroId: o.id, origem: 'redistribuida', rotulo: a.rotulo));
    sorteio.carga[o.id] = (sorteio.carga[o.id] ?? 0) + atv.peso;
    audit('redistribuição', '“${atv.nome}” passou de ${m.nome} para ${o.nome}, que fica com os pontos. Sem dívida (RN07).');
    avisar('Missão redistribuída', '${o.nome} assume “${atv.nome}” e fica com os pontos.', 'd20');
  }

  void setPeso(String atvId, double p) {
    final a = ativ(atvId);
    audit('peso', '${eu.nome} mudou o peso de “${a.nome}” de ${fmt(a.peso)} para ${fmt(p)}.');
    a.peso = p;
    notifyListeners();
  }

  void setLimite(int v) {
    limiteDiario = v;
    notifyListeners();
  }

  void setMinBloco(int v) {
    minBloco = v;
    notifyListeners();
  }

  /// RN11: liberação extra com PIN e justificativa. Retorna o erro, se houver.
  String? emergencia(String mid, int minutos, String justificativa, String pinDigitado) {
    if (justificativa.trim().isEmpty) return 'A justificativa é obrigatória (RN11).';
    if (pinDigitado != pin) return 'PIN incorreto.';
    final m = membro(mid);
    m.minutos += minutos;
    audit('emergência', '${eu.nome} liberou $minutos min para ${m.nome} com PIN: $justificativa.');
    avisar('Tempo liberado!', '+$minutos min de emergência para ${m.nome}.', 'tela');
    return null;
  }

  // ---------------------------------------------------------------- computador simulado (1 s = 1 min)
  bool get pcLigado => pcDono != null;

  void pcLigar() {
    final m = eu;
    if (m.minutos <= 0) return;
    pcDono = m.id;
    pcSuave = 0;
    audit('tempo', 'Computador de ${m.nome} desbloqueado com ${m.minutos} min de saldo.');
    _pcT?.cancel();
    _pcT = Timer.periodic(const Duration(seconds: 1), (_) => _pcTick());
    notifyListeners();
  }

  void pcParar([String? motivo]) {
    if (pcDono == null) return;
    _pcT?.cancel();
    audit('tempo', 'Computador de ${membro(pcDono!).nome} ${motivo ?? 'desligado'}.');
    pcDono = null;
    pcSuave = 0;
  }

  void pcDesligar() {
    pcParar('desligado com saldo guardado');
    notifyListeners();
  }

  void _pcTick() {
    final m = membro(pcDono!);
    if (pcSuave > 0) {
      pcSuave--;
      if (pcSuave == 0) {
        pcParar('bloqueado: saldo esgotado');
        avisar('Tempo esgotado', 'O computador foi bloqueado. Conclua uma missão para liberar mais.', 'tela');
        return;
      }
    } else {
      m.minutos = max(0, m.minutos - 1);
      m.usadoHoje++;
      if (m.minutos == 0) pcSuave = 5;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _pcT?.cancel();
    _avisoT?.cancel();
    super.dispose();
  }
}
