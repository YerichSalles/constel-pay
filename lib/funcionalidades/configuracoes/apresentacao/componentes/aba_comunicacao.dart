import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/campo_senha.dart';
import '../../../../compartilhado/widgets/campo_texto.dart';
import '../../../../nucleo/configuracao/ambiente.dart';
import '../../../../nucleo/utils/validadores.dart';
import '../controladores/controlador_configuracoes.dart';
import 'painel_status_comunicacao.dart';
import 'secao_configuracoes.dart';
import 'secao_faturamento.dart';

/// Largura mínima para o layout em duas colunas (formulário + painel de
/// status fixo ao lado).
const double _larguraDuasColunas = 860;

class AbaComunicacao extends ConsumerStatefulWidget {
  const AbaComunicacao({super.key});

  @override
  ConsumerState<AbaComunicacao> createState() => _AbaComunicacaoState();
}

class _AbaComunicacaoState extends ConsumerState<AbaComunicacao> {
  final _formulario = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _senha = TextEditingController();
  final _identificador = TextEditingController();
  final _idDispositivo = TextEditingController();
  final _urlProducao = TextEditingController();
  final _urlHomologacao = TextEditingController();
  final _urlNuvemProducao = TextEditingController();
  final _urlNuvemHomologacao = TextEditingController();
  Ambiente _ambiente = Ambiente.homologacao;
  bool _preenchido = false;

  @override
  void initState() {
    super.initState();
    // A linha do estabelecimento acompanha o UUID digitado.
    _idDispositivo.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usuario.dispose();
    _senha.dispose();
    _identificador.dispose();
    _idDispositivo.dispose();
    _urlProducao.dispose();
    _urlHomologacao.dispose();
    _urlNuvemProducao.dispose();
    _urlNuvemHomologacao.dispose();
    super.dispose();
  }

  String? _validarUrl(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    return Validadores.urlValida(valor)
        ? null
        : 'Informe uma URL válida (http/https).';
  }

  String? _validarUuid(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    return Validadores.uuidValido(valor)
        ? null
        : 'Informe um UUID válido (8-4-4-4-12).';
  }

  void _salvar(EstadoConfiguracoes estado) {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    ref.read(provedorConfiguracoes.notifier).salvarComunicacao(
          usuario: _usuario.text.trim(),
          senha: _senha.text,
          ambiente: _ambiente,
          urlProducao: _urlProducao.text,
          urlHomologacao: _urlHomologacao.text,
          urlNuvemProducao: _urlNuvemProducao.text,
          urlNuvemHomologacao: _urlNuvemHomologacao.text,
          identificadorDispositivo: _identificador.text,
          idDispositivo: _idDispositivo.text,
        );
  }

