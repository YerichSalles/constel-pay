import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/campo_senha.dart';
import '../../../../compartilhado/widgets/campo_texto.dart';
import '../../../../nucleo/configuracao/ambiente.dart';
import '../../../../nucleo/utils/validadores.dart';
import '../controladores/controlador_configuracoes.dart';

class AbaComunicacao extends ConsumerStatefulWidget {
  const AbaComunicacao({super.key});

  @override
  ConsumerState<AbaComunicacao> createState() => _AbaComunicacaoState();
}

class _AbaComunicacaoState extends ConsumerState<AbaComunicacao> {
  final _formulario = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _senha = TextEditingController();
  final _urlProducao = TextEditingController();
  final _urlHomologacao = TextEditingController();
  Ambiente _ambiente = Ambiente.homologacao;
  bool _preenchido = false;

  @override
  void dispose() {
    _usuario.dispose();
    _senha.dispose();
    _urlProducao.dispose();
    _urlHomologacao.dispose();
    super.dispose();
  }

  String? _validarUrl(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    return Validadores.urlValida(valor)
        ? null
        : 'Informe uma URL válida (http/https).';
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorConfiguracoes);
    final controlador = ref.read(provedorConfiguracoes.notifier);
    if (!estado.carregando && !_preenchido) {
      _usuario.text = estado.usuario;
      _senha.text = estado.senha;
      _urlProducao.text = estado.configuracao.urlBaseProducao;
      _urlHomologacao.text = estado.configuracao.urlBaseHomologacao;
      _ambiente = estado.configuracao.ambiente;
      _preenchido = true;
    }
    return Form(
      key: _formulario,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CampoTexto(rotulo: 'Usuário', controlador: _usuario),
          const SizedBox(height: 14),
          CampoSenha(rotulo: 'Senha', controlador: _senha),
          const SizedBox(height: 20),
          SegmentedButton<Ambiente>(
            segments: Ambiente.values
                .map((a) => ButtonSegment(value: a, label: Text(a.rotulo)))
                .toList(),
            selected: {_ambiente},
            onSelectionChanged: (selecao) =>
                setState(() => _ambiente = selecao.first),
          ),
          const SizedBox(height: 20),
          CampoTexto(
              rotulo: 'URL Base Produção',
              controlador: _urlProducao,
              validador: _validarUrl,
              tipoTeclado: TextInputType.url),
          const SizedBox(height: 14),
          CampoTexto(
              rotulo: 'URL Base Homologação',
              controlador: _urlHomologacao,
              validador: _validarUrl,
              tipoTeclado: TextInputType.url),
          const SizedBox(height: 24),
          BotaoSecundario(
            rotulo: estado.testando ? 'Testando...' : 'Testar conexão',
            aoTocar: estado.testando ? null : controlador.testarConexao,
          ),
          const SizedBox(height: 12),
          BotaoPrimario(
            rotulo: 'Salvar',
            carregando: estado.salvando,
            aoTocar: () {
              if (!(_formulario.currentState?.validate() ?? false)) return;
              controlador.salvarComunicacao(
                usuario: _usuario.text.trim(),
                senha: _senha.text,
                ambiente: _ambiente,
                urlProducao: _urlProducao.text,
                urlHomologacao: _urlHomologacao.text,
              );
            },
          ),
        ],
      ),
    );
  }
}
