import 'package:freezed_annotation/freezed_annotation.dart';

part 'midia_propaganda.freezed.dart';

enum TipoMidia { imagem, video }

/// Como a midia se acomoda na tela da propaganda.
enum AjusteMidia { automatico, preencher, encaixar, esticar }

/// O que pinta a sobra quando a midia nao cobre a tela toda.
enum FundoMidia { borrado, cor }

/// Qual parte da midia sobrevive ao corte do modo preencher (grade 3x3).
enum AncoraMidia {
  topoEsquerda,
  topo,
  topoDireita,
  esquerda,
  centro,
  direita,
  baseEsquerda,
  base,
  baseDireita,
}

@freezed
class MidiaPropaganda with _$MidiaPropaganda {
  const factory MidiaPropaganda({
    required String id,
    required TipoMidia tipo,
    required String caminho,
    @Default(8) int duracaoSegundos,
    @Default(AjusteMidia.automatico) AjusteMidia ajuste,
    required int ordem,
    @Default(true) bool ativo,
  }) = _MidiaPropaganda;
}
