import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class EstilosTexto {
  static TextTheme criarTextTheme(Color corTexto) =>
      GoogleFonts.interTextTheme()
          .apply(bodyColor: corTexto, displayColor: corTexto);
}
