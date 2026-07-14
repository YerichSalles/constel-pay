import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';
import '../../../propaganda/dominio/entidades/publicidade_barra.dart';
import '../../dominio/entidades/tema_personalizado.dart';
import '../controladores/controlador_publicidade.dart';
import 'barra_acoes_aparencia.dart';
import 'cartao_formato_publicidade.dart';
import 'dialogo_ajuste_midia.dart';
import 'editor_carrossel.dart';
import 'editor_letreiro.dart';
import 'editor_parceiro.dart';
import 'previa_publicidade.dart';
import 'secao_configuracoes.dart';
import 'selecao_midia.dart';

/// Largura mínima para o layout em duas colunas (configurações + prévia
/// fixa ao lado), mesmo limiar usado pela aba Aparência.
const double _larguraDuasColunas = 860;

/// Largura mínima para os 3 cards de formato ficarem lado a lado; abaixo
/// disso empilham.
const double _larguraCardsEmpilhados = 560;

/// Extensões aceitas para banners e mídia do parceiro na barra superior:
/// somente imagem/GIF (vídeo não é suportado nesta entrega).
const List<String> _extensoesBarraSuperior = [
  'jpg',
  'jpeg',
  'png',
  'webp',
  'gif'
];

/// Seção "Barra superior" da aba Propaganda: ativa/desativa a publicidade
/// exibida na barra do atendimento, escolhe o formato (carrossel, letreiro
/// ou parceiro fixo) e edita seu conteúdo, com prévia ao vivo e ciclo de
/// rascunho/aplicar/descartar sobre `provedorPublicidade`.
class SecaoBarraSuperior extends ConsumerStatefulWidget {
  const SecaoBarraSuperior({super.key});

  @override
  ConsumerState<SecaoBarraSuperior> createState() => _SecaoBarraSuperiorState();
}

class _SecaoBarraSuperiorState extends ConsumerState<SecaoBarraSuperior> {
  String _nomeEstabelecimento = '';

