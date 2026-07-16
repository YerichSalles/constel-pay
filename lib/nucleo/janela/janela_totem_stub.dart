/// Implementação vazia para plataformas sem `dart:io` (ex.: web), onde não
/// há janela nativa para configurar. O import condicional em
/// [servico_janela_totem] escolhe entre este stub e a versão io.
Future<void> configurarJanelaWindowsTotem() async {}
