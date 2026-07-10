import 'package:constel_pay/funcionalidades/autenticacao/dados/modelos/resposta_login_nuvem.dart';
import 'package:flutter_test/flutter_test.dart';

// JWT real capturado do log de `POST auth/login`.
// Claim exp = 1783812111 -> 2026-07-11T23:21:51Z.
const _token =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c3VhcmlvIjp7ImlkIjoiODVhODNhZmItM2M4MS00Y2RkLWE2YWEtMTU3NTg1NjRkODQxIiwibm9tZSI6IlllcmljaCBTYWxlcyIsImltYWdlbSI6Imh0dHBzOi8vczMuYW1hem9uYXdzLmNvbS9hdGxhcy5jb25zdGVsLmNsb3VkL2ZpbGVzL2RkZmU0NzliLTliMTEtNGVhMi04ZTMwLWFjZDk4NWRjMmZmOC5qcGcifSwiZW1wcmVzYSI6eyJpZCI6IjBkMTU0MmUxLTcxZmQtNDBmOS1iMWY3LWFlMDBhYjA4NjI2YyIsIm5vbWUiOiJEdXJhbmdvIEJ1aWxkZXIncyJ9LCJkaXNwb3NpdGl2byI6eyJpZCI6ImJlN2I1YjNmLTJjZjEtNGU3OC1iYjAyLWZkY2RkYjcyNzY4YiIsIm5vbWUiOiJOQllFUklDSCBDQUlYQSJ9LCJlc3RhYmVsZWNpbWVudG8iOnsiaWQiOiJmZTViNDIyZS1iZmIyLTQzMjgtODNkNC03ODc2MDIwYWNlZjkiLCJub21lIjoiRGlvbsOtc2lvIFRvcnJlcyJ9LCJmdXNvIjoiR01ULTAzIiwiaWF0IjoxNzgzNjM5MzExLCJleHAiOjE3ODM4MTIxMTF9.50n8zdd69zfxTWBgflX23w0uUbe0uyReP3C_efUY3xw';

void main() {
  final respostaApi = <String, dynamic>{
    'usuario': {
      'id': '85a83afb-3c81-4cdd-a6aa-15758564d841',
      'nome': 'Yerich Sales',
      'imagem': 'https://x/y.jpg',
    },
    'empresa': {'id': 'emp1', 'nome': "Durango Builder's"},
    'dispositivo': {'id': 'dev1', 'nome': 'NBYERICH CAIXA'},
    'estabelecimento': {'id': 'est1', 'nome': 'Dionísio Torres'},
    'fuso': 'GMT-03',
    'token': _token,
  };

  test('paraEntidade mapeia os campos relevantes da resposta real', () {
    final sessao = RespostaLoginNuvem.paraEntidade(respostaApi);
    expect(sessao.token, _token);
    expect(sessao.usuario.nome, 'Yerich Sales');
    expect(sessao.usuario.imagem, 'https://x/y.jpg');
    expect(sessao.empresa.nome, "Durango Builder's");
    expect(sessao.dispositivo.nome, 'NBYERICH CAIXA');
    expect(sessao.estabelecimento.nome, 'Dionísio Torres');
    expect(sessao.estabelecimento.ambientes, isEmpty);
  });

  test('validade é derivada do claim exp do JWT', () {
    final sessao = RespostaLoginNuvem.paraEntidade(respostaApi);
    expect(sessao.validade, DateTime.utc(2026, 7, 11, 23, 21, 51));
    expect(sessao.validade.isUtc, isTrue);
  });

  test('paraEntidade mapeia ambientes quando presentes', () {
    final json = Map<String, dynamic>.from(respostaApi)
      ..['estabelecimento'] = {
        'id': 'est1',
        'nome': 'Loja',
        'estabelecimentoAmbientes': [
          {'id': 'amb1', 'nome': 'Padrão', 'padrao': true},
          {'id': 'amb2', 'nome': 'BAR', 'padrao': false},
        ],
      };
    final sessao = RespostaLoginNuvem.paraEntidade(json);
    expect(sessao.estabelecimento.ambientes.length, 2);
    expect(sessao.estabelecimento.ambientes.first.padrao, isTrue);
    expect(sessao.estabelecimento.ambientes[1].nome, 'BAR');
  });

  test('paraEntidade lança quando o token é inválido (fonte captura)', () {
    final json = Map<String, dynamic>.from(respostaApi)..['token'] = 'abc';
    expect(() => RespostaLoginNuvem.paraEntidade(json), throwsA(anything));
  });
}
