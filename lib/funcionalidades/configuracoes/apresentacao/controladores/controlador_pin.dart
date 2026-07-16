import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../nucleo/constantes/constantes_app.dart';

part 'controlador_pin.freezed.dart';

@freezed
class EstadoPin with _$EstadoPin {
  const factory EstadoPin({
    @Default('') String digitos,
    String? erro,
    @Default(false) bool concluido,
  }) = _EstadoPin;
}

/// O PIN de acesso às configurações é fixo ([ConstantesApp.pinAcesso]) — não
/// há criação nem armazenamento; o operador apenas digita para verificar.
class ControladorPin extends StateNotifier<EstadoPin> {
  ControladorPin() : super(const EstadoPin());

  void digitar(String digito) {
    if (state.digitos.length >= ConstantesApp.pinAcesso.length) return;
    state = state.copyWith(digitos: '${state.digitos}$digito', erro: null);
  }

  void apagar() {
    if (state.digitos.isEmpty) return;
    state = state.copyWith(
        digitos: state.digitos.substring(0, state.digitos.length - 1),
        erro: null);
  }

  void confirmar() {
    if (state.digitos == ConstantesApp.pinAcesso) {
      state = state.copyWith(concluido: true);
    } else {
      state = state.copyWith(erro: 'PIN incorreto.', digitos: '');
    }
  }
}

final provedorPin =
    StateNotifierProvider.autoDispose<ControladorPin, EstadoPin>(
  (ref) => ControladorPin(),
);
