import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_tema_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:constel_pay/nucleo/configuracao/ambiente.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RepositorioConfiguracaoImpl', () {
    test('devolve padrao quando nada foi salvo', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioConfiguracaoImpl(await SharedPreferences.getInstance());
      final config = await repositorio.obter();
      expect(config, const ConfiguracaoTerminal());
    });

    test('salva e recupera a configuracao', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioConfiguracaoImpl(await SharedPreferences.getInstance());
      const config = ConfiguracaoTerminal(
        nomeRestaurante: 'Durango Burgers',
        ambiente: Ambiente.producao,
        urlBaseProducao: 'https://api.durango.com.br',
        pinHash: 'abc123',
      );
      await repositorio.salvar(config);
      expect(await repositorio.obter(), config);
    });

    test('devolve padrao quando o JSON esta corrompido', () async {
      SharedPreferences.setMockInitialValues(
          {'configuracao_terminal': '{invalido'});
      final repositorio =
          RepositorioConfiguracaoImpl(await SharedPreferences.getInstance());
      expect(await repositorio.obter(), const ConfiguracaoTerminal());
    });
  });

  group('RepositorioTemaImpl', () {
    test('salva e recupera o tema', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioTemaImpl(await SharedPreferences.getInstance());
      const tema =
          TemaPersonalizado(corPrimaria: '#112233', logoPath: '/tmp/logo.png');
      await repositorio.salvar(tema);
      expect(await repositorio.obter(), tema);
    });

    test('devolve padrao quando nada foi salvo', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioTemaImpl(await SharedPreferences.getInstance());
      expect(await repositorio.obter(), const TemaPersonalizado());
    });

    test('a orientacao da tela sobrevive ao round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioTemaImpl(await SharedPreferences.getInstance());
      const tema = TemaPersonalizado(orientacaoTela: OrientacaoTela.horizontal);
      await repositorio.salvar(tema);
      expect((await repositorio.obter()).orientacaoTela,
          OrientacaoTela.horizontal);
    });
  });

  group('faixa de pagamento no tema', () {
    test('a cor da faixa herda a primaria ate ser escolhida', () {
      const herdando = TemaPersonalizado(corPrimaria: '#C0392B');
      expect(herdando.corFaixaEfetiva, '#C0392B');

      const propria =
          TemaPersonalizado(corPrimaria: '#C0392B', corFaixa: '#1B7F3B');
      expect(propria.corFaixaEfetiva, '#1B7F3B');
    });

    test('texto vazio ou so espacos cai no padrao', () {
      expect(const TemaPersonalizado().textoFaixaEfetivo, textoFaixaPadrao);
      expect(const TemaPersonalizado(textoFaixa: '').textoFaixaEfetivo,
          textoFaixaPadrao);
      expect(const TemaPersonalizado(textoFaixa: '   ').textoFaixaEfetivo,
          textoFaixaPadrao);
      expect(
          const TemaPersonalizado(textoFaixa: 'Pague aqui').textoFaixaEfetivo,
          'Pague aqui');
    });

    test('texto com espacos nas pontas chega aparado na faixa', () {
      expect(
          const TemaPersonalizado(textoFaixa: '  Pague aqui  ')
              .textoFaixaEfetivo,
          'Pague aqui');
    });

    test(
        'corFaixa em branco (string vazia ou so espacos) tambem herda a '
        'primaria, igual ao null', () {
      const vazia = TemaPersonalizado(corPrimaria: '#FFD166', corFaixa: '');
      expect(vazia.corFaixaEfetiva, '#FFD166');

      const espacos =
          TemaPersonalizado(corPrimaria: '#FFD166', corFaixa: '   ');
      expect(espacos.corFaixaEfetiva, '#FFD166');

      const nula = TemaPersonalizado(corPrimaria: '#FFD166');
      expect(nula.corFaixaEfetiva, '#FFD166');

      const propria =
          TemaPersonalizado(corPrimaria: '#FFD166', corFaixa: '#1B7F3B');
      expect(propria.corFaixaEfetiva, '#1B7F3B');
    });

    test('os campos da faixa sobrevivem ao round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioTemaImpl(await SharedPreferences.getInstance());
      const tema = TemaPersonalizado(
        corFaixa: '#1B7F3B',
        corTextoFaixa: '#000000',
        textoFaixa: 'Pague aqui',
      );
      await repositorio.salvar(tema);
      expect(await repositorio.obter(), tema);
    });

    test('tema gravado antes da faixa continua carregando', () async {
      // Se um campo da faixa virar obrigatorio no ModeloTemaPersonalizado, o
      // fromJson lanca e o tema da loja volta ao padrao sem aviso nenhum.
      SharedPreferences.setMockInitialValues({
        'tema_personalizado': '{"corPrimaria":"#C0392B",'
            '"corSecundaria":"#FFD166","corFundo":"#F7F7FB",'
            '"corBotoes":"#C0392B"}',
      });
      final repositorio =
          RepositorioTemaImpl(await SharedPreferences.getInstance());
      final tema = await repositorio.obter();
      expect(tema.corPrimaria, '#C0392B',
          reason: 'o tema da loja nao pode ser perdido');
      expect(tema.corFaixa, isNull);
      expect(tema.corFaixaEfetiva, '#C0392B');
      expect(tema.corTextoFaixa, '#FFFFFF');
      expect(tema.textoFaixa, textoFaixaPadrao);
      expect(tema.orientacaoTela, OrientacaoTela.vertical,
          reason: 'tema legado sem o campo carrega com o padrao em pe');
    });
  });
}
