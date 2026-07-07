import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../nucleo/utils/hasher_pin.dart';
import '../../../../nucleo/utils/validadores.dart';
import '../../dominio/repositorios/repositorio_configuracao.dart';

part 'controlador_pin.freezed.dart';

enum ModoPin { criar, confirmar, verificar }

@freezed
class EstadoPin with _$EstadoPin {
  const factory EstadoPin({
    @Default(ModoPin.verificar) ModoPin modo,
    @Default('') String digitos,
    @Default('') String primeiroPin,
    String? erro,
    @Default(false) bool concluido,
    @Default(true) bool carregando,
  }) = _EstadoPin;
}

class ControladorPin extends StateNotifier<EstadoPin> {
  ControladorPin(this._repositorio) : super(const EstadoPin());

  final RepositorioConfiguracao _repositorio;

  Future<void> iniciar() async {
    final configuracao = await _repositorio.obter();
    state = EstadoPin(
      modo: configuracao.pinHash.isEmpty ? ModoPin.criar : ModoPin.verificar,
      carregando: false,
    );
  }

  void digitar(String digito) {
    if (state.digitos.length >= 6) return;
    state = state.copyWith(digitos: '${state.digitos}$digito', erro: null);
  }

  void apagar() {
    if (state.digitos.isEmpty) return;
    state = state.copyWith(
        digitos: state.digitos.substring(0, state.digitos.length - 1),
        erro: null);
  }

  Future<void> confirmar() async {
    final pin = state.digitos;
    switch (state.modo) {
      case ModoPin.criar:
        if (!Validadores.pinValido(pin)) {
          state = state.copyWith(
              erro: 'O PIN deve ter de 4 a 6 dígitos.', digitos: '');
          return;
        }
        state = state.copyWith(
            modo: ModoPin.confirmar, primeiroPin: pin, digitos: '');
      case ModoPin.confirmar:
        if (pin != state.primeiroPin) {
          state = state.copyWith(
            modo: ModoPin.criar,
            primeiroPin: '',
            digitos: '',
            erro: 'Os PINs não conferem. Tente de novo.',
          );
          return;
        }
        final configuracao = await _repositorio.obter();
        await _repositorio
            .salvar(configuracao.copyWith(pinHash: HasherPin.gerar(pin)));
        state = state.copyWith(concluido: true);
      case ModoPin.verificar:
        final configuracao = await _repositorio.obter();
        if (HasherPin.verificar(pin, configuracao.pinHash)) {
          state = state.copyWith(concluido: true);
        } else {
          state = state.copyWith(erro: 'PIN incorreto.', digitos: '');
        }
    }
  }
}

final provedorPin =
    StateNotifierProvider.autoDispose<ControladorPin, EstadoPin>(
  (ref) => ControladorPin(ref.watch(provedorRepositorioConfiguracao)),
);
