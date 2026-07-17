import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../dominio/entidades/tema_personalizado.dart';
import 'barra_acoes_aparencia.dart';
import 'campo_cor.dart';
import 'indicador_contraste.dart';
import 'previa_tema.dart';
import 'secao_configuracoes.dart';
import 'seletor_fonte.dart';
import 'seletor_logo.dart';

/// Largura mínima para o layout em duas colunas (configurações + prévia
/// fixa ao lado).
const double _larguraDuasColunas = 860;

class AbaAparencia extends ConsumerStatefulWidget {
  const AbaAparencia({super.key});

  @override
  ConsumerState<AbaAparencia> createState() => _AbaAparenciaState();
}

class _AbaAparenciaState extends ConsumerState<AbaAparencia>
    with AutomaticKeepAliveClientMixin {
  TemaPersonalizado? _rascunho;
  String _nomeEstabelecimento = '';
  late final TextEditingController _textoFaixaPt =
      TextEditingController(text: ref.read(provedorTema).textoFaixa);
  late final TextEditingController _textoFaixaEn =
      TextEditingController(text: ref.read(provedorTema).textoFaixaEn);
  late final TextEditingController _textoFaixaEs =
      TextEditingController(text: ref.read(provedorTema).textoFaixaEs);

  // Mantém o rascunho vivo ao alternar de aba, para o operador não perder
  // alterações ainda não aplicadas.
  @override
  bool get wantKeepAlive => true;

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

  @override
  void dispose() {
    _textoFaixaPt.dispose();
    _textoFaixaEn.dispose();
    _textoFaixaEs.dispose();
    super.dispose();
  }

  void _editar(TemaPersonalizado novo) => setState(() => _rascunho = novo);

  Future<void> _aplicar() async {
    final salvo = ref.read(provedorTema);
    // A logo é gerenciada e persistida à parte pelo SeletorLogo; o rascunho
    // nunca a sobrescreve.
    final novo = (_rascunho ?? salvo).copyWith(logoPath: salvo.logoPath);
    await ref.read(provedorTema.notifier).atualizar(novo);
    if (!mounted) return;
    setState(() => _rascunho = null);
    mostrarSnackbarPadrao(context, 'Alterações aplicadas com sucesso.');
  }

  Future<void> _restaurar() async {
    final confirmado = await mostrarDialogoConfirmacao(
      context,
      titulo: 'Restaurar aparência padrão?',
      mensagem: 'Todas as personalizações de aparência serão substituídas '
          'pelos valores originais do Constel Pay. Nada é salvo até você '
          'tocar em "Aplicar alterações".',
      confirmar: 'Restaurar',
      destrutivo: true,
    );
    if (!confirmado || !mounted) return;
    setState(() => _rascunho =
        TemaPersonalizado(logoPath: ref.read(provedorTema).logoPath));
    _textoFaixaPt.text = textoFaixaPadrao;
    _textoFaixaEn.clear();
    _textoFaixaEs.clear();
  }

  Widget _secaoIdentidade(TemaPersonalizado tema) {
    final nome =
        _nomeEstabelecimento.isEmpty ? 'Estabelecimento' : _nomeEstabelecimento;
    return SecaoConfiguracoes(
      titulo: 'Identidade visual',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SeletorLogo(),
          const SizedBox(height: 16),
          SeletorFonte(
            valor: tema.fonte,
            textoPrevia: '$nome — Terminal de autopagamento',
            aoMudar: (fonte) => _editar(tema.copyWith(fonte: fonte)),
          ),
        ],
      ),
    );
  }

  Widget _secaoCores(TemaPersonalizado tema) {
    return SecaoConfiguracoes(
      titulo: 'Cores gerais',
      descricao: 'Toque na amostra para abrir o seletor ou edite o '
          'hexadecimal.',
      filho: Column(
        children: [
          CampoCor(
            key: const Key('cor_principal'),
            rotulo: 'Cor principal',
            valorHex: tema.corPrimaria,
            aoMudar: (hex) => _editar(tema.copyWith(corPrimaria: hex)),
          ),
          const SizedBox(height: 14),
          CampoCor(
            key: const Key('cor_secundaria'),
            rotulo: 'Cor secundária',
            valorHex: tema.corSecundaria,
            aoMudar: (hex) => _editar(tema.copyWith(corSecundaria: hex)),
          ),
          const SizedBox(height: 14),
          CampoCor(
            rotulo: 'Cor de fundo',
            valorHex: tema.corFundo,
            aoMudar: (hex) => _editar(tema.copyWith(corFundo: hex)),
          ),
          const SizedBox(height: 14),
          CampoCor(
            rotulo: 'Cor dos botões',
            valorHex: tema.corBotoes,
            aoMudar: (hex) => _editar(tema.copyWith(corBotoes: hex)),
          ),
          const SizedBox(height: 14),
          CampoCor(
            rotulo: 'Cor dos textos',
            valorHex: tema.corTexto,
            aoMudar: (hex) => _editar(tema.copyWith(corTexto: hex)),
          ),
        ],
      ),
    );
  }

  Widget _campoTextoFaixa({
    required String rotulo,
    required TextEditingController controlador,
    required ValueChanged<String> aoMudar,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 78,
          child: Text(rotulo,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: TextFormField(
            controller: controlador,
            decoration: const InputDecoration(
              isDense: true,
              hintText: textoFaixaPadrao,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: aoMudar,
          ),
        ),
      ],
    );
  }

  Widget _secaoFaixa(TemaPersonalizado tema) {
    final primaria =
        TemaConstel.corDeHex(tema.corPrimaria, CoresApp.primariaPadrao);
    // Reserva a primaria da propria loja, e nao a padrao hardcoded: assim o
    // indicador nunca avalia uma cor que o totem nao pintaria.
    final faixaFundo = TemaConstel.corDeHex(tema.corFaixaEfetiva, primaria);
    final faixaTexto = TemaConstel.corDeHex(tema.corTextoFaixa, Colors.white);
    return SecaoConfiguracoes(
      titulo: 'Faixa de pagamento',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Texto da faixa por idioma',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          const Text(
            'A faixa mostra o texto do idioma escolhido pelo cliente. '
            'Deixe em branco para usar a chamada padrão traduzida.',
            style: TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
          ),
          const SizedBox(height: 10),
          _campoTextoFaixa(
            rotulo: 'Português',
            controlador: _textoFaixaPt,
            aoMudar: (valor) => _editar(tema.copyWith(textoFaixa: valor)),
          ),
          const SizedBox(height: 10),
          _campoTextoFaixa(
            rotulo: 'English',
            controlador: _textoFaixaEn,
            aoMudar: (valor) => _editar(tema.copyWith(textoFaixaEn: valor)),
          ),
          const SizedBox(height: 10),
          _campoTextoFaixa(
            rotulo: 'Español',
            controlador: _textoFaixaEs,
            aoMudar: (valor) => _editar(tema.copyWith(textoFaixaEs: valor)),
          ),
          const SizedBox(height: 14),
          CampoCor(
            key: const Key('cor_faixa'),
            rotulo: 'Cor da faixa',
            valorHex: tema.corFaixaEfetiva,
            aoMudar: (hex) => _editar(tema.copyWith(corFaixa: hex)),
          ),
          const SizedBox(height: 14),
          CampoCor(
            key: const Key('cor_texto_faixa'),
            rotulo: 'Cor do texto da faixa',
            valorHex: tema.corTextoFaixa,
            aoMudar: (hex) => _editar(tema.copyWith(corTextoFaixa: hex)),
          ),
          const SizedBox(height: 14),
          IndicadorContraste(corFundo: faixaFundo, corTexto: faixaTexto),
        ],
      ),
    );
  }

  Widget _secaoBarraCreditos(TemaPersonalizado tema) {
    return SecaoConfiguracoes(
      titulo: 'Barra inferior',
      descricao: 'A faixa com "Constel Pay" e o site da Constel no rodapé das '
          'telas. O texto ajusta o contraste sozinho conforme a cor '
          'escolhida.',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MergeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _editar(tema.copyWith(
                  pintarBarraCreditosPrincipal:
                      !tema.pintarBarraCreditosPrincipal)),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pintar a barra na tela principal',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Switch(
                    key: const Key('interruptor_barra_creditos_principal'),
                    value: tema.pintarBarraCreditosPrincipal,
                    onChanged: (valor) => _editar(
                        tema.copyWith(pintarBarraCreditosPrincipal: valor)),
                  ),
                ],
              ),
            ),
          ),
          const Text(
            'Desligada, a barra fica transparente sobre a faixa de pagamento.',
            style: TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
          ),
          if (tema.pintarBarraCreditosPrincipal) ...[
            const SizedBox(height: 14),
            CampoCor(
              key: const Key('cor_barra_creditos_principal'),
              rotulo: 'Cor da barra na tela principal',
              valorHex: tema.corBarraCreditosPrincipalEfetiva,
              aoMudar: (hex) =>
                  _editar(tema.copyWith(corBarraCreditosPrincipal: hex)),
            ),
          ],
          const SizedBox(height: 14),
          CampoCor(
            key: const Key('cor_barra_creditos_chat'),
            rotulo: 'Cor da barra na tela do chat',
            valorHex: tema.corBarraCreditosChatEfetiva,
            aoMudar: (hex) => _editar(tema.copyWith(corBarraCreditosChat: hex)),
          ),
        ],
      ),
    );
  }

  Widget _secaoPrevia(TemaPersonalizado tema, String? logoPath) {
    return SecaoConfiguracoes(
      titulo: 'Pré-visualização',
      descricao: 'Veja como as alterações serão exibidas no terminal.',
      filho: PreviaTema(
        tema: tema,
        nomeEstabelecimento: _nomeEstabelecimento,
        logoPath: logoPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final salvo = ref.watch(provedorTema);
    final tema = _rascunho ?? salvo;
    final pendentes = _rascunho != null &&
        _rascunho!.copyWith(logoPath: salvo.logoPath) != salvo;

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (contexto, restricoes) {
              final duasColunas = restricoes.maxWidth >= _larguraDuasColunas;
              final secoes = [
                _secaoIdentidade(tema),
                const SizedBox(height: 16),
                _secaoCores(tema),
                const SizedBox(height: 16),
                _secaoFaixa(tema),
                const SizedBox(height: 16),
                _secaoBarraCreditos(tema),
              ];
              if (!duasColunas) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    ...secoes,
                    const SizedBox(height: 16),
                    _secaoPrevia(tema, salvo.logoPath),
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
                      child: _secaoPrevia(tema, salvo.logoPath),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        BarraAcoesAparencia(
          alteracoesPendentes: pendentes,
          aoRestaurar: _restaurar,
          aoAplicar: _aplicar,
        ),
      ],
    );
  }
}
