import 'package:flutter/material.dart';

abstract final class EstilosTexto {
  static const String fontePadrao = 'Inter';

  /// Fontes empacotadas em `assets/fontes` e declaradas no pubspec.
  /// Nao dependem de internet: o terminal funciona offline.
  static const List<String> fontesDisponiveis = <String>[
    'Inter',
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Nunito',
    'Rubik',
  ];

  static String familia(String fonte) =>
      fontesDisponiveis.contains(fonte) ? fonte : fontePadrao;

  static TextTheme criarTextTheme(
    Color corTexto, [
    String fonte = fontePadrao,
  ]) =>
      ThemeData.light().textTheme.apply(
            fontFamily: familia(fonte),
            bodyColor: corTexto,
            displayColor: corTexto,
          );

  /// Estilo isolado na fonte escolhida, para previews e rotulos.
  static TextStyle estilo(String fonte, TextStyle base) =>
      base.copyWith(fontFamily: familia(fonte));
}
