import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/layout/layout_responsivo.dart';
import '../../../../compartilhado/widgets/barra_superior.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../../comprovante/apresentacao/componentes/card_comprovante.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';
import '../../dominio/entidades/mensagem.dart';
import '../../dominio/entidades/tipo_mensagem.dart';
import '../componentes/area_acoes.dart';
import '../componentes/avatar_bot.dart';
import '../componentes/banner_boas_vindas.dart';
import '../componentes/bolha_mensagem.dart';
import '../componentes/card_comanda.dart';
import '../componentes/card_detalhe_comanda.dart';
import '../componentes/card_mesa.dart';
import '../componentes/card_metodos_pagamento.dart';
import '../componentes/card_pix.dart';
import '../componentes/card_scanner.dart';
import '../componentes/card_sucesso.dart';
import '../componentes/indicador_digitando.dart';
import '../controladores/controlador_fluxo_pagamento.dart';
import '../controladores/estado_fluxo_pagamento.dart';

class PaginaChat extends ConsumerStatefulWidget {
  const PaginaChat({super.key});

  @override
  ConsumerState<PaginaChat> createState() => _PaginaChatState();
}

class _PaginaChatState extends ConsumerState<PaginaChat> {
  final ScrollController _rolagem = ScrollController();
  String _nomeRestaurante = 'Constel Pay';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final configuracao =
          await ref.read(provedorRepositorioConfiguracao).obter();
      if (mounted) {
        setState(() => _nomeRestaurante = configuracao.nomeRestaurante);
      }
      await ref.read(provedorFluxoPagamento.notifier).iniciar();
    });
  }

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  void _rolarParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_rolagem.hasClients) {
        _rolagem.jumpTo(_rolagem.position.maxScrollExtent);
      }
    });
  }

  Future<void> _confirmarSaida() async {
    final sair = await mostrarDialogoConfirmacao(
      context,
      titulo: 'Cancelar operação?',
      mensagem: 'O atendimento atual será encerrado e nada será cobrado.',
      confirmar: 'Sim, cancelar',
      cancelar: 'Continuar aqui',
      destrutivo: true,
    );
    if (sair && mounted) {
      ref.read(provedorFluxoPagamento.notifier).novaOperacao();
      context.go('/splash');
    }
  }

  Widget _porTipo(Mensagem mensagem, EstadoFluxoPagamento estado,
      ControladorFluxoPagamento controlador) {
    Widget recuado(Widget filho) => Padding(
        padding: const EdgeInsets.only(left: 42, right: 24), child: filho);
    switch (mensagem.tipo) {
      case TipoMensagem.texto:
        return BolhaMensagem(mensagem: mensagem);
      case TipoMensagem.mesa:
        final mesa = estado.mesa;
        return mesa == null
            ? const SizedBox.shrink()
            : recuado(CardMesa(mesa: mesa));
      case TipoMensagem.leituraCartao:
      case TipoMensagem.comanda:
        final id = mensagem.dados?['comandaId'] as String?;
        final cartao = estado.cartoes.where((c) => c.id == id).firstOrNull;
        if (cartao == null) return const SizedBox.shrink();
        return recuado(
            CardComanda(cartao: cartao, aoVerItens: controlador.verItens));
      case TipoMensagem.detalhe:
        final id = mensagem.dados?['comandaId'] as String?;
        final cartao = estado.cartoes.where((c) => c.id == id).firstOrNull;
        if (cartao == null) return const SizedBox.shrink();
        return recuado(CardDetalheComanda(cartao: cartao));
      case TipoMensagem.scanner:
        return recuado(CardScanner(
          aoEscanear: controlador.lerCartao,
          habilitado: estado.etapa == EtapaFluxo.lendo && !estado.digitando,
        ));
      case TipoMensagem.metodos:
        return recuado(CardMetodosPagamento(
          metodos: const [
            MetodoPagamento.pix,
            MetodoPagamento.credito,
            MetodoPagamento.debito,
          ],
          aoSelecionar: controlador.selecionarMetodo,
          habilitado:
              estado.etapa == EtapaFluxo.escolhaMetodo && !estado.digitando,
        ));
      case TipoMensagem.pix:
        final dados = estado.dadosPix;
        if (dados == null) return const SizedBox.shrink();
        return recuado(CardPix(
          dadosPix: dados,
          copiado: estado.copiado,
          aoCopiar: () {
            Clipboard.setData(ClipboardData(text: dados.copiaCola));
            controlador.marcarCopiado();
          },
          aoConfirmar: controlador.confirmarPagamentoPix,
          habilitado:
              estado.etapa == EtapaFluxo.pixAguardando && !estado.digitando,
        ));
      case TipoMensagem.sucesso:
        return recuado(CardSucesso(
          valorCentavos: mensagem.dados?['valorCentavos'] as int? ?? 0,
          comandas: List<String>.from(
              mensagem.dados?['comandas'] as List? ?? const []),
        ));
      case TipoMensagem.comprovante:
        final dados = mensagem.dados ?? const {};
        return recuado(CardComprovante(
          valorCentavos: dados['valorCentavos'] as int? ?? 0,
          metodoNome: (dados['metodo'] as String? ?? 'pix').toUpperCase(),
          comandas: List<String>.from(dados['comandas'] as List? ?? const []),
          dataHora: DateTime.tryParse(dados['dataHora'] as String? ?? '') ??
              DateTime.now(),
          nomeRestaurante: dados['nomeRestaurante'] as String? ?? '',
          comprovanteId: dados['id'] as String? ?? '',
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorFluxoPagamento);
    final controlador = ref.read(provedorFluxoPagamento.notifier);
    ref.listen(provedorFluxoPagamento.select((e) => e.mensagens.length),
        (_, __) => _rolarParaFim());
    ref.listen(provedorFluxoPagamento.select((e) => e.digitando),
        (_, __) => _rolarParaFim());

    final subtitulo = estado.mesa != null
        ? 'Mesa ${estado.mesa!.numero} · Atendimento online'
        : 'Atendimento online';
    final modo = modoPorLargura(MediaQuery.sizeOf(context).width);

    return Scaffold(
      appBar: BarraSuperior(
        titulo: _nomeRestaurante,
        subtitulo: subtitulo,
        avatar: const AvatarBot(tamanho: 40),
        aoVoltar: _confirmarSaida,
      ),
      body: Column(
        children: [
          if (modo == ModoDispositivo.totem)
            Container(
              width: double.infinity,
              color: CoresApp.textoPrincipal,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🏧 AUTOATENDIMENTO',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5)),
                  Text(_nomeRestaurante.toUpperCase(),
                      style: const TextStyle(
                          color: CoresApp.secundariaPadrao,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5)),
                ],
              ),
            ),
          Expanded(
            child: ConteudoCentralizado(
              filho: ListView(
                controller: _rolagem,
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
                children: [
                  BannerBoasVindas(nomeRestaurante: _nomeRestaurante),
                  ...estado.mensagens.map(
                    (mensagem) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _porTipo(mensagem, estado, controlador),
                    ),
                  ),
                  if (estado.digitando) const IndicadorDigitando(),
                ],
              ),
            ),
          ),
          AreaAcoes(
            estado: estado,
            aoLerOutro: controlador.lerOutroCartao,
            aoIrPagamento: controlador.irParaPagamento,
            aoDefinirGorjeta: controlador.definirGorjeta,
            aoPagarRestante: controlador.pagarRestante,
            aoEncerrar: controlador.encerrar,
            aoNovaOperacao: () {
              controlador.novaOperacao();
              context.go('/splash');
            },
          ),
        ],
      ),
    );
  }
}
