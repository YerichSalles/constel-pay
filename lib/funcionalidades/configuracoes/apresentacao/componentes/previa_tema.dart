import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/estilos_texto.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/widgets/icone_emoji.dart';
import '../../../../compartilhado/widgets/imagem_logo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../dominio/entidades/tema_personalizado.dart';

/// Miniatura compacta do terminal com o tema em edição aplicado: barra
/// superior, logo, nome do estabelecimento, card de conteúdo, botão e a
/// faixa de pagamento. Atualiza em tempo real com o rascunho, antes de o
/// operador aplicar as alterações.
class PreviaTema extends StatelessWidget {
  const PreviaTema({
    super.key,
    required this.tema,
    required this.nomeEstabelecimento,
    this.logoPath,
  });

  final TemaPersonalizado tema;
  final String nomeEstabelecimento;
  final String? logoPath;

  @override
  Widget build(BuildContext context) {
    final primaria =
        TemaConstel.corDeHex(tema.corPrimaria, CoresApp.primariaPadrao);
    final secundaria =
        TemaConstel.corDeHex(tema.corSecundaria, CoresApp.secundariaPadrao);
    final fundo = TemaConstel.corDeHex(tema.corFundo, CoresApp.fundoPadrao);
    final botoes = TemaConstel.corDeHex(tema.corBotoes, CoresApp.botoesPadrao);
    final corTexto =
        TemaConstel.corDeHex(tema.corTexto, CoresApp.textoPrincipal);
    final faixaFundo = TemaConstel.corDeHex(tema.corFaixaEfetiva, primaria);
    final faixaTexto = TemaConstel.corDeHex(tema.corTextoFaixa, Colors.white);
    final corSobrePrimaria = primaria.computeLuminance() < .5
        ? Colors.white
        : const Color(0xFF1E1E1E);
    final nome =
        nomeEstabelecimento.isEmpty ? 'Estabelecimento' : nomeEstabelecimento;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: CoresApp.bordaCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: primaria,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    _MiniLogo(logoPath: logoPath, tamanho: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nome,
                        overflow: TextOverflow.ellipsis,
                        style: EstilosTexto.estilo(
                          tema.fonte,
                          TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: corSobrePrimaria,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Detalhe na cor secundária, espelhando o indicador das abas
              // do app: apoio visual discreto, nunca cor dominante.
              Container(
                key: const Key('previa_detalhe_secundaria'),
                height: 3,
                color: secundaria,
              ),
              Container(
                color: fundo,
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _MiniLogo(logoPath: logoPath, tamanho: 64, raio: 16),
                    const SizedBox(height: 12),
                    Text(
                      nome,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: EstilosTexto.estilo(
                        tema.fonte,
                        TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: corTexto,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CoresApp.bordaCard),
                      ),
                      child: Row(
                        children: [
                          Container(
                            key: const Key('previa_avatar_secundaria'),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: secundaria,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 12,
                              color: secundaria.computeLuminance() < .5
                                  ? Colors.white
                                  : const Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Olá! Vamos localizar sua comanda.',
                              style: EstilosTexto.estilo(
                                tema.fonte,
                                TextStyle(fontSize: 12.5, color: corTexto),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: botoes,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Exemplo de botão',
                        textAlign: TextAlign.center,
                        style: EstilosTexto.estilo(
                          tema.fonte,
                          const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: faixaFundo,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  tema.textoFaixaParaIdioma(
                      Localizations.localeOf(context).languageCode,
                      AppLocalizations.of(context).tapToPay),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: EstilosTexto.estilo(
                    tema.fonte,
                    TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: faixaTexto,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniLogo extends StatelessWidget {
  const _MiniLogo({required this.logoPath, required this.tamanho, this.raio});

  final String? logoPath;
  final double tamanho;
  final double? raio;

  @override
  Widget build(BuildContext context) {
    final caminho = logoPath;
    final temLogo = caminho != null && File(caminho).existsSync();
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: raio == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: raio == null ? null : BorderRadius.circular(raio!),
        border: Border.all(color: CoresApp.bordaCard),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(tamanho * .1),
      alignment: Alignment.center,
      child: temLogo
          ? ImagemLogo(
              caminho: caminho,
              reserva: IconeEmoji('🍽️', tamanho: tamanho * .48),
            )
          : IconeEmoji('🍽️', tamanho: tamanho * .48),
    );
  }
}
