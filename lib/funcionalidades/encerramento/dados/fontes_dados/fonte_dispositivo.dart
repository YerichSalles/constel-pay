import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';

/// Documento do dispositivo na API da LOJA (`estrutura/dispositivo/<id>`).
/// Traz o cabeçalho fiscal já configurado para o terminal (histórico,
/// operação, moeda, dispositivo, departamento). É a fonte da configuração de
/// faturamento que NÃO depende de venda anterior.
class FonteDispositivo {
  FonteDispositivo(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<Resultado<Map<String, dynamic>>> obter(String id) async {
    final resposta =
        await _clienteApi.get('${ConstantesApp.caminhoDispositivo}/$id');
    try {
      return switch (resposta) {
        Sucesso(:final valor) => Sucesso(valor.data as Map<String, dynamic>),
        Erro(:final falha) => Erro(falha),
      };
    } catch (_) {
      return const Erro(
          FalhaDesconhecida('O documento do dispositivo veio ilegível.'));
    }
  }
}
