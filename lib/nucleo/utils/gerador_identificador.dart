import 'dart:math';

/// Gera o identificador único de transação da fatura, no formato usado pelo
/// caixa: 17 caracteres A-Z/0-9 (ex.: `Z1FTGFRQXFDGLVHTS`). O identificador é
/// gerado UMA vez por tentativa de encerramento e reutilizado em qualquer
/// retry — é ele que impede fatura duplicada no retaguarda.
class GeradorIdentificador {
  GeradorIdentificador([Random? aleatorio])
      : _aleatorio = aleatorio ?? Random.secure();

  static const String _alfabeto = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const int _tamanho = 17;

  final Random _aleatorio;

  String gerar() => String.fromCharCodes(Iterable.generate(
        _tamanho,
        (_) => _alfabeto.codeUnitAt(_aleatorio.nextInt(_alfabeto.length)),
      ));
}
