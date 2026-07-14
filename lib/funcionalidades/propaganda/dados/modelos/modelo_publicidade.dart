// O JsonKey abaixo anota um parametro de construtor (padrao freezed), o que o
// analyzer confunde com alvo invalido mesmo sendo o uso correto e documentado.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../dominio/entidades/publicidade_barra.dart';
import 'modelo_midia.dart';

part 'modelo_publicidade.freezed.dart';
part 'modelo_publicidade.g.dart';

@freezed
class ModeloMensagemLetreiro with _$ModeloMensagemLetreiro {
  const ModeloMensagemLetreiro._();

  const factory ModeloMensagemLetreiro({
    required String id,
    required String texto,
    required int ordem,
    @Default(true) bool ativo,
  }) = _ModeloMensagemLetreiro;

  factory ModeloMensagemLetreiro.fromJson(Map<String, dynamic> json) =>
      _$ModeloMensagemLetreiroFromJson(json);

  factory ModeloMensagemLetreiro.deEntidade(MensagemLetreiro entidade) =>
      ModeloMensagemLetreiro(
        id: entidade.id,
        texto: entidade.texto,
        ordem: entidade.ordem,
        ativo: entidade.ativo,
      );

  MensagemLetreiro paraEntidade() => MensagemLetreiro(
        id: id,
        texto: texto,
        ordem: ordem,
        ativo: ativo,
      );
}

@freezed
class ModeloPublicidade with _$ModeloPublicidade {
  const ModeloPublicidade._();

  const factory ModeloPublicidade({
    @Default(false) bool ativa,
    @Default(FormatoPublicidade.carrossel)
    @JsonKey(unknownEnumValue: FormatoPublicidade.carrossel)
    FormatoPublicidade formato,
    @Default([]) List<ModeloMidia> banners,
    @Default(6) int intervaloSegundos,
    @Default(TransicaoCarrossel.suave)
    @JsonKey(unknownEnumValue: TransicaoCarrossel.suave)
    TransicaoCarrossel transicao,
    @Default([]) List<ModeloMensagemLetreiro> mensagens,
    @Default(VelocidadeLetreiro.normal)
    @JsonKey(unknownEnumValue: VelocidadeLetreiro.normal)
    VelocidadeLetreiro velocidade,
    @Default('•') String separador,
    ModeloMidia? midiaParceiro,
  }) = _ModeloPublicidade;

  factory ModeloPublicidade.fromJson(Map<String, dynamic> json) =>
      _$ModeloPublicidadeFromJson(json);

  factory ModeloPublicidade.deEntidade(PublicidadeBarra entidade) =>
      ModeloPublicidade(
        ativa: entidade.ativa,
        formato: entidade.formato,
        banners:
            entidade.banners.map((b) => ModeloMidia.deEntidade(b)).toList(),
        intervaloSegundos: entidade.intervaloSegundos,
        transicao: entidade.transicao,
        mensagens: entidade.mensagens
            .map((m) => ModeloMensagemLetreiro.deEntidade(m))
            .toList(),
        velocidade: entidade.velocidade,
        separador: entidade.separador,
        midiaParceiro: entidade.midiaParceiro == null
            ? null
            : ModeloMidia.deEntidade(entidade.midiaParceiro!),
      );

  PublicidadeBarra paraEntidade() => PublicidadeBarra(
        ativa: ativa,
        formato: formato,
        banners: banners.map((b) => b.paraEntidade()).toList(),
        intervaloSegundos: intervaloSegundos,
        transicao: transicao,
        mensagens: mensagens.map((m) => m.paraEntidade()).toList(),
        velocidade: velocidade,
        separador: separador,
        midiaParceiro: midiaParceiro?.paraEntidade(),
      );
}
