import '../entidades/configuracao_faturamento.dart';

/// Configuração de faturamento fornecida pelo retaguarda (JSON importado nas
/// configurações do terminal). `null` = não configurado — encerramento real
/// fica desabilitado e o fluxo segue apenas com o comprovante local.
abstract interface class RepositorioConfiguracaoFaturamento {
  Future<ConfiguracaoFaturamento?> obter();

  /// Valida e persiste o JSON cru. Lança [FormatException] se o texto não
  /// for JSON válido ou não tiver a estrutura mínima (objetos com `id`).
  Future<void> salvar(String jsonBruto);

  Future<void> remover();
}