  /// Reprodução da prévia é pausável só aqui, para não distrair durante a
  /// edição; começa parada.
  bool _reproduzindo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final configuracao =
          await ref.read(provedorRepositorioConfiguracao).obter();
      if (mounted) {
        setState(() => _nomeEstabelecimento = configuracao.nomeRestaurante);
      }
    });
  }

  Future<void> _adicionarBanners(ControladorPublicidade controlador) async {
    final resultado =
        await escolherECopiarMidias(extensoes: _extensoesBarraSuperior);
    if (resultado.houveFalha && mounted) {
      mostrarSnackbarPadrao(
          context, 'Não foi possível importar um dos arquivos.',
          erro: true);
    }
    if (resultado.copiados.isNotEmpty) {
      controlador.adicionarBanners(resultado.copiados);
    }
  }

  Future<void> _alterarMidiaParceiro(ControladorPublicidade controlador) async {
    final resultado = await escolherECopiarMidias(
        extensoes: _extensoesBarraSuperior, multiplas: false);
    if (resultado.houveFalha && mounted) {
      mostrarSnackbarPadrao(
          context, 'Não foi possível importar um dos arquivos.',
          erro: true);
    }
    if (resultado.copiados.isNotEmpty) {
      controlador.definirMidiaParceiro(resultado.copiados.first);
    }
  }

  /// Abre o mesmo diálogo de ajuste da mídia usado no Conteúdo da tela, mas
  /// travado na orientação horizontal (a barra é sempre uma faixa deitada) e
  /// persistindo só ajuste/âncora/zoom — fundo e rotação não fazem sentido
  /// aqui e ficam ignorados.
  void _abrirAjuste(
    TemaPersonalizado tema,
    MidiaPropaganda midia, {
    required void Function({
      required AjusteMidia ajuste,
      required AncoraMidia ancora,
      required int zoomPercentual,
    }) aoSalvar,
  }) {
    final corTema = TemaConstel.corDeHex(
        tema.corPrimaria, Theme.of(context).colorScheme.primary);
    showDialog<void>(
      context: context,
      builder: (_) => DialogoAjusteMidia(
        midia: midia,
        corTema: corTema,
        orientacao: OrientacaoTela.horizontal,
        aoSalvar: ({
          required AjusteMidia ajuste,
          required FundoMidia fundo,
          required AncoraMidia ancora,
          required int zoomPercentual,
          required int rotacaoGraus,
        }) =>
            aoSalvar(
                ajuste: ajuste, ancora: ancora, zoomPercentual: zoomPercentual),
      ),
    );
  }

  Future<void> _confirmarRemocao({
    required String titulo,
    required String mensagem,
    required VoidCallback aoConfirmar,
  }) async {
    final confirmado = await mostrarDialogoConfirmacao(
      context,
      titulo: titulo,
      mensagem: mensagem,
      confirmar: 'Remover',
      destrutivo: true,
    );
    if (confirmado) aoConfirmar();
  }

  Future<void> _aplicar(ControladorPublicidade controlador) async {
    final aplicado = await controlador.aplicar();
    if (!mounted) return;
    mostrarSnackbarPadrao(
      context,
      aplicado
          ? 'Configurações de propaganda aplicadas com sucesso.'
          : 'Adicione ao menos um conteúdo antes de ativar este formato.',
      erro: !aplicado,
    );
  }

  Future<void> _descartar(ControladorPublicidade controlador) async {
    final confirmado = await mostrarDialogoConfirmacao(
      context,
      titulo: 'Descartar alterações?',
      mensagem: 'As alterações feitas na publicidade da barra superior serão '
          'perdidas.',
      confirmar: 'Descartar',
      destrutivo: true,
    );
    if (confirmado) controlador.descartar();
  }

  Widget _secaoToggle(
      PublicidadeBarra publicidade, ControladorPublicidade controlador) {
    return SecaoConfiguracoes(
      titulo: 'Publicidade na barra superior',
      descricao:
          'Exiba campanhas, eventos, avisos, marcas ou parceiros durante o '
          'atendimento.',
      filho: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Exibir publicidade na barra'),
        value: publicidade.ativa,
        onChanged: controlador.alternarAtiva,
      ),
    );
  }

  Widget _secaoFormatos(
      PublicidadeBarra publicidade, ControladorPublicidade controlador) {
    final cartoes = [
      CartaoFormatoPublicidade(
        codigo: '1A',
        nome: 'Carrossel de banners',
        descricao: 'Alterne automaticamente campanhas, eventos, parceiros e '
            'conteúdos institucionais.',
        complemento: 'Melhor opção para exibir várias artes no mesmo espaço.',
        miniatura: CartaoFormatoPublicidade.miniaturaCarrossel(),
        selecionado: publicidade.formato == FormatoPublicidade.carrossel,
        aoTocar: () =>
            controlador.selecionarFormato(FormatoPublicidade.carrossel),
      ),
      CartaoFormatoPublicidade(
        codigo: '1B',
        nome: 'Letreiro de mensagens',
        descricao:
            'Exiba frases e avisos em movimento sem precisar criar artes.',
        complemento: 'Indicado para eventos, promoções e comunicados rápidos.',
        miniatura: CartaoFormatoPublicidade.miniaturaLetreiro(),
        selecionado: publicidade.formato == FormatoPublicidade.letreiro,
        aoTocar: () =>
            controlador.selecionarFormato(FormatoPublicidade.letreiro),
      ),
      CartaoFormatoPublicidade(
        codigo: '1C',
        nome: 'Espaço fixo de parceiro',
        descricao: 'Exiba uma única imagem, GIF ou vídeo continuamente.',
        complemento:
            'Indicado para publicidade de parceiros ou campanhas prioritárias.',
        miniatura: CartaoFormatoPublicidade.miniaturaParceiro(),
        selecionado: publicidade.formato == FormatoPublicidade.parceiro,
        aoTocar: () =>
            controlador.selecionarFormato(FormatoPublicidade.parceiro),
      ),
    ];
    return SecaoConfiguracoes(
      titulo: 'Formato de exibição',
      filho: LayoutBuilder(
        builder: (context, restricoes) {
          if (restricoes.maxWidth < _larguraCardsEmpilhados) {
            return Column(
              children: [
                for (final cartao in cartoes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: cartao,
                  ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final cartao in cartoes)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: cartao,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _editorAtual(PublicidadeBarra publicidade, TemaPersonalizado tema,
      ControladorPublicidade controlador) {
    switch (publicidade.formato) {
      case FormatoPublicidade.carrossel:
        return EditorCarrossel(
          publicidade: publicidade,
          aoDefinirIntervalo: controlador.definirIntervalo,
          aoDefinirTransicao: controlador.definirTransicao,
          aoAdicionarBanners: () => _adicionarBanners(controlador),
          aoAlternarBanner: controlador.alternarBannerAtivo,
          aoMoverBanner: controlador.moverBanner,
          aoRemoverBanner: (id) => _confirmarRemocao(
            titulo: 'Remover banner?',
            mensagem: 'Este banner deixará de ser exibido na barra superior.',
            aoConfirmar: () => controlador.removerBanner(id),
          ),
          aoAjustarBanner: (midia) => _abrirAjuste(
            tema,
            midia,
            aoSalvar: (
                    {required ajuste,
                    required ancora,
                    required zoomPercentual}) =>
                controlador.ajustarBanner(midia.id,
                    ajuste: ajuste,
                    ancora: ancora,
                    zoomPercentual: zoomPercentual),
          ),
        );
      case FormatoPublicidade.letreiro:
        return EditorLetreiro(
          publicidade: publicidade,
          tema: tema,
          aoAdicionarMensagem: controlador.adicionarMensagem,
          aoEditarMensagem: controlador.editarMensagem,
          aoAlternarMensagem: controlador.alternarMensagemAtiva,
          aoMoverMensagem: controlador.moverMensagem,
          aoRemoverMensagem: (id) => _confirmarRemocao(
            titulo: 'Remover mensagem?',
            mensagem: 'Esta mensagem deixará de ser exibida na barra superior.',
            aoConfirmar: () => controlador.removerMensagem(id),
          ),
          aoDefinirVelocidade: controlador.definirVelocidade,
          aoDefinirSeparador: controlador.definirSeparador,
          aoAjustarAparencia: () =>
              DefaultTabController.maybeOf(context)?.animateTo(1),
        );
      case FormatoPublicidade.parceiro:
        return EditorParceiro(
          publicidade: publicidade,
          aoAlterarMidia: () => _alterarMidiaParceiro(controlador),
          aoRemoverMidia: () => _confirmarRemocao(
            titulo: 'Remover publicidade?',
            mensagem:
                'A publicidade do parceiro deixará de ser exibida na barra '
                'superior.',
            aoConfirmar: controlador.removerMidiaParceiro,
          ),
          aoAjustarMidia: () {
            final midia = publicidade.midiaParceiro;
            if (midia == null) return;
            _abrirAjuste(
              tema,
              midia,
              aoSalvar: (
                      {required ajuste,
                      required ancora,
                      required zoomPercentual}) =>
                  controlador.ajustarMidiaParceiro(
                      ajuste: ajuste,
                      ancora: ancora,
                      zoomPercentual: zoomPercentual),
            );
          },
        );
    }
  }

  Widget _secaoPrevia(PublicidadeBarra publicidade, TemaPersonalizado tema) {
    return PreviaPublicidade(
      publicidade: publicidade,
      tema: tema,
      nomeEstabelecimento: _nomeEstabelecimento,
      logoPath: tema.logoPath,
      reproduzindo: _reproduzindo,
      aoAlternarReproducao: () =>
          setState(() => _reproduzindo = !_reproduzindo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = ref.watch(provedorTema);
    final estado = ref.watch(provedorPublicidade);
    final publicidade = estado.rascunho;
    final controlador = ref.read(provedorPublicidade.notifier);

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (contexto, restricoes) {
              final duasColunas = restricoes.maxWidth >= _larguraDuasColunas;
              final secoes = [
                _secaoToggle(publicidade, controlador),
                const SizedBox(height: 16),
                _secaoFormatos(publicidade, controlador),
                const SizedBox(height: 16),
                _editorAtual(publicidade, tema, controlador),
              ];
              if (!duasColunas) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    ...secoes,
                    const SizedBox(height: 16),
                    _secaoPrevia(publicidade, tema),
                  ],
                );
              }
              // Duas colunas: a prévia fica num painel próprio à direita e
              // permanece visível enquanto a coluna de configurações rola.
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 62,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
                      children: secoes,
                    ),
                  ),
                  Expanded(
                    flex: 38,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(10, 20, 20, 20),
                      child: _secaoPrevia(publicidade, tema),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        BarraAcoesAparencia(
          alteracoesPendentes: estado.pendentes,
          aoRestaurar: () => _descartar(controlador),
          aoAplicar: () => _aplicar(controlador),
          rotuloSecundario: 'Descartar alterações',
        ),
      ],
    );
  }
}
