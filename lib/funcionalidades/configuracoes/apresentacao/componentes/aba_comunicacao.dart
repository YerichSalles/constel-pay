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
    // A linha do estabelecimento aparece/some conforme o UUID é digitado.
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
    return Form(
      key: _formulario,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CampoTexto(rotulo: 'Usuário', controlador: _usuario),
          const SizedBox(height: 14),
          CampoSenha(rotulo: 'Senha', controlador: _senha),
          const SizedBox(height: 20),
          const Text('Dispositivo',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 10),
          CampoTexto(
              rotulo: 'Identificador do dispositivo',
              controlador: _identificador),
          const SizedBox(height: 14),
          CampoTexto(
              rotulo: 'ID do dispositivo (UUID)',
              controlador: _idDispositivo,
              validador: _validarUuid),
          // Somente leitura: o vínculo do dispositivo com o estabelecimento
          // vem do login e só pode ser alterado no servidor web.
          if (_idDispositivo.text.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              estado.nomeEstabelecimento.isEmpty
                  ? 'Estabelecimento: — (obtido após o login)'
                  : 'Estabelecimento: ${estado.nomeEstabelecimento}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CoresApp.textoSecundario),
            ),
          ],
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
          // Só as URLs do ambiente selecionado ficam visíveis; os valores do
          // outro ambiente permanecem nos controladores e continuam salvos.
          const Text('API local (consumo do cartão)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 10),
          if (_ambiente == Ambiente.producao)
            CampoTexto(
                rotulo: 'URL Local Produção',
                controlador: _urlProducao,
                validador: _validarUrl,
                tipoTeclado: TextInputType.url)
          else
            CampoTexto(
                rotulo: 'URL Local Homologação',
                controlador: _urlHomologacao,
                validador: _validarUrl,
                tipoTeclado: TextInputType.url),
          const SizedBox(height: 20),
          const Text('API na nuvem (login)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 10),
          if (_ambiente == Ambiente.producao)
            CampoTexto(
                rotulo: 'URL Nuvem Produção',
                controlador: _urlNuvemProducao,
                validador: _validarUrl,
                tipoTeclado: TextInputType.url)
          else
            CampoTexto(
                rotulo: 'URL Nuvem Homologação',
                controlador: _urlNuvemHomologacao,
                validador: _validarUrl,
                tipoTeclado: TextInputType.url),
          const SizedBox(height: 24),
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
                urlNuvemProducao: _urlNuvemProducao.text,
                urlNuvemHomologacao: _urlNuvemHomologacao.text,
                identificadorDispositivo: _identificador.text,
                idDispositivo: _idDispositivo.text,
              );
            },
          ),
          const SizedBox(height: 12),
          BotaoSecundario(
            rotulo: estado.testandoLocal
                ? 'Testando API Local...'
                : 'Testar API Local',
            aoTocar: estado.testandoLocal ? null : controlador.testarApiLocal,
          ),
          const SizedBox(height: 12),
          BotaoSecundario(
            rotulo: estado.testandoNuvem
                ? 'Testando API Nuvem...'
                : 'Testar API Nuvem',
            aoTocar: estado.testandoNuvem ? null : controlador.testarApiNuvem,
          ),
        ],
      ),
    );
  }
}
