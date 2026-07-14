import 'package:freezed_annotation/freezed_annotation.dart';

import 'midia_propaganda.dart';

part 'publicidade_barra.freezed.dart';

enum FormatoPublicidade { carrossel, letreiro, parceiro }

enum TransicaoCarrossel { suave, deslizar, semAnimacao }

enum VelocidadeLetreiro { lenta, normal, rapida }

const List<int> intervalosCarrossel = [3, 5, 6, 8, 10, 15];
const List<String> separadoresLetreiro = ['•', '|', '—', '★'];
const int limiteMensagemLetreiro = 100;

@freezed
class MensagemLetreiro with _$MensagemLetreiro {
  const factory MensagemLetreiro({
    required String id,
    required String texto,
    required int ordem,
    @Default(true) bool ativo,
  }) = _MensagemLetreiro;
}

@freezed
class PublicidadeBarra with _$PublicidadeBarra {
  const PublicidadeBarra._();
  const factory PublicidadeBarra({
    @Default(false) bool ativa,
    @Default(FormatoPublicidade.carrossel) FormatoPublicidade formato,
    @Default([]) List<MidiaPropaganda> banners,
    @Default(6) int intervaloSegundos,
    @Default(TransicaoCarrossel.suave) TransicaoCarrossel transicao,
    @Default([]) List<MensagemLetreiro> mensagens,
    @Default(VelocidadeLetreiro.normal) VelocidadeLetreiro velocidade,
    @Default('•') String separador,
    MidiaPropaganda? midiaParceiro,
  }) = _PublicidadeBarra;

  List<MidiaPropaganda> get bannersAtivos =>
      (banners.where((b) => b.ativo).toList()
        ..sort((a, b) => a.ordem.compareTo(b.ordem)));
  List<MensagemLetreiro> get mensagensAtivas =>
      (mensagens.where((m) => m.ativo).toList()
        ..sort((a, b) => a.ordem.compareTo(b.ordem)));

  /// O formato selecionado tem conteúdo ativo para exibir?
  bool get formatoTemConteudo => switch (formato) {
        FormatoPublicidade.carrossel => bannersAtivos.isNotEmpty,
        FormatoPublicidade.letreiro => mensagensAtivas.isNotEmpty,
        FormatoPublicidade.parceiro => midiaParceiro != null,
      };

  /// Deve exibir publicidade no terminal?
  bool get exibivel => ativa && formatoTemConteudo;
}
