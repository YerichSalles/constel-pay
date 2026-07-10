import 'package:constel_pay/funcionalidades/autenticacao/dados/modelos/requisicao_login_nuvem.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('paraJson monta o payload no formato esperado pela API', () {
    const requisicao = RequisicaoLoginNuvem(
      username: 'admin@audax.com',
      password: 'segredo',
      timezone: 'GMT-03',
      nomeAplicativo: 'Constel Pay',
      versaoAplicativo: '1.0.0',
      dataAplicativo: '2026-07-08',
      caminhoApi: 'http://localhost:3000/api/',
      idDispositivo: 'dev-uuid',
      nomeDispositivo: 'TERMINAL-01',
    );

    expect(requisicao.paraJson(), {
      'username': 'admin@audax.com',
      'password': 'segredo',
      'timezone': 'GMT-03',
      'aplicativo': {
        'nome': 'Constel Pay',
        'versao': '1.0.0',
        'data': '2026-07-08',
      },
      'api': {'caminho': 'http://localhost:3000/api/'},
      'dispositivo': {'id': 'dev-uuid', 'nome': 'TERMINAL-01'},
    });
  });
}
