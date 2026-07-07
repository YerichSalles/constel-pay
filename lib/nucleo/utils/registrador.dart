import 'package:logger/logger.dart';

/// Retém as últimas linhas de log em memória para exportação no diagnóstico.
class SaidaMemoria extends LogOutput {
  final List<String> linhas = [];

  static const int _maximo = 1000;

  @override
  void output(OutputEvent event) {
    linhas.addAll(event.lines);
    if (linhas.length > _maximo) {
      linhas.removeRange(0, linhas.length - _maximo);
    }
  }
}

final SaidaMemoria saidaMemoria = SaidaMemoria();

/// Logger do app. NUNCA registrar senha, token, dados de cartão ou payload sensível.
final Logger registrador = Logger(
  output: MultiOutput([ConsoleOutput(), saidaMemoria]),
  printer: SimplePrinter(printTime: true),
);
