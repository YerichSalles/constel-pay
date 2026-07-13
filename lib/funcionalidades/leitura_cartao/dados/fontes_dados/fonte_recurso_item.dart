import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/resultado.dart';

/// Foto do item para a UI. A foto é enfeite: qualquer falha vira string vazia
/// e a tela cai no emoji — nunca atrapalha o pagamento.
abstract interface class FonteRecursoItem {
  Future<String> obterImagem(String itemId);
}

/// Busca a foto no cadastro da loja (`recurso/item/{itemId}`), que devolve o
/// item completo; o app usa só o campo `imagem` (URL pública no S3).
class FonteRecursoItemApi implements FonteRecursoItem {
  FonteRecursoItemApi(this._clienteApi);

  final ClienteApi _clienteApi;

  /// Cache por id do item: a mesma comanda repete itens e a mesa é relida
  /// várias vezes durante o atendimento.
  final Map<String, String> _cache = {};

  @override
  Future<String> obterImagem(String itemId) async {
    if (itemId.isEmpty) return '';
    final emCache = _cache[itemId];
    if (emCache != null) return emCache;

    final resposta =
        await _clienteApi.get('${ConstantesApp.caminhoRecursoItem}$itemId');
    final url = switch (resposta) {
      Sucesso(:final valor) when valor.data is Map<String, dynamic> =>
        (valor.data as Map<String, dynamic>)['imagem'] as String? ?? '',
      _ => '',
    };
    if (url.isNotEmpty) _cache[itemId] = url;
    return url;
  }
}
