import 'package:flutter/material.dart';

import '../../funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'cores_app.dart';
import 'estilos_texto.dart';

abstract final class TemaConstel {
  static Color corDeHex(String hex, Color padrao) {
    final limpo = hex.replaceAll('#', '').trim();
    if (limpo.length != 6) return padrao;
    final valor = int.tryParse(limpo, radix: 16);
    if (valor == null) return padrao;
    return Color(0xFF000000 | valor);
  }

  static String hexDeCor(Color cor) =>
      '#${(cor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  static ThemeData criar(TemaPersonalizado tema) {
    final primaria = corDeHex(tema.corPrimaria, CoresApp.primariaPadrao);
    final secundaria = corDeHex(tema.corSecundaria, CoresApp.secundariaPadrao);
    final fundo = corDeHex(tema.corFundo, CoresApp.fundoPadrao);
    final botoes = corDeHex(tema.corBotoes, CoresApp.botoesPadrao);

    final esquema = ColorScheme.fromSeed(
      seedColor: primaria,
      primary: primaria,
      secondary: secundaria,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fundo,
      textTheme: EstilosTexto.criarTextTheme(CoresApp.textoPrincipal),
      appBarTheme: AppBarTheme(
        backgroundColor: primaria,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: botoes,
          foregroundColor: Colors.white,
          disabledBackgroundColor: botoes.withValues(alpha: .4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: botoes,
          side: BorderSide(color: botoes.withValues(alpha: .5), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CoresApp.bordaCard),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CoresApp.bordaCard),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaria, width: 2),
        ),
        labelStyle: const TextStyle(color: CoresApp.textoSecundario),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaria,
        unselectedLabelColor: CoresApp.textoSecundario,
        indicatorColor: primaria,
      ),
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
