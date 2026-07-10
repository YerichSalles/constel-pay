import 'package:constel_pay/funcionalidades/autenticacao/dados/modelos/resposta_login_nuvem.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const respostaApi = <String, dynamic>{
    'nome': 'Yerich Sales',
    'credencial': 'admin@audax.com',
    'imagem': 'https://x/y.jpg',
    'empresa': {'id': 'emp1', 'nome': "Durango Builder's"},
    'token': 'eyJhbGciOi...',
    'validade': '2026-07-11T00:00:13.000Z',
    'dispositivo': {'id': 'dev1', 'nome': 'NBYERICH CAIXA'},
    'estabelecimento': {
      'id': 'est1',
      'nome': 'Dionísio Torres',
      'estabelecimentoAmbientes': [
        {'id': 'amb1', 'nome': 'Padrão', 'situacao': 1, 'padrao': true},
        {'id': 'amb2', 'nome': 'BAR', 'situacao': 1, 'padrao': false},
      ],
    },
  };

  test('paraEntidade mapeia os campos relevantes', () {
    final sessao = RespostaLoginNuvem.paraEntidade(respostaApi);
    expect(sessao.token, 'eyJhbGciOi...');
    expect(sessao.validade, DateTime.parse('2026-07-11T00:00:13.000Z'));
    expect(sessao.usuario.nome, 'Yerich Sales');
    expect(sessao.usuario.credencial, 'admin@audax.com');
    expect(sessao.empresa.nome, "Durango Builder's");
    expect(sessao.dispositivo.nome, 'NBYERICH CAIXA');
    expect(sessao.estabelecimento.nome, 'Dionísio Torres');
    expect(sessao.estabelecimento.ambientes.length, 2);
    expect(sessao.estabelecimento.ambientes.first.padrao, isTrue);
    expect(sessao.estabelecimento.ambientes[1].nome, 'BAR');
  });

  test('paraEntidade tolera estabelecimento sem ambientes', () {
    final json = Map<String, dynamic>.from(respostaApi)
      ..['estabelecimento'] = {'id': 'est1', 'nome': 'Loja'};
    final sessao = RespostaLoginNuvem.paraEntidade(json);
    expect(sessao.estabelecimento.ambientes, isEmpty);
  });

  test('paraEntidade lanca quando validade esta ausente (fonte captura)', () {
    final json = Map<String, dynamic>.from(respostaApi)..remove('validade');
    expect(() => RespostaLoginNuvem.paraEntidade(json), throwsA(anything));
  });
}
