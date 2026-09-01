/// Códigos de adquirente do cadastro do retaguarda, os mesmos usados nos
/// outros apps do ecossistema Constel. Só `stone` está integrado ao Constel
/// Pay hoje — os demais ficam documentados para quando uma nova adquirente
/// for implementada. NÃO ativar um valor novo sem confirmar com o time; o
/// enum existe para não inventar código nenhum.
enum CodigoAdquirente {
  iFood(110),
  rede(310),
  stone(320),
  cielo(330),
  getNet(340),
  pagBank(350),
  safraPay(360),
  redeRFAL(310),
  standalone(999);

  const CodigoAdquirente(this.value);

  final int value;
}
