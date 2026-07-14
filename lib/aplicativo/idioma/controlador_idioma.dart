import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Idioma do atendimento atual (pt-BR / en / es). Não é persistido: cada
/// atendimento novo começa em pt-BR e o idioma escolhido pelo cliente vale
/// só até o atendimento terminar (sucesso, cancelamento ou inatividade).
class ControladorIdioma extends StateNotifier<Locale> {
  ControladorIdioma() : super(padrao);

  static const Locale padrao = Locale('pt', 'BR');

  void selecionar(Locale locale) => state = locale;

  void resetar() => state = padrao;
}
