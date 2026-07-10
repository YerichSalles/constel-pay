/// Payload do `POST auth/login` da API de nuvem.
class RequisicaoLoginNuvem {
  const RequisicaoLoginNuvem({
    required this.username,
    required this.password,
    required this.timezone,
    required this.nomeAplicativo,
    required this.versaoAplicativo,
    required this.dataAplicativo,
    required this.caminhoApi,
    required this.idDispositivo,
    required this.nomeDispositivo,
  });

  final String username;
  final String password;
  final String timezone;
  final String nomeAplicativo;
  final String versaoAplicativo;
  final String dataAplicativo;
  final String caminhoApi;
  final String idDispositivo;
  final String nomeDispositivo;

  Map<String, dynamic> paraJson() => {
        'username': username,
        'password': password,
        'timezone': timezone,
        'aplicativo': {
          'nome': nomeAplicativo,
          'versao': versaoAplicativo,
          'data': dataAplicativo,
        },
        'api': {'caminho': caminhoApi},
        'dispositivo': {'id': idDispositivo, 'nome': nomeDispositivo},
      };
}