  Widget _secaoTerminal(EstadoConfiguracoes estado) {
    return SecaoConfiguracoes(
      titulo: 'Terminal',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Somente leitura: o vínculo do dispositivo com o estabelecimento
          // vem do login e só pode ser alterado no servidor web.
          if (_idDispositivo.text.trim().isNotEmpty) ...[
            Text(
              estado.nomeEstabelecimento.isEmpty
                  ? 'Estabelecimento: — (obtido após o login)'
                  : 'Estabelecimento: ${estado.nomeEstabelecimento}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CoresApp.textoSecundario),
            ),
            const SizedBox(height: 12),
          ],
          CampoTexto(
              rotulo: 'Identificador do terminal', controlador: _identificador),
          const SizedBox(height: 14),
          CampoTexto(
              rotulo: 'ID do dispositivo (UUID)',
              controlador: _idDispositivo,
              validador: _validarUuid),
        ],
      ),
    );
  }

  Widget _secaoAmbiente() {
    return SecaoConfiguracoes(
      titulo: 'Ambiente',
      descricao: 'Define quais URLs o terminal usa para se comunicar.',
      filho: SegmentedButton<Ambiente>(
        segments: Ambiente.values
            .map((a) => ButtonSegment(value: a, label: Text(a.rotulo)))
            .toList(),
        selected: {_ambiente},
        onSelectionChanged: (selecao) =>
            setState(() => _ambiente = selecao.first),
      ),
    );
  }

  Widget _secaoNuvem(EstadoConfiguracoes estado) {
    final controlador = ref.read(provedorConfiguracoes.notifier);
    return SecaoConfiguracoes(
      titulo: 'Autenticação na nuvem',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampoTexto(rotulo: 'Usuário', controlador: _usuario),
          const SizedBox(height: 14),
          CampoSenha(rotulo: 'Senha', controlador: _senha),
          const SizedBox(height: 14),
          // Só a URL do ambiente selecionado fica visível; o valor do outro
          // ambiente permanece no controlador e continua salvo.
          if (_ambiente == Ambiente.producao)
            CampoTexto(
                rotulo: 'URL da API (Produção)',
                controlador: _urlNuvemProducao,
                validador: _validarUrl,
                tipoTeclado: TextInputType.url)
          else
            CampoTexto(
                rotulo: 'URL da API (Homologação)',
                controlador: _urlNuvemHomologacao,
                validador: _validarUrl,
                tipoTeclado: TextInputType.url),
          const SizedBox(height: 14),
          const Text('Status da autenticação',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          LinhaStatusConexao(
            status: estado.statusNuvem,
            rotuloConectado: 'Autenticada',
            detalhe: [
              if (estado.usuarioNuvem.isNotEmpty) estado.usuarioNuvem,
              if (estado.latenciaNuvemMs != null)
                '${estado.latenciaNuvemMs} ms',
            ].join(' · '),
          ),
          const SizedBox(height: 14),
          BotaoSecundario(
            rotulo: estado.testandoNuvem
                ? 'Validando acesso...'
                : 'Validar acesso à nuvem',
            aoTocar: estado.testandoNuvem ? null : controlador.testarApiNuvem,
          ),
        ],
      ),
    );
  }

  Widget _secaoLocal(EstadoConfiguracoes estado) {
    final controlador = ref.read(provedorConfiguracoes.notifier);
    return SecaoConfiguracoes(
      titulo: 'Comunicação local',
      descricao: 'API da loja usada no consumo do cartão.',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_ambiente == Ambiente.producao)
            CampoTexto(
                rotulo: 'URL da API local (Produção)',
                controlador: _urlProducao,
                validador: _validarUrl,
                tipoTeclado: TextInputType.url)
          else
            CampoTexto(
                rotulo: 'URL da API local (Homologação)',
                controlador: _urlHomologacao,
                validador: _validarUrl,
                tipoTeclado: TextInputType.url),
          const SizedBox(height: 14),
          const Text('Status da conexão',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          LinhaStatusConexao(
            status: estado.statusLocal,
            rotuloConectado: 'Conectada',
            detalhe: estado.latenciaLocalMs != null
                ? '${estado.latenciaLocalMs} ms'
                : null,
          ),
          const SizedBox(height: 14),
          BotaoSecundario(
            rotulo: estado.testandoLocal
                ? 'Testando conexão...'
                : 'Testar conexão local',
            aoTocar: estado.testandoLocal ? null : controlador.testarApiLocal,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorConfiguracoes);
    final controlador = ref.read(provedorConfiguracoes.notifier);
    if (!estado.carregando && !_preenchido) {
      _usuario.text = estado.usuario;
      _senha.text = estado.senha;
      _identificador.text = estado.configuracao.identificadorDispositivo;
      _idDispositivo.text = estado.configuracao.idDispositivo;
      _urlProducao.text = estado.configuracao.urlBaseProducao;
      _urlHomologacao.text = estado.configuracao.urlBaseHomologacao;
      _urlNuvemProducao.text = estado.configuracao.urlNuvemProducao;
      _urlNuvemHomologacao.text = estado.configuracao.urlNuvemHomologacao;
      _ambiente = estado.configuracao.ambiente;
      _preenchido = true;
    }

    final verificando = estado.testandoLocal || estado.testandoNuvem;
    final painel = PainelStatusComunicacao(
      estado: estado,
      ambienteSelecionado: _ambiente,
      aoVerificarTodas: verificando ? null : controlador.verificarTodas,
    );
    final secoes = [
      _secaoTerminal(estado),
      const SizedBox(height: 16),
      _secaoAmbiente(),
      const SizedBox(height: 16),
      _secaoNuvem(estado),
      const SizedBox(height: 16),
      _secaoLocal(estado),
      const SizedBox(height: 16),
      const SecaoFaturamento(),
      const SizedBox(height: 20),
      BotaoPrimario(
        rotulo: 'Salvar',
        carregando: estado.salvando,
        aoTocar: () => _salvar(estado),
      ),
    ];

    return Form(
      key: _formulario,
      child: LayoutBuilder(
        builder: (contexto, restricoes) {
          if (restricoes.maxWidth < _larguraDuasColunas) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                painel,
                const SizedBox(height: 16),
                ...secoes,
              ],
            );
          }
          // Duas colunas: o painel de status fica fixo à direita enquanto o
          // formulário rola.
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
                  child: painel,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
