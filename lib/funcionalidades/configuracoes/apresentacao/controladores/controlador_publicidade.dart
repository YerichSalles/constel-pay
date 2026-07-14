import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';
import '../../../propaganda/dominio/entidades/publicidade_barra.dart';
import '../../../propaganda/dominio/repositorios/repositorio_publicidade.dart';

part 'controlador_publicidade.freezed.dart';

@freezed
class EstadoPublicidade with _$EstadoPublicidade {
  const EstadoPublicidade._();
  const factory EstadoPublicidade({
    @Default(PublicidadeBarra()) PublicidadeBarra salva,
    @Default(PublicidadeBarra()) PublicidadeBarra rascunho,
    @Default(true) bool carregando,
  }) = _EstadoPublicidade;

  bool get pendentes => !carregando && rascunho != salva;
}

/// Controla o rascunho de edição da publicidade da barra superior.
///
/// Todo método de edição altera apenas [EstadoPublicidade.rascunho]; o valor
/// [EstadoPublicidade.salva] só muda em [carregar] e em [aplicar].
class ControladorPublicidade extends StateNotifier<EstadoPublicidade> {
  ControladorPublicidade(this._repositorio) : super(const EstadoPublicidade());

  final RepositorioPublicidade _repositorio;

  static const Uuid _uuid = Uuid();

  Future<void> carregar() async {
    final publicidade = await _repositorio.obter();
    state = EstadoPublicidade(
      salva: publicidade,
      rascunho: publicidade,
      carregando: false,
    );
  }

  void editar(PublicidadeBarra novo) {
    state = state.copyWith(rascunho: novo);
  }

  void alternarAtiva(bool valor) =>
      editar(state.rascunho.copyWith(ativa: valor));

  /// Troca o formato exibido; NUNCA limpa banners, mensagens ou parceiro dos
  /// outros formatos — cada um mantém seus próprios dados ao alternar.
  void selecionarFormato(FormatoPublicidade formato) =>
      editar(state.rascunho.copyWith(formato: formato));

  void definirIntervalo(int segundos) =>
      editar(state.rascunho.copyWith(intervaloSegundos: segundos));

  void definirTransicao(TransicaoCarrossel transicao) =>
      editar(state.rascunho.copyWith(transicao: transicao));

  void definirVelocidade(VelocidadeLetreiro velocidade) =>
      editar(state.rascunho.copyWith(velocidade: velocidade));

  void definirSeparador(String separador) =>
      editar(state.rascunho.copyWith(separador: separador));

  // Banners

  void adicionarBanners(List<String> caminhos) {
    final banners = state.rascunho.banners;
    var proximaOrdem = banners.isEmpty
        ? 1
        : banners.map((b) => b.ordem).reduce((a, b) => a > b ? a : b) + 1;
    final novos = caminhos
        .map((caminho) => MidiaPropaganda(
              id: _uuid.v4(),
              tipo: TipoMidia.imagem,
              caminho: caminho,
              ordem: proximaOrdem++,
            ))
        .toList();
    editar(state.rascunho.copyWith(banners: [...banners, ...novos]));
  }

  void alternarBannerAtivo(String id) {
    editar(state.rascunho.copyWith(banners: [
      for (final banner in state.rascunho.banners)
        banner.id == id ? banner.copyWith(ativo: !banner.ativo) : banner,
    ]));
  }

  void moverBanner(String id, int delta) {
    final movidos = _moverBanners(state.rascunho.banners, id, delta);
    if (movidos != null) editar(state.rascunho.copyWith(banners: movidos));
  }

  void removerBanner(String id) {
    editar(state.rascunho.copyWith(
      banners: state.rascunho.banners.where((b) => b.id != id).toList(),
    ));
  }

  void ajustarBanner(
    String id, {
    required AjusteMidia ajuste,
    required AncoraMidia ancora,
    required int zoomPercentual,
  }) {
    editar(state.rascunho.copyWith(banners: [
      for (final banner in state.rascunho.banners)
        banner.id == id
            ? banner.copyWith(
                ajuste: ajuste, ancora: ancora, zoomPercentual: zoomPercentual)
            : banner,
    ]));
  }

  // Mensagens

  void adicionarMensagem(String texto) {
    final limpo = texto.trim();
    if (limpo.isEmpty) return;
    final mensagens = state.rascunho.mensagens;
    final proximaOrdem = mensagens.isEmpty
        ? 1
        : mensagens.map((m) => m.ordem).reduce((a, b) => a > b ? a : b) + 1;
    final nova =
        MensagemLetreiro(id: _uuid.v4(), texto: limpo, ordem: proximaOrdem);
    editar(state.rascunho.copyWith(mensagens: [...mensagens, nova]));
  }

