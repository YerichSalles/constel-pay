import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/campo_texto.dart';
import 'secao_configuracoes.dart';

/// Configuração do encerramento financeiro: o JSON de faturamento fornecido
/// pelo retaguarda (histórico, operação, moeda, modalidade, resultado,
/// dispositivo e forma/plano/conta por método). Sem essa configuração o
/// terminal NÃO gera fatura — o fluxo segue apenas com o comprovante local.
class SecaoFaturamento extends ConsumerStatefulWidget {
  const SecaoFaturamento({super.key});

  @override
  ConsumerState<SecaoFaturamento> createState() => _SecaoFaturamentoState();
}

class _SecaoFaturamentoState extends ConsumerState<SecaoFaturamento> {
  final _json = TextEditingController();
  String _status = '';
  bool _erro = false;
  bool _configurado = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _json.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final configuracao =
        await ref.read(provedorRepositorioConfiguracaoFaturamento).obter();
    if (!mounted) return;
    setState(() => _configurado = configuracao != null);
  }

  Future<void> _aplicar() async {
    final texto = _json.text.trim();
    if (texto.isEmpty) return;
    try {
      await ref.read(provedorRepositorioConfiguracaoFaturamento).salvar(texto);
      if (!mounted) return;
      setState(() {
        _configurado = true;
        _erro = false;
        _status = 'Configuração de faturamento aplicada.';
        _json.clear();
      });
    } on FormatException catch (excecao) {
      if (!mounted) return;
      setState(() {
        _erro = true;
        _status = excecao.message;
      });
    }
  }

  Future<void> _remover() async {
    await ref.read(provedorRepositorioConfiguracaoFaturamento).remover();
    if (!mounted) return;
    setState(() {
      _configurado = false;
      _erro = false;
      _status = 'Configuração removida. O terminal não gera mais fatura.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SecaoConfiguracoes(
      titulo: 'Faturamento',
      descricao: 'Habilita o encerramento real da comanda (fatura no '
          'retaguarda) após o pagamento. Cole o JSON de faturamento '
          'fornecido pelo retaguarda e aplique.',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _configurado
                ? 'Status: configurado — o encerramento gera fatura.'
                : 'Status: não configurado — sem geração de fatura.',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CoresApp.textoSecundario),
          ),
          const SizedBox(height: 12),
          CampoTexto(
            rotulo: 'JSON de faturamento',
            dica: '{"historico": …, "formasPagamento": {"pix": …}}',
            controlador: _json,
            linhas: 5,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BotaoSecundario(
                    rotulo: 'Aplicar configuração', aoTocar: _aplicar),
              ),
              if (_configurado) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: BotaoSecundario(rotulo: 'Remover', aoTocar: _remover),
                ),
              ],
            ],
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _status,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _erro ? CoresApp.erro : CoresApp.textoSecundario),
            ),
          ],
        ],
      ),
    );
  }
}
