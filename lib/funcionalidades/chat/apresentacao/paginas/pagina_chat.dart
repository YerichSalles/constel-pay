import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/layout/layout_responsivo.dart';
import '../../../../compartilhado/widgets/barra_creditos.dart';
import '../../../../compartilhado/widgets/barra_superior.dart';
import '../../../../compartilhado/widgets/captura_leitor_codigo.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../../../compartilhado/widgets/imagem_logo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../comprovante/apresentacao/componentes/card_comprovante.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';
import '../../../propaganda/apresentacao/componentes/publicidade_barra_superior.dart';
import '../../dominio/entidades/mensagem.dart';
import '../../dominio/entidades/tipo_mensagem.dart';
import '../componentes/area_acoes.dart';
import '../componentes/avatar_bot.dart';
import '../componentes/banner_boas_vindas.dart';
import '../componentes/bolha_mensagem.dart';
import '../componentes/card_comanda.dart';
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

  /// Leitura por câmera: só no Android e só se o operador tiver ligado nas
  /// configurações. No totem Windows a leitura é sempre pelo leitor físico.
  bool _cameraDisponivel = false;
  Timer? _retornoAutomatico;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final configuracao =
          await ref.read(provedorRepositorioConfiguracao).obter();
      if (mounted) {
        setState(() {
          _nomeRestaurante = configuracao.nomeRestaurante;
          _cameraDisponivel = configuracao.leituraPorCamera &&
              defaultTargetPlatform == TargetPlatform.android;
        });
      }
      await ref.read(provedorFluxoPagamento.notifier).iniciar();
    });
  }

  @override
  void dispose() {
    _retornoAutomatico?.cancel();
    _rolagem.dispose();
    super.dispose();
  }

  /// Com o comprovante na tela, o terminal volta sozinho ao início depois de
  /// um tempo — o cliente não precisa tocar em nada; "Novo pagamento" só
  /// antecipa a volta.
  void _agendarRetornoAutomatico() {
    _retornoAutomatico?.cancel();
    _retornoAutomatico = Timer(ConstantesApp.duracaoExibicaoComprovante, () {
      if (!mounted) return;
      if (ref.read(provedorFluxoPagamento).etapa != EtapaFluxo.encerramento) {
        return;
      }
      _novaOperacao();
    });
  }

  void _novaOperacao() {
    _retornoAutomatico?.cancel();
    ref.read(provedorFluxoPagamento.notifier).novaOperacao();
    ref.read(provedorIdioma.notifier).resetar();
    context.go('/splash');
  }

  void _rolarParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_rolagem.hasClients) {
        _rolagem.jumpTo(_rolagem.position.maxScrollExtent);
      }
    });
  }

  Future<void> _confirmarSaida() async {
    final t = AppLocalizations.of(context);
    final sair = await mostrarDialogoConfirmacao(
      context,
      titulo: t.cancelOperationTitle,
      mensagem: t.cancelOperationMessage,
      confirmar: t.confirmCancel,
      cancelar: t.continueHere,
      destrutivo: true,
    );
    if (sair && mounted) {
      ref.read(provedorFluxoPagamento.notifier).novaOperacao();
      ref.read(provedorIdioma.notifier).resetar();
      context.go('/splash');
    }
  }

  int? _ultimoScannerId(EstadoFluxoPagamento estado) => estado.mensagens
      .lastWhereOrNull((m) => m.tipo == TipoMensagem.scanner)
      ?.id;

  Widget _porTipo(Mensagem mensagem, EstadoFluxoPagamento estado,
      ControladorFluxoPagamento controlador) {
    Widget recuado(Widget filho) => Padding(
        padding: const EdgeInsets.only(left: 42, right: 24), child: filho);
    switch (mensagem.tipo) {
      case TipoMensagem.texto:
        return BolhaMensagem(mensagem: mensagem);
      case TipoMensagem.leituraCartao:
      case TipoMensagem.comanda:
        final id = mensagem.dados?['comandaId'] as String?;
        final cartao = estado.cartoes.where((c) => c.id == id).firstOrNull;
        if (cartao == null) return const SizedBox.shrink();
        return recuado(CardComanda(cartao: cartao));
      case TipoMensagem.scanner:
        // Cada nova tentativa acrescenta um scanner e os anteriores continuam
        // na conversa. Só o último abre a câmera: sem isso, voltar a ler
        // acenderia a câmera de todas as tentativas passadas ao mesmo tempo.
        final atual = mensagem.id == _ultimoScannerId(estado);
        final lendo = estado.etapa == EtapaFluxo.lendo && !estado.digitando;
        return recuado(CardScanner(
          aoLerPorCamera:
              _cameraDisponivel ? controlador.consultarPorCodigo : null,
          cameraAtiva: atual && lendo,
        ));
      case TipoMensagem.metodos:
        return recuado(CardMetodosPagamento(
          metodos: const [
            MetodoPagamento.credito,
            MetodoPagamento.debito,
            MetodoPagamento.pix,
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

  /// Logo do estabelecimento na barra; sem logo configurada, mantém o
  /// avatar com ícone de pagamento.
  Widget _avatarBarra() {
    final logoPath = ref.watch(provedorTema).logoPath;
    if (logoPath == null || !File(logoPath).existsSync()) {
      return const AvatarBot(tamanho: 40);
    }
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(4),
      child: ImagemLogo(
        caminho: logoPath,
        reserva: const AvatarBot(tamanho: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorFluxoPagamento);
    final controlador = ref.read(provedorFluxoPagamento.notifier);
    ref.listen(provedorFluxoPagamento.select((e) => e.mensagens.length),
        (_, __) => _rolarParaFim());
    ref.listen(provedorFluxoPagamento.select((e) => e.digitando),
        (_, __) => _rolarParaFim());
    ref.listen(provedorFluxoPagamento.select((e) => e.etapa), (_, etapa) {
      if (etapa == EtapaFluxo.encerramento) _agendarRetornoAutomatico();
    });
    final publicidadeSalva = ref.watch(provedorPublicidadeSalva).valueOrNull;
    final corCreditos = TemaConstel.corDeHex(
        ref.watch(provedorTema).corBarraCreditosChatEfetiva,
        Theme.of(context).colorScheme.primary);

    return Scaffold(
      appBar: BarraSuperior(
        titulo: _nomeRestaurante,
        avatar: _avatarBarra(),
        aoVoltar: _confirmarSaida,
        publicidade: (publicidadeSalva?.exibivel ?? false)
            ? const PublicidadeBarraSuperior()
            : null,
      ),
      body: CapturaLeitorCodigo(
        ativo: estado.etapa == EtapaFluxo.lendo && !estado.digitando,
        aoLer: controlador.consultarPorCodigo,
        filho: Column(
          children: [
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
              aoPagarRestante: controlador.pagarRestante,
              aoEncerrar: controlador.encerrar,
              aoNovaOperacao: _novaOperacao,
              aoTentarNovamente: controlador.tentarNovamente,
              aoContinuarComCartoes: controlador.continuarComCartoes,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BarraCreditos(corFundo: corCreditos),
    );
  }
}
