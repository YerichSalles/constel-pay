enum Ambiente { producao, homologacao }

extension AmbienteRotulo on Ambiente {
  String get rotulo => switch (this) {
        Ambiente.producao => 'Produção',
        Ambiente.homologacao => 'Homologação',
      };
}
