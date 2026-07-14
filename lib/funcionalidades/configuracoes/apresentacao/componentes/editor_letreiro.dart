import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/estilos_texto.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/feedback/estado_vazio.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../propaganda/dominio/entidades/publicidade_barra.dart';
import '../../dominio/entidades/tema_personalizado.dart';
import 'secao_configuracoes.dart';

/// Editor do formato "Letreiro de mensagens" (1B). Controlado: recebe o
/// rascunho da publicidade + tema (só leitura, herdado da Aparência) +
/// callbacks, sem estado próprio de domínio.
class EditorLetreiro extends StatelessWidget {
  const EditorLetreiro({
    super.key,
    required this.publicidade,
    required this.tema,
    required this.aoAdicionarMensagem,
    required this.aoEditarMensagem,
    required this.aoAlternarMensagem,
    required this.aoMoverMensagem,
    required this.aoRemoverMensagem,
    required this.aoDefinirVelocidade,
    required this.aoDefinirSeparador,
    required this.aoAjustarAparencia,
  });

  final PublicidadeBarra publicidade;
  final TemaPersonalizado tema;
  final ValueChanged<String> aoAdicionarMensagem;
  final void Function(String id, String texto) aoEditarMensagem;
  final ValueChanged<String> aoAlternarMensagem;
  final void Function(String id, int delta) aoMoverMensagem;
  final ValueChanged<String> aoRemoverMensagem;
  final ValueChanged<VelocidadeLetreiro> aoDefinirVelocidade;
  final ValueChanged<String> aoDefinirSeparador;
  final VoidCallback aoAjustarAparencia;

  static const Map<VelocidadeLetreiro, String> _rotulosVelocidade = {
    VelocidadeLetreiro.lenta: 'Lenta',
    VelocidadeLetreiro.normal: 'Normal',
    VelocidadeLetreiro.rapida: 'Rápida',
  };

  Widget _rotulo(String texto) => Text(texto,
      style: const TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario));

  Future<void> _abrirDialogo(BuildContext context,
      {MensagemLetreiro? mensagem}) async {
    final texto = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoMensagem(textoInicial: mensagem?.texto),
    );
    if (texto == null) return;
    if (mensagem == null) {
      aoAdicionarMensagem(texto);
    } else {
      aoEditarMensagem(mensagem.id, texto);
    }
  }

  Widget _cardMensagem(BuildContext context, MensagemLetreiro mensagem) {
    return Container(
      key: ValueKey(mensagem.id),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CoresApp.bordaCard),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(mensagem.texto,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(fontSize: 13)),
          ),
          Tooltip(
            message: 'Editar',
            child: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => _abrirDialogo(context, mensagem: mensagem)),
          ),
          Tooltip(
            message: 'Mover para cima',
            child: IconButton(
                icon: const Icon(Icons.arrow_upward, size: 18),
                onPressed: () => aoMoverMensagem(mensagem.id, -1)),
          ),
          Tooltip(
            message: 'Mover para baixo',
            child: IconButton(
                icon: const Icon(Icons.arrow_downward, size: 18),
                onPressed: () => aoMoverMensagem(mensagem.id, 1)),
          ),
          Tooltip(
            message: 'Ativar ou desativar',
            child: Switch(
                value: mensagem.ativo,
                onChanged: (_) => aoAlternarMensagem(mensagem.id)),
          ),
          Tooltip(
            message: 'Remover',
            child: IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: CoresApp.erro, size: 20),
              onPressed: () => aoRemoverMensagem(mensagem.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bolinhaCor(String hex) => Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: TemaConstel.corDeHex(hex, CoresApp.primariaPadrao),
          border: Border.all(color: CoresApp.bordaCard),
        ),
      );

  Widget _estiloVisual() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CoresApp.lilasClaro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estilo visual',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 2),
          _rotulo('Fonte e cores herdadas da aba Aparência.'),
          const SizedBox(height: 8),
          Text('Fonte: ${tema.fonte}',
              style: EstilosTexto.estilo(
                  tema.fonte,
                  const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600))),
          const SizedBox(height: 6),
          Row(children: [
            _bolinhaCor(tema.corPrimaria),
            Text('Cor principal: ${tema.corPrimaria}',
                style: const TextStyle(fontSize: 12)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            _bolinhaCor(tema.corSecundaria),
            Text('Cor secundária: ${tema.corSecundaria}',
                style: const TextStyle(fontSize: 12)),
          ]),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero),
              onPressed: aoAjustarAparencia,
              child: const Text('Ajustar aparência'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final corSecundaria =
        TemaConstel.corDeHex(tema.corSecundaria, CoresApp.secundariaPadrao);
    final mensagens = publicidade.mensagens;
    return SecaoConfiguracoes(
      titulo: 'Letreiro de mensagens',
      descricao: 'Crie avisos e divulgações sem precisar produzir imagens.',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mensagens',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 8),
          if (mensagens.isEmpty)
            const EstadoVazio(
                emoji: '📢', titulo: 'Nenhum conteúdo configurado.')
          else
            ...mensagens.map((m) => _cardMensagem(context, m)),
          const SizedBox(height: 8),
          BotaoSecundario(
              rotulo: '+ Adicionar mensagem',
              aoTocar: () => _abrirDialogo(context)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                _rotulo('Velocidade'),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<VelocidadeLetreiro>(
                    value: publicidade.velocidade,
                    isDense: true,
                    items: [
                      for (final v in VelocidadeLetreiro.values)
                        DropdownMenuItem(
                            value: v, child: Text(_rotulosVelocidade[v]!)),
                    ],
                    onChanged: (novo) {
                      if (novo != null) aoDefinirVelocidade(novo);
                    },
                  ),
                ),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                _rotulo('Separador'),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: publicidade.separador,
                    isDense: true,
                    items: [
                      for (final s in separadoresLetreiro)
                        DropdownMenuItem(
                          value: s,
                          child: Text(s,
                              style: TextStyle(
                                  color: corSecundaria,
                                  fontWeight: FontWeight.w700)),
                        ),
                    ],
                    onChanged: (novo) {
                      if (novo != null) aoDefinirSeparador(novo);
                    },
                  ),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          _estiloVisual(),
        ],
      ),
    );
  }
}

/// Diálogo de criação/edição de mensagem do letreiro, com contador nativo
/// de caracteres (via [TextFormField.maxLength]).
class _DialogoMensagem extends StatefulWidget {
  const _DialogoMensagem({this.textoInicial});

  final String? textoInicial;

  @override
  State<_DialogoMensagem> createState() => _DialogoMensagemState();
}

class _DialogoMensagemState extends State<_DialogoMensagem> {
  late final TextEditingController _controlador =
      TextEditingController(text: widget.textoInicial ?? '');
  late bool _valido = _controlador.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
          widget.textoInicial == null ? 'Nova mensagem' : 'Editar mensagem',
          style: const TextStyle(fontWeight: FontWeight.w800)),
      content: TextFormField(
        controller: _controlador,
        maxLength: limiteMensagemLetreiro,
        maxLines: 2,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Mensagem'),
        onChanged: (valor) => setState(() => _valido = valor.trim().isNotEmpty),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _valido
              ? () => Navigator.of(context).pop(_controlador.text)
              : null,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
