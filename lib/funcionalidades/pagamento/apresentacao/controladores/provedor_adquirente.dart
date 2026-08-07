import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dominio/entidades/tipo_adquirente.dart';

/// Adquirente ativa nesta build, como estado do app.
///
/// A flag de build é lida uma única vez, aqui (`TipoAdquirente.doAmbiente`), e
/// o `Provider` guarda o valor. Do resto do código em diante isto é estado
/// normal: nenhuma tela, controlador ou repositório consulta
/// `String.fromEnvironment` por conta própria.
///
/// Nos testes, sobrescreva com `overrideWithValue` para exercitar o
/// comportamento de cada adquirente.
final provedorAdquirente =
    Provider<TipoAdquirente>((ref) => TipoAdquirente.doAmbiente());
