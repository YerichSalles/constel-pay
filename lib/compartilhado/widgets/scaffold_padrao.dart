import 'package:flutter/material.dart';

class ScaffoldPadrao extends StatelessWidget {
  const ScaffoldPadrao(
      {super.key, required this.corpo, this.barra, this.corFundo});

  final Widget corpo;
  final PreferredSizeWidget? barra;
  final Color? corFundo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barra,
      backgroundColor: corFundo,
      body: SafeArea(child: corpo),
    );
  }
}
