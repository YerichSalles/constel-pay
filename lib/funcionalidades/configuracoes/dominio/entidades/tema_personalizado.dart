import 'package:freezed_annotation/freezed_annotation.dart';

part 'tema_personalizado.freezed.dart';

const String textoFaixaPadrao = 'Toque para pagar';

/// Orientacao fisica da tela onde o app roda; o preview do dialogo Ajustar
/// simula esta orientacao.
enum OrientacaoTela { vertical, horizontal }

@freezed
class TemaPersonalizado with _$TemaPersonalizado {
  const TemaPersonalizado._();

  const factory TemaPersonalizado({
    @Default('#5E52D6') String corPrimaria,
    @Default('#FFD166') String corSecundaria,
    @Default('#F7F7FB') String corFundo,
    @Default('#5E52D6') String corBotoes,
    @Default('#2F2B3D') String corTexto,
    String? corFaixa,
    @Default('#FFFFFF') String corTextoFaixa,
    // Texto da faixa por idioma. `textoFaixa` é o português (mantém o nome
    // antigo para não quebrar temas já salvos); en/es entram vazios e, quando
    // vazios, caem no texto padrão traduzido pelo l10n do idioma atual.
    @Default(textoFaixaPadrao) String textoFaixa,
    @Default('') String textoFaixaEn,
    @Default('') String textoFaixaEs,
    // Barra de créditos (rodapé "Constel Pay" / site). Na tela principal ela
    // nasce transparente sobre a faixa de pagamento; só ganha fundo próprio
    // quando o operador liga `pintarBarraCreditosPrincipal`. No chat ela sempre
    // tem fundo — só a cor é escolhida.
    @Default(false) bool pintarBarraCreditosPrincipal,
    String? corBarraCreditosPrincipal,
    String? corBarraCreditosChat,
    @Default('Inter') String fonte,
    String? logoPath,
    @Default(OrientacaoTela.vertical) OrientacaoTela orientacaoTela,
  }) = _TemaPersonalizado;

  /// A faixa acompanha a cor principal ate o operador escolher uma cor propria
  /// para ela. Nulo aqui e o que da a heranca, sem precisar de uma flag
  /// "herdar sim/nao" separada para manter em sincronia. Uma string vazia ou
  /// so com espacos (campo limpo pelo operador no editor de texto) conta como
  /// a mesma coisa que null: senao a heranca morre em silencio.
  String get corFaixaEfetiva =>
      (corFaixa?.trim().isEmpty ?? true) ? corPrimaria : corFaixa!.trim();

  /// As barras de creditos acompanham a cor principal ate o operador escolher
  /// uma cor propria, pela mesma razao de [corFaixaEfetiva]: null (ou campo
  /// limpo) e o que da a heranca, sem uma flag "herdar" extra para manter em
  /// sincronia.
  String get corBarraCreditosPrincipalEfetiva =>
      (corBarraCreditosPrincipal?.trim().isEmpty ?? true)
          ? corPrimaria
          : corBarraCreditosPrincipal!.trim();

  String get corBarraCreditosChatEfetiva =>
      (corBarraCreditosChat?.trim().isEmpty ?? true)
          ? corPrimaria
          : corBarraCreditosChat!.trim();

  /// Um totem sem chamada para pagar e um defeito, nao uma preferencia: campo
  /// vazio cai no padrao. O texto tambem chega aparado, para nao levar os
  /// espacos que o operador deixou nas pontas para a faixa.
  String get textoFaixaEfetivo =>
      textoFaixa.trim().isEmpty ? textoFaixaPadrao : textoFaixa.trim();

  /// Texto da faixa no [idioma] pedido ('pt', 'en' ou 'es'). Campo vazio — ou
  /// igual ao sentinela padrao 'Toque para pagar' — cai no [padraoTraduzido]
  /// (a chamada padrao ja traduzida pelo l10n do idioma atual), para cada
  /// idioma cair no seu proprio padrao quando o operador nao personaliza.
  String textoFaixaParaIdioma(String idioma, String padraoTraduzido) {
    final bruto = switch (idioma) {
      'en' => textoFaixaEn,
      'es' => textoFaixaEs,
      _ => textoFaixa,
    }
        .trim();
    if (bruto.isEmpty || bruto == textoFaixaPadrao) return padraoTraduzido;
    return bruto;
  }
}