  void editarMensagem(String id, String texto) {
    final limpo = texto.trim();
    if (limpo.isEmpty) return;
    editar(state.rascunho.copyWith(mensagens: [
      for (final mensagem in state.rascunho.mensagens)
        mensagem.id == id ? mensagem.copyWith(texto: limpo) : mensagem,
    ]));
  }

  void alternarMensagemAtiva(String id) {
    editar(state.rascunho.copyWith(mensagens: [
      for (final mensagem in state.rascunho.mensagens)
        mensagem.id == id
            ? mensagem.copyWith(ativo: !mensagem.ativo)
            : mensagem,
    ]));
  }

  void moverMensagem(String id, int delta) {
    final movidas = _moverMensagens(state.rascunho.mensagens, id, delta);
    if (movidas != null) editar(state.rascunho.copyWith(mensagens: movidas));
  }

  void removerMensagem(String id) {
    editar(state.rascunho.copyWith(
      mensagens: state.rascunho.mensagens.where((m) => m.id != id).toList(),
    ));
  }

  // Parceiro

  /// Substitui a mídia do parceiro (sempre uma só).
  void definirMidiaParceiro(String caminho) {
    editar(state.rascunho.copyWith(
      midiaParceiro: MidiaPropaganda(
        id: _uuid.v4(),
        tipo: TipoMidia.imagem,
        caminho: caminho,
        ordem: 0,
      ),
    ));
  }

  void ajustarMidiaParceiro({
    required AjusteMidia ajuste,
    required AncoraMidia ancora,
    required int zoomPercentual,
  }) {
    final midia = state.rascunho.midiaParceiro;
    if (midia == null) return;
    editar(state.rascunho.copyWith(
      midiaParceiro: midia.copyWith(
          ajuste: ajuste, ancora: ancora, zoomPercentual: zoomPercentual),
    ));
  }

  void removerMidiaParceiro() {
    editar(state.rascunho.copyWith(midiaParceiro: null));
  }

  // Ciclo

  /// Persiste o rascunho como novo valor salvo. Se a publicidade está ativa
  /// mas o formato selecionado não tem conteúdo para exibir, não persiste e
  /// retorna false.
  Future<bool> aplicar() async {
    if (state.rascunho.ativa && !state.rascunho.formatoTemConteudo) {
      return false;
    }
    await _repositorio.salvar(state.rascunho);
    state = state.copyWith(salva: state.rascunho);
    return true;
  }

  void descartar() {
    state = state.copyWith(rascunho: state.salva);
  }

  /// Troca a `ordem` do banner [id] com a do vizinho a [delta] posições
  /// (ordenando antes pela `ordem` atual). Sem efeito se o item não existir
  /// ou o vizinho estiver fora dos limites. Mantém as ordens únicas.
  List<MidiaPropaganda>? _moverBanners(
      List<MidiaPropaganda> banners, String id, int delta) {
    final lista = [...banners]..sort((a, b) => a.ordem.compareTo(b.ordem));
    final indice = lista.indexWhere((item) => item.id == id);
    final destino = indice + delta;
    if (indice < 0 || destino < 0 || destino >= lista.length) return null;
    final ordemA = lista[indice].ordem;
    final ordemB = lista[destino].ordem;
    lista[indice] = lista[indice].copyWith(ordem: ordemB);
    lista[destino] = lista[destino].copyWith(ordem: ordemA);
    lista.sort((a, b) => a.ordem.compareTo(b.ordem));
    return lista;
  }

  /// Mesma semântica de [_moverBanners], para mensagens do letreiro.
  List<MensagemLetreiro>? _moverMensagens(
      List<MensagemLetreiro> mensagens, String id, int delta) {
    final lista = [...mensagens]..sort((a, b) => a.ordem.compareTo(b.ordem));
    final indice = lista.indexWhere((item) => item.id == id);
    final destino = indice + delta;
    if (indice < 0 || destino < 0 || destino >= lista.length) return null;
    final ordemA = lista[indice].ordem;
    final ordemB = lista[destino].ordem;
    lista[indice] = lista[indice].copyWith(ordem: ordemB);
    lista[destino] = lista[destino].copyWith(ordem: ordemA);
    lista.sort((a, b) => a.ordem.compareTo(b.ordem));
    return lista;
  }
}

final provedorPublicidade = StateNotifierProvider.autoDispose<
    ControladorPublicidade, EstadoPublicidade>((ref) {
  final controlador =
      ControladorPublicidade(ref.watch(provedorRepositorioPublicidade));
  controlador.carregar();
  return controlador;
});
