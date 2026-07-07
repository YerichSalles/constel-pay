# Constel Pay — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementar o Constel Pay completo — terminal de autoatendimento para pagamento de consumo em restaurantes, com fluxo conversacional (chat), pagamento Pix mockado, comprovante e configurações administrativas com 5 abas protegidas por PIN.

**Architecture:** Feature First em pt-BR (`aplicativo/`, `nucleo/`, `funcionalidades/`, `compartilhado/`), cada funcionalidade com camadas `dados`/`dominio`/`apresentacao`. Estado com Riverpod (`StateNotifier`), navegação com GoRouter, modelos imutáveis com Freezed. Mocks isolados em `fontes_dados`, troca por API real = trocar provider.

**Tech Stack:** Flutter >= 3.22, Dart >= 3.4, Material 3, flutter_riverpod, go_router, dio, freezed, shared_preferences, flutter_secure_storage, logger, uuid, crypto, qr_flutter, google_fonts (Inter), connectivity_plus, video_player, file_picker, package_info_plus, path_provider.

**Spec:** `docs/superpowers/specs/2026-07-06-constel-pay-design.md`

## Global Constraints

- Flutter `>=3.22.0`, Dart `>=3.4.0 <4.0.0`.
- Nomenclatura 100% em pt-BR: classes, arquivos, variáveis, métodos, pastas (exceto convenções obrigatórias do Flutter/libs).
- PROIBIDO: GetX, Provider (package), MobX, Bloc.
- Valores monetários SEMPRE `int` em centavos. Nunca `double`. Formato exibido: `R$ 0,00`.
- Nenhuma URL hardcoded — URLs vêm de `ConfiguracaoTerminal` (ambiente ativo).
- Nenhum arquivo de código com mais de 600 linhas (limite duro: 700).
- Cores padrão: primária `#5E52D6`, secundária `#FFD166`, fundo `#F7F7FB`, botões `#5E52D6`. Texto principal `#2F2B3D`, secundário `#8A8794`. Fonte: Inter.
- Textos visíveis ao usuário em pt-BR, sem linguagem técnica.
- Sem `print` solto; logging via `registrador` (Logger) que nunca registra senha/token/dados de cartão.
- Idempotência (UUID) em toda operação de pagamento; sem retry automático em POST.
- Todo commit termina com a linha `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>` (segundo `-m`).
- Ao final de cada tarefa: `dart format .`, `flutter analyze` (0 issues), `flutter test` (verde).
- Se alguma versão de pacote conflitar no `flutter pub get`, resolva com `flutter pub add <pacote>` (versão atual) — não remova o pacote.

## Desvios da spec (decisões registradas)

1. **Cores e logo** vivem em `TemaPersonalizado` (RepositorioTema), não em `ConfiguracaoTerminal` — a spec listava nos dois lugares; um só dono evita duplicação.
2. **Chat sem repositório/modelo**: mensagens são estado efêmero do controlador, nada é persistido. Arquivos `repositorio_chat*.dart` e `modelo_mensagem.dart` omitidos.
3. **`card_leitura_cartao.dart` unificado em `card_comanda.dart`** — um único visual de comanda lida (check + itens + subtotal).
4. **`TipoMensagem` ganha o valor `comprovante`** (card de comprovante no encerramento).
5. **Chips "Enviar por e-mail"/"Baixar comprovante" fora do v1** (não há backend); o comprovante é exibido na tela. O mock de pagamento sempre aprova — claramente rotulado como mock.
6. **Modelos JSON** criados apenas para dados persistidos (configuração, tema, mídia, credencial). DTOs de API entram junto com a integração real.
7. **Crédito/Débito aparecem no grid de métodos mas respondem "ainda não disponível"** — só Pix é funcional (conforme spec).
8. **Fonte Inter via `google_fonts`** (download+cache em runtime; em widget tests cai no fallback silenciosamente). Para uso 100% offline, os TTFs podem ser embarcados depois em `assets/google_fonts/`.
9. **Testar conexão = GET na raiz da URL base** (sucesso = resposta HTTP). Nenhum endpoint inventado; "Versão da API" exibe "não disponível (mock)".

---

### Task 1: Scaffold do projeto Flutter

**Files:**
- Delete: `pubspec.yaml`, `lib/main.dart` (esqueletos vazios atuais)
- Create: projeto Flutter completo via `flutter create`, `pubspec.yaml` novo, estrutura de pastas

**Interfaces:**
- Produces: projeto compilável `constel_pay` com todas as dependências resolvidas e árvore de pastas da spec.

- [ ] **Step 1: Remover esqueleto vazio e criar o projeto**

```bash
cd /d/src/audax/pay
rm pubspec.yaml lib/main.dart
flutter create . --project-name constel_pay --org br.com.constel --platforms android,windows --empty
```

Expected: "All done!" e `flutter run` disponível.

- [ ] **Step 2: Substituir o pubspec.yaml completo**

```yaml
name: constel_pay
description: Terminal de autoatendimento para pagamento de consumo em restaurantes.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'
  flutter: '>=3.22.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  go_router: ^14.8.1
  dio: ^5.7.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  shared_preferences: ^2.3.4
  flutter_secure_storage: ^9.2.2
  logger: ^2.5.0
  intl: any
  uuid: ^4.5.1
  connectivity_plus: ^6.1.1
  google_fonts: ^6.2.1
  crypto: ^3.0.6
  qr_flutter: ^4.1.0
  video_player: ^2.9.2
  file_picker: ^8.1.6
  package_info_plus: ^8.1.2
  path_provider: ^2.1.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.9.0
  flutter_lints: ^5.0.0
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
```

- [ ] **Step 3: Resolver dependências**

Run: `flutter pub get`
Expected: "Got dependencies!" sem erros. Se houver conflito de versão, `flutter pub add <pacote>` para a versão compatível atual.

- [ ] **Step 4: Criar a estrutura de pastas**

```bash
cd /d/src/audax/pay
mkdir -p lib/aplicativo/tema \
  lib/nucleo/configuracao lib/nucleo/constantes lib/nucleo/erros lib/nucleo/formatadores lib/nucleo/utils \
  lib/funcionalidades/splash/apresentacao/paginas \
  lib/funcionalidades/propaganda/dados/modelos lib/funcionalidades/propaganda/dados/fontes_dados lib/funcionalidades/propaganda/dados/repositorios \
  lib/funcionalidades/propaganda/dominio/entidades lib/funcionalidades/propaganda/dominio/repositorios \
  lib/funcionalidades/propaganda/apresentacao/paginas lib/funcionalidades/propaganda/apresentacao/componentes lib/funcionalidades/propaganda/apresentacao/controladores \
  lib/funcionalidades/leitura_cartao/dados/fontes_dados lib/funcionalidades/leitura_cartao/dados/repositorios \
  lib/funcionalidades/leitura_cartao/dominio/entidades lib/funcionalidades/leitura_cartao/dominio/repositorios lib/funcionalidades/leitura_cartao/dominio/casos_uso \
  lib/funcionalidades/chat/dominio/entidades \
  lib/funcionalidades/chat/apresentacao/paginas lib/funcionalidades/chat/apresentacao/componentes lib/funcionalidades/chat/apresentacao/controladores \
  lib/funcionalidades/pagamento/dados/fontes_dados lib/funcionalidades/pagamento/dados/repositorios \
  lib/funcionalidades/pagamento/dominio/entidades lib/funcionalidades/pagamento/dominio/repositorios lib/funcionalidades/pagamento/dominio/casos_uso \
  lib/funcionalidades/comprovante/dominio/entidades lib/funcionalidades/comprovante/apresentacao/componentes \
  lib/funcionalidades/configuracoes/dados/modelos lib/funcionalidades/configuracoes/dados/fontes_dados lib/funcionalidades/configuracoes/dados/repositorios \
  lib/funcionalidades/configuracoes/dominio/entidades lib/funcionalidades/configuracoes/dominio/repositorios lib/funcionalidades/configuracoes/dominio/casos_uso \
  lib/funcionalidades/configuracoes/apresentacao/paginas lib/funcionalidades/configuracoes/apresentacao/componentes lib/funcionalidades/configuracoes/apresentacao/controladores \
  lib/compartilhado/widgets lib/compartilhado/layout lib/compartilhado/feedback \
  test/nucleo test/funcionalidades test/compartilhado
```

- [ ] **Step 5: Criar main.dart provisório (substituído na Task 24)**

`lib/main.dart`:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Constel Pay')))));
}
```

- [ ] **Step 6: Validar**

Run: `flutter analyze`
Expected: "No issues found!"

- [ ] **Step 7: Iniciar git e commit inicial**

```bash
cd /d/src/audax/pay
git init -b main
git add -A
git commit -m "chore: scaffold do projeto Flutter constel_pay" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 2: Núcleo — Falha e Resultado

**Files:**
- Create: `lib/nucleo/erros/falha.dart`
- Create: `lib/nucleo/erros/resultado.dart`
- Test: `test/nucleo/erros/resultado_test.dart`

**Interfaces:**
- Produces: `sealed class Falha { final String mensagem; }` com subclasses `FalhaRede`, `FalhaTimeout`, `FalhaServidor`, `FalhaValidacao`, `FalhaDesconhecida` (todas `const`, mensagem padrão em pt-BR exceto `FalhaValidacao` que exige mensagem). `sealed class Resultado<T>` com `Sucesso<T>(T valor)`, `Erro<T>(Falha falha)` e método `R quando<R>({required R Function(T) sucesso, required R Function(Falha) erro})`.

- [ ] **Step 1: Escrever o teste que falha**

`test/nucleo/erros/resultado_test.dart`:

```dart
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Resultado', () {
    test('quando executa o ramo de sucesso', () {
      const Resultado<int> resultado = Sucesso(42);
      final saida = resultado.quando(
        sucesso: (valor) => 'ok $valor',
        erro: (_) => 'erro',
      );
      expect(saida, 'ok 42');
    });

    test('quando executa o ramo de erro com a mensagem da falha', () {
      const Resultado<int> resultado = Erro(FalhaRede());
      final saida = resultado.quando(
        sucesso: (_) => 'ok',
        erro: (falha) => falha.mensagem,
      );
      expect(saida, 'Sem conexão com a internet.');
    });

    test('falhas possuem mensagens padrão em pt-BR', () {
      expect(const FalhaTimeout().mensagem, contains('demorou'));
      expect(const FalhaServidor().mensagem, contains('servidor'));
      expect(const FalhaDesconhecida().mensagem, contains('inesperado'));
      expect(const FalhaValidacao('Campo obrigatório.').mensagem, 'Campo obrigatório.');
    });
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/nucleo/erros/resultado_test.dart`
Expected: FAIL — "Target of URI doesn't exist".

- [ ] **Step 3: Implementar**

`lib/nucleo/erros/falha.dart`:

```dart
sealed class Falha {
  const Falha(this.mensagem);

  final String mensagem;
}

final class FalhaRede extends Falha {
  const FalhaRede([super.mensagem = 'Sem conexão com a internet.']);
}

final class FalhaTimeout extends Falha {
  const FalhaTimeout([super.mensagem = 'O servidor demorou para responder. Tente novamente.']);
}

final class FalhaServidor extends Falha {
  const FalhaServidor([super.mensagem = 'Erro ao comunicar com o servidor.']);
}

final class FalhaValidacao extends Falha {
  const FalhaValidacao(super.mensagem);
}

final class FalhaDesconhecida extends Falha {
  const FalhaDesconhecida([super.mensagem = 'Ocorreu um erro inesperado.']);
}
```

`lib/nucleo/erros/resultado.dart`:

```dart
import 'falha.dart';

sealed class Resultado<T> {
  const Resultado();

  R quando<R>({
    required R Function(T valor) sucesso,
    required R Function(Falha falha) erro,
  }) =>
      switch (this) {
        Sucesso<T>(:final valor) => sucesso(valor),
        Erro<T>(:final falha) => erro(falha),
      };
}

final class Sucesso<T> extends Resultado<T> {
  const Sucesso(this.valor);

  final T valor;
}

final class Erro<T> extends Resultado<T> {
  const Erro(this.falha);

  final Falha falha;
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/nucleo/erros/resultado_test.dart`
Expected: PASS (3 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: nucleo de erros (Falha e Resultado)" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 3: Núcleo — Formatadores, Validadores e Constantes

**Files:**
- Create: `lib/nucleo/formatadores/formatador_moeda.dart`
- Create: `lib/nucleo/formatadores/formatador_data.dart`
- Create: `lib/nucleo/utils/validadores.dart`
- Create: `lib/nucleo/constantes/constantes_app.dart`
- Test: `test/nucleo/formatadores/formatador_moeda_test.dart`
- Test: `test/nucleo/formatadores/formatador_data_test.dart`
- Test: `test/nucleo/utils/validadores_test.dart`

**Interfaces:**
- Produces: `FormatadorMoeda.formatar(int centavos) -> String` (ex.: `31800 -> 'R$ 318,00'`). `FormatadorData.dataHora(DateTime) -> 'dd/MM/yyyy HH:mm'`, `FormatadorData.hora(DateTime) -> 'HH:mm'`. `Validadores.urlValida(String) -> bool`, `Validadores.pinValido(String) -> bool` (4-6 dígitos). `ConstantesApp.tempoInatividade`, `ConstantesApp.duracaoSplash`, `ConstantesApp.atrasoBotPadrao`, `ConstantesApp.chaveUltimaSincronizacao`.

- [ ] **Step 1: Escrever os testes que falham**

`test/nucleo/formatadores/formatador_moeda_test.dart`:

```dart
import 'package:constel_pay/nucleo/formatadores/formatador_moeda.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormatadorMoeda', () {
    test('formata zero', () => expect(FormatadorMoeda.formatar(0), r'R$ 0,00'));
    test('formata centavos', () => expect(FormatadorMoeda.formatar(5), r'R$ 0,05'));
    test('formata valor simples', () => expect(FormatadorMoeda.formatar(31800), r'R$ 318,00'));
    test('formata com separador de milhar', () => expect(FormatadorMoeda.formatar(1234567), r'R$ 12.345,67'));
    test('formata milhões', () => expect(FormatadorMoeda.formatar(100000000), r'R$ 1.000.000,00'));
    test('formata negativo', () => expect(FormatadorMoeda.formatar(-500), r'-R$ 5,00'));
  });
}
```

`test/nucleo/formatadores/formatador_data_test.dart`:

```dart
import 'package:constel_pay/nucleo/formatadores/formatador_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormatadorData', () {
    final data = DateTime(2026, 7, 6, 19, 42);
    test('dataHora', () => expect(FormatadorData.dataHora(data), '06/07/2026 19:42'));
    test('hora', () => expect(FormatadorData.hora(data), '19:42'));
  });
}
```

`test/nucleo/utils/validadores_test.dart`:

```dart
import 'package:constel_pay/nucleo/utils/validadores.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validadores.urlValida', () {
    test('aceita https', () => expect(Validadores.urlValida('https://api.constel.com.br'), isTrue));
    test('aceita http com porta', () => expect(Validadores.urlValida('http://10.0.0.5:8080'), isTrue));
    test('rejeita vazio', () => expect(Validadores.urlValida(''), isFalse));
    test('rejeita sem esquema', () => expect(Validadores.urlValida('api.constel.com.br'), isFalse));
    test('rejeita esquema errado', () => expect(Validadores.urlValida('ftp://x.com'), isFalse));
  });

  group('Validadores.pinValido', () {
    test('aceita 4 digitos', () => expect(Validadores.pinValido('1234'), isTrue));
    test('aceita 6 digitos', () => expect(Validadores.pinValido('123456'), isTrue));
    test('rejeita 3 digitos', () => expect(Validadores.pinValido('123'), isFalse));
    test('rejeita 7 digitos', () => expect(Validadores.pinValido('1234567'), isFalse));
    test('rejeita letras', () => expect(Validadores.pinValido('12a4'), isFalse));
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/nucleo`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/nucleo/formatadores/formatador_moeda.dart` (implementação manual — determinística, sem dependência de locale do intl):

```dart
abstract final class FormatadorMoeda {
  static String formatar(int centavos) {
    final negativo = centavos < 0;
    final absoluto = centavos.abs();
    final inteiro = (absoluto ~/ 100).toString();
    final resto = (absoluto % 100).toString().padLeft(2, '0');
    final agrupado = StringBuffer();
    for (var i = 0; i < inteiro.length; i++) {
      agrupado.write(inteiro[i]);
      final restantes = inteiro.length - i - 1;
      if (restantes > 0 && restantes % 3 == 0) agrupado.write('.');
    }
    return '${negativo ? '-' : ''}R\$ $agrupado,$resto';
  }
}
```

`lib/nucleo/formatadores/formatador_data.dart`:

```dart
import 'package:intl/intl.dart';

abstract final class FormatadorData {
  static String dataHora(DateTime data) => DateFormat('dd/MM/yyyy HH:mm').format(data);

  static String hora(DateTime data) => DateFormat('HH:mm').format(data);
}
```

`lib/nucleo/utils/validadores.dart`:

```dart
abstract final class Validadores {
  static bool urlValida(String valor) {
    final uri = Uri.tryParse(valor.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static bool pinValido(String valor) => RegExp(r'^\d{4,6}$').hasMatch(valor);
}
```

`lib/nucleo/constantes/constantes_app.dart`:

```dart
abstract final class ConstantesApp {
  static const Duration tempoInatividade = Duration(minutes: 2);
  static const Duration duracaoSplash = Duration(seconds: 4);
  static const Duration atrasoBotPadrao = Duration(milliseconds: 650);
  static const Duration duracaoPadraoImagem = Duration(seconds: 8);
  static const String chaveUltimaSincronizacao = 'ultima_sincronizacao';
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/nucleo`
Expected: PASS (todos).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: formatadores de moeda/data, validadores e constantes" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 4: Entidades de domínio e enums (Freezed)

**Files:**
- Create: `lib/nucleo/configuracao/ambiente.dart`
- Create: `lib/funcionalidades/leitura_cartao/dominio/entidades/item_consumo.dart`
- Create: `lib/funcionalidades/leitura_cartao/dominio/entidades/cartao_consumo.dart`
- Create: `lib/funcionalidades/leitura_cartao/dominio/entidades/mesa.dart`
- Create: `lib/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart`
- Create: `lib/funcionalidades/pagamento/dominio/entidades/status_pagamento.dart`
- Create: `lib/funcionalidades/pagamento/dominio/entidades/pagamento.dart`
- Create: `lib/funcionalidades/pagamento/dominio/entidades/dados_pix.dart`
- Create: `lib/funcionalidades/comprovante/dominio/entidades/comprovante.dart`
- Create: `lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart`
- Create: `lib/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart`
- Create: `lib/funcionalidades/configuracoes/dominio/entidades/credencial.dart`
- Create: `lib/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart`
- Create: `lib/funcionalidades/chat/dominio/entidades/tipo_mensagem.dart`
- Create: `lib/funcionalidades/chat/dominio/entidades/mensagem.dart`
- Test: `test/funcionalidades/entidades_test.dart`

**Interfaces:**
- Produces (todas Freezed, imutáveis, `const factory`):
  - `enum Ambiente { producao, homologacao }` + extensão `rotulo` ('Produção'/'Homologação').
  - `ItemConsumo{emoji, nome, quantidade, valorCentavos}` + getter `totalCentavos = quantidade * valorCentavos`.
  - `CartaoConsumo{id, codigo, nome, pessoa, emoji, resumo, itens, subtotalCentavos, selecionado=false, pago=false}`.
  - `enum StatusMesa { aberta, fechada }`; `Mesa{numero, abertoEm, totalComandas, totalCentavos, status}`.
  - `enum MetodoPagamento { pix, credito, debito, tef, pos, voucher, dinheiro }` + extensões `rotulo`, `descricao`, `emoji`.
  - `enum StatusPagamento { aguardando, processando, aprovado, recusado, cancelado, expirado, erro }` + extensão `rotulo`.
  - `Pagamento{id, valorCentavos, gorjetaCentavos, totalCentavos, metodo, status, criadoEm, atualizadoEm, comandaIds}`.
  - `DadosPix{qrCode, copiaCola, valorCentavos, expiraEm}`.
  - `Comprovante{id, pagamentoId, valorCentavos, metodo, comandas, dataHora, nomeRestaurante}`.
  - `enum TipoMidia { imagem, video }`; `MidiaPropaganda{id, tipo, caminho, duracaoSegundos=8, ordem, ativo=true}`.
  - `ConfiguracaoTerminal{nomeRestaurante='Constel Pay', identificadorDispositivo='TERMINAL-01', ambiente=homologacao, urlBaseProducao='', urlBaseHomologacao='', pinHash=''}` + getter `urlBaseAtiva`.
  - `Credencial{usuario, senha}`.
  - `TemaPersonalizado{corPrimaria='#5E52D6', corSecundaria='#FFD166', corFundo='#F7F7FB', corBotoes='#5E52D6', logoPath}`.
  - `enum TipoMensagem { texto, mesa, comanda, detalhe, scanner, metodos, pix, sucesso, leituraCartao, comprovante }`; `enum LadoMensagem { assistente, cliente }`.
  - `Mensagem{id, tipo, lado=assistente, texto?, subtexto?, emoji?, dados?}`.

- [ ] **Step 1: Escrever o teste que falha**

`test/funcionalidades/entidades_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/item_consumo.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/nucleo/configuracao/ambiente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('urlBaseAtiva respeita o ambiente', () {
    const config = ConfiguracaoTerminal(
      urlBaseProducao: 'https://producao',
      urlBaseHomologacao: 'https://homologacao',
    );
    expect(config.urlBaseAtiva, 'https://homologacao');
    expect(config.copyWith(ambiente: Ambiente.producao).urlBaseAtiva, 'https://producao');
  });

  test('ItemConsumo calcula o total da linha', () {
    const item = ItemConsumo(emoji: '🍺', nome: 'Chopp 300ml', quantidade: 2, valorCentavos: 900);
    expect(item.totalCentavos, 1800);
  });

  test('TemaPersonalizado tem as cores padrão da identidade', () {
    const tema = TemaPersonalizado();
    expect(tema.corPrimaria, '#5E52D6');
    expect(tema.corSecundaria, '#FFD166');
    expect(tema.corFundo, '#F7F7FB');
    expect(tema.corBotoes, '#5E52D6');
  });

  test('MetodoPagamento tem os 7 metodos com rotulos', () {
    expect(MetodoPagamento.values, hasLength(7));
    expect(MetodoPagamento.pix.rotulo, 'Pix');
    expect(MetodoPagamento.credito.rotulo, 'Crédito');
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/entidades_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar enums simples**

`lib/nucleo/configuracao/ambiente.dart`:

```dart
enum Ambiente { producao, homologacao }

extension AmbienteRotulo on Ambiente {
  String get rotulo => switch (this) {
        Ambiente.producao => 'Produção',
        Ambiente.homologacao => 'Homologação',
      };
}
```

`lib/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart`:

```dart
enum MetodoPagamento { pix, credito, debito, tef, pos, voucher, dinheiro }

extension MetodoPagamentoInfo on MetodoPagamento {
  String get rotulo => switch (this) {
        MetodoPagamento.pix => 'Pix',
        MetodoPagamento.credito => 'Crédito',
        MetodoPagamento.debito => 'Débito',
        MetodoPagamento.tef => 'TEF',
        MetodoPagamento.pos => 'POS',
        MetodoPagamento.voucher => 'Voucher',
        MetodoPagamento.dinheiro => 'Dinheiro',
      };

  String get descricao => switch (this) {
        MetodoPagamento.pix => 'Aprovação na hora',
        MetodoPagamento.credito => 'Em até 12x',
        MetodoPagamento.debito => 'À vista',
        MetodoPagamento.tef => 'Terminal integrado',
        MetodoPagamento.pos => 'Maquininha',
        MetodoPagamento.voucher => 'Vale-refeição',
        MetodoPagamento.dinheiro => 'No caixa',
      };

  String get emoji => switch (this) {
        MetodoPagamento.pix => '⚡',
        MetodoPagamento.credito => '💳',
        MetodoPagamento.debito => '🏧',
        MetodoPagamento.tef => '🖥️',
        MetodoPagamento.pos => '📟',
        MetodoPagamento.voucher => '🎫',
        MetodoPagamento.dinheiro => '💵',
      };
}
```

`lib/funcionalidades/pagamento/dominio/entidades/status_pagamento.dart`:

```dart
enum StatusPagamento { aguardando, processando, aprovado, recusado, cancelado, expirado, erro }

extension StatusPagamentoRotulo on StatusPagamento {
  String get rotulo => switch (this) {
        StatusPagamento.aguardando => 'Aguardando',
        StatusPagamento.processando => 'Processando',
        StatusPagamento.aprovado => 'Aprovado',
        StatusPagamento.recusado => 'Recusado',
        StatusPagamento.cancelado => 'Cancelado',
        StatusPagamento.expirado => 'Expirado',
        StatusPagamento.erro => 'Erro',
      };
}
```

`lib/funcionalidades/chat/dominio/entidades/tipo_mensagem.dart`:

```dart
enum TipoMensagem {
  texto,
  mesa,
  comanda,
  detalhe,
  scanner,
  metodos,
  pix,
  sucesso,
  leituraCartao,
  comprovante,
}

enum LadoMensagem { assistente, cliente }
```

- [ ] **Step 4: Implementar entidades Freezed**

`lib/funcionalidades/leitura_cartao/dominio/entidades/item_consumo.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_consumo.freezed.dart';

@freezed
class ItemConsumo with _$ItemConsumo {
  const ItemConsumo._();

  const factory ItemConsumo({
    required String emoji,
    required String nome,
    required int quantidade,
    required int valorCentavos,
  }) = _ItemConsumo;

  int get totalCentavos => quantidade * valorCentavos;
}
```

`lib/funcionalidades/leitura_cartao/dominio/entidades/cartao_consumo.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'item_consumo.dart';

part 'cartao_consumo.freezed.dart';

@freezed
class CartaoConsumo with _$CartaoConsumo {
  const factory CartaoConsumo({
    required String id,
    required String codigo,
    required String nome,
    required String pessoa,
    required String emoji,
    required String resumo,
    required List<ItemConsumo> itens,
    required int subtotalCentavos,
    @Default(false) bool selecionado,
    @Default(false) bool pago,
  }) = _CartaoConsumo;
}
```

`lib/funcionalidades/leitura_cartao/dominio/entidades/mesa.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mesa.freezed.dart';

enum StatusMesa { aberta, fechada }

@freezed
class Mesa with _$Mesa {
  const factory Mesa({
    required int numero,
    required DateTime abertoEm,
    required int totalComandas,
    required int totalCentavos,
    @Default(StatusMesa.aberta) StatusMesa status,
  }) = _Mesa;
}
```

`lib/funcionalidades/pagamento/dominio/entidades/pagamento.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'metodo_pagamento.dart';
import 'status_pagamento.dart';

part 'pagamento.freezed.dart';

@freezed
class Pagamento with _$Pagamento {
  const factory Pagamento({
    required String id,
    required int valorCentavos,
    required int gorjetaCentavos,
    required int totalCentavos,
    required MetodoPagamento metodo,
    required StatusPagamento status,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    required List<String> comandaIds,
  }) = _Pagamento;
}
```

`lib/funcionalidades/pagamento/dominio/entidades/dados_pix.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dados_pix.freezed.dart';

@freezed
class DadosPix with _$DadosPix {
  const factory DadosPix({
    required String qrCode,
    required String copiaCola,
    required int valorCentavos,
    required DateTime expiraEm,
  }) = _DadosPix;
}
```

`lib/funcionalidades/comprovante/dominio/entidades/comprovante.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';

part 'comprovante.freezed.dart';

@freezed
class Comprovante with _$Comprovante {
  const factory Comprovante({
    required String id,
    required String pagamentoId,
    required int valorCentavos,
    required MetodoPagamento metodo,
    required List<String> comandas,
    required DateTime dataHora,
    required String nomeRestaurante,
  }) = _Comprovante;
}
```

`lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'midia_propaganda.freezed.dart';

enum TipoMidia { imagem, video }

@freezed
class MidiaPropaganda with _$MidiaPropaganda {
  const factory MidiaPropaganda({
    required String id,
    required TipoMidia tipo,
    required String caminho,
    @Default(8) int duracaoSegundos,
    required int ordem,
    @Default(true) bool ativo,
  }) = _MidiaPropaganda;
}
```

`lib/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../nucleo/configuracao/ambiente.dart';

part 'configuracao_terminal.freezed.dart';

@freezed
class ConfiguracaoTerminal with _$ConfiguracaoTerminal {
  const ConfiguracaoTerminal._();

  const factory ConfiguracaoTerminal({
    @Default('Constel Pay') String nomeRestaurante,
    @Default('TERMINAL-01') String identificadorDispositivo,
    @Default(Ambiente.homologacao) Ambiente ambiente,
    @Default('') String urlBaseProducao,
    @Default('') String urlBaseHomologacao,
    @Default('') String pinHash,
  }) = _ConfiguracaoTerminal;

  String get urlBaseAtiva =>
      ambiente == Ambiente.producao ? urlBaseProducao : urlBaseHomologacao;
}
```

`lib/funcionalidades/configuracoes/dominio/entidades/credencial.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'credencial.freezed.dart';

@freezed
class Credencial with _$Credencial {
  const factory Credencial({
    required String usuario,
    required String senha,
  }) = _Credencial;
}
```

`lib/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tema_personalizado.freezed.dart';

@freezed
class TemaPersonalizado with _$TemaPersonalizado {
  const factory TemaPersonalizado({
    @Default('#5E52D6') String corPrimaria,
    @Default('#FFD166') String corSecundaria,
    @Default('#F7F7FB') String corFundo,
    @Default('#5E52D6') String corBotoes,
    String? logoPath,
  }) = _TemaPersonalizado;
}
```

`lib/funcionalidades/chat/dominio/entidades/mensagem.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'tipo_mensagem.dart';

part 'mensagem.freezed.dart';

@freezed
class Mensagem with _$Mensagem {
  const factory Mensagem({
    required int id,
    required TipoMensagem tipo,
    @Default(LadoMensagem.assistente) LadoMensagem lado,
    String? texto,
    String? subtexto,
    String? emoji,
    Map<String, dynamic>? dados,
  }) = _Mensagem;
}
```

- [ ] **Step 5: Gerar código Freezed**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: "Succeeded" com arquivos `.freezed.dart` gerados.

- [ ] **Step 6: Rodar e ver passar**

Run: `flutter test test/funcionalidades/entidades_test.dart`
Expected: PASS (4 testes).

- [ ] **Step 7: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: entidades de dominio e enums com Freezed" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 5: Tema — CoresApp, EstilosTexto e TemaConstel

**Files:**
- Create: `lib/aplicativo/tema/cores_app.dart`
- Create: `lib/aplicativo/tema/estilos_texto.dart`
- Create: `lib/aplicativo/tema/tema_constel.dart`
- Test: `test/aplicativo/tema_constel_test.dart`

**Interfaces:**
- Consumes: `TemaPersonalizado` (Task 4).
- Produces: `CoresApp` (constantes: `primariaPadrao`, `secundariaPadrao`, `fundoPadrao`, `botoesPadrao`, `textoPrincipal`, `textoSecundario`, `lilasClaro #EEEBFD`, `lilasBolha #ECE7FF`, `bordaCard #F1F0F4`, `sucesso`, `erro`). `TemaConstel.criar(TemaPersonalizado) -> ThemeData`, `TemaConstel.corDeHex(String, Color padrao) -> Color`, `TemaConstel.hexDeCor(Color) -> String`. `EstilosTexto.criarTextTheme(Color) -> TextTheme` (Inter via google_fonts).

- [ ] **Step 1: Escrever o teste que falha**

`test/aplicativo/tema_constel_test.dart`:

```dart
import 'package:constel_pay/aplicativo/tema/cores_app.dart';
import 'package:constel_pay/aplicativo/tema/tema_constel.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TemaConstel.corDeHex', () {
    test('converte hex valido com #', () {
      expect(TemaConstel.corDeHex('#5E52D6', Colors.black), const Color(0xFF5E52D6));
    });
    test('converte hex valido sem #', () {
      expect(TemaConstel.corDeHex('FFD166', Colors.black), const Color(0xFFFFD166));
    });
    test('devolve padrao para hex invalido', () {
      expect(TemaConstel.corDeHex('xyz', CoresApp.primariaPadrao), CoresApp.primariaPadrao);
      expect(TemaConstel.corDeHex('', CoresApp.primariaPadrao), CoresApp.primariaPadrao);
    });
  });

  test('hexDeCor devolve o hex em maiusculas com #', () {
    expect(TemaConstel.hexDeCor(const Color(0xFF5E52D6)), '#5E52D6');
  });

  test('criar aplica as cores personalizadas', () {
    final tema = TemaConstel.criar(const TemaPersonalizado(corPrimaria: '#FF0000', corFundo: '#00FF00'));
    expect(tema.colorScheme.primary, const Color(0xFFFF0000));
    expect(tema.scaffoldBackgroundColor, const Color(0xFF00FF00));
    expect(tema.useMaterial3, isTrue);
  });

  test('criar usa os padroes Constel quando tema vazio', () {
    final tema = TemaConstel.criar(const TemaPersonalizado());
    expect(tema.colorScheme.primary, CoresApp.primariaPadrao);
    expect(tema.scaffoldBackgroundColor, CoresApp.fundoPadrao);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/aplicativo/tema_constel_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/aplicativo/tema/cores_app.dart`:

```dart
import 'package:flutter/material.dart';

abstract final class CoresApp {
  static const Color primariaPadrao = Color(0xFF5E52D6);
  static const Color secundariaPadrao = Color(0xFFFFD166);
  static const Color fundoPadrao = Color(0xFFF7F7FB);
  static const Color botoesPadrao = Color(0xFF5E52D6);
  static const Color textoPrincipal = Color(0xFF2F2B3D);
  static const Color textoSecundario = Color(0xFF8A8794);
  static const Color lilasClaro = Color(0xFFEEEBFD);
  static const Color lilasBolha = Color(0xFFECE7FF);
  static const Color bordaCard = Color(0xFFF1F0F4);
  static const Color sucesso = Color(0xFF2E7D32);
  static const Color erro = Color(0xFFD32F2F);
}
```

`lib/aplicativo/tema/estilos_texto.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class EstilosTexto {
  static TextTheme criarTextTheme(Color corTexto) =>
      GoogleFonts.interTextTheme().apply(bodyColor: corTexto, displayColor: corTexto);
}
```

`lib/aplicativo/tema/tema_constel.dart`:

```dart
import 'package:flutter/material.dart';

import '../../funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'cores_app.dart';
import 'estilos_texto.dart';

abstract final class TemaConstel {
  static Color corDeHex(String hex, Color padrao) {
    final limpo = hex.replaceAll('#', '').trim();
    if (limpo.length != 6) return padrao;
    final valor = int.tryParse(limpo, radix: 16);
    if (valor == null) return padrao;
    return Color(0xFF000000 | valor);
  }

  static String hexDeCor(Color cor) =>
      '#${(cor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  static ThemeData criar(TemaPersonalizado tema) {
    final primaria = corDeHex(tema.corPrimaria, CoresApp.primariaPadrao);
    final secundaria = corDeHex(tema.corSecundaria, CoresApp.secundariaPadrao);
    final fundo = corDeHex(tema.corFundo, CoresApp.fundoPadrao);
    final botoes = corDeHex(tema.corBotoes, CoresApp.botoesPadrao);

    final esquema = ColorScheme.fromSeed(
      seedColor: primaria,
      primary: primaria,
      secondary: secundaria,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fundo,
      textTheme: EstilosTexto.criarTextTheme(CoresApp.textoPrincipal),
      appBarTheme: AppBarTheme(
        backgroundColor: primaria,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: botoes,
          foregroundColor: Colors.white,
          disabledBackgroundColor: botoes.withValues(alpha: .4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: botoes,
          side: BorderSide(color: botoes.withValues(alpha: .5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CoresApp.bordaCard),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CoresApp.bordaCard),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaria, width: 2),
        ),
        labelStyle: const TextStyle(color: CoresApp.textoSecundario),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaria,
        unselectedLabelColor: CoresApp.textoSecundario,
        indicatorColor: primaria,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
```

Nota: se `Color.toARGB32()` não existir na versão do Flutter em uso, substitua por `cor.value` (API antiga) — o teste cobre os dois casos.

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/aplicativo/tema_constel_test.dart`
Expected: PASS (6 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: tema Material 3 (TemaConstel, CoresApp, EstilosTexto)" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 6: Widgets compartilhados

**Files:**
- Create: `lib/compartilhado/widgets/botao_primario.dart`
- Create: `lib/compartilhado/widgets/botao_secundario.dart`
- Create: `lib/compartilhado/widgets/campo_texto.dart`
- Create: `lib/compartilhado/widgets/campo_senha.dart`
- Create: `lib/compartilhado/widgets/cartao.dart`
- Create: `lib/compartilhado/widgets/indicador_carregamento.dart`
- Create: `lib/compartilhado/widgets/dialogo_confirmacao.dart`
- Create: `lib/compartilhado/widgets/barra_superior.dart`
- Create: `lib/compartilhado/widgets/scaffold_padrao.dart`
- Create: `lib/compartilhado/feedback/snackbar_padrao.dart`
- Create: `lib/compartilhado/feedback/estado_vazio.dart`
- Create: `lib/compartilhado/feedback/estado_erro.dart`
- Create: `lib/compartilhado/layout/layout_responsivo.dart`
- Test: `test/compartilhado/widgets_test.dart`

**Interfaces:**
- Consumes: `CoresApp` (Task 5).
- Produces:
  - `BotaoPrimario({rotulo, aoTocar, icone?, carregando=false, expandido=true})`
  - `BotaoSecundario({rotulo, aoTocar, icone?, expandido=true})`
  - `CampoTexto({rotulo, controlador?, dica?, validador?, tipoTeclado?, aoMudar?, habilitado=true})`
  - `CampoSenha({rotulo, controlador?, validador?})` — alterna visibilidade
  - `Cartao({filho, preenchimento=EdgeInsets.all(16), aoTocar?, margem?})` — borda 20px, sombra sutil
  - `IndicadorCarregamento({mensagem?})`
  - `Future<bool> mostrarDialogoConfirmacao(BuildContext, {titulo, mensagem, confirmar='Confirmar', cancelar='Cancelar', destrutivo=false})`
  - `BarraSuperior({titulo, subtitulo?, avatar?, aoVoltar?, acoes?})` implements `PreferredSizeWidget`
  - `ScaffoldPadrao({corpo, barra?, corFundo?})`
  - `mostrarSnackbarPadrao(BuildContext, String mensagem, {bool erro=false})`
  - `EstadoVazio({emoji, titulo, mensagem?, acao?})` / `EstadoErro({mensagem, aoTentarNovamente?})`
  - `enum ModoDispositivo { celular, tablet, totem }`; `ModoDispositivo modoPorLargura(double)` (>=1024 totem, >=600 tablet, senão celular); `ConteudoCentralizado({filho, larguraMaxima=620})`

- [ ] **Step 1: Escrever os testes que falham**

`test/compartilhado/widgets_test.dart`:

```dart
import 'package:constel_pay/compartilhado/feedback/estado_erro.dart';
import 'package:constel_pay/compartilhado/layout/layout_responsivo.dart';
import 'package:constel_pay/compartilhado/widgets/botao_primario.dart';
import 'package:constel_pay/compartilhado/widgets/campo_senha.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget filho) => MaterialApp(home: Scaffold(body: filho));

void main() {
  testWidgets('BotaoPrimario mostra rotulo e dispara callback', (tester) async {
    var tocado = false;
    await tester.pumpWidget(_app(BotaoPrimario(rotulo: 'Pagar', aoTocar: () => tocado = true)));
    expect(find.text('Pagar'), findsOneWidget);
    await tester.tap(find.byType(BotaoPrimario));
    expect(tocado, isTrue);
  });

  testWidgets('BotaoPrimario carregando desabilita o toque', (tester) async {
    var tocado = false;
    await tester.pumpWidget(_app(BotaoPrimario(rotulo: 'Pagar', carregando: true, aoTocar: () => tocado = true)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(BotaoPrimario), warnIfMissed: false);
    expect(tocado, isFalse);
  });

  testWidgets('CampoSenha alterna a visibilidade', (tester) async {
    await tester.pumpWidget(_app(const CampoSenha(rotulo: 'Senha')));
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('EstadoErro mostra mensagem e botao de tentar novamente', (tester) async {
    var tentou = false;
    await tester.pumpWidget(_app(EstadoErro(mensagem: 'Falhou', aoTentarNovamente: () => tentou = true)));
    expect(find.text('Falhou'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    expect(tentou, isTrue);
  });

  test('modoPorLargura aplica os breakpoints', () {
    expect(modoPorLargura(412), ModoDispositivo.celular);
    expect(modoPorLargura(660), ModoDispositivo.tablet);
    expect(modoPorLargura(1200), ModoDispositivo.totem);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/compartilhado/widgets_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar os widgets**

`lib/compartilhado/widgets/botao_primario.dart`:

```dart
import 'package:flutter/material.dart';

class BotaoPrimario extends StatelessWidget {
  const BotaoPrimario({
    super.key,
    required this.rotulo,
    this.aoTocar,
    this.icone,
    this.carregando = false,
    this.expandido = true,
  });

  final String rotulo;
  final VoidCallback? aoTocar;
  final Widget? icone;
  final bool carregando;
  final bool expandido;

  @override
  Widget build(BuildContext context) {
    final filho = carregando
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icone != null) ...[icone!, const SizedBox(width: 10)],
              Flexible(child: Text(rotulo, overflow: TextOverflow.ellipsis)),
            ],
          );
    final botao = ElevatedButton(onPressed: carregando ? null : aoTocar, child: filho);
    return expandido ? SizedBox(width: double.infinity, child: botao) : botao;
  }
}
```

`lib/compartilhado/widgets/botao_secundario.dart`:

```dart
import 'package:flutter/material.dart';

class BotaoSecundario extends StatelessWidget {
  const BotaoSecundario({
    super.key,
    required this.rotulo,
    this.aoTocar,
    this.icone,
    this.expandido = true,
  });

  final String rotulo;
  final VoidCallback? aoTocar;
  final Widget? icone;
  final bool expandido;

  @override
  Widget build(BuildContext context) {
    final botao = OutlinedButton(
      onPressed: aoTocar,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icone != null) ...[icone!, const SizedBox(width: 10)],
          Flexible(child: Text(rotulo, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
    return expandido ? SizedBox(width: double.infinity, child: botao) : botao;
  }
}
```

`lib/compartilhado/widgets/campo_texto.dart`:

```dart
import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.rotulo,
    this.controlador,
    this.dica,
    this.validador,
    this.tipoTeclado,
    this.aoMudar,
    this.habilitado = true,
  });

  final String rotulo;
  final TextEditingController? controlador;
  final String? dica;
  final String? Function(String?)? validador;
  final TextInputType? tipoTeclado;
  final void Function(String)? aoMudar;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      enabled: habilitado,
      keyboardType: tipoTeclado,
      validator: validador,
      onChanged: aoMudar,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(labelText: rotulo, hintText: dica),
    );
  }
}
```

`lib/compartilhado/widgets/campo_senha.dart`:

```dart
import 'package:flutter/material.dart';

class CampoSenha extends StatefulWidget {
  const CampoSenha({super.key, required this.rotulo, this.controlador, this.validador});

  final String rotulo;
  final TextEditingController? controlador;
  final String? Function(String?)? validador;

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _oculto = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controlador,
      obscureText: _oculto,
      validator: widget.validador,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.rotulo,
        suffixIcon: IconButton(
          icon: Icon(_oculto ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _oculto = !_oculto),
        ),
      ),
    );
  }
}
```

`lib/compartilhado/widgets/cartao.dart`:

```dart
import 'package:flutter/material.dart';

import '../../aplicativo/tema/cores_app.dart';

class Cartao extends StatelessWidget {
  const Cartao({
    super.key,
    required this.filho,
    this.preenchimento = const EdgeInsets.all(16),
    this.aoTocar,
    this.margem,
  });

  final Widget filho;
  final EdgeInsetsGeometry preenchimento;
  final VoidCallback? aoTocar;
  final EdgeInsetsGeometry? margem;

  @override
  Widget build(BuildContext context) {
    final borda = BorderRadius.circular(20);
    return Container(
      margin: margem,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borda,
        border: Border.all(color: CoresApp.bordaCard),
        boxShadow: [
          BoxShadow(
            color: CoresApp.textoPrincipal.withValues(alpha: .09),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: aoTocar,
          borderRadius: borda,
          child: Padding(padding: preenchimento, child: filho),
        ),
      ),
    );
  }
}
```

`lib/compartilhado/widgets/indicador_carregamento.dart`:

```dart
import 'package:flutter/material.dart';

import '../../aplicativo/tema/cores_app.dart';

class IndicadorCarregamento extends StatelessWidget {
  const IndicadorCarregamento({super.key, this.mensagem});

  final String? mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (mensagem != null) ...[
            const SizedBox(height: 14),
            Text(
              mensagem!,
              style: const TextStyle(color: CoresApp.textoSecundario, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
```

`lib/compartilhado/widgets/dialogo_confirmacao.dart`:

```dart
import 'package:flutter/material.dart';

import '../../aplicativo/tema/cores_app.dart';

Future<bool> mostrarDialogoConfirmacao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String confirmar = 'Confirmar',
  String cancelar = 'Cancelar',
  bool destrutivo = false,
}) async {
  final resposta = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(contexto).pop(false),
          child: Text(cancelar),
        ),
        FilledButton(
          style: destrutivo ? FilledButton.styleFrom(backgroundColor: CoresApp.erro) : null,
          onPressed: () => Navigator.of(contexto).pop(true),
          child: Text(confirmar),
        ),
      ],
    ),
  );
  return resposta ?? false;
}
```

`lib/compartilhado/widgets/barra_superior.dart`:

```dart
import 'package:flutter/material.dart';

class BarraSuperior extends StatelessWidget implements PreferredSizeWidget {
  const BarraSuperior({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.avatar,
    this.aoVoltar,
    this.acoes,
  });

  final String titulo;
  final String? subtitulo;
  final Widget? avatar;
  final VoidCallback? aoVoltar;
  final List<Widget>? acoes;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: kToolbarHeight + 8,
      leading: aoVoltar != null
          ? IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: aoVoltar)
          : null,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (avatar != null) ...[avatar!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitulo != null)
                  Text(
                    subtitulo!,
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: .92)),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: acoes,
    );
  }
}
```

`lib/compartilhado/widgets/scaffold_padrao.dart`:

```dart
import 'package:flutter/material.dart';

class ScaffoldPadrao extends StatelessWidget {
  const ScaffoldPadrao({super.key, required this.corpo, this.barra, this.corFundo});

  final Widget corpo;
  final PreferredSizeWidget? barra;
  final Color? corFundo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barra,
      backgroundColor: corFundo,
      body: SafeArea(child: corpo),
    );
  }
}
```

`lib/compartilhado/feedback/snackbar_padrao.dart`:

```dart
import 'package:flutter/material.dart';

import '../../aplicativo/tema/cores_app.dart';

void mostrarSnackbarPadrao(BuildContext context, String mensagem, {bool erro = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(mensagem, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: erro ? CoresApp.erro : CoresApp.textoPrincipal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
}
```

`lib/compartilhado/feedback/estado_vazio.dart`:

```dart
import 'package:flutter/material.dart';

import '../../aplicativo/tema/cores_app.dart';

class EstadoVazio extends StatelessWidget {
  const EstadoVazio({super.key, required this.emoji, required this.titulo, this.mensagem, this.acao});

  final String emoji;
  final String titulo;
  final String? mensagem;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            if (mensagem != null) ...[
              const SizedBox(height: 6),
              Text(
                mensagem!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: CoresApp.textoSecundario, fontWeight: FontWeight.w500),
              ),
            ],
            if (acao != null) ...[const SizedBox(height: 18), acao!],
          ],
        ),
      ),
    );
  }
}
```

`lib/compartilhado/feedback/estado_erro.dart`:

```dart
import 'package:flutter/material.dart';

import '../widgets/botao_secundario.dart';
import 'estado_vazio.dart';

class EstadoErro extends StatelessWidget {
  const EstadoErro({super.key, required this.mensagem, this.aoTentarNovamente});

  final String mensagem;
  final VoidCallback? aoTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return EstadoVazio(
      emoji: '⚠️',
      titulo: 'Algo deu errado',
      mensagem: mensagem,
      acao: aoTentarNovamente != null
          ? BotaoSecundario(rotulo: 'Tentar novamente', aoTocar: aoTentarNovamente, expandido: false)
          : null,
    );
  }
}
```

`lib/compartilhado/layout/layout_responsivo.dart`:

```dart
import 'package:flutter/material.dart';

enum ModoDispositivo { celular, tablet, totem }

ModoDispositivo modoPorLargura(double largura) {
  if (largura >= 1024) return ModoDispositivo.totem;
  if (largura >= 600) return ModoDispositivo.tablet;
  return ModoDispositivo.celular;
}

class ConteudoCentralizado extends StatelessWidget {
  const ConteudoCentralizado({super.key, required this.filho, this.larguraMaxima = 620});

  final Widget filho;
  final double larguraMaxima;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: larguraMaxima),
        child: filho,
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/compartilhado/widgets_test.dart`
Expected: PASS (5 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: widgets compartilhados (botoes, campos, cartao, feedback, layout)" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 7: Persistência — RepositorioConfiguracao e RepositorioTema

**Files:**
- Create: `lib/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart`
- Create: `lib/funcionalidades/configuracoes/dominio/repositorios/repositorio_tema.dart`
- Create: `lib/funcionalidades/configuracoes/dados/modelos/modelo_configuracao.dart`
- Create: `lib/funcionalidades/configuracoes/dados/modelos/modelo_tema_personalizado.dart`
- Create: `lib/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart`
- Create: `lib/funcionalidades/configuracoes/dados/repositorios/repositorio_tema_impl.dart`
- Create: `lib/aplicativo/injecao.dart`
- Create: `lib/aplicativo/tema/controlador_tema.dart`
- Test: `test/funcionalidades/configuracoes/repositorios_locais_test.dart`

**Interfaces:**
- Consumes: `ConfiguracaoTerminal`, `TemaPersonalizado` (Task 4).
- Produces:
  - `abstract interface class RepositorioConfiguracao { Future<ConfiguracaoTerminal> obter(); Future<void> salvar(ConfiguracaoTerminal configuracao); }`
  - `abstract interface class RepositorioTema { Future<TemaPersonalizado> obter(); Future<void> salvar(TemaPersonalizado tema); }`
  - `RepositorioConfiguracaoImpl(SharedPreferences)` / `RepositorioTemaImpl(SharedPreferences)` — JSON nas chaves `configuracao_terminal` / `tema_personalizado`; JSON corrompido devolve padrão.
  - `lib/aplicativo/injecao.dart`: `provedorSharedPreferences` (throw até override no main), `provedorRepositorioConfiguracao`, `provedorRepositorioTema`, `provedorAtrasoBot` (`Provider<Duration>` = `ConstantesApp.atrasoBotPadrao`).
  - `ControladorTema extends StateNotifier<TemaPersonalizado>` com `carregar()` e `atualizar(TemaPersonalizado)`; `provedorTema` (`StateNotifierProvider`).

- [ ] **Step 1: Escrever o teste que falha**

`test/funcionalidades/configuracoes/repositorios_locais_test.dart`:

```dart
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
      final repositorio = RepositorioConfiguracaoImpl(await SharedPreferences.getInstance());
      final config = await repositorio.obter();
      expect(config, const ConfiguracaoTerminal());
    });

    test('salva e recupera a configuracao', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio = RepositorioConfiguracaoImpl(await SharedPreferences.getInstance());
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
      SharedPreferences.setMockInitialValues({'configuracao_terminal': '{invalido'});
      final repositorio = RepositorioConfiguracaoImpl(await SharedPreferences.getInstance());
      expect(await repositorio.obter(), const ConfiguracaoTerminal());
    });
  });

  group('RepositorioTemaImpl', () {
    test('salva e recupera o tema', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio = RepositorioTemaImpl(await SharedPreferences.getInstance());
      const tema = TemaPersonalizado(corPrimaria: '#112233', logoPath: '/tmp/logo.png');
      await repositorio.salvar(tema);
      expect(await repositorio.obter(), tema);
    });

    test('devolve padrao quando nada foi salvo', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio = RepositorioTemaImpl(await SharedPreferences.getInstance());
      expect(await repositorio.obter(), const TemaPersonalizado());
    });
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/repositorios_locais_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar interfaces, modelos e impls**

`lib/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart`:

```dart
import '../entidades/configuracao_terminal.dart';

abstract interface class RepositorioConfiguracao {
  Future<ConfiguracaoTerminal> obter();

  Future<void> salvar(ConfiguracaoTerminal configuracao);
}
```

`lib/funcionalidades/configuracoes/dominio/repositorios/repositorio_tema.dart`:

```dart
import '../entidades/tema_personalizado.dart';

abstract interface class RepositorioTema {
  Future<TemaPersonalizado> obter();

  Future<void> salvar(TemaPersonalizado tema);
}
```

`lib/funcionalidades/configuracoes/dados/modelos/modelo_configuracao.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../nucleo/configuracao/ambiente.dart';
import '../../dominio/entidades/configuracao_terminal.dart';

part 'modelo_configuracao.freezed.dart';
part 'modelo_configuracao.g.dart';

@freezed
class ModeloConfiguracao with _$ModeloConfiguracao {
  const ModeloConfiguracao._();

  const factory ModeloConfiguracao({
    required String nomeRestaurante,
    required String identificadorDispositivo,
    required Ambiente ambiente,
    required String urlBaseProducao,
    required String urlBaseHomologacao,
    required String pinHash,
  }) = _ModeloConfiguracao;

  factory ModeloConfiguracao.fromJson(Map<String, dynamic> json) =>
      _$ModeloConfiguracaoFromJson(json);

  factory ModeloConfiguracao.deEntidade(ConfiguracaoTerminal entidade) => ModeloConfiguracao(
        nomeRestaurante: entidade.nomeRestaurante,
        identificadorDispositivo: entidade.identificadorDispositivo,
        ambiente: entidade.ambiente,
        urlBaseProducao: entidade.urlBaseProducao,
        urlBaseHomologacao: entidade.urlBaseHomologacao,
        pinHash: entidade.pinHash,
      );

  ConfiguracaoTerminal paraEntidade() => ConfiguracaoTerminal(
        nomeRestaurante: nomeRestaurante,
        identificadorDispositivo: identificadorDispositivo,
        ambiente: ambiente,
        urlBaseProducao: urlBaseProducao,
        urlBaseHomologacao: urlBaseHomologacao,
        pinHash: pinHash,
      );
}
```

`lib/funcionalidades/configuracoes/dados/modelos/modelo_tema_personalizado.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../dominio/entidades/tema_personalizado.dart';

part 'modelo_tema_personalizado.freezed.dart';
part 'modelo_tema_personalizado.g.dart';

@freezed
class ModeloTemaPersonalizado with _$ModeloTemaPersonalizado {
  const ModeloTemaPersonalizado._();

  const factory ModeloTemaPersonalizado({
    required String corPrimaria,
    required String corSecundaria,
    required String corFundo,
    required String corBotoes,
    String? logoPath,
  }) = _ModeloTemaPersonalizado;

  factory ModeloTemaPersonalizado.fromJson(Map<String, dynamic> json) =>
      _$ModeloTemaPersonalizadoFromJson(json);

  factory ModeloTemaPersonalizado.deEntidade(TemaPersonalizado entidade) =>
      ModeloTemaPersonalizado(
        corPrimaria: entidade.corPrimaria,
        corSecundaria: entidade.corSecundaria,
        corFundo: entidade.corFundo,
        corBotoes: entidade.corBotoes,
        logoPath: entidade.logoPath,
      );

  TemaPersonalizado paraEntidade() => TemaPersonalizado(
        corPrimaria: corPrimaria,
        corSecundaria: corSecundaria,
        corFundo: corFundo,
        corBotoes: corBotoes,
        logoPath: logoPath,
      );
}
```

`lib/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart`:

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../dominio/entidades/configuracao_terminal.dart';
import '../../dominio/repositorios/repositorio_configuracao.dart';
import '../modelos/modelo_configuracao.dart';

class RepositorioConfiguracaoImpl implements RepositorioConfiguracao {
  RepositorioConfiguracaoImpl(this._preferencias);

  final SharedPreferences _preferencias;

  static const String _chave = 'configuracao_terminal';

  @override
  Future<ConfiguracaoTerminal> obter() async {
    final texto = _preferencias.getString(_chave);
    if (texto == null) return const ConfiguracaoTerminal();
    try {
      final json = jsonDecode(texto) as Map<String, dynamic>;
      return ModeloConfiguracao.fromJson(json).paraEntidade();
    } catch (_) {
      return const ConfiguracaoTerminal();
    }
  }

  @override
  Future<void> salvar(ConfiguracaoTerminal configuracao) async {
    final json = jsonEncode(ModeloConfiguracao.deEntidade(configuracao).toJson());
    await _preferencias.setString(_chave, json);
  }
}
```

`lib/funcionalidades/configuracoes/dados/repositorios/repositorio_tema_impl.dart`:

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../dominio/entidades/tema_personalizado.dart';
import '../../dominio/repositorios/repositorio_tema.dart';
import '../modelos/modelo_tema_personalizado.dart';

class RepositorioTemaImpl implements RepositorioTema {
  RepositorioTemaImpl(this._preferencias);

  final SharedPreferences _preferencias;

  static const String _chave = 'tema_personalizado';

  @override
  Future<TemaPersonalizado> obter() async {
    final texto = _preferencias.getString(_chave);
    if (texto == null) return const TemaPersonalizado();
    try {
      final json = jsonDecode(texto) as Map<String, dynamic>;
      return ModeloTemaPersonalizado.fromJson(json).paraEntidade();
    } catch (_) {
      return const TemaPersonalizado();
    }
  }

  @override
  Future<void> salvar(TemaPersonalizado tema) async {
    final json = jsonEncode(ModeloTemaPersonalizado.deEntidade(tema).toJson());
    await _preferencias.setString(_chave, json);
  }
}
```

`lib/aplicativo/tema/controlador_tema.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import '../../funcionalidades/configuracoes/dominio/repositorios/repositorio_tema.dart';

class ControladorTema extends StateNotifier<TemaPersonalizado> {
  ControladorTema(this._repositorio) : super(const TemaPersonalizado());

  final RepositorioTema _repositorio;

  Future<void> carregar() async {
    state = await _repositorio.obter();
  }

  Future<void> atualizar(TemaPersonalizado novoTema) async {
    await _repositorio.salvar(novoTema);
    state = novoTema;
  }
}
```

`lib/aplicativo/injecao.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import '../funcionalidades/configuracoes/dados/repositorios/repositorio_tema_impl.dart';
import '../funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import '../funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import '../funcionalidades/configuracoes/dominio/repositorios/repositorio_tema.dart';
import '../nucleo/constantes/constantes_app.dart';
import 'tema/controlador_tema.dart';

final provedorSharedPreferences = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Sobrescrito no main.dart'),
);

final provedorAtrasoBot = Provider<Duration>((ref) => ConstantesApp.atrasoBotPadrao);

final provedorRepositorioConfiguracao = Provider<RepositorioConfiguracao>(
  (ref) => RepositorioConfiguracaoImpl(ref.watch(provedorSharedPreferences)),
);

final provedorRepositorioTema = Provider<RepositorioTema>(
  (ref) => RepositorioTemaImpl(ref.watch(provedorSharedPreferences)),
);

final provedorTema = StateNotifierProvider<ControladorTema, TemaPersonalizado>(
  (ref) => ControladorTema(ref.watch(provedorRepositorioTema)),
);
```

- [ ] **Step 4: Gerar código e rodar os testes**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/funcionalidades/configuracoes/repositorios_locais_test.dart
```
Expected: PASS (5 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: repositorios locais de configuracao e tema + injecao Riverpod" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 8: Persistência — RepositorioCredencial e HasherPin

**Files:**
- Create: `lib/nucleo/utils/hasher_pin.dart`
- Create: `lib/funcionalidades/configuracoes/dominio/repositorios/repositorio_credencial.dart`
- Create: `lib/funcionalidades/configuracoes/dados/repositorios/repositorio_credencial_impl.dart`
- Modify: `lib/aplicativo/injecao.dart` (adicionar `provedorArmazenamentoSeguro`, `provedorRepositorioCredencial`)
- Test: `test/nucleo/utils/hasher_pin_test.dart`
- Test: `test/funcionalidades/configuracoes/repositorio_credencial_test.dart`

**Interfaces:**
- Produces:
  - `HasherPin.gerar(String pin) -> String` (sha256 de `'constel-pay:<pin>'`, hex 64 chars); `HasherPin.verificar(String pin, String hash) -> bool`.
  - `abstract interface class RepositorioCredencial { Future<Credencial?> obter(); Future<void> salvar(Credencial credencial); Future<void> remover(); }`
  - `RepositorioCredencialImpl(FlutterSecureStorage)` — chaves `credencial_usuario`, `credencial_senha`.
  - Providers: `provedorArmazenamentoSeguro` (`Provider<FlutterSecureStorage>`), `provedorRepositorioCredencial`.

- [ ] **Step 1: Escrever os testes que falham**

`test/nucleo/utils/hasher_pin_test.dart`:

```dart
import 'package:constel_pay/nucleo/utils/hasher_pin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HasherPin', () {
    test('gera hash deterministico de 64 caracteres hex', () {
      final hash = HasherPin.gerar('1234');
      expect(hash, hasLength(64));
      expect(hash, HasherPin.gerar('1234'));
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(hash), isTrue);
    });

    test('pins diferentes geram hashes diferentes', () {
      expect(HasherPin.gerar('1234'), isNot(HasherPin.gerar('4321')));
    });

    test('verificar compara pin com hash', () {
      final hash = HasherPin.gerar('123456');
      expect(HasherPin.verificar('123456', hash), isTrue);
      expect(HasherPin.verificar('000000', hash), isFalse);
    });
  });
}
```

`test/funcionalidades/configuracoes/repositorio_credencial_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_credencial_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/credencial.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockArmazenamento extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockArmazenamento armazenamento;
  late RepositorioCredencialImpl repositorio;

  setUp(() {
    armazenamento = _MockArmazenamento();
    repositorio = RepositorioCredencialImpl(armazenamento);
  });

  test('salvar grava usuario e senha em chaves separadas', () async {
    when(() => armazenamento.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    await repositorio.salvar(const Credencial(usuario: 'operador', senha: 's3nh4'));
    verify(() => armazenamento.write(key: 'credencial_usuario', value: 'operador')).called(1);
    verify(() => armazenamento.write(key: 'credencial_senha', value: 's3nh4')).called(1);
  });

  test('obter devolve null quando nao ha credencial', () async {
    when(() => armazenamento.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    expect(await repositorio.obter(), isNull);
  });

  test('obter devolve a credencial salva', () async {
    when(() => armazenamento.read(key: 'credencial_usuario')).thenAnswer((_) async => 'operador');
    when(() => armazenamento.read(key: 'credencial_senha')).thenAnswer((_) async => 's3nh4');
    expect(await repositorio.obter(), const Credencial(usuario: 'operador', senha: 's3nh4'));
  });

  test('remover apaga as duas chaves', () async {
    when(() => armazenamento.delete(key: any(named: 'key'))).thenAnswer((_) async {});
    await repositorio.remover();
    verify(() => armazenamento.delete(key: 'credencial_usuario')).called(1);
    verify(() => armazenamento.delete(key: 'credencial_senha')).called(1);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/nucleo/utils/hasher_pin_test.dart test/funcionalidades/configuracoes/repositorio_credencial_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/nucleo/utils/hasher_pin.dart`:

```dart
import 'dart:convert';

import 'package:crypto/crypto.dart';

abstract final class HasherPin {
  static const String _sal = 'constel-pay';

  static String gerar(String pin) => sha256.convert(utf8.encode('$_sal:$pin')).toString();

  static bool verificar(String pin, String hash) => gerar(pin) == hash;
}
```

`lib/funcionalidades/configuracoes/dominio/repositorios/repositorio_credencial.dart`:

```dart
import '../entidades/credencial.dart';

abstract interface class RepositorioCredencial {
  Future<Credencial?> obter();

  Future<void> salvar(Credencial credencial);

  Future<void> remover();
}
```

`lib/funcionalidades/configuracoes/dados/repositorios/repositorio_credencial_impl.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../dominio/entidades/credencial.dart';
import '../../dominio/repositorios/repositorio_credencial.dart';

class RepositorioCredencialImpl implements RepositorioCredencial {
  RepositorioCredencialImpl(this._armazenamento);

  final FlutterSecureStorage _armazenamento;

  static const String _chaveUsuario = 'credencial_usuario';
  static const String _chaveSenha = 'credencial_senha';

  @override
  Future<Credencial?> obter() async {
    final usuario = await _armazenamento.read(key: _chaveUsuario);
    final senha = await _armazenamento.read(key: _chaveSenha);
    if (usuario == null || senha == null) return null;
    return Credencial(usuario: usuario, senha: senha);
  }

  @override
  Future<void> salvar(Credencial credencial) async {
    await _armazenamento.write(key: _chaveUsuario, value: credencial.usuario);
    await _armazenamento.write(key: _chaveSenha, value: credencial.senha);
  }

  @override
  Future<void> remover() async {
    await _armazenamento.delete(key: _chaveUsuario);
    await _armazenamento.delete(key: _chaveSenha);
  }
}
```

Adicionar em `lib/aplicativo/injecao.dart` (imports de `flutter_secure_storage`, `repositorio_credencial.dart` e `repositorio_credencial_impl.dart` + providers):

```dart
final provedorArmazenamentoSeguro = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final provedorRepositorioCredencial = Provider<RepositorioCredencial>(
  (ref) => RepositorioCredencialImpl(ref.watch(provedorArmazenamentoSeguro)),
);
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/nucleo/utils/hasher_pin_test.dart test/funcionalidades/configuracoes/repositorio_credencial_test.dart`
Expected: PASS (7 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: repositorio de credenciais (secure storage) e hasher de PIN" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 9: Persistência — RepositorioPropaganda

**Files:**
- Create: `lib/funcionalidades/propaganda/dominio/repositorios/repositorio_propaganda.dart`
- Create: `lib/funcionalidades/propaganda/dados/modelos/modelo_midia.dart`
- Create: `lib/funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart`
- Modify: `lib/aplicativo/injecao.dart` (adicionar `provedorRepositorioPropaganda`)
- Test: `test/funcionalidades/propaganda/repositorio_propaganda_test.dart`

**Interfaces:**
- Consumes: `MidiaPropaganda`, `TipoMidia` (Task 4).
- Produces:
  - `abstract interface class RepositorioPropaganda { Future<List<MidiaPropaganda>> obterTodas(); Future<List<MidiaPropaganda>> obterAtivasOrdenadas(); Future<void> salvarTodas(List<MidiaPropaganda> midias); }`
  - `RepositorioPropagandaImpl(SharedPreferences)` — chave `midias_propaganda`, JSON array.
  - Provider: `provedorRepositorioPropaganda`.

- [ ] **Step 1: Escrever o teste que falha**

`test/funcionalidades/propaganda/repositorio_propaganda_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const midias = [
    MidiaPropaganda(id: 'a', tipo: TipoMidia.imagem, caminho: '/m/a.png', ordem: 2),
    MidiaPropaganda(id: 'b', tipo: TipoMidia.video, caminho: '/m/b.mp4', ordem: 1),
    MidiaPropaganda(id: 'c', tipo: TipoMidia.imagem, caminho: '/m/c.png', ordem: 3, ativo: false),
  ];

  test('devolve lista vazia quando nada foi salvo', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio = RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    expect(await repositorio.obterTodas(), isEmpty);
  });

  test('salva e recupera todas as midias', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio = RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    await repositorio.salvarTodas(midias);
    expect(await repositorio.obterTodas(), midias);
  });

  test('obterAtivasOrdenadas filtra inativas e ordena por ordem', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio = RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    await repositorio.salvarTodas(midias);
    final ativas = await repositorio.obterAtivasOrdenadas();
    expect(ativas.map((m) => m.id).toList(), ['b', 'a']);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/propaganda/repositorio_propaganda_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/funcionalidades/propaganda/dominio/repositorios/repositorio_propaganda.dart`:

```dart
import '../entidades/midia_propaganda.dart';

abstract interface class RepositorioPropaganda {
  Future<List<MidiaPropaganda>> obterTodas();

  Future<List<MidiaPropaganda>> obterAtivasOrdenadas();

  Future<void> salvarTodas(List<MidiaPropaganda> midias);
}
```

`lib/funcionalidades/propaganda/dados/modelos/modelo_midia.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../dominio/entidades/midia_propaganda.dart';

part 'modelo_midia.freezed.dart';
part 'modelo_midia.g.dart';

@freezed
class ModeloMidia with _$ModeloMidia {
  const ModeloMidia._();

  const factory ModeloMidia({
    required String id,
    required TipoMidia tipo,
    required String caminho,
    required int duracaoSegundos,
    required int ordem,
    required bool ativo,
  }) = _ModeloMidia;

  factory ModeloMidia.fromJson(Map<String, dynamic> json) => _$ModeloMidiaFromJson(json);

  factory ModeloMidia.deEntidade(MidiaPropaganda entidade) => ModeloMidia(
        id: entidade.id,
        tipo: entidade.tipo,
        caminho: entidade.caminho,
        duracaoSegundos: entidade.duracaoSegundos,
        ordem: entidade.ordem,
        ativo: entidade.ativo,
      );

  MidiaPropaganda paraEntidade() => MidiaPropaganda(
        id: id,
        tipo: tipo,
        caminho: caminho,
        duracaoSegundos: duracaoSegundos,
        ordem: ordem,
        ativo: ativo,
      );
}
```

`lib/funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart`:

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../dominio/entidades/midia_propaganda.dart';
import '../../dominio/repositorios/repositorio_propaganda.dart';
import '../modelos/modelo_midia.dart';

class RepositorioPropagandaImpl implements RepositorioPropaganda {
  RepositorioPropagandaImpl(this._preferencias);

  final SharedPreferences _preferencias;

  static const String _chave = 'midias_propaganda';

  @override
  Future<List<MidiaPropaganda>> obterTodas() async {
    final texto = _preferencias.getString(_chave);
    if (texto == null) return const [];
    try {
      final lista = jsonDecode(texto) as List<dynamic>;
      return lista
          .map((item) => ModeloMidia.fromJson(item as Map<String, dynamic>).paraEntidade())
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<MidiaPropaganda>> obterAtivasOrdenadas() async {
    final todas = await obterTodas();
    final ativas = todas.where((midia) => midia.ativo).toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
    return ativas;
  }

  @override
  Future<void> salvarTodas(List<MidiaPropaganda> midias) async {
    final json = jsonEncode(midias.map((m) => ModeloMidia.deEntidade(m).toJson()).toList());
    await _preferencias.setString(_chave, json);
  }
}
```

Adicionar em `lib/aplicativo/injecao.dart`:

```dart
final provedorRepositorioPropaganda = Provider<RepositorioPropaganda>(
  (ref) => RepositorioPropagandaImpl(ref.watch(provedorSharedPreferences)),
);
```

- [ ] **Step 4: Gerar código e rodar os testes**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/funcionalidades/propaganda/repositorio_propaganda_test.dart
```
Expected: PASS (3 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: repositorio de propaganda com persistencia local" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 10: ClienteApi (Dio) e CasoUsoTestarConexao

**Files:**
- Create: `lib/nucleo/configuracao/cliente_api.dart`
- Create: `lib/nucleo/utils/registrador.dart`
- Create: `lib/funcionalidades/configuracoes/dominio/casos_uso/caso_uso_testar_conexao.dart`
- Modify: `lib/aplicativo/injecao.dart` (adicionar `provedorClienteApi`, `provedorCasoUsoTestarConexao`)
- Test: `test/nucleo/configuracao/cliente_api_test.dart`

**Interfaces:**
- Consumes: `RepositorioConfiguracao` (Task 7), `Resultado`/`Falha` (Task 2), `Validadores` (Task 3).
- Produces:
  - `registrador` (Logger global com `SaidaMemoria` que retém as últimas 1000 linhas em `saidaMemoria.linhas`).
  - `ClienteApi({required RepositorioConfiguracao repositorioConfiguracao, Dio? dio})` com `Future<Resultado<Response<dynamic>>> get(String caminho)`, `Future<Resultado<Response<dynamic>>> post(String caminho, {Object? dados, String? chaveIdempotencia})` (header `Idempotency-Key`), e `static Falha mapearFalha(DioException)`.
  - `CasoUsoTestarConexao({required ClienteApi clienteApi, required RepositorioConfiguracao repositorioConfiguracao, required SharedPreferences preferencias})` com `Future<Resultado<DateTime>> executar()` — valida URL, faz GET `/`, grava `ultima_sincronizacao` (ISO-8601) no sucesso.

- [ ] **Step 1: Escrever o teste que falha**

`test/nucleo/configuracao/cliente_api_test.dart`:

```dart
import 'dart:convert';

import 'package:constel_pay/funcionalidades/configuracoes/dominio/casos_uso/caso_uso_testar_conexao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RepositorioFake implements RepositorioConfiguracao {
  _RepositorioFake(this.configuracao);

  ConfiguracaoTerminal configuracao;

  @override
  Future<ConfiguracaoTerminal> obter() async => configuracao;

  @override
  Future<void> salvar(ConfiguracaoTerminal nova) async => configuracao = nova;
}

class _AdaptadorFake implements HttpClientAdapter {
  int chamadas = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    chamadas++;
    return ResponseBody.fromString(jsonEncode({'ok': true}), 200,
        headers: {'content-type': ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mapearFalha traduz os tipos de erro do Dio', () {
    final opcoes = RequestOptions(path: '/');
    expect(ClienteApi.mapearFalha(DioException(requestOptions: opcoes, type: DioExceptionType.connectionTimeout)), isA<FalhaTimeout>());
    expect(ClienteApi.mapearFalha(DioException(requestOptions: opcoes, type: DioExceptionType.receiveTimeout)), isA<FalhaTimeout>());
    expect(ClienteApi.mapearFalha(DioException(requestOptions: opcoes, type: DioExceptionType.connectionError)), isA<FalhaRede>());
    expect(ClienteApi.mapearFalha(DioException(requestOptions: opcoes, type: DioExceptionType.badResponse)), isA<FalhaServidor>());
    expect(ClienteApi.mapearFalha(DioException(requestOptions: opcoes, type: DioExceptionType.cancel)), isA<FalhaValidacao>());
  });

  test('get usa a URL base do ambiente ativo', () async {
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal(urlBaseHomologacao: 'https://homolog.constel.dev'));
    final dio = Dio();
    final adaptador = _AdaptadorFake();
    dio.httpClientAdapter = adaptador;
    final cliente = ClienteApi(repositorioConfiguracao: repositorio, dio: dio);
    final resultado = await cliente.get('/');
    expect(resultado, isA<Sucesso<Response<dynamic>>>());
    expect(adaptador.chamadas, 1);
  });

  test('get sem URL configurada devolve FalhaValidacao', () async {
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal());
    final cliente = ClienteApi(repositorioConfiguracao: repositorio, dio: Dio());
    final resultado = await cliente.get('/');
    expect(resultado, isA<Erro<Response<dynamic>>>());
    expect((resultado as Erro<Response<dynamic>>).falha, isA<FalhaValidacao>());
  });

  test('testar conexao grava ultima sincronizacao no sucesso', () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal(urlBaseHomologacao: 'https://homolog.constel.dev'));
    final dio = Dio()..httpClientAdapter = _AdaptadorFake();
    final casoUso = CasoUsoTestarConexao(
      clienteApi: ClienteApi(repositorioConfiguracao: repositorio, dio: dio),
      repositorioConfiguracao: repositorio,
      preferencias: preferencias,
    );
    final resultado = await casoUso.executar();
    expect(resultado, isA<Sucesso<DateTime>>());
    expect(preferencias.getString('ultima_sincronizacao'), isNotNull);
  });

  test('testar conexao com URL invalida devolve FalhaValidacao sem chamar a rede', () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal(urlBaseHomologacao: 'nao-e-url'));
    final adaptador = _AdaptadorFake();
    final dio = Dio()..httpClientAdapter = adaptador;
    final casoUso = CasoUsoTestarConexao(
      clienteApi: ClienteApi(repositorioConfiguracao: repositorio, dio: dio),
      repositorioConfiguracao: repositorio,
      preferencias: preferencias,
    );
    final resultado = await casoUso.executar();
    expect(resultado, isA<Erro<DateTime>>());
    expect(adaptador.chamadas, 0);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/nucleo/configuracao/cliente_api_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/nucleo/utils/registrador.dart`:

```dart
import 'package:logger/logger.dart';

/// Retém as últimas linhas de log em memória para exportação no diagnóstico.
class SaidaMemoria extends LogOutput {
  final List<String> linhas = [];

  static const int _maximo = 1000;

  @override
  void output(OutputEvent event) {
    linhas.addAll(event.lines);
    if (linhas.length > _maximo) {
      linhas.removeRange(0, linhas.length - _maximo);
    }
  }
}

final SaidaMemoria saidaMemoria = SaidaMemoria();

/// Logger do app. NUNCA registrar senha, token, dados de cartão ou payload sensível.
final Logger registrador = Logger(
  output: MultiOutput([ConsoleOutput(), saidaMemoria]),
  printer: SimplePrinter(printTime: true),
);
```

`lib/nucleo/configuracao/cliente_api.dart`:

```dart
import 'package:dio/dio.dart';

import '../../funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import '../erros/falha.dart';
import '../erros/resultado.dart';
import '../utils/registrador.dart';

class ClienteApi {
  ClienteApi({required RepositorioConfiguracao repositorioConfiguracao, Dio? dio})
      : _repositorioConfiguracao = repositorioConfiguracao,
        _dio = dio ?? Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (opcoes, manipulador) async {
          final configuracao = await _repositorioConfiguracao.obter();
          final base = configuracao.urlBaseAtiva;
          if (base.isEmpty) {
            return manipulador.reject(
              DioException(requestOptions: opcoes, type: DioExceptionType.cancel),
            );
          }
          opcoes.baseUrl = base;
          // Log seguro: método e caminho apenas — nunca headers nem corpo.
          registrador.i('HTTP ${opcoes.method} ${opcoes.path}');
          manipulador.next(opcoes);
        },
        onError: (erro, manipulador) {
          registrador.w('HTTP erro ${erro.type.name} em ${erro.requestOptions.path}');
          manipulador.next(erro);
        },
      ),
    );
  }

  final Dio _dio;
  final RepositorioConfiguracao _repositorioConfiguracao;

  Future<Resultado<Response<dynamic>>> get(String caminho) async {
    try {
      return Sucesso(await _dio.get<dynamic>(caminho));
    } on DioException catch (excecao) {
      return Erro(mapearFalha(excecao));
    }
  }

  Future<Resultado<Response<dynamic>>> post(
    String caminho, {
    Object? dados,
    String? chaveIdempotencia,
  }) async {
    try {
      return Sucesso(
        await _dio.post<dynamic>(
          caminho,
          data: dados,
          options: Options(
            headers: {if (chaveIdempotencia != null) 'Idempotency-Key': chaveIdempotencia},
          ),
        ),
      );
    } on DioException catch (excecao) {
      return Erro(mapearFalha(excecao));
    }
  }

  static Falha mapearFalha(DioException excecao) => switch (excecao.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          const FalhaTimeout(),
        DioExceptionType.connectionError => const FalhaRede(),
        DioExceptionType.badResponse => const FalhaServidor(),
        DioExceptionType.cancel =>
          const FalhaValidacao('Configure a URL do ambiente nas configurações.'),
        _ => const FalhaDesconhecida(),
      };
}
```

`lib/funcionalidades/configuracoes/dominio/casos_uso/caso_uso_testar_conexao.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../../nucleo/utils/validadores.dart';
import '../repositorios/repositorio_configuracao.dart';

class CasoUsoTestarConexao {
  CasoUsoTestarConexao({
    required ClienteApi clienteApi,
    required RepositorioConfiguracao repositorioConfiguracao,
    required SharedPreferences preferencias,
  })  : _clienteApi = clienteApi,
        _repositorioConfiguracao = repositorioConfiguracao,
        _preferencias = preferencias;

  final ClienteApi _clienteApi;
  final RepositorioConfiguracao _repositorioConfiguracao;
  final SharedPreferences _preferencias;

  Future<Resultado<DateTime>> executar() async {
    final configuracao = await _repositorioConfiguracao.obter();
    if (!Validadores.urlValida(configuracao.urlBaseAtiva)) {
      return const Erro(FalhaValidacao('Configure uma URL válida para o ambiente ativo.'));
    }
    final resposta = await _clienteApi.get('/');
    switch (resposta) {
      case Sucesso():
        final agora = DateTime.now();
        await _preferencias.setString(
          ConstantesApp.chaveUltimaSincronizacao,
          agora.toIso8601String(),
        );
        return Sucesso(agora);
      case Erro(:final falha):
        return Erro(falha);
    }
  }
}
```

Adicionar em `lib/aplicativo/injecao.dart`:

```dart
final provedorClienteApi = Provider<ClienteApi>(
  (ref) => ClienteApi(repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao)),
);

final provedorCasoUsoTestarConexao = Provider<CasoUsoTestarConexao>(
  (ref) => CasoUsoTestarConexao(
    clienteApi: ref.watch(provedorClienteApi),
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    preferencias: ref.watch(provedorSharedPreferences),
  ),
);
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/nucleo/configuracao/cliente_api_test.dart`
Expected: PASS (5 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: ClienteApi com URL dinamica por ambiente e teste de conexao" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 11: Feature leitura_cartao — mock, repositório e caso de uso

**Files:**
- Create: `lib/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart`
- Create: `lib/funcionalidades/leitura_cartao/dominio/repositorios/repositorio_leitura.dart`
- Create: `lib/funcionalidades/leitura_cartao/dados/repositorios/repositorio_leitura_impl.dart`
- Create: `lib/funcionalidades/leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart`
- Modify: `lib/aplicativo/injecao.dart` (adicionar `provedorFonteLeituraMock`, `provedorRepositorioLeitura`, `provedorCasoUsoLerCartao`)
- Test: `test/funcionalidades/leitura_cartao/leitura_cartao_test.dart`

**Interfaces:**
- Consumes: `CartaoConsumo`, `ItemConsumo`, `Mesa`, `StatusMesa` (Task 4), `Resultado`/`Falha` (Task 2).
- Produces:
  - `FonteLeituraMock({Duration atraso = Duration(milliseconds: 900)})` com `Mesa obterMesa()`, `Future<CartaoConsumo?> lerProximo()`, `int get restantes`, `void reiniciar()`. Dados: mesa 12 com 3 comandas — João (R$ 136,00), Maria (R$ 102,00), Ana (R$ 80,00), total R$ 318,00.
  - `abstract interface class RepositorioLeitura { Future<Resultado<Mesa>> obterMesa(); Future<Resultado<CartaoConsumo>> lerCartao(); int get cartoesRestantes; void reiniciar(); }`
  - `RepositorioLeituraImpl(FonteLeituraMock)` — `lerCartao()` com fonte esgotada devolve `Erro(FalhaValidacao('Não há mais cartões em aberto nesta mesa.'))`.
  - `CasoUsoLerCartao(RepositorioLeitura)` com `Future<Resultado<CartaoConsumo>> executar()`.

- [ ] **Step 1: Escrever o teste que falha**

`test/funcionalidades/leitura_cartao/leitura_cartao_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/repositorios/repositorio_leitura_impl.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/cartao_consumo.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FonteLeituraMock fonte;
  late RepositorioLeituraImpl repositorio;
  late CasoUsoLerCartao casoUso;

  setUp(() {
    fonte = FonteLeituraMock(atraso: Duration.zero);
    repositorio = RepositorioLeituraImpl(fonte);
    casoUso = CasoUsoLerCartao(repositorio);
  });

  test('mesa mock e a mesa 12 com total R\$ 318,00', () {
    final mesa = fonte.obterMesa();
    expect(mesa.numero, 12);
    expect(mesa.totalComandas, 3);
    expect(mesa.totalCentavos, 31800);
  });

  test('subtotal de cada comanda coincide com a soma dos itens', () async {
    for (var i = 0; i < 3; i++) {
      final resultado = await casoUso.executar();
      final cartao = (resultado as Sucesso<CartaoConsumo>).valor;
      final soma = cartao.itens.fold<int>(0, (acumulado, item) => acumulado + item.totalCentavos);
      expect(cartao.subtotalCentavos, soma, reason: 'comanda ${cartao.nome}');
    }
  });

  test('le as tres comandas em ordem e depois devolve falha', () async {
    final primeira = await casoUso.executar();
    expect((primeira as Sucesso<CartaoConsumo>).valor.pessoa, 'João');
    expect((primeira).valor.subtotalCentavos, 13600);
    expect(repositorio.cartoesRestantes, 2);

    final segunda = await casoUso.executar();
    expect((segunda as Sucesso<CartaoConsumo>).valor.pessoa, 'Maria');

    final terceira = await casoUso.executar();
    expect((terceira as Sucesso<CartaoConsumo>).valor.pessoa, 'Ana');
    expect(repositorio.cartoesRestantes, 0);

    final quarta = await casoUso.executar();
    expect(quarta, isA<Erro<CartaoConsumo>>());
    expect((quarta as Erro<CartaoConsumo>).falha, isA<FalhaValidacao>());
  });

  test('reiniciar permite ler tudo de novo', () async {
    await casoUso.executar();
    await casoUso.executar();
    repositorio.reiniciar();
    expect(repositorio.cartoesRestantes, 3);
    final resultado = await casoUso.executar();
    expect((resultado as Sucesso<CartaoConsumo>).valor.pessoa, 'João');
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/leitura_cartao/leitura_cartao_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart`:

```dart
import '../../dominio/entidades/cartao_consumo.dart';
import '../../dominio/entidades/item_consumo.dart';
import '../../dominio/entidades/mesa.dart';

/// Fonte MOCK de leitura de cartões. Simula a mesa 12 com 3 comandas.
/// Será substituída pela integração real (scanner/API) trocando o provider.
class FonteLeituraMock {
  FonteLeituraMock({this.atraso = const Duration(milliseconds: 900)});

  final Duration atraso;

  static const List<CartaoConsumo> _cartoes = [
    CartaoConsumo(
      id: 'c1',
      codigo: '789100000001',
      nome: 'Comanda 01',
      pessoa: 'João',
      emoji: '🍲',
      resumo: '2 pratos · 3 bebidas',
      subtotalCentavos: 13600,
      itens: [
        ItemConsumo(emoji: '🍲', nome: 'Feijoada individual', quantidade: 1, valorCentavos: 4600),
        ItemConsumo(emoji: '🥩', nome: 'Picanha na chapa', quantidade: 1, valorCentavos: 6400),
        ItemConsumo(emoji: '🍺', nome: 'Chopp 300ml', quantidade: 2, valorCentavos: 900),
        ItemConsumo(emoji: '🥤', nome: 'Guaraná lata', quantidade: 1, valorCentavos: 800),
      ],
    ),
    CartaoConsumo(
      id: 'c2',
      codigo: '789100000002',
      nome: 'Comanda 02',
      pessoa: 'Maria',
      emoji: '🦐',
      resumo: '1 prato · 3 bebidas',
      subtotalCentavos: 10200,
      itens: [
        ItemConsumo(emoji: '🦐', nome: 'Moqueca de camarão', quantidade: 1, valorCentavos: 7200),
        ItemConsumo(emoji: '🍹', nome: 'Caipirinha', quantidade: 2, valorCentavos: 1200),
        ItemConsumo(emoji: '💧', nome: 'Água com gás', quantidade: 1, valorCentavos: 600),
      ],
    ),
    CartaoConsumo(
      id: 'c3',
      codigo: '789100000003',
      nome: 'Comanda 03',
      pessoa: 'Ana',
      emoji: '🍚',
      resumo: '1 prato · 1 sobremesa · 1 bebida',
      subtotalCentavos: 8000,
      itens: [
        ItemConsumo(emoji: '🍚', nome: 'Risoto de funghi', quantidade: 1, valorCentavos: 5200),
        ItemConsumo(emoji: '🍊', nome: 'Suco de laranja', quantidade: 1, valorCentavos: 1200),
        ItemConsumo(emoji: '🍮', nome: 'Pudim de leite', quantidade: 1, valorCentavos: 1600),
      ],
    ),
  ];

  final Set<String> _lidos = {};

  Mesa obterMesa() => Mesa(
        numero: 12,
        abertoEm: DateTime.now().subtract(const Duration(minutes: 24)),
        totalComandas: _cartoes.length,
        totalCentavos: _cartoes.fold(0, (acumulado, c) => acumulado + c.subtotalCentavos),
      );

  Future<CartaoConsumo?> lerProximo() async {
    await Future<void>.delayed(atraso);
    for (final cartao in _cartoes) {
      if (!_lidos.contains(cartao.id)) {
        _lidos.add(cartao.id);
        return cartao;
      }
    }
    return null;
  }

  int get restantes => _cartoes.length - _lidos.length;

  void reiniciar() => _lidos.clear();
}
```

`lib/funcionalidades/leitura_cartao/dominio/repositorios/repositorio_leitura.dart`:

```dart
import '../../../../nucleo/erros/resultado.dart';
import '../entidades/cartao_consumo.dart';
import '../entidades/mesa.dart';

abstract interface class RepositorioLeitura {
  Future<Resultado<Mesa>> obterMesa();

  Future<Resultado<CartaoConsumo>> lerCartao();

  int get cartoesRestantes;

  void reiniciar();
}
```

`lib/funcionalidades/leitura_cartao/dados/repositorios/repositorio_leitura_impl.dart`:

```dart
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/cartao_consumo.dart';
import '../../dominio/entidades/mesa.dart';
import '../../dominio/repositorios/repositorio_leitura.dart';
import '../fontes_dados/fonte_leitura_mock.dart';

class RepositorioLeituraImpl implements RepositorioLeitura {
  RepositorioLeituraImpl(this._fonte);

  final FonteLeituraMock _fonte;

  @override
  Future<Resultado<Mesa>> obterMesa() async => Sucesso(_fonte.obterMesa());

  @override
  Future<Resultado<CartaoConsumo>> lerCartao() async {
    final cartao = await _fonte.lerProximo();
    if (cartao == null) {
      return const Erro(FalhaValidacao('Não há mais cartões em aberto nesta mesa.'));
    }
    return Sucesso(cartao);
  }

  @override
  int get cartoesRestantes => _fonte.restantes;

  @override
  void reiniciar() => _fonte.reiniciar();
}
```

`lib/funcionalidades/leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart`:

```dart
import '../../../../nucleo/erros/resultado.dart';
import '../entidades/cartao_consumo.dart';
import '../repositorios/repositorio_leitura.dart';

class CasoUsoLerCartao {
  CasoUsoLerCartao(this._repositorio);

  final RepositorioLeitura _repositorio;

  Future<Resultado<CartaoConsumo>> executar() => _repositorio.lerCartao();
}
```

Adicionar em `lib/aplicativo/injecao.dart`:

```dart
final provedorFonteLeituraMock = Provider<FonteLeituraMock>((ref) => FonteLeituraMock());

final provedorRepositorioLeitura = Provider<RepositorioLeitura>(
  (ref) => RepositorioLeituraImpl(ref.watch(provedorFonteLeituraMock)),
);

final provedorCasoUsoLerCartao = Provider<CasoUsoLerCartao>(
  (ref) => CasoUsoLerCartao(ref.watch(provedorRepositorioLeitura)),
);
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/funcionalidades/leitura_cartao/leitura_cartao_test.dart`
Expected: PASS (4 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: leitura de cartao com fonte mock (mesa 12, 3 comandas)" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 12: Feature pagamento — mock com idempotência e casos de uso

**Files:**
- Create: `lib/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart`
- Create: `lib/funcionalidades/pagamento/dominio/repositorios/repositorio_pagamento.dart`
- Create: `lib/funcionalidades/pagamento/dados/repositorios/repositorio_pagamento_impl.dart`
- Create: `lib/funcionalidades/pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart`
- Create: `lib/funcionalidades/pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart`
- Create: `lib/funcionalidades/pagamento/dominio/casos_uso/caso_uso_verificar_pagamento.dart`
- Modify: `lib/aplicativo/injecao.dart` (adicionar providers da feature pagamento)
- Test: `test/funcionalidades/pagamento/pagamento_test.dart`

**Interfaces:**
- Consumes: `Pagamento`, `DadosPix`, `StatusPagamento`, `MetodoPagamento` (Task 4), `Resultado`/`Falha` (Task 2).
- Produces:
  - `FontePagamentoMock({Duration atraso = Duration(milliseconds: 900)})` com `Future<DadosPix> gerarPix({required String chaveIdempotencia, required int valorCentavos})`, `Future<Pagamento> processar(Pagamento pagamento)` (idempotente: mesmo `pagamento.id` devolve o resultado já processado sem reprocessar), `StatusPagamento consultarStatus(String pagamentoId)`, `int get execucoesProcessar`.
  - `abstract interface class RepositorioPagamento { Future<Resultado<DadosPix>> gerarPix({required String chaveIdempotencia, required int valorCentavos}); Future<Resultado<Pagamento>> processarPagamento(Pagamento pagamento); Future<Resultado<StatusPagamento>> verificarPagamento(String pagamentoId); }`
  - `CasoUsoGerarPix(RepositorioPagamento)` com `executar({required String chaveIdempotencia, required int valorCentavos})` — valida `valorCentavos > 0` senão `Erro(FalhaValidacao('O valor do pagamento deve ser maior que zero.'))`.
  - `CasoUsoProcessarPagamento(RepositorioPagamento)` com `executar(Pagamento pagamento)`.
  - `CasoUsoVerificarPagamento(RepositorioPagamento)` com `executar(String pagamentoId)`.

- [ ] **Step 1: Escrever o teste que falha**

`test/funcionalidades/pagamento/pagamento_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/repositorios/repositorio_pagamento_impl.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/dados_pix.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/status_pagamento.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter_test/flutter_test.dart';

Pagamento _pagamento(String id) => Pagamento(
      id: id,
      valorCentavos: 13600,
      gorjetaCentavos: 1360,
      totalCentavos: 14960,
      metodo: MetodoPagamento.pix,
      status: StatusPagamento.processando,
      criadoEm: DateTime(2026, 7, 6),
      atualizadoEm: DateTime(2026, 7, 6),
      comandaIds: const ['c1'],
    );

void main() {
  late FontePagamentoMock fonte;
  late RepositorioPagamentoImpl repositorio;

  setUp(() {
    fonte = FontePagamentoMock(atraso: Duration.zero);
    repositorio = RepositorioPagamentoImpl(fonte);
  });

  test('gerarPix devolve dados com o valor e expiracao futura', () async {
    final casoUso = CasoUsoGerarPix(repositorio);
    final resultado = await casoUso.executar(chaveIdempotencia: 'chave-1', valorCentavos: 14960);
    final dados = (resultado as Sucesso<DadosPix>).valor;
    expect(dados.valorCentavos, 14960);
    expect(dados.copiaCola, isNotEmpty);
    expect(dados.qrCode, dados.copiaCola);
    expect(dados.expiraEm.isAfter(DateTime.now()), isTrue);
  });

  test('gerarPix com valor zero devolve FalhaValidacao', () async {
    final casoUso = CasoUsoGerarPix(repositorio);
    final resultado = await casoUso.executar(chaveIdempotencia: 'chave-1', valorCentavos: 0);
    expect(resultado, isA<Erro<DadosPix>>());
    expect((resultado as Erro<DadosPix>).falha, isA<FalhaValidacao>());
  });

  test('processar aprova o pagamento', () async {
    final casoUso = CasoUsoProcessarPagamento(repositorio);
    final resultado = await casoUso.executar(_pagamento('pag-1'));
    final aprovado = (resultado as Sucesso<Pagamento>).valor;
    expect(aprovado.status, StatusPagamento.aprovado);
    expect(aprovado.totalCentavos, 14960);
  });

  test('processar e idempotente: mesmo id nao reprocessa', () async {
    final casoUso = CasoUsoProcessarPagamento(repositorio);
    final primeiro = await casoUso.executar(_pagamento('pag-1'));
    final segundo = await casoUso.executar(_pagamento('pag-1'));
    expect((primeiro as Sucesso<Pagamento>).valor, (segundo as Sucesso<Pagamento>).valor);
    expect(fonte.execucoesProcessar, 1);
  });

  test('consultarStatus devolve aprovado apos processar e aguardando antes', () {
    expect(fonte.consultarStatus('nao-existe'), StatusPagamento.aguardando);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/pagamento/pagamento_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart`:

```dart
import '../../dominio/entidades/dados_pix.dart';
import '../../dominio/entidades/pagamento.dart';
import '../../dominio/entidades/status_pagamento.dart';

/// Fonte MOCK de pagamento. Sempre aprova após um atraso simulado.
/// O payload Pix é claramente rotulado como MOCK — não é um Pix real.
class FontePagamentoMock {
  FontePagamentoMock({this.atraso = const Duration(milliseconds: 900)});

  final Duration atraso;

  final Map<String, Pagamento> _processados = {};

  int execucoesProcessar = 0;

  Future<DadosPix> gerarPix({
    required String chaveIdempotencia,
    required int valorCentavos,
  }) async {
    await Future<void>.delayed(atraso);
    final payload = '00020126-CONSTEL-PAY-MOCK-$chaveIdempotencia-$valorCentavos';
    return DadosPix(
      qrCode: payload,
      copiaCola: payload,
      valorCentavos: valorCentavos,
      expiraEm: DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  Future<Pagamento> processar(Pagamento pagamento) async {
    final existente = _processados[pagamento.id];
    if (existente != null) return existente;
    execucoesProcessar++;
    await Future<void>.delayed(atraso);
    final aprovado = pagamento.copyWith(
      status: StatusPagamento.aprovado,
      atualizadoEm: DateTime.now(),
    );
    _processados[pagamento.id] = aprovado;
    return aprovado;
  }

  StatusPagamento consultarStatus(String pagamentoId) =>
      _processados[pagamentoId]?.status ?? StatusPagamento.aguardando;
}
```

`lib/funcionalidades/pagamento/dominio/repositorios/repositorio_pagamento.dart`:

```dart
import '../../../../nucleo/erros/resultado.dart';
import '../entidades/dados_pix.dart';
import '../entidades/pagamento.dart';
import '../entidades/status_pagamento.dart';

abstract interface class RepositorioPagamento {
  Future<Resultado<DadosPix>> gerarPix({
    required String chaveIdempotencia,
    required int valorCentavos,
  });

  Future<Resultado<Pagamento>> processarPagamento(Pagamento pagamento);

  Future<Resultado<StatusPagamento>> verificarPagamento(String pagamentoId);
}
```

`lib/funcionalidades/pagamento/dados/repositorios/repositorio_pagamento_impl.dart`:

```dart
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/dados_pix.dart';
import '../../dominio/entidades/pagamento.dart';
import '../../dominio/entidades/status_pagamento.dart';
import '../../dominio/repositorios/repositorio_pagamento.dart';
import '../fontes_dados/fonte_pagamento_mock.dart';

class RepositorioPagamentoImpl implements RepositorioPagamento {
  RepositorioPagamentoImpl(this._fonte);

  final FontePagamentoMock _fonte;

  @override
  Future<Resultado<DadosPix>> gerarPix({
    required String chaveIdempotencia,
    required int valorCentavos,
  }) async {
    try {
      return Sucesso(await _fonte.gerarPix(
        chaveIdempotencia: chaveIdempotencia,
        valorCentavos: valorCentavos,
      ));
    } catch (_) {
      return const Erro(FalhaDesconhecida());
    }
  }

  @override
  Future<Resultado<Pagamento>> processarPagamento(Pagamento pagamento) async {
    try {
      return Sucesso(await _fonte.processar(pagamento));
    } catch (_) {
      return const Erro(FalhaDesconhecida());
    }
  }

  @override
  Future<Resultado<StatusPagamento>> verificarPagamento(String pagamentoId) async {
    return Sucesso(_fonte.consultarStatus(pagamentoId));
  }
}
```

`lib/funcionalidades/pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart`:

```dart
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../entidades/dados_pix.dart';
import '../repositorios/repositorio_pagamento.dart';

class CasoUsoGerarPix {
  CasoUsoGerarPix(this._repositorio);

  final RepositorioPagamento _repositorio;

  Future<Resultado<DadosPix>> executar({
    required String chaveIdempotencia,
    required int valorCentavos,
  }) async {
    if (valorCentavos <= 0) {
      return const Erro(FalhaValidacao('O valor do pagamento deve ser maior que zero.'));
    }
    return _repositorio.gerarPix(
      chaveIdempotencia: chaveIdempotencia,
      valorCentavos: valorCentavos,
    );
  }
}
```

`lib/funcionalidades/pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart`:

```dart
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../entidades/pagamento.dart';
import '../repositorios/repositorio_pagamento.dart';

class CasoUsoProcessarPagamento {
  CasoUsoProcessarPagamento(this._repositorio);

  final RepositorioPagamento _repositorio;

  Future<Resultado<Pagamento>> executar(Pagamento pagamento) async {
    if (pagamento.totalCentavos <= 0) {
      return const Erro(FalhaValidacao('O valor do pagamento deve ser maior que zero.'));
    }
    if (pagamento.totalCentavos != pagamento.valorCentavos + pagamento.gorjetaCentavos) {
      return const Erro(FalhaValidacao('Os valores do pagamento não conferem.'));
    }
    return _repositorio.processarPagamento(pagamento);
  }
}
```

`lib/funcionalidades/pagamento/dominio/casos_uso/caso_uso_verificar_pagamento.dart`:

```dart
import '../../../../nucleo/erros/resultado.dart';
import '../entidades/status_pagamento.dart';
import '../repositorios/repositorio_pagamento.dart';

class CasoUsoVerificarPagamento {
  CasoUsoVerificarPagamento(this._repositorio);

  final RepositorioPagamento _repositorio;

  Future<Resultado<StatusPagamento>> executar(String pagamentoId) =>
      _repositorio.verificarPagamento(pagamentoId);
}
```

Adicionar em `lib/aplicativo/injecao.dart`:

```dart
final provedorFontePagamentoMock = Provider<FontePagamentoMock>((ref) => FontePagamentoMock());

final provedorRepositorioPagamento = Provider<RepositorioPagamento>(
  (ref) => RepositorioPagamentoImpl(ref.watch(provedorFontePagamentoMock)),
);

final provedorCasoUsoGerarPix = Provider<CasoUsoGerarPix>(
  (ref) => CasoUsoGerarPix(ref.watch(provedorRepositorioPagamento)),
);

final provedorCasoUsoProcessarPagamento = Provider<CasoUsoProcessarPagamento>(
  (ref) => CasoUsoProcessarPagamento(ref.watch(provedorRepositorioPagamento)),
);

final provedorCasoUsoVerificarPagamento = Provider<CasoUsoVerificarPagamento>(
  (ref) => CasoUsoVerificarPagamento(ref.watch(provedorRepositorioPagamento)),
);
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/funcionalidades/pagamento/pagamento_test.dart`
Expected: PASS (5 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: pagamento mock com idempotencia e casos de uso Pix" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 13: Controlador do fluxo de pagamento (chat)

**Files:**
- Create: `lib/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart`
- Create: `lib/funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart`
- Test: `test/funcionalidades/chat/controlador_fluxo_pagamento_test.dart`

**Interfaces:**
- Consumes: `CasoUsoLerCartao`, `RepositorioLeitura` (Task 11), `CasoUsoGerarPix`, `CasoUsoProcessarPagamento` (Task 12), `RepositorioConfiguracao` (Task 7), entidades (Task 4), `FormatadorMoeda` (Task 3).
- Produces:
  - `enum EtapaFluxo { inicial, lendo, aguardandoMaisCartoes, gorjeta, escolhaMetodo, pixAguardando, processando, sucessoComRestante, sucessoCompleto, encerramento }`
  - `EstadoFluxoPagamento` (Freezed): `{etapa=inicial, mensagens=[], mesa?, cartoes=[], cartoesRestantes=0, gorjetaPercentual=0, dadosPix?, digitando=false, copiado=false}` + getters `selecionados` (cartões `selecionado && !pago`), `subtotalCentavos`, `gorjetaCentavos` (arredondado: `((subtotal * pct) / 100).round()`), `totalCentavos`.
  - `ControladorFluxoPagamento extends StateNotifier<EstadoFluxoPagamento>` com métodos: `iniciar()`, `lerCartao()`, `lerOutroCartao()`, `irParaPagamento()`, `definirGorjeta(int percentual)`, `selecionarMetodo(MetodoPagamento)`, `confirmarPagamentoPix()`, `marcarCopiado()`, `verItens(String comandaId)`, `pagarRestante()`, `encerrar()`, `novaOperacao()`.
  - `provedorFluxoPagamento` (`StateNotifierProvider<ControladorFluxoPagamento, EstadoFluxoPagamento>`).
  - Convenções de `Mensagem.dados`: `leituraCartao`/`detalhe` → `{'comandaId': String}`; `sucesso` → `{'valorCentavos': int, 'comandas': List<String>}`; `comprovante` → `{'id', 'valorCentavos', 'metodo' (name), 'comandas', 'dataHora' (ISO), 'nomeRestaurante'}`.

- [ ] **Step 1: Escrever os testes que falham**

`test/funcionalidades/chat/controlador_fluxo_pagamento_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/chat/dominio/entidades/tipo_mensagem.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/repositorios/repositorio_leitura_impl.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/repositorios/repositorio_pagamento_impl.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepositorioConfiguracaoFake implements RepositorioConfiguracao {
  @override
  Future<ConfiguracaoTerminal> obter() async =>
      const ConfiguracaoTerminal(nomeRestaurante: 'Durango Burgers');

  @override
  Future<void> salvar(ConfiguracaoTerminal configuracao) async {}
}

void main() {
  late FontePagamentoMock fontePagamento;
  late RepositorioLeituraImpl repositorioLeitura;
  late ControladorFluxoPagamento controlador;

  setUp(() {
    final fonteLeitura = FonteLeituraMock(atraso: Duration.zero);
    fontePagamento = FontePagamentoMock(atraso: Duration.zero);
    repositorioLeitura = RepositorioLeituraImpl(fonteLeitura);
    final repositorioPagamento = RepositorioPagamentoImpl(fontePagamento);
    controlador = ControladorFluxoPagamento(
      casoUsoLerCartao: CasoUsoLerCartao(repositorioLeitura),
      repositorioLeitura: repositorioLeitura,
      casoUsoGerarPix: CasoUsoGerarPix(repositorioPagamento),
      casoUsoProcessarPagamento: CasoUsoProcessarPagamento(repositorioPagamento),
      repositorioConfiguracao: _RepositorioConfiguracaoFake(),
      atrasoBot: Duration.zero,
    );
  });

  Future<void> irAteEscolhaMetodo({int gorjeta = 10}) async {
    await controlador.iniciar();
    await controlador.lerCartao();
    await controlador.irParaPagamento();
    await controlador.definirGorjeta(gorjeta);
  }

  test('iniciar apresenta boas-vindas e scanner', () async {
    await controlador.iniciar();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.lendo);
    expect(estado.mensagens.map((m) => m.tipo),
        containsAllInOrder([TipoMensagem.texto, TipoMensagem.texto, TipoMensagem.scanner]));
  });

  test('iniciar duas vezes nao duplica mensagens', () async {
    await controlador.iniciar();
    final quantidade = controlador.state.mensagens.length;
    await controlador.iniciar();
    expect(controlador.state.mensagens.length, quantidade);
  });

  test('primeira leitura identifica a mesa e seleciona a comanda', () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.aguardandoMaisCartoes);
    expect(estado.mesa?.numero, 12);
    expect(estado.cartoes, hasLength(1));
    expect(estado.selecionados, hasLength(1));
    expect(estado.subtotalCentavos, 13600);
    expect(estado.cartoesRestantes, 2);
    expect(estado.mensagens.any((m) => m.tipo == TipoMensagem.mesa), isTrue);
    expect(estado.mensagens.any((m) => m.tipo == TipoMensagem.leituraCartao), isTrue);
  });

  test('lerCartao fora da etapa lendo e ignorado', () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    final quantidade = controlador.state.mensagens.length;
    await controlador.lerCartao();
    expect(controlador.state.mensagens.length, quantidade);
  });

  test('gorjeta de 10% calcula os totais corretamente', () async {
    await irAteEscolhaMetodo();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.escolhaMetodo);
    expect(estado.subtotalCentavos, 13600);
    expect(estado.gorjetaCentavos, 1360);
    expect(estado.totalCentavos, 14960);
    expect(estado.mensagens.any((m) => m.tipo == TipoMensagem.metodos), isTrue);
  });

  test('selecionar Pix gera dados e vai para pixAguardando', () async {
    await irAteEscolhaMetodo();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.pixAguardando);
    expect(estado.dadosPix?.valorCentavos, 14960);
    expect(estado.mensagens.any((m) => m.tipo == TipoMensagem.pix), isTrue);
  });

  test('selecionar metodo indisponivel mantem a etapa de escolha', () async {
    await irAteEscolhaMetodo();
    await controlador.selecionarMetodo(MetodoPagamento.credito);
    expect(controlador.state.etapa, EtapaFluxo.escolhaMetodo);
    expect(controlador.state.dadosPix, isNull);
  });

  test('confirmar pagamento quita a comanda e informa restantes', () async {
    await irAteEscolhaMetodo();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.sucessoComRestante);
    expect(estado.cartoes.single.pago, isTrue);
    expect(estado.selecionados, isEmpty);
    final sucesso = estado.mensagens.lastWhere((m) => m.tipo == TipoMensagem.sucesso);
    expect(sucesso.dados?['valorCentavos'], 14960);
    expect(sucesso.dados?['comandas'], ['Comanda 01']);
  });

  test('fluxo completo das 3 comandas termina em sucessoCompleto', () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    await controlador.lerOutroCartao();
    await controlador.lerCartao();
    await controlador.lerOutroCartao();
    await controlador.lerCartao();
    expect(controlador.state.cartoesRestantes, 0);
    expect(controlador.state.subtotalCentavos, 31800);
    await controlador.irParaPagamento();
    await controlador.definirGorjeta(0);
    expect(controlador.state.totalCentavos, 31800);
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
    expect(controlador.state.etapa, EtapaFluxo.sucessoCompleto);
  });

  test('encerrar exibe o comprovante com o nome do restaurante', () async {
    await irAteEscolhaMetodo();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
    await controlador.encerrar();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.encerramento);
    final comprovante = estado.mensagens.lastWhere((m) => m.tipo == TipoMensagem.comprovante);
    expect(comprovante.dados?['nomeRestaurante'], 'Durango Burgers');
    expect(comprovante.dados?['valorCentavos'], 14960);
  });

  test('pagarRestante volta ao scanner', () async {
    await irAteEscolhaMetodo();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
    await controlador.pagarRestante();
    expect(controlador.state.etapa, EtapaFluxo.lendo);
  });

  test('novaOperacao reseta tudo e permite reler os cartoes', () async {
    await irAteEscolhaMetodo();
    controlador.novaOperacao();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.inicial);
    expect(estado.mensagens, isEmpty);
    expect(estado.cartoes, isEmpty);
    expect(repositorioLeitura.cartoesRestantes, 3);
  });

  test('verItens adiciona mensagem de detalhe da comanda', () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    controlador.verItens('c1');
    final detalhe = controlador.state.mensagens.last;
    expect(detalhe.tipo, TipoMensagem.detalhe);
    expect(detalhe.dados?['comandaId'], 'c1');
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/chat/controlador_fluxo_pagamento_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar o estado**

`lib/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../leitura_cartao/dominio/entidades/cartao_consumo.dart';
import '../../../leitura_cartao/dominio/entidades/mesa.dart';
import '../../../pagamento/dominio/entidades/dados_pix.dart';
import '../../dominio/entidades/mensagem.dart';

part 'estado_fluxo_pagamento.freezed.dart';

enum EtapaFluxo {
  inicial,
  lendo,
  aguardandoMaisCartoes,
  gorjeta,
  escolhaMetodo,
  pixAguardando,
  processando,
  sucessoComRestante,
  sucessoCompleto,
  encerramento,
}

@freezed
class EstadoFluxoPagamento with _$EstadoFluxoPagamento {
  const EstadoFluxoPagamento._();

  const factory EstadoFluxoPagamento({
    @Default(EtapaFluxo.inicial) EtapaFluxo etapa,
    @Default([]) List<Mensagem> mensagens,
    Mesa? mesa,
    @Default([]) List<CartaoConsumo> cartoes,
    @Default(0) int cartoesRestantes,
    @Default(0) int gorjetaPercentual,
    DadosPix? dadosPix,
    @Default(false) bool digitando,
    @Default(false) bool copiado,
  }) = _EstadoFluxoPagamento;

  List<CartaoConsumo> get selecionados =>
      cartoes.where((c) => c.selecionado && !c.pago).toList();

  int get subtotalCentavos =>
      selecionados.fold(0, (acumulado, c) => acumulado + c.subtotalCentavos);

  int get gorjetaCentavos => ((subtotalCentavos * gorjetaPercentual) / 100).round();

  int get totalCentavos => subtotalCentavos + gorjetaCentavos;
}
```

- [ ] **Step 4: Implementar o controlador**

`lib/funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../comprovante/dominio/entidades/comprovante.dart';
import '../../../configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import '../../../leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart';
import '../../../leitura_cartao/dominio/repositorios/repositorio_leitura.dart';
import '../../../pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart';
import '../../../pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';
import '../../../pagamento/dominio/entidades/pagamento.dart';
import '../../../pagamento/dominio/entidades/status_pagamento.dart';
import '../../dominio/entidades/mensagem.dart';
import '../../dominio/entidades/tipo_mensagem.dart';
import 'estado_fluxo_pagamento.dart';

class ControladorFluxoPagamento extends StateNotifier<EstadoFluxoPagamento> {
  ControladorFluxoPagamento({
    required CasoUsoLerCartao casoUsoLerCartao,
    required RepositorioLeitura repositorioLeitura,
    required CasoUsoGerarPix casoUsoGerarPix,
    required CasoUsoProcessarPagamento casoUsoProcessarPagamento,
    required RepositorioConfiguracao repositorioConfiguracao,
    this.atrasoBot = const Duration(milliseconds: 650),
  })  : _casoUsoLerCartao = casoUsoLerCartao,
        _repositorioLeitura = repositorioLeitura,
        _casoUsoGerarPix = casoUsoGerarPix,
        _casoUsoProcessarPagamento = casoUsoProcessarPagamento,
        _repositorioConfiguracao = repositorioConfiguracao,
        super(const EstadoFluxoPagamento());

  final CasoUsoLerCartao _casoUsoLerCartao;
  final RepositorioLeitura _repositorioLeitura;
  final CasoUsoGerarPix _casoUsoGerarPix;
  final CasoUsoProcessarPagamento _casoUsoProcessarPagamento;
  final RepositorioConfiguracao _repositorioConfiguracao;
  final Duration atrasoBot;

  static const Uuid _uuid = Uuid();

  int _proximoIdMensagem = 1;
  String? _chaveIdempotencia;
  Comprovante? _ultimoComprovante;

  // ---- auxiliares ----

  Mensagem _mensagem(
    TipoMensagem tipo, {
    LadoMensagem lado = LadoMensagem.assistente,
    String? texto,
    String? subtexto,
    String? emoji,
    Map<String, dynamic>? dados,
  }) =>
      Mensagem(
        id: _proximoIdMensagem++,
        tipo: tipo,
        lado: lado,
        texto: texto,
        subtexto: subtexto,
        emoji: emoji,
        dados: dados,
      );

  void _adicionar(Mensagem mensagem) =>
      state = state.copyWith(mensagens: [...state.mensagens, mensagem]);

  Future<void> _bot(void Function() acao) async {
    state = state.copyWith(digitando: true);
    await Future<void>.delayed(atrasoBot);
    if (!mounted) return;
    state = state.copyWith(digitando: false);
    acao();
  }

  // ---- fluxo ----

  Future<void> iniciar() async {
    if (state.etapa != EtapaFluxo.inicial) return;
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '🍽️',
          texto: 'Olá! Bem-vindo(a). Vou fechar sua conta em segundos. 😊'));
      _adicionar(_mensagem(TipoMensagem.texto,
          texto:
              'Para começar, aponte a câmera para o código do seu cartão de consumo 👇'));
      _adicionar(_mensagem(TipoMensagem.scanner));
    });
  }

  Future<void> lerCartao() async {
    if (state.etapa != EtapaFluxo.lendo || state.digitando) return;
    state = state.copyWith(digitando: true);
    final primeiraLeitura = state.cartoes.isEmpty;
    if (primeiraLeitura) {
      final resultadoMesa = await _repositorioLeitura.obterMesa();
      resultadoMesa.quando(
        sucesso: (mesa) => state = state.copyWith(mesa: mesa),
        erro: (_) {},
      );
    }
    final resultado = await _casoUsoLerCartao.executar();
    if (!mounted) return;
    state = state.copyWith(digitando: false);
    resultado.quando(
      sucesso: (cartao) {
        state = state.copyWith(
          cartoes: [...state.cartoes, cartao.copyWith(selecionado: true)],
          cartoesRestantes: _repositorioLeitura.cartoesRestantes,
        );
        if (primeiraLeitura && state.mesa != null) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '📍',
              texto:
                  'Cartão lido! Identificamos sua mesa: Mesa ${state.mesa!.numero} 🪑'));
          _adicionar(_mensagem(TipoMensagem.mesa));
        }
        _adicionar(_mensagem(TipoMensagem.leituraCartao, dados: {'comandaId': cartao.id}));
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '✅',
            texto: state.cartoesRestantes > 0
                ? 'Deseja adicionar mais cartões da mesa?'
                : 'Esse foi o último cartão em aberto da mesa.'));
        state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
      },
      erro: (falha) {
        _adicionar(_mensagem(TipoMensagem.texto, emoji: '⚠️', texto: falha.mensagem));
        state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
      },
    );
  }

  Future<void> lerOutroCartao() async {
    if (state.etapa != EtapaFluxo.aguardandoMaisCartoes) return;
    _adicionar(
        _mensagem(TipoMensagem.texto, lado: LadoMensagem.cliente, texto: 'Ler outro cartão'));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(
          _mensagem(TipoMensagem.texto, texto: 'Beleza! Aponte para o próximo código 👇'));
      _adicionar(_mensagem(TipoMensagem.scanner));
    });
  }

  Future<void> irParaPagamento() async {
    if (state.etapa != EtapaFluxo.aguardandoMaisCartoes || state.selecionados.isEmpty) return;
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente,
        texto: 'Ir para o pagamento · ${FormatadorMoeda.formatar(state.subtotalCentavos)}'));
    state = state.copyWith(etapa: EtapaFluxo.gorjeta);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '💜',
          texto: 'Deseja incluir os 10% de serviço (gorjeta)?',
          subtexto: 'É opcional e vai direto para a equipe que te atendeu.'));
    });
  }

  Future<void> definirGorjeta(int percentual) async {
    if (state.etapa != EtapaFluxo.gorjeta) return;
    state = state.copyWith(gorjetaPercentual: percentual);
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente,
        texto: percentual > 0 ? 'Sim, incluir os $percentual%' : 'Sem taxa de serviço'));
    _chaveIdempotencia = _uuid.v4();
    state = state.copyWith(etapa: EtapaFluxo.escolhaMetodo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '💳',
          texto: 'Como você quer pagar ${FormatadorMoeda.formatar(state.totalCentavos)}?',
          subtexto: percentual > 0
              ? 'Inclui ${FormatadorMoeda.formatar(state.gorjetaCentavos)} de serviço.'
              : 'Sem taxa de serviço.'));
      _adicionar(_mensagem(TipoMensagem.metodos));
    });
  }

  Future<void> selecionarMetodo(MetodoPagamento metodo) async {
    if (state.etapa != EtapaFluxo.escolhaMetodo || state.digitando) return;
    _adicionar(
        _mensagem(TipoMensagem.texto, lado: LadoMensagem.cliente, texto: metodo.rotulo));
    if (metodo != MetodoPagamento.pix) {
      await _bot(() {
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: 'ℹ️',
            texto:
                'Este método ainda não está disponível neste terminal. Use o Pix por enquanto. 😉'));
      });
      return;
    }
    state = state.copyWith(digitando: true, copiado: false);
    final resultado = await _casoUsoGerarPix.executar(
      chaveIdempotencia: _chaveIdempotencia!,
      valorCentavos: state.totalCentavos,
    );
    if (!mounted) return;
    state = state.copyWith(digitando: false);
    resultado.quando(
      sucesso: (dados) {
        state = state.copyWith(dadosPix: dados, etapa: EtapaFluxo.pixAguardando);
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '📲', texto: 'Pronto! Escaneie o QR Code ou copie o código Pix 👇'));
        _adicionar(_mensagem(TipoMensagem.pix));
      },
      erro: (falha) {
        _adicionar(_mensagem(TipoMensagem.texto, emoji: '⚠️', texto: falha.mensagem));
      },
    );
  }

  void marcarCopiado() => state = state.copyWith(copiado: true);

  Future<void> confirmarPagamentoPix() async {
    if (state.etapa != EtapaFluxo.pixAguardando || state.digitando) return;
    state = state.copyWith(etapa: EtapaFluxo.processando, digitando: true);
    final selecionados = state.selecionados;
    final agora = DateTime.now();
    final pagamento = Pagamento(
      id: _chaveIdempotencia!,
      valorCentavos: state.subtotalCentavos,
      gorjetaCentavos: state.gorjetaCentavos,
      totalCentavos: state.totalCentavos,
      metodo: MetodoPagamento.pix,
      status: StatusPagamento.processando,
      criadoEm: agora,
      atualizadoEm: agora,
      comandaIds: selecionados.map((c) => c.id).toList(),
    );
    final resultado = await _casoUsoProcessarPagamento.executar(pagamento);
    if (!mounted) return;
    state = state.copyWith(digitando: false);
    final configuracao = await _repositorioConfiguracao.obter();
    if (!mounted) return;
    resultado.quando(
      sucesso: (aprovado) {
        if (aprovado.status != StatusPagamento.aprovado) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '❌',
              texto:
                  'Pagamento ${aprovado.status.rotulo.toLowerCase()}. Tente novamente.'));
          state = state.copyWith(etapa: EtapaFluxo.pixAguardando);
          return;
        }
        final nomes = selecionados.map((c) => c.nome).toList();
        final cartoesAtualizados = state.cartoes
            .map((c) =>
                c.selecionado && !c.pago ? c.copyWith(pago: true, selecionado: false) : c)
            .toList();
        state = state.copyWith(cartoes: cartoesAtualizados, gorjetaPercentual: 0);
        _adicionar(_mensagem(TipoMensagem.sucesso,
            dados: {'valorCentavos': aprovado.totalCentavos, 'comandas': nomes}));
        _ultimoComprovante = Comprovante(
          id: _uuid.v4(),
          pagamentoId: aprovado.id,
          valorCentavos: aprovado.totalCentavos,
          metodo: aprovado.metodo,
          comandas: nomes,
          dataHora: DateTime.now(),
          nomeRestaurante: configuracao.nomeRestaurante,
        );
        _chaveIdempotencia = null;
        final restantes = state.cartoesRestantes;
        if (restantes > 0) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '🧾',
              texto:
                  'Ainda há $restantes ${restantes > 1 ? 'comandas' : 'comanda'} em aberto na mesa. Quer pagar agora?'));
          state = state.copyWith(etapa: EtapaFluxo.sucessoComRestante);
        } else {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '🥳', texto: 'Tudo certo! Sua mesa está totalmente quitada.'));
          state = state.copyWith(etapa: EtapaFluxo.sucessoCompleto);
        }
      },
      erro: (falha) {
        _adicionar(_mensagem(TipoMensagem.texto, emoji: '⚠️', texto: falha.mensagem));
        state = state.copyWith(etapa: EtapaFluxo.pixAguardando);
      },
    );
  }

  void verItens(String comandaId) =>
      _adicionar(_mensagem(TipoMensagem.detalhe, dados: {'comandaId': comandaId}));

  Future<void> pagarRestante() async {
    if (state.etapa != EtapaFluxo.sucessoComRestante) return;
    _adicionar(
        _mensagem(TipoMensagem.texto, lado: LadoMensagem.cliente, texto: 'Pagar restante'));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(
          _mensagem(TipoMensagem.texto, texto: 'Beleza! Aponte para o próximo código 👇'));
      _adicionar(_mensagem(TipoMensagem.scanner));
    });
  }

  Future<void> encerrar() async {
    if (state.etapa != EtapaFluxo.sucessoComRestante &&
        state.etapa != EtapaFluxo.sucessoCompleto) {
      return;
    }
    _adicionar(_mensagem(TipoMensagem.texto, lado: LadoMensagem.cliente, texto: 'Encerrar'));
    state = state.copyWith(etapa: EtapaFluxo.encerramento);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '🙏',
          texto: 'Obrigado pela visita! Volte sempre 💜',
          subtexto: 'Aqui está o seu comprovante.'));
      final comprovante = _ultimoComprovante;
      if (comprovante != null) {
        _adicionar(_mensagem(TipoMensagem.comprovante, dados: {
          'id': comprovante.id,
          'valorCentavos': comprovante.valorCentavos,
          'metodo': comprovante.metodo.name,
          'comandas': comprovante.comandas,
          'dataHora': comprovante.dataHora.toIso8601String(),
          'nomeRestaurante': comprovante.nomeRestaurante,
        }));
      }
    });
  }

  void novaOperacao() {
    _repositorioLeitura.reiniciar();
    _proximoIdMensagem = 1;
    _chaveIdempotencia = null;
    _ultimoComprovante = null;
    state = const EstadoFluxoPagamento();
  }
}

final provedorFluxoPagamento =
    StateNotifierProvider<ControladorFluxoPagamento, EstadoFluxoPagamento>((ref) {
  return ControladorFluxoPagamento(
    casoUsoLerCartao: ref.watch(provedorCasoUsoLerCartao),
    repositorioLeitura: ref.watch(provedorRepositorioLeitura),
    casoUsoGerarPix: ref.watch(provedorCasoUsoGerarPix),
    casoUsoProcessarPagamento: ref.watch(provedorCasoUsoProcessarPagamento),
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    atrasoBot: ref.watch(provedorAtrasoBot),
  );
});
```

- [ ] **Step 5: Gerar código e rodar os testes**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/funcionalidades/chat/controlador_fluxo_pagamento_test.dart
```
Expected: PASS (12 testes).

- [ ] **Step 6: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: controlador do fluxo conversacional de pagamento" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 14: Componentes do chat — parte 1 (bolhas, avatar, banner, cards de mesa/comanda/detalhe)

**Files:**
- Create: `lib/funcionalidades/chat/apresentacao/componentes/avatar_bot.dart`
- Create: `lib/funcionalidades/chat/apresentacao/componentes/bolha_mensagem.dart`
- Create: `lib/funcionalidades/chat/apresentacao/componentes/indicador_digitando.dart`
- Create: `lib/funcionalidades/chat/apresentacao/componentes/banner_boas_vindas.dart`
- Create: `lib/funcionalidades/chat/apresentacao/componentes/card_mesa.dart`
- Create: `lib/funcionalidades/chat/apresentacao/componentes/card_comanda.dart`
- Create: `lib/funcionalidades/chat/apresentacao/componentes/card_detalhe_comanda.dart`
- Test: `test/funcionalidades/chat/componentes_chat_1_test.dart`

**Interfaces:**
- Consumes: `Mensagem`, `TipoMensagem`/`LadoMensagem` (Task 4), `Mesa`, `CartaoConsumo` (Task 4), `CoresApp` (Task 5), `Cartao` (Task 6), `FormatadorMoeda`/`FormatadorData` (Task 3).
- Produces:
  - `AvatarBot({tamanho=34})` — círculo com gradiente primário e emoji 🧑‍🍳.
  - `BolhaMensagem({mensagem})` — assistente: branco à esquerda com avatar; cliente: lilás `#ECE7FF` à direita. Suporta `emoji` (quadro 56x56) e `subtexto`.
  - `IndicadorDigitando()` — avatar + 3 pontos.
  - `BannerBoasVindas({nomeRestaurante})` — círculo 🍽️ + nome + 'Autoatendimento · Pagamento na mesa'.
  - `CardMesa({mesa})` — 🪑, 'Mesa N', 'Aberta às HH:mm · N comandas', selo 'ABERTA', 'Total consumido' + valor.
  - `CardComanda({cartao, aoVerItens})` — check roxo, emoji, nome · pessoa, resumo (ou 'Pago ✓'), link '👁️ ver itens', subtotal. Pago = opacidade 0.6.
  - `CardDetalheComanda({cartao})` — lista de itens (emoji, nome, 'X un · R$ y,zz cada', total da linha) + 'Total da comanda'.

- [ ] **Step 1: Escrever os testes que falham**

`test/funcionalidades/chat/componentes_chat_1_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/bolha_mensagem.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_comanda.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_detalhe_comanda.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_mesa.dart';
import 'package:constel_pay/funcionalidades/chat/dominio/entidades/mensagem.dart';
import 'package:constel_pay/funcionalidades/chat/dominio/entidades/tipo_mensagem.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/mesa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget filho) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: filho)));

void main() {
  testWidgets('BolhaMensagem do assistente mostra texto e subtexto', (tester) async {
    const mensagem = Mensagem(
        id: 1, tipo: TipoMensagem.texto, texto: 'Olá!', subtexto: 'Bem-vindo', emoji: '🍽️');
    await tester.pumpWidget(_app(const BolhaMensagem(mensagem: mensagem)));
    expect(find.text('Olá!'), findsOneWidget);
    expect(find.text('Bem-vindo'), findsOneWidget);
    expect(find.text('🍽️'), findsOneWidget);
  });

  testWidgets('CardMesa mostra numero e total consumido', (tester) async {
    final mesa = Mesa(
        numero: 12,
        abertoEm: DateTime(2026, 7, 6, 19, 42),
        totalComandas: 3,
        totalCentavos: 31800);
    await tester.pumpWidget(_app(CardMesa(mesa: mesa)));
    expect(find.text('Mesa 12'), findsOneWidget);
    expect(find.textContaining('19:42'), findsOneWidget);
    expect(find.text(r'R$ 318,00'), findsOneWidget);
    expect(find.text('ABERTA'), findsOneWidget);
  });

  testWidgets('CardComanda mostra dados e dispara ver itens', (tester) async {
    final cartao = (await FonteLeituraMock(atraso: Duration.zero).lerProximo())!;
    var visto = '';
    await tester.pumpWidget(
        _app(CardComanda(cartao: cartao, aoVerItens: (id) => visto = id)));
    expect(find.textContaining('Comanda 01'), findsOneWidget);
    expect(find.text(r'R$ 136,00'), findsOneWidget);
    await tester.tap(find.textContaining('ver itens'));
    expect(visto, 'c1');
  });

  testWidgets('CardDetalheComanda lista os itens com totais', (tester) async {
    final cartao = (await FonteLeituraMock(atraso: Duration.zero).lerProximo())!;
    await tester.pumpWidget(_app(CardDetalheComanda(cartao: cartao)));
    expect(find.text('Feijoada individual'), findsOneWidget);
    expect(find.textContaining('2 un'), findsOneWidget);
    expect(find.text('Total da comanda'), findsOneWidget);
    expect(find.text(r'R$ 136,00'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/chat/componentes_chat_1_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/funcionalidades/chat/apresentacao/componentes/avatar_bot.dart`:

```dart
import 'package:flutter/material.dart';

class AvatarBot extends StatelessWidget {
  const AvatarBot({super.key, this.tamanho = 34});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaria.withValues(alpha: .85), primaria],
        ),
        boxShadow: [
          BoxShadow(color: primaria.withValues(alpha: .4), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      alignment: Alignment.center,
      child: Text('🧑‍🍳', style: TextStyle(fontSize: tamanho / 2)),
    );
  }
}
```

`lib/funcionalidades/chat/apresentacao/componentes/bolha_mensagem.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../dominio/entidades/mensagem.dart';
import '../../dominio/entidades/tipo_mensagem.dart';
import 'avatar_bot.dart';

class BolhaMensagem extends StatelessWidget {
  const BolhaMensagem({super.key, required this.mensagem});

  final Mensagem mensagem;

  @override
  Widget build(BuildContext context) {
    final assistente = mensagem.lado == LadoMensagem.assistente;
    final bolha = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: assistente ? Colors.white : CoresApp.lilasBolha,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(assistente ? 4 : 18),
          topRight: const Radius.circular(18),
          bottomLeft: const Radius.circular(18),
          bottomRight: Radius.circular(assistente ? 18 : 4),
        ),
        boxShadow: [
          BoxShadow(
            color: CoresApp.textoPrincipal.withValues(alpha: .07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mensagem.emoji != null)
            Container(
              width: 56,
              height: 56,
              margin: const EdgeInsets.only(bottom: 9),
              decoration: BoxDecoration(
                color: CoresApp.lilasClaro,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(mensagem.emoji!, style: const TextStyle(fontSize: 30)),
            ),
          Text(
            mensagem.texto ?? '',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: CoresApp.textoPrincipal,
              height: 1.5,
            ),
          ),
          if (mensagem.subtexto != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                mensagem.subtexto!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: CoresApp.textoSecundario,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
    if (assistente) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AvatarBot(),
          const SizedBox(width: 8),
          Flexible(child: bolha),
          const SizedBox(width: 40),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 60),
        Flexible(child: bolha),
      ],
    );
  }
}
```

`lib/funcionalidades/chat/apresentacao/componentes/indicador_digitando.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import 'avatar_bot.dart';

class IndicadorDigitando extends StatefulWidget {
  const IndicadorDigitando({super.key});

  @override
  State<IndicadorDigitando> createState() => _IndicadorDigitandoState();
}

class _IndicadorDigitandoState extends State<IndicadorDigitando>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AvatarBot(),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CoresApp.textoPrincipal.withValues(alpha: .06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _controlador,
            builder: (contexto, _) => Row(
              children: List.generate(3, (indice) {
                final fase = (_controlador.value * 3 - indice).clamp(0.0, 1.0);
                final opacidade = 0.3 + 0.7 * (1 - (fase - 0.5).abs() * 2).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Opacity(
                    opacity: opacidade,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: CoresApp.textoSecundario,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
```

`lib/funcionalidades/chat/apresentacao/componentes/banner_boas_vindas.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';

class BannerBoasVindas extends StatelessWidget {
  const BannerBoasVindas({super.key, required this.nomeRestaurante});

  final String nomeRestaurante;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 18),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [CoresApp.lilasBolha, CoresApp.lilasClaro],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: .18),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text('🍽️', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 10),
          Text(nomeRestaurante,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          const Text(
            'Autoatendimento · Pagamento na mesa',
            style: TextStyle(fontSize: 12.5, color: CoresApp.textoSecundario),
          ),
        ],
      ),
    );
  }
}
```

`lib/funcionalidades/chat/apresentacao/componentes/card_mesa.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../nucleo/formatadores/formatador_data.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../leitura_cartao/dominio/entidades/mesa.dart';

class CardMesa extends StatelessWidget {
  const CardMesa({super.key, required this.mesa});

  final Mesa mesa;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Cartao(
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CoresApp.lilasClaro,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text('🪑', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mesa ${mesa.numero}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(
                      'Aberta às ${FormatadorData.hora(mesa.abertoEm)} · ${mesa.totalComandas} comandas',
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: CoresApp.textoSecundario,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CoresApp.lilasClaro,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mesa.status == StatusMesa.aberta ? 'ABERTA' : 'FECHADA',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaria),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: CoresApp.bordaCard),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Total consumido',
                  style: TextStyle(
                      fontSize: 12.5,
                      color: CoresApp.textoSecundario,
                      fontWeight: FontWeight.w600)),
              Text(
                FormatadorMoeda.formatar(mesa.totalCentavos),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: primaria),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

`lib/funcionalidades/chat/apresentacao/componentes/card_comanda.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../leitura_cartao/dominio/entidades/cartao_consumo.dart';

class CardComanda extends StatelessWidget {
  const CardComanda({super.key, required this.cartao, this.aoVerItens});

  final CartaoConsumo cartao;
  final void Function(String comandaId)? aoVerItens;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    final marcado = cartao.selecionado || cartao.pago;
    return Opacity(
      opacity: cartao.pago ? .6 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cartao.pago ? const Color(0xFFF6F6F8) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: marcado && !cartao.pago ? primaria : CoresApp.bordaCard,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaria.withValues(alpha: marcado && !cartao.pago ? .2 : .05),
              blurRadius: marcado ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: marcado ? primaria : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: marcado ? primaria : const Color(0xFFDCDBE1), width: 2),
              ),
              alignment: Alignment.center,
              child: marcado
                  ? const Text('✓',
                      style: TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800))
                  : null,
            ),
            const SizedBox(width: 11),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: CoresApp.lilasClaro,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Text(cartao.emoji, style: const TextStyle(fontSize: 25)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: cartao.nome,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: CoresApp.textoPrincipal),
                      children: [
                        TextSpan(
                          text: ' · ${cartao.pessoa}',
                          style: const TextStyle(
                              color: CoresApp.textoSecundario, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cartao.pago ? 'Pago ✓' : cartao.resumo,
                    style: const TextStyle(
                        fontSize: 12,
                        color: CoresApp.textoSecundario,
                        fontWeight: FontWeight.w600),
                  ),
                  if (aoVerItens != null)
                    GestureDetector(
                      onTap: () => aoVerItens!(cartao.id),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          '👁️ ver itens',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700, color: primaria),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              FormatadorMoeda.formatar(cartao.subtotalCentavos),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
```

`lib/funcionalidades/chat/apresentacao/componentes/card_detalhe_comanda.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../leitura_cartao/dominio/entidades/cartao_consumo.dart';

class CardDetalheComanda extends StatelessWidget {
  const CardDetalheComanda({super.key, required this.cartao});

  final CartaoConsumo cartao;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Cartao(
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${cartao.nome} · ${cartao.pessoa}',
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...cartao.itens.map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CoresApp.bordaCard)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CoresApp.fundoPadrao,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(item.emoji, style: const TextStyle(fontSize: 23)),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.nome,
                            style: const TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.w700)),
                        Text(
                          '${item.quantidade} un · ${FormatadorMoeda.formatar(item.valorCentavos)} cada',
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: CoresApp.textoSecundario,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Text(FormatadorMoeda.formatar(item.totalCentavos),
                      style:
                          const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total da comanda',
                  style: TextStyle(
                      fontSize: 13,
                      color: CoresApp.textoSecundario,
                      fontWeight: FontWeight.w700)),
              Text(
                FormatadorMoeda.formatar(cartao.subtotalCentavos),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primaria),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/funcionalidades/chat/componentes_chat_1_test.dart`
Expected: PASS (4 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: componentes do chat (bolhas, mesa, comanda, detalhe)" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 15: Componentes do chat — parte 2 (scanner, métodos, pix, sucesso, comprovante, ações)

**Files:**
- Create: `lib/funcionalidades/chat/apresentacao/componentes/card_scanner.dart`
- Create: `lib/funcionalidades/chat/apresentacao/componentes/card_metodos_pagamento.dart`
- Create: `lib/funcionalidades/chat/apresentacao/componentes/card_pix.dart`
- Create: `lib/funcionalidades/chat/apresentacao/componentes/card_sucesso.dart`
- Create: `lib/funcionalidades/comprovante/apresentacao/componentes/card_comprovante.dart`
- Create: `lib/funcionalidades/chat/apresentacao/componentes/chip_acao.dart`
- Create: `lib/funcionalidades/chat/apresentacao/componentes/barra_total.dart`
- Test: `test/funcionalidades/chat/componentes_chat_2_test.dart`

**Interfaces:**
- Consumes: `DadosPix`, `MetodoPagamento` (Task 4), `Comprovante` via Map (convenção Task 13), `FormatadorMoeda`/`FormatadorData` (Task 3), `BotaoPrimario` (Task 6), `qr_flutter`.
- Produces:
  - `CardScanner({aoEscanear, habilitado=true})` — caixa escura com cantos roxos, linha de scan animada (AnimationController repetindo — testes NÃO devem usar `pumpAndSettle`), botão '📷 Simular leitura do código' (desabilitado quando `!habilitado`).
  - `CardMetodosPagamento({metodos, aoSelecionar, habilitado=true})` — grade 2 colunas de cards (emoji, rotulo, descricao).
  - `CardPix({dadosPix, copiado, aoCopiar, aoConfirmar, habilitado=true})` — 'Pague com Pix', valor, `QrImageView` 172px, botão lilás 'Copiar código Pix'/'Código copiado ✓', `BotaoPrimario` 'Já fiz o pagamento', texto 'Válido por 5 minutos'.
  - `CardSucesso({valorCentavos, comandas})` — círculo ✓ gradiente, 'Pagamento aprovado! 🎉', valor, chips '✓ <comanda>'.
  - `CardComprovante({valorCentavos, metodoNome, comandas, dataHora, nomeRestaurante, comprovanteId})` — recibo com linhas: restaurante, data/hora formatada, comandas, método, valor, id.
  - `ChipAcao({rotulo, aoTocar, primario=false})` — pílula.
  - `BarraTotal({rotulo, valorCentavos})` — fundo lilás claro, rotulo à esquerda, valor à direita.

- [ ] **Step 1: Escrever os testes que falham**

`test/funcionalidades/chat/componentes_chat_2_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/barra_total.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_metodos_pagamento.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_pix.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_scanner.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_sucesso.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/chip_acao.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/dados_pix.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget filho) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: filho)));

void main() {
  testWidgets('CardScanner dispara aoEscanear quando habilitado', (tester) async {
    var escaneou = false;
    await tester.pumpWidget(_app(CardScanner(aoEscanear: () => escaneou = true)));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.textContaining('Simular leitura'));
    expect(escaneou, isTrue);
  });

  testWidgets('CardScanner desabilitado nao dispara', (tester) async {
    var escaneou = false;
    await tester.pumpWidget(
        _app(CardScanner(aoEscanear: () => escaneou = true, habilitado: false)));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.textContaining('Simular leitura'), warnIfMissed: false);
    expect(escaneou, isFalse);
  });

  testWidgets('CardMetodosPagamento lista os metodos e seleciona', (tester) async {
    MetodoPagamento? escolhido;
    await tester.pumpWidget(_app(CardMetodosPagamento(
      metodos: const [MetodoPagamento.pix, MetodoPagamento.credito],
      aoSelecionar: (metodo) => escolhido = metodo,
    )));
    expect(find.text('Pix'), findsOneWidget);
    expect(find.text('Crédito'), findsOneWidget);
    await tester.tap(find.text('Pix'));
    expect(escolhido, MetodoPagamento.pix);
  });

  testWidgets('CardPix mostra valor, copia e confirma', (tester) async {
    var copiou = false;
    var confirmou = false;
    final dados = DadosPix(
      qrCode: 'MOCK-PIX-123',
      copiaCola: 'MOCK-PIX-123',
      valorCentavos: 14960,
      expiraEm: DateTime.now().add(const Duration(minutes: 5)),
    );
    await tester.pumpWidget(_app(CardPix(
      dadosPix: dados,
      copiado: false,
      aoCopiar: () => copiou = true,
      aoConfirmar: () => confirmou = true,
    )));
    expect(find.text(r'R$ 149,60'), findsOneWidget);
    await tester.tap(find.textContaining('Copiar código'));
    expect(copiou, isTrue);
    await tester.tap(find.text('Já fiz o pagamento'));
    expect(confirmou, isTrue);
  });

  testWidgets('CardSucesso mostra valor e comandas quitadas', (tester) async {
    await tester.pumpWidget(_app(const CardSucesso(
      valorCentavos: 14960,
      comandas: ['Comanda 01', 'Comanda 02'],
    )));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('aprovado'), findsOneWidget);
    expect(find.text(r'R$ 149,60'), findsOneWidget);
    expect(find.text('✓ Comanda 01'), findsOneWidget);
    expect(find.text('✓ Comanda 02'), findsOneWidget);
  });

  testWidgets('ChipAcao e BarraTotal renderizam', (tester) async {
    var tocado = false;
    await tester.pumpWidget(_app(Column(children: [
      ChipAcao(rotulo: 'Encerrar', aoTocar: () => tocado = true, primario: true),
      const BarraTotal(rotulo: '2 cartões', valorCentavos: 23800),
    ])));
    await tester.tap(find.text('Encerrar'));
    expect(tocado, isTrue);
    expect(find.text(r'R$ 238,00'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/chat/componentes_chat_2_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/funcionalidades/chat/apresentacao/componentes/card_scanner.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/cartao.dart';

class CardScanner extends StatefulWidget {
  const CardScanner({super.key, required this.aoEscanear, this.habilitado = true});

  final VoidCallback aoEscanear;
  final bool habilitado;

  @override
  State<CardScanner> createState() => _CardScannerState();
}

class _CardScannerState extends State<CardScanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controlador =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Widget _canto({required Alignment alinhamento, required Color cor}) {
    const lado = BorderSide(width: 3);
    final superior = alinhamento.y < 0;
    final esquerdo = alinhamento.x < 0;
    return Align(
      alignment: alinhamento,
      child: Container(
        margin: const EdgeInsets.all(12),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border(
            top: superior ? lado.copyWith(color: cor) : BorderSide.none,
            bottom: !superior ? lado.copyWith(color: cor) : BorderSide.none,
            left: esquerdo ? lado.copyWith(color: cor) : BorderSide.none,
            right: !esquerdo ? lado.copyWith(color: cor) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Cartao(
      preenchimento: const EdgeInsets.all(14),
      filho: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 152,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFF16181A)),
                  Center(
                    child: Container(
                      width: 180,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: const LinearGradient(
                          colors: [Colors.white, Colors.transparent, Colors.white],
                          stops: [0, .5, 1],
                        ),
                      ),
                      child: const Opacity(
                        opacity: .9,
                        child: Text(''),
                      ),
                    ),
                  ),
                  _canto(alinhamento: Alignment.topLeft, cor: primaria),
                  _canto(alinhamento: Alignment.topRight, cor: primaria),
                  _canto(alinhamento: Alignment.bottomLeft, cor: primaria),
                  _canto(alinhamento: Alignment.bottomRight, cor: primaria),
                  AnimatedBuilder(
                    animation: _controlador,
                    builder: (contexto, _) => Positioned(
                      left: 20,
                      right: 20,
                      top: 14 + (152 - 30 - 14) * _controlador.value,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: primaria,
                          boxShadow: [
                            BoxShadow(
                              color: primaria.withValues(alpha: .9),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          BotaoPrimario(
            rotulo: '📷 Simular leitura do código',
            aoTocar: widget.habilitado ? widget.aoEscanear : null,
          ),
        ],
      ),
    );
  }
}
```

`lib/funcionalidades/chat/apresentacao/componentes/card_metodos_pagamento.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';

class CardMetodosPagamento extends StatelessWidget {
  const CardMetodosPagamento({
    super.key,
    required this.metodos,
    required this.aoSelecionar,
    this.habilitado = true,
  });

  final List<MetodoPagamento> metodos;
  final void Function(MetodoPagamento) aoSelecionar;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: metodos
          .map(
            (metodo) => Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: habilitado ? () => aoSelecionar(metodo) : null,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFECEBF1), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: CoresApp.lilasClaro,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        alignment: Alignment.center,
                        child: Text(metodo.emoji, style: const TextStyle(fontSize: 21)),
                      ),
                      const SizedBox(height: 8),
                      Text(metodo.rotulo,
                          style:
                              const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      Text(
                        metodo.descricao,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: CoresApp.textoSecundario,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
```

`lib/funcionalidades/chat/apresentacao/componentes/card_pix.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../pagamento/dominio/entidades/dados_pix.dart';

class CardPix extends StatelessWidget {
  const CardPix({
    super.key,
    required this.dadosPix,
    required this.copiado,
    required this.aoCopiar,
    required this.aoConfirmar,
    this.habilitado = true,
  });

  final DadosPix dadosPix;
  final bool copiado;
  final VoidCallback aoCopiar;
  final VoidCallback aoConfirmar;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Cartao(
      preenchimento: const EdgeInsets.all(18),
      filho: Column(
        children: [
          const Text('Pague com Pix',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(
            FormatadorMoeda.formatar(dadosPix.valorCentavos),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: primaria),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEBF1)),
            ),
            child: QrImageView(data: dadosPix.copiaCola, size: 172),
          ),
          const SizedBox(height: 6),
          const Text('Válido por 5 minutos',
              style: TextStyle(
                  fontSize: 11.5,
                  color: CoresApp.textoSecundario,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Material(
            color: CoresApp.lilasClaro,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: aoCopiar,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  copiado ? 'Código copiado ✓' : '📋 Copiar código Pix',
                  style: TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w800, color: primaria),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          BotaoPrimario(
            rotulo: 'Já fiz o pagamento',
            aoTocar: habilitado ? aoConfirmar : null,
          ),
        ],
      ),
    );
  }
}
```

`lib/funcionalidades/chat/apresentacao/componentes/card_sucesso.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';

class CardSucesso extends StatelessWidget {
  const CardSucesso({super.key, required this.valorCentavos, required this.comandas});

  final int valorCentavos;
  final List<String> comandas;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF4F1FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDD5FB)),
        boxShadow: [
          BoxShadow(
              color: primaria.withValues(alpha: .18),
              blurRadius: 30,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (contexto, escala, filho) =>
                Transform.scale(scale: escala, child: filho),
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [primaria.withValues(alpha: .85), primaria]),
                boxShadow: [
                  BoxShadow(
                      color: primaria.withValues(alpha: .4),
                      blurRadius: 24,
                      offset: const Offset(0, 10)),
                ],
              ),
              alignment: Alignment.center,
              child: const Text('✓',
                  style: TextStyle(
                      fontSize: 40, color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Pagamento aprovado! 🎉',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            FormatadorMoeda.formatar(valorCentavos),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: primaria),
          ),
          const SizedBox(height: 12),
          const Text('COMANDAS QUITADAS',
              style: TextStyle(
                  fontSize: 11,
                  color: CoresApp.textoSecundario,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .4)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: comandas
                .map(
                  (nome) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: CoresApp.lilasClaro,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('✓ $nome',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primaria)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
```

`lib/funcionalidades/comprovante/apresentacao/componentes/card_comprovante.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../nucleo/formatadores/formatador_data.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';

class CardComprovante extends StatelessWidget {
  const CardComprovante({
    super.key,
    required this.valorCentavos,
    required this.metodoNome,
    required this.comandas,
    required this.dataHora,
    required this.nomeRestaurante,
    required this.comprovanteId,
  });

  final int valorCentavos;
  final String metodoNome;
  final List<String> comandas;
  final DateTime dataHora;
  final String nomeRestaurante;
  final String comprovanteId;

  Widget _linha(String rotulo, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rotulo,
                style: const TextStyle(
                    fontSize: 12.5,
                    color: CoresApp.textoSecundario,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(valor,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Cartao(
      preenchimento: const EdgeInsets.all(18),
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: Text('🧾', style: TextStyle(fontSize: 32))),
          const SizedBox(height: 6),
          Center(
            child: Text('Comprovante de pagamento',
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
          ),
          Center(
            child: Text(nomeRestaurante,
                style: const TextStyle(
                    fontSize: 12.5,
                    color: CoresApp.textoSecundario,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: CoresApp.bordaCard),
          const SizedBox(height: 8),
          _linha('Data e hora', FormatadorData.dataHora(dataHora)),
          _linha('Comandas', comandas.join(', ')),
          _linha('Forma de pagamento', metodoNome),
          _linha('Identificador', comprovanteId),
          const SizedBox(height: 8),
          Container(height: 1, color: CoresApp.bordaCard),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Valor pago',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              Text(
                FormatadorMoeda.formatar(valorCentavos),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: primaria),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

`lib/funcionalidades/chat/apresentacao/componentes/chip_acao.dart`:

```dart
import 'package:flutter/material.dart';

class ChipAcao extends StatelessWidget {
  const ChipAcao({super.key, required this.rotulo, required this.aoTocar, this.primario = false});

  final String rotulo;
  final VoidCallback aoTocar;
  final bool primario;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Material(
      color: primario ? primaria : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: primario
                ? null
                : Border.all(color: primaria.withValues(alpha: .4), width: 1.5),
            boxShadow: primario
                ? [
                    BoxShadow(
                        color: primaria.withValues(alpha: .35),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ]
                : null,
          ),
          child: Text(
            rotulo,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: primario ? Colors.white : primaria,
            ),
          ),
        ),
      ),
    );
  }
}
```

`lib/funcionalidades/chat/apresentacao/componentes/barra_total.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';

class BarraTotal extends StatelessWidget {
  const BarraTotal({super.key, required this.rotulo, required this.valorCentavos});

  final String rotulo;
  final int valorCentavos;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: CoresApp.lilasClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rotulo,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primaria)),
          Text(
            FormatadorMoeda.formatar(valorCentavos),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primaria),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/funcionalidades/chat/componentes_chat_2_test.dart`
Expected: PASS (6 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: componentes do chat (scanner, metodos, pix, sucesso, comprovante)" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 16: Página do chat

**Files:**
- Create: `lib/funcionalidades/chat/apresentacao/componentes/area_acoes.dart`
- Create: `lib/funcionalidades/chat/apresentacao/paginas/pagina_chat.dart`
- Test: `test/funcionalidades/chat/pagina_chat_test.dart`

**Interfaces:**
- Consumes: tudo das Tasks 13–15, `provedorFluxoPagamento`, `provedorTema`, `provedorRepositorioConfiguracao`, `ConteudoCentralizado`, `BarraSuperior`, `mostrarDialogoConfirmacao`.
- Produces:
  - `AreaAcoes({estado, aoLerOutro, aoIrPagamento, aoDefinirGorjeta, aoPagarRestante, aoEncerrar, aoNovaOperacao})` — barra branca inferior: `BarraTotal` (visível em `aguardandoMaisCartoes`/`gorjeta`/`escolhaMetodo`/`pixAguardando` com seleção), chips por etapa (ocultos quando `digitando`):
    - `aguardandoMaisCartoes`: ['Ler outro cartão' se `cartoesRestantes > 0`, 'Ir para o pagamento' (primário)]
    - `gorjeta`: ['Sim, incluir 10%' (primário), 'Sem taxa']
    - `sucessoComRestante`: ['Pagar restante' (primário), 'Encerrar']
    - `sucessoCompleto`: ['Encerrar' (primário)]
    - `encerramento`: ['Novo pagamento' (primário)]
    - demais: dica '👆 Toque em uma opção acima para continuar' nas etapas `lendo`/`escolhaMetodo`/`pixAguardando`.
  - `PaginaChat` (ConsumerStatefulWidget) — `BarraSuperior` (avatar bot, nome do restaurante, subtítulo 'Mesa N · Atendimento online' quando mesa identificada, senão 'Atendimento online'; botão voltar com diálogo de confirmação que chama `novaOperacao()` e navega para `/splash`), lista rolável de mensagens com `BannerBoasVindas` no topo, mapeamento por `TipoMensagem`, `IndicadorDigitando` quando `digitando`, auto-scroll ao fim quando mensagens mudam, `AreaAcoes` embaixo. Cards de assistente (não-bolha) recebem `Padding(left: 42, right: 24)`. Callback 'Novo pagamento' chama `novaOperacao()` e `context.go('/splash')`.

- [ ] **Step 1: Escrever o teste que falha**

`test/funcionalidades/chat/pagina_chat_test.dart` (usa GoRouter mínimo; delays zerados via overrides; NUNCA `pumpAndSettle` — o scanner tem animação infinita):

```dart
import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/paginas/pagina_chat.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('fluxo completo no chat: leitura -> pix -> sucesso -> comprovante',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final roteador = GoRouter(
      initialLocation: '/chat',
      routes: [
        GoRoute(path: '/chat', builder: (_, __) => const PaginaChat()),
        GoRoute(
            path: '/splash',
            builder: (_, __) => const Scaffold(body: Text('SPLASH'))),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
          provedorAtrasoBot.overrideWithValue(Duration.zero),
          provedorFonteLeituraMock.overrideWithValue(FonteLeituraMock(atraso: Duration.zero)),
          provedorFontePagamentoMock
              .overrideWithValue(FontePagamentoMock(atraso: Duration.zero)),
        ],
        child: MaterialApp.router(routerConfig: roteador),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // boas-vindas + scanner
    expect(find.textContaining('cartão de consumo'), findsWidgets);
    expect(find.textContaining('Simular leitura'), findsOneWidget);

    // leitura do primeiro cartao
    await tester.tap(find.textContaining('Simular leitura'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Mesa 12'), findsOneWidget);
    expect(find.textContaining('Comanda 01'), findsWidgets);

    // ir para pagamento
    await tester.tap(find.textContaining('Ir para o pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('10% de serviço'), findsWidgets);

    // sem taxa
    await tester.tap(find.text('Sem taxa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Pix'), findsOneWidget);

    // escolher pix
    await tester.tap(find.text('Pix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Já fiz o pagamento'), findsOneWidget);

    // confirmar pagamento
    await tester.tap(find.text('Já fiz o pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('aprovado'), findsWidgets);

    // encerrar
    await tester.ensureVisible(find.text('Encerrar'));
    await tester.tap(find.text('Encerrar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Comprovante de pagamento'), findsOneWidget);
    expect(find.text('Novo pagamento'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/chat/pagina_chat_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar a área de ações**

`lib/funcionalidades/chat/apresentacao/componentes/area_acoes.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/layout/layout_responsivo.dart';
import '../controladores/estado_fluxo_pagamento.dart';
import 'barra_total.dart';
import 'chip_acao.dart';

class AreaAcoes extends StatelessWidget {
  const AreaAcoes({
    super.key,
    required this.estado,
    required this.aoLerOutro,
    required this.aoIrPagamento,
    required this.aoDefinirGorjeta,
    required this.aoPagarRestante,
    required this.aoEncerrar,
    required this.aoNovaOperacao,
  });

  final EstadoFluxoPagamento estado;
  final VoidCallback aoLerOutro;
  final VoidCallback aoIrPagamento;
  final void Function(int percentual) aoDefinirGorjeta;
  final VoidCallback aoPagarRestante;
  final VoidCallback aoEncerrar;
  final VoidCallback aoNovaOperacao;

  List<Widget> _chips() {
    if (estado.digitando) return const [];
    switch (estado.etapa) {
      case EtapaFluxo.aguardandoMaisCartoes:
        return [
          if (estado.cartoesRestantes > 0)
            ChipAcao(rotulo: 'Ler outro cartão', aoTocar: aoLerOutro),
          ChipAcao(rotulo: 'Ir para o pagamento', aoTocar: aoIrPagamento, primario: true),
        ];
      case EtapaFluxo.gorjeta:
        return [
          ChipAcao(
              rotulo: 'Sim, incluir 10%',
              aoTocar: () => aoDefinirGorjeta(10),
              primario: true),
          ChipAcao(rotulo: 'Sem taxa', aoTocar: () => aoDefinirGorjeta(0)),
        ];
      case EtapaFluxo.sucessoComRestante:
        return [
          ChipAcao(rotulo: 'Pagar restante', aoTocar: aoPagarRestante, primario: true),
          ChipAcao(rotulo: 'Encerrar', aoTocar: aoEncerrar),
        ];
      case EtapaFluxo.sucessoCompleto:
        return [ChipAcao(rotulo: 'Encerrar', aoTocar: aoEncerrar, primario: true)];
      case EtapaFluxo.encerramento:
        return [ChipAcao(rotulo: 'Novo pagamento', aoTocar: aoNovaOperacao, primario: true)];
      default:
        return const [];
    }
  }

  bool get _mostraTotal =>
      const [
        EtapaFluxo.aguardandoMaisCartoes,
        EtapaFluxo.gorjeta,
        EtapaFluxo.escolhaMetodo,
        EtapaFluxo.pixAguardando,
      ].contains(estado.etapa) &&
      estado.selecionados.isNotEmpty;

  bool get _mostraDica =>
      !estado.digitando &&
      const [EtapaFluxo.lendo, EtapaFluxo.escolhaMetodo, EtapaFluxo.pixAguardando]
          .contains(estado.etapa);

  @override
  Widget build(BuildContext context) {
    final chips = _chips();
    final selecionados = estado.selecionados.length;
    final rotuloBarra = '$selecionados ${selecionados > 1 ? 'cartões' : 'cartão'}'
        '${estado.gorjetaPercentual > 0 ? ' · inclui serviço' : ''}';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: CoresApp.bordaCard)),
        boxShadow: [
          BoxShadow(
              color: CoresApp.textoPrincipal.withValues(alpha: .06),
              blurRadius: 20,
              offset: const Offset(0, -6)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: SafeArea(
        top: false,
        child: ConteudoCentralizado(
          filho: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_mostraTotal) ...[
                BarraTotal(rotulo: rotuloBarra, valorCentavos: estado.totalCentavos),
                const SizedBox(height: 10),
              ],
              if (chips.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: chips,
                      ),
                    ),
                  ],
                )
              else if (_mostraDica)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '👆 Toque em uma opção acima para continuar',
                    style: TextStyle(
                        fontSize: 12.5,
                        color: CoresApp.textoSecundario,
                        fontWeight: FontWeight.w600),
                  ),
                )
              else
                const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Implementar a página**

`lib/funcionalidades/chat/apresentacao/paginas/pagina_chat.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../compartilhado/layout/layout_responsivo.dart';
import '../../../../compartilhado/widgets/barra_superior.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../../comprovante/apresentacao/componentes/card_comprovante.dart';
import '../../dominio/entidades/mensagem.dart';
import '../../dominio/entidades/tipo_mensagem.dart';
import '../componentes/area_acoes.dart';
import '../componentes/avatar_bot.dart';
import '../componentes/banner_boas_vindas.dart';
import '../componentes/bolha_mensagem.dart';
import '../componentes/card_comanda.dart';
import '../componentes/card_detalhe_comanda.dart';
import '../componentes/card_mesa.dart';
import '../componentes/card_metodos_pagamento.dart';
import '../componentes/card_pix.dart';
import '../componentes/card_scanner.dart';
import '../componentes/card_sucesso.dart';
import '../componentes/indicador_digitando.dart';
import '../controladores/controlador_fluxo_pagamento.dart';
import '../controladores/estado_fluxo_pagamento.dart';

class PaginaChat extends ConsumerStatefulWidget {
  const PaginaChat({super.key});

  @override
  ConsumerState<PaginaChat> createState() => _PaginaChatState();
}

class _PaginaChatState extends ConsumerState<PaginaChat> {
  final ScrollController _rolagem = ScrollController();
  String _nomeRestaurante = 'Constel Pay';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final configuracao = await ref.read(provedorRepositorioConfiguracao).obter();
      if (mounted) setState(() => _nomeRestaurante = configuracao.nomeRestaurante);
      await ref.read(provedorFluxoPagamento.notifier).iniciar();
    });
  }

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  void _rolarParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_rolagem.hasClients) {
        _rolagem.animateTo(
          _rolagem.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _confirmarSaida() async {
    final sair = await mostrarDialogoConfirmacao(
      context,
      titulo: 'Cancelar operação?',
      mensagem: 'O atendimento atual será encerrado e nada será cobrado.',
      confirmar: 'Sim, cancelar',
      cancelar: 'Continuar aqui',
      destrutivo: true,
    );
    if (sair && mounted) {
      ref.read(provedorFluxoPagamento.notifier).novaOperacao();
      context.go('/splash');
    }
  }

  Widget _porTipo(Mensagem mensagem, EstadoFluxoPagamento estado,
      ControladorFluxoPagamento controlador) {
    Widget recuado(Widget filho) =>
        Padding(padding: const EdgeInsets.only(left: 42, right: 24), child: filho);
    switch (mensagem.tipo) {
      case TipoMensagem.texto:
        return BolhaMensagem(mensagem: mensagem);
      case TipoMensagem.mesa:
        final mesa = estado.mesa;
        return mesa == null ? const SizedBox.shrink() : recuado(CardMesa(mesa: mesa));
      case TipoMensagem.leituraCartao:
      case TipoMensagem.comanda:
        final id = mensagem.dados?['comandaId'] as String?;
        final cartao = estado.cartoes.where((c) => c.id == id).firstOrNull;
        if (cartao == null) return const SizedBox.shrink();
        return recuado(CardComanda(cartao: cartao, aoVerItens: controlador.verItens));
      case TipoMensagem.detalhe:
        final id = mensagem.dados?['comandaId'] as String?;
        final cartao = estado.cartoes.where((c) => c.id == id).firstOrNull;
        if (cartao == null) return const SizedBox.shrink();
        return recuado(CardDetalheComanda(cartao: cartao));
      case TipoMensagem.scanner:
        return recuado(CardScanner(
          aoEscanear: controlador.lerCartao,
          habilitado: estado.etapa == EtapaFluxo.lendo && !estado.digitando,
        ));
      case TipoMensagem.metodos:
        return recuado(CardMetodosPagamento(
          metodos: const [
            MetodoPagamento.pix,
            MetodoPagamento.credito,
            MetodoPagamento.debito,
          ],
          aoSelecionar: controlador.selecionarMetodo,
          habilitado: estado.etapa == EtapaFluxo.escolhaMetodo && !estado.digitando,
        ));
      case TipoMensagem.pix:
        final dados = estado.dadosPix;
        if (dados == null) return const SizedBox.shrink();
        return recuado(CardPix(
          dadosPix: dados,
          copiado: estado.copiado,
          aoCopiar: () {
            Clipboard.setData(ClipboardData(text: dados.copiaCola));
            controlador.marcarCopiado();
          },
          aoConfirmar: controlador.confirmarPagamentoPix,
          habilitado: estado.etapa == EtapaFluxo.pixAguardando && !estado.digitando,
        ));
      case TipoMensagem.sucesso:
        return recuado(CardSucesso(
          valorCentavos: mensagem.dados?['valorCentavos'] as int? ?? 0,
          comandas: List<String>.from(mensagem.dados?['comandas'] as List? ?? const []),
        ));
      case TipoMensagem.comprovante:
        final dados = mensagem.dados ?? const {};
        return recuado(CardComprovante(
          valorCentavos: dados['valorCentavos'] as int? ?? 0,
          metodoNome: (dados['metodo'] as String? ?? 'pix').toUpperCase(),
          comandas: List<String>.from(dados['comandas'] as List? ?? const []),
          dataHora:
              DateTime.tryParse(dados['dataHora'] as String? ?? '') ?? DateTime.now(),
          nomeRestaurante: dados['nomeRestaurante'] as String? ?? '',
          comprovanteId: dados['id'] as String? ?? '',
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorFluxoPagamento);
    final controlador = ref.read(provedorFluxoPagamento.notifier);
    ref.listen(provedorFluxoPagamento.select((e) => e.mensagens.length),
        (_, __) => _rolarParaFim());
    ref.listen(
        provedorFluxoPagamento.select((e) => e.digitando), (_, __) => _rolarParaFim());

    final subtitulo = estado.mesa != null
        ? 'Mesa ${estado.mesa!.numero} · Atendimento online'
        : 'Atendimento online';

    return Scaffold(
      appBar: BarraSuperior(
        titulo: _nomeRestaurante,
        subtitulo: subtitulo,
        avatar: const AvatarBot(tamanho: 40),
        aoVoltar: _confirmarSaida,
      ),
      body: Column(
        children: [
          Expanded(
            child: ConteudoCentralizado(
              filho: ListView(
                controller: _rolagem,
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
                children: [
                  BannerBoasVindas(nomeRestaurante: _nomeRestaurante),
                  ...estado.mensagens.map(
                    (mensagem) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _porTipo(mensagem, estado, controlador),
                    ),
                  ),
                  if (estado.digitando) const IndicadorDigitando(),
                ],
              ),
            ),
          ),
          AreaAcoes(
            estado: estado,
            aoLerOutro: controlador.lerOutroCartao,
            aoIrPagamento: controlador.irParaPagamento,
            aoDefinirGorjeta: controlador.definirGorjeta,
            aoPagarRestante: controlador.pagarRestante,
            aoEncerrar: controlador.encerrar,
            aoNovaOperacao: () {
              controlador.novaOperacao();
              context.go('/splash');
            },
          ),
        ],
      ),
    );
  }
}
```

Notas do arquivo acima:
- Adicionar o import de `../../../pagamento/dominio/entidades/metodo_pagamento.dart` (usado na lista de métodos). Pix é funcional; crédito/débito respondem "ainda não disponível" via controlador.
- **Modo totem (spec §10):** logo no início do `body`, antes do `Column`, detectar o modo e exibir a faixa de autoatendimento. Código a incluir no `build`, envolvendo o `Column` existente:

```dart
final modo = modoPorLargura(MediaQuery.sizeOf(context).width);
// body:
body: Column(
  children: [
    if (modo == ModoDispositivo.totem)
      Container(
        width: double.infinity,
        color: CoresApp.textoPrincipal,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🏧 AUTOATENDIMENTO',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5)),
            Text(_nomeRestaurante.toUpperCase(),
                style: const TextStyle(
                    color: CoresApp.secundariaPadrao,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5)),
          ],
        ),
      ),
    Expanded(child: /* ConteudoCentralizado com o ListView, como acima */),
    AreaAcoes(/* como acima */),
  ],
),
```

(Imports adicionais: `cores_app.dart` e `layout_responsivo.dart` já está importado.)

- [ ] **Step 5: Rodar e ver passar**

Run: `flutter test test/funcionalidades/chat/pagina_chat_test.dart`
Expected: PASS (1 teste de fluxo completo).

- [ ] **Step 6: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: pagina do chat com fluxo conversacional completo" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 17: Splash e DetectorToqueLongo

**Files:**
- Create: `lib/compartilhado/widgets/detector_toque_longo.dart`
- Create: `lib/funcionalidades/splash/apresentacao/paginas/pagina_splash.dart`
- Test: `test/funcionalidades/splash/pagina_splash_test.dart`

**Interfaces:**
- Consumes: `provedorTema`, `provedorRepositorioConfiguracao` (Task 7), `TemaConstel` (Task 5), `ConstantesApp` (Task 3).
- Produces:
  - `DetectorToqueLongo({filho, aoCompletar, duracao=Duration(seconds: 3)})` — `Listener` que inicia um `Timer` no pointer-down e cancela no pointer-up/cancel; ao completar chama `aoCompletar`.
  - `PaginaSplash` — fundo gradiente na cor primária, logo (arquivo de `tema.logoPath` se existir, senão 🍽️ em círculo), nome do restaurante, 'Terminal de autoatendimento', `IndicadorCarregamento` discreto. Timer de `ConstantesApp.duracaoSplash` OU toque → `context.go('/propaganda')`. Toque longo (3s) no logo → `context.go('/pin?destino=/configuracoes')`.

- [ ] **Step 1: Escrever os testes que falham**

`test/funcionalidades/splash/pagina_splash_test.dart`:

```dart
import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/compartilhado/widgets/detector_toque_longo.dart';
import 'package:constel_pay/funcionalidades/splash/apresentacao/paginas/pagina_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GoRouter> _roteador() async {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const PaginaSplash()),
      GoRoute(path: '/propaganda', builder: (_, __) => const Scaffold(body: Text('PROPAGANDA'))),
      GoRoute(path: '/pin', builder: (_, __) => const Scaffold(body: Text('PIN'))),
    ],
  );
}

Future<void> _montar(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
      child: MaterialApp.router(routerConfig: await _roteador()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('avanca automaticamente para a propaganda apos o timer', (tester) async {
    await _montar(tester);
    expect(find.byType(PaginaSplash), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(find.text('PROPAGANDA'), findsOneWidget);
  });

  testWidgets('toque simples tambem avanca', (tester) async {
    await _montar(tester);
    await tester.tap(find.byType(PaginaSplash));
    await tester.pump();
    await tester.pump();
    expect(find.text('PROPAGANDA'), findsOneWidget);
  });

  testWidgets('toque longo de 3s no logo abre o PIN', (tester) async {
    await _montar(tester);
    final gesto = await tester.startGesture(
        tester.getCenter(find.byType(DetectorToqueLongo)));
    await tester.pump(const Duration(milliseconds: 3200));
    await gesto.up();
    await tester.pump();
    await tester.pump();
    expect(find.text('PIN'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/splash/pagina_splash_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/compartilhado/widgets/detector_toque_longo.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';

/// Detecta um toque contínuo de [duracao] (padrão 3s) sobre [filho].
/// Usado para o acesso discreto às configurações do terminal.
class DetectorToqueLongo extends StatefulWidget {
  const DetectorToqueLongo({
    super.key,
    required this.filho,
    required this.aoCompletar,
    this.duracao = const Duration(seconds: 3),
  });

  final Widget filho;
  final VoidCallback aoCompletar;
  final Duration duracao;

  @override
  State<DetectorToqueLongo> createState() => _DetectorToqueLongoState();
}

class _DetectorToqueLongoState extends State<DetectorToqueLongo> {
  Timer? _temporizador;

  void _iniciar(_) {
    _temporizador?.cancel();
    _temporizador = Timer(widget.duracao, widget.aoCompletar);
  }

  void _cancelar([dynamic _]) {
    _temporizador?.cancel();
    _temporizador = null;
  }

  @override
  void dispose() {
    _cancelar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _iniciar,
      onPointerUp: _cancelar,
      onPointerCancel: _cancelar,
      behavior: HitTestBehavior.opaque,
      child: widget.filho,
    );
  }
}
```

`lib/funcionalidades/splash/apresentacao/paginas/pagina_splash.dart`:

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/widgets/detector_toque_longo.dart';
import '../../../../nucleo/constantes/constantes_app.dart';

class PaginaSplash extends ConsumerStatefulWidget {
  const PaginaSplash({super.key});

  @override
  ConsumerState<PaginaSplash> createState() => _PaginaSplashState();
}

class _PaginaSplashState extends ConsumerState<PaginaSplash> {
  Timer? _temporizador;
  String _nomeRestaurante = '';

  @override
  void initState() {
    super.initState();
    _temporizador = Timer(ConstantesApp.duracaoSplash, _avancar);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final configuracao = await ref.read(provedorRepositorioConfiguracao).obter();
      if (mounted) setState(() => _nomeRestaurante = configuracao.nomeRestaurante);
    });
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  void _avancar() {
    _temporizador?.cancel();
    if (mounted) context.go('/propaganda');
  }

  void _abrirConfiguracoes() {
    _temporizador?.cancel();
    if (mounted) context.go('/pin?destino=/configuracoes');
  }

  @override
  Widget build(BuildContext context) {
    final tema = ref.watch(provedorTema);
    final primaria = TemaConstel.corDeHex(tema.corPrimaria, Theme.of(context).colorScheme.primary);
    final logoPath = tema.logoPath;
    final temLogo = logoPath != null && File(logoPath).existsSync();

    return GestureDetector(
      onTap: _avancar,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaria.withValues(alpha: .9), primaria],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DetectorToqueLongo(
                aoCompletar: _abrirConfiguracoes,
                filho: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: .25),
                          blurRadius: 40,
                          offset: const Offset(0, 16)),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: temLogo
                      ? Image.file(File(logoPath), fit: BoxFit.cover)
                      : const Text('🍽️', style: TextStyle(fontSize: 60)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _nomeRestaurante,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Terminal de autoatendimento',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: .85)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white.withValues(alpha: .8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/funcionalidades/splash/pagina_splash_test.dart`
Expected: PASS (3 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: splash com acesso oculto as configuracoes por toque longo" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 18: Propaganda — controlador e página

**Files:**
- Create: `lib/funcionalidades/propaganda/apresentacao/controladores/controlador_propaganda.dart`
- Create: `lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart`
- Create: `lib/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart`
- Test: `test/funcionalidades/propaganda/propaganda_test.dart`

**Interfaces:**
- Consumes: `RepositorioPropaganda` (Task 9), `MidiaPropaganda`/`TipoMidia` (Task 4), `BotaoPrimario`/`Cartao` (Task 6), `provedorRepositorioConfiguracao`, `video_player`.
- Produces:
  - `EstadoPropaganda` (Freezed): `{midias=[], indice=0, carregando=true}` + getter `midiaAtual` (null se vazio).
  - `ControladorPropaganda extends StateNotifier<EstadoPropaganda>` com `carregar()` (busca ativas ordenadas) e `avancar()` (índice circular: `(indice + 1) % midias.length`, no-op se vazio); `provedorPropaganda` (`StateNotifierProvider.autoDispose`).
  - `PlayerPropaganda({midia, aoTerminar})` — imagem: `Image.file` + `Timer(duracaoSegundos)` → `aoTerminar`; vídeo: `VideoPlayerController.file` com play e listener de fim → `aoTerminar`; arquivo inexistente → chama `aoTerminar` após 1s.
  - `PaginaPropaganda({preview=false})` — carregando: fundo primário; playlist vazia: tela CTA "Toque para pagar" (branding + 3 passos Escaneie/Pague/Pronto como no HTML); com mídias: player em tela cheia. Qualquer toque → `preview ? context.pop() : context.go('/chat')`.

- [ ] **Step 1: Escrever os testes que falham**

`test/funcionalidades/propaganda/propaganda_test.dart`:

```dart
import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/controladores/controlador_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('controlador carrega midias ativas e avanca circularmente', () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioPropagandaImpl(preferencias);
    await repositorio.salvarTodas(const [
      MidiaPropaganda(id: 'a', tipo: TipoMidia.imagem, caminho: '/x/a.png', ordem: 1),
      MidiaPropaganda(id: 'b', tipo: TipoMidia.imagem, caminho: '/x/b.png', ordem: 2),
    ]);
    final controlador = ControladorPropaganda(repositorio);
    await controlador.carregar();
    expect(controlador.state.midias, hasLength(2));
    expect(controlador.state.midiaAtual?.id, 'a');
    controlador.avancar();
    expect(controlador.state.midiaAtual?.id, 'b');
    controlador.avancar();
    expect(controlador.state.midiaAtual?.id, 'a');
  });

  testWidgets('sem midias mostra CTA e navega para o chat ao tocar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final roteador = GoRouter(
      initialLocation: '/propaganda',
      routes: [
        GoRoute(path: '/propaganda', builder: (_, __) => const PaginaPropaganda()),
        GoRoute(path: '/chat', builder: (_, __) => const Scaffold(body: Text('CHAT'))),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: MaterialApp.router(routerConfig: roteador),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Toque para pagar'), findsOneWidget);
    expect(find.text('Escaneie'), findsOneWidget);
    await tester.tap(find.text('Toque para pagar'));
    await tester.pump();
    await tester.pump();
    expect(find.text('CHAT'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/propaganda/propaganda_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/funcionalidades/propaganda/apresentacao/controladores/controlador_propaganda.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../aplicativo/injecao.dart';
import '../../dominio/entidades/midia_propaganda.dart';
import '../../dominio/repositorios/repositorio_propaganda.dart';

part 'controlador_propaganda.freezed.dart';

@freezed
class EstadoPropaganda with _$EstadoPropaganda {
  const EstadoPropaganda._();

  const factory EstadoPropaganda({
    @Default([]) List<MidiaPropaganda> midias,
    @Default(0) int indice,
    @Default(true) bool carregando,
  }) = _EstadoPropaganda;

  MidiaPropaganda? get midiaAtual => midias.isEmpty ? null : midias[indice % midias.length];
}

class ControladorPropaganda extends StateNotifier<EstadoPropaganda> {
  ControladorPropaganda(this._repositorio) : super(const EstadoPropaganda());

  final RepositorioPropaganda _repositorio;

  Future<void> carregar() async {
    final midias = await _repositorio.obterAtivasOrdenadas();
    state = state.copyWith(midias: midias, indice: 0, carregando: false);
  }

  void avancar() {
    if (state.midias.isEmpty) return;
    state = state.copyWith(indice: (state.indice + 1) % state.midias.length);
  }
}

final provedorPropaganda =
    StateNotifierProvider.autoDispose<ControladorPropaganda, EstadoPropaganda>(
  (ref) => ControladorPropaganda(ref.watch(provedorRepositorioPropaganda)),
);
```

`lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart`:

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../dominio/entidades/midia_propaganda.dart';

class PlayerPropaganda extends StatefulWidget {
  const PlayerPropaganda({super.key, required this.midia, required this.aoTerminar});

  final MidiaPropaganda midia;
  final VoidCallback aoTerminar;

  @override
  State<PlayerPropaganda> createState() => _PlayerPropagandaState();
}

class _PlayerPropagandaState extends State<PlayerPropaganda> {
  Timer? _temporizador;
  VideoPlayerController? _video;

  @override
  void initState() {
    super.initState();
    _preparar();
  }

  @override
  void didUpdateWidget(covariant PlayerPropaganda anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.midia.id != widget.midia.id) {
      _limpar();
      _preparar();
    }
  }

  void _preparar() {
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) {
      _temporizador = Timer(const Duration(seconds: 1), widget.aoTerminar);
      return;
    }
    if (widget.midia.tipo == TipoMidia.imagem) {
      _temporizador =
          Timer(Duration(seconds: widget.midia.duracaoSegundos), widget.aoTerminar);
    } else {
      final controlador = VideoPlayerController.file(arquivo);
      _video = controlador;
      controlador.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        controlador.play();
      });
      controlador.addListener(() {
        final valor = controlador.value;
        if (valor.isInitialized &&
            !valor.isPlaying &&
            valor.position >= valor.duration &&
            valor.duration > Duration.zero) {
          widget.aoTerminar();
        }
      });
    }
  }

  void _limpar() {
    _temporizador?.cancel();
    _temporizador = null;
    _video?.dispose();
    _video = null;
  }

  @override
  void dispose() {
    _limpar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) {
      return const ColoredBox(color: Colors.black);
    }
    if (widget.midia.tipo == TipoMidia.imagem) {
      return Image.file(arquivo, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
    final video = _video;
    if (video == null || !video.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: video.value.size.width,
        height: video.value.size.height,
        child: VideoPlayer(video),
      ),
    );
  }
}
```

`lib/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../componentes/player_propaganda.dart';
import '../controladores/controlador_propaganda.dart';

class PaginaPropaganda extends ConsumerStatefulWidget {
  const PaginaPropaganda({super.key, this.preview = false});

  final bool preview;

  @override
  ConsumerState<PaginaPropaganda> createState() => _PaginaPropagandaState();
}

class _PaginaPropagandaState extends ConsumerState<PaginaPropaganda> {
  String _nomeRestaurante = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(provedorPropaganda.notifier).carregar();
      final configuracao = await ref.read(provedorRepositorioConfiguracao).obter();
      if (mounted) setState(() => _nomeRestaurante = configuracao.nomeRestaurante);
    });
  }

  void _prosseguir() {
    if (widget.preview) {
      // O preview é aberto via Navigator.push (aba Propaganda), fora das rotas do GoRouter.
      Navigator.of(context).maybePop();
    } else {
      context.go('/chat');
    }
  }

  Widget _passo(String emoji, String titulo, String subtitulo) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CoresApp.bordaCard),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: CoresApp.lilasClaro,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 19)),
            ),
            const SizedBox(height: 7),
            Text(titulo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            Text(subtitulo,
                style: const TextStyle(
                    fontSize: 10,
                    color: CoresApp.textoSecundario,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _telaChamada(Color primaria) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaria, primaria.withValues(alpha: .8)],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🍽️', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 12),
                  Text(
                    _nomeRestaurante,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
            decoration: const BoxDecoration(
              color: CoresApp.fundoPadrao,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pague sua conta sem chamar o garçom',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text(
                    'Escaneie o cartão de consumo da sua mesa e pague em segundos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: CoresApp.textoSecundario,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _passo('📷', 'Escaneie', 'o cartão'),
                      const SizedBox(width: 8),
                      _passo('💳', 'Pague', 'com Pix'),
                      const SizedBox(width: 8),
                      _passo('✅', 'Pronto', 'sem fila'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  BotaoPrimario(rotulo: 'Toque para pagar', aoTocar: _prosseguir),
                  const SizedBox(height: 12),
                  const Text('🔒 Pagamento seguro · Autoatendimento',
                      style: TextStyle(
                          fontSize: 11.5,
                          color: CoresApp.textoSecundario,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorPropaganda);
    final tema = ref.watch(provedorTema);
    final primaria =
        TemaConstel.corDeHex(tema.corPrimaria, Theme.of(context).colorScheme.primary);

    final Widget conteudo;
    if (estado.carregando) {
      conteudo = ColoredBox(color: primaria);
    } else if (estado.midiaAtual == null) {
      conteudo = _telaChamada(primaria);
    } else {
      conteudo = Stack(
        fit: StackFit.expand,
        children: [
          PlayerPropaganda(
            midia: estado.midiaAtual!,
            aoTerminar: () => ref.read(provedorPropaganda.notifier).avancar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .55),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  '👆 Toque na tela para pagar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _prosseguir,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(body: conteudo),
    );
  }
}
```

- [ ] **Step 4: Gerar código e rodar os testes**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/funcionalidades/propaganda/propaganda_test.dart
```
Expected: PASS (2 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: propaganda com playlist de midias e tela de chamada" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 19: PIN — controlador, teclado numérico e página

**Files:**
- Create: `lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_pin.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/teclado_numerico.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/paginas/pagina_pin.dart`
- Test: `test/funcionalidades/configuracoes/controlador_pin_test.dart`

**Interfaces:**
- Consumes: `RepositorioConfiguracao` (Task 7), `HasherPin` (Task 8), `Validadores` (Task 3).
- Produces:
  - `enum ModoPin { criar, confirmar, verificar }`
  - `EstadoPin` (Freezed): `{modo=verificar, digitos='', primeiroPin='', erro?, concluido=false, carregando=true}`
  - `ControladorPin(RepositorioConfiguracao)` com `iniciar()` (modo = `criar` se `pinHash` vazio, senão `verificar`), `digitar(String digito)` (máx. 6), `apagar()`, `confirmar()`:
    - `criar`: valida `Validadores.pinValido`; guarda em `primeiroPin`, muda para `confirmar`.
    - `confirmar`: igual ao primeiro → salva `HasherPin.gerar` em `pinHash`, `concluido=true`; diferente → erro 'Os PINs não conferem. Tente de novo.' e volta para `criar`.
    - `verificar`: `HasherPin.verificar` → `concluido=true`; senão erro 'PIN incorreto.' e limpa dígitos.
  - `provedorPin` (`StateNotifierProvider.autoDispose`).
  - `TecladoNumerico({aoDigitar, aoApagar, aoConfirmar, confirmarHabilitado})` — grade 1-9, apagar, 0, OK.
  - `PaginaPin({destino})` — título por modo ('Crie o PIN de acesso' / 'Confirme o novo PIN' / 'Digite o PIN'), indicador de dígitos (bolinhas), erro em vermelho, teclado. Quando `concluido`: modo era `verificar` → `context.go(destino ?? '/configuracoes')`; era criação → `context.go(destino ?? '/splash')`.

- [ ] **Step 1: Escrever o teste que falha**

`test/funcionalidades/configuracoes/controlador_pin_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_pin.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/nucleo/utils/hasher_pin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ControladorPin> criarControlador({String pinHash = ''}) async {
    SharedPreferences.setMockInitialValues({});
    final repositorio = RepositorioConfiguracaoImpl(await SharedPreferences.getInstance());
    await repositorio.salvar(ConfiguracaoTerminal(pinHash: pinHash));
    final controlador = ControladorPin(repositorio);
    await controlador.iniciar();
    return controlador;
  }

  void digitarPin(ControladorPin controlador, String pin) {
    for (final digito in pin.split('')) {
      controlador.digitar(digito);
    }
  }

  test('sem pinHash inicia em modo criar', () async {
    final controlador = await criarControlador();
    expect(controlador.state.modo, ModoPin.criar);
  });

  test('criacao completa: criar -> confirmar -> concluido', () async {
    final controlador = await criarControlador();
    digitarPin(controlador, '1234');
    await controlador.confirmar();
    expect(controlador.state.modo, ModoPin.confirmar);
    expect(controlador.state.digitos, isEmpty);
    digitarPin(controlador, '1234');
    await controlador.confirmar();
    expect(controlador.state.concluido, isTrue);
  });

  test('confirmacao divergente volta para criar com erro', () async {
    final controlador = await criarControlador();
    digitarPin(controlador, '1234');
    await controlador.confirmar();
    digitarPin(controlador, '9999');
    await controlador.confirmar();
    expect(controlador.state.modo, ModoPin.criar);
    expect(controlador.state.erro, isNotNull);
    expect(controlador.state.concluido, isFalse);
  });

  test('pin curto em modo criar gera erro de validacao', () async {
    final controlador = await criarControlador();
    digitarPin(controlador, '12');
    await controlador.confirmar();
    expect(controlador.state.erro, isNotNull);
    expect(controlador.state.modo, ModoPin.criar);
  });

  test('verificar com pin correto conclui', () async {
    final controlador = await criarControlador(pinHash: HasherPin.gerar('4321'));
    expect(controlador.state.modo, ModoPin.verificar);
    digitarPin(controlador, '4321');
    await controlador.confirmar();
    expect(controlador.state.concluido, isTrue);
  });

  test('verificar com pin errado mostra erro e limpa digitos', () async {
    final controlador = await criarControlador(pinHash: HasherPin.gerar('4321'));
    digitarPin(controlador, '0000');
    await controlador.confirmar();
    expect(controlador.state.concluido, isFalse);
    expect(controlador.state.erro, 'PIN incorreto.');
    expect(controlador.state.digitos, isEmpty);
  });

  test('digitar respeita o limite de 6 digitos e apagar remove o ultimo', () async {
    final controlador = await criarControlador();
    digitarPin(controlador, '12345678');
    expect(controlador.state.digitos, '123456');
    controlador.apagar();
    expect(controlador.state.digitos, '12345');
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/controlador_pin_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar o controlador**

`lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_pin.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../nucleo/utils/hasher_pin.dart';
import '../../../../nucleo/utils/validadores.dart';
import '../../dominio/repositorios/repositorio_configuracao.dart';

part 'controlador_pin.freezed.dart';

enum ModoPin { criar, confirmar, verificar }

@freezed
class EstadoPin with _$EstadoPin {
  const factory EstadoPin({
    @Default(ModoPin.verificar) ModoPin modo,
    @Default('') String digitos,
    @Default('') String primeiroPin,
    String? erro,
    @Default(false) bool concluido,
    @Default(true) bool carregando,
  }) = _EstadoPin;
}

class ControladorPin extends StateNotifier<EstadoPin> {
  ControladorPin(this._repositorio) : super(const EstadoPin());

  final RepositorioConfiguracao _repositorio;

  Future<void> iniciar() async {
    final configuracao = await _repositorio.obter();
    state = EstadoPin(
      modo: configuracao.pinHash.isEmpty ? ModoPin.criar : ModoPin.verificar,
      carregando: false,
    );
  }

  void digitar(String digito) {
    if (state.digitos.length >= 6) return;
    state = state.copyWith(digitos: '${state.digitos}$digito', erro: null);
  }

  void apagar() {
    if (state.digitos.isEmpty) return;
    state = state.copyWith(
        digitos: state.digitos.substring(0, state.digitos.length - 1), erro: null);
  }

  Future<void> confirmar() async {
    final pin = state.digitos;
    switch (state.modo) {
      case ModoPin.criar:
        if (!Validadores.pinValido(pin)) {
          state = state.copyWith(erro: 'O PIN deve ter de 4 a 6 dígitos.', digitos: '');
          return;
        }
        state = state.copyWith(modo: ModoPin.confirmar, primeiroPin: pin, digitos: '');
      case ModoPin.confirmar:
        if (pin != state.primeiroPin) {
          state = state.copyWith(
            modo: ModoPin.criar,
            primeiroPin: '',
            digitos: '',
            erro: 'Os PINs não conferem. Tente de novo.',
          );
          return;
        }
        final configuracao = await _repositorio.obter();
        await _repositorio.salvar(configuracao.copyWith(pinHash: HasherPin.gerar(pin)));
        state = state.copyWith(concluido: true);
      case ModoPin.verificar:
        final configuracao = await _repositorio.obter();
        if (HasherPin.verificar(pin, configuracao.pinHash)) {
          state = state.copyWith(concluido: true);
        } else {
          state = state.copyWith(erro: 'PIN incorreto.', digitos: '');
        }
    }
  }
}

final provedorPin = StateNotifierProvider.autoDispose<ControladorPin, EstadoPin>(
  (ref) => ControladorPin(ref.watch(provedorRepositorioConfiguracao)),
);
```

- [ ] **Step 4: Implementar teclado e página**

`lib/funcionalidades/configuracoes/apresentacao/componentes/teclado_numerico.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';

class TecladoNumerico extends StatelessWidget {
  const TecladoNumerico({
    super.key,
    required this.aoDigitar,
    required this.aoApagar,
    required this.aoConfirmar,
    this.confirmarHabilitado = true,
  });

  final void Function(String digito) aoDigitar;
  final VoidCallback aoApagar;
  final VoidCallback aoConfirmar;
  final bool confirmarHabilitado;

  Widget _tecla(BuildContext context, Widget filho, VoidCallback? aoTocar,
      {Color? cor}) {
    return Material(
      color: cor ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(height: 62, child: Center(child: filho)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    const estiloDigito = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
    final linhas = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        children: [
          for (final linha in linhas)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  for (final digito in linha) ...[
                    Expanded(
                        child: _tecla(context, Text(digito, style: estiloDigito),
                            () => aoDigitar(digito))),
                    if (digito != linha.last) const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _tecla(
                    context,
                    const Icon(Icons.backspace_outlined, color: CoresApp.textoSecundario),
                    aoApagar),
              ),
              const SizedBox(width: 10),
              Expanded(child: _tecla(context, const Text('0', style: estiloDigito), () => aoDigitar('0'))),
              const SizedBox(width: 10),
              Expanded(
                child: _tecla(
                  context,
                  const Icon(Icons.check, color: Colors.white),
                  confirmarHabilitado ? aoConfirmar : null,
                  cor: confirmarHabilitado ? primaria : primaria.withValues(alpha: .4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

`lib/funcionalidades/configuracoes/apresentacao/paginas/pagina_pin.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../componentes/teclado_numerico.dart';
import '../controladores/controlador_pin.dart';

class PaginaPin extends ConsumerStatefulWidget {
  const PaginaPin({super.key, this.destino});

  final String? destino;

  @override
  ConsumerState<PaginaPin> createState() => _PaginaPinState();
}

class _PaginaPinState extends ConsumerState<PaginaPin> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => ref.read(provedorPin.notifier).iniciar());
  }

  String _titulo(ModoPin modo) => switch (modo) {
        ModoPin.criar => 'Crie o PIN de acesso',
        ModoPin.confirmar => 'Confirme o novo PIN',
        ModoPin.verificar => 'Digite o PIN',
      };

  String _subtitulo(ModoPin modo) => switch (modo) {
        ModoPin.criar => 'De 4 a 6 dígitos. Ele protege as configurações do terminal.',
        ModoPin.confirmar => 'Digite o mesmo PIN novamente.',
        ModoPin.verificar => 'Acesso restrito ao administrador.',
      };

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorPin);
    final controlador = ref.read(provedorPin.notifier);
    ref.listen(provedorPin.select((e) => e.concluido), (_, concluido) {
      if (!concluido) return;
      final criacao = estado.modo != ModoPin.verificar;
      context.go(widget.destino ?? (criacao ? '/splash' : '/configuracoes'));
    });

    if (estado.carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 12),
                Text(_titulo(estado.modo),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  _subtitulo(estado.modo),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: CoresApp.textoSecundario, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (indice) {
                    final preenchida = indice < estado.digitos.length;
                    return Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: preenchida
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                            color: preenchida
                                ? Theme.of(context).colorScheme.primary
                                : CoresApp.textoSecundario),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  height: 34,
                  child: Center(
                    child: estado.erro != null
                        ? Text(estado.erro!,
                            style: const TextStyle(
                                color: CoresApp.erro, fontWeight: FontWeight.w700))
                        : null,
                  ),
                ),
                TecladoNumerico(
                  aoDigitar: controlador.digitar,
                  aoApagar: controlador.apagar,
                  aoConfirmar: controlador.confirmar,
                  confirmarHabilitado: estado.digitos.length >= 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Gerar código e rodar os testes**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/funcionalidades/configuracoes/controlador_pin_test.dart
```
Expected: PASS (7 testes).

- [ ] **Step 6: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: protecao por PIN com teclado numerico" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 20: Configurações — estrutura, Aba Geral e Aba Comunicação

**Files:**
- Create: `lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_configuracoes.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/seletor_logo.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_geral.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_comunicacao.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/paginas/pagina_configuracoes.dart` (com abas Aparência/Propaganda/Diagnóstico como placeholders `EstadoVazio` até as Tasks 21–23)
- Test: `test/funcionalidades/configuracoes/controlador_configuracoes_test.dart`
- Test: `test/funcionalidades/configuracoes/abas_basicas_test.dart`

**Interfaces:**
- Consumes: repositórios (Tasks 7–8), `CasoUsoTestarConexao` (Task 10), widgets (Task 6), `Ambiente` (Task 4), `FormatadorData` (Task 3), `file_picker`.
- Produces:
  - `EstadoConfiguracoes` (Freezed): `{configuracao=ConfiguracaoTerminal(), usuario='', senha='', carregando=true, salvando=false, testando=false, mensagem?, mensagemErro=false}`.
  - `ControladorConfiguracoes({repositorioConfiguracao, repositorioCredencial, casoUsoTestarConexao})` com `carregar()`, `salvarConfiguracao(ConfiguracaoTerminal)`, `salvarComunicacao({usuario, senha, ambiente, urlProducao, urlHomologacao})` (salva credencial no secure storage + config), `testarConexao()` (mensagem 'Conexão OK · HH:mm' ou a mensagem da falha com `mensagemErro=true`), `limparMensagem()`.
  - `provedorConfiguracoes` (`StateNotifierProvider.autoDispose`).
  - `SeletorLogo` — mostra logo atual (do `provedorTema`), botão 'Escolher logo' via `FilePicker.platform.pickFiles(type: FileType.image)` → `provedorTema.atualizar(tema.copyWith(logoPath: caminho))`, botão 'Remover' quando há logo.
  - `AbaGeral` — campos nome/identificador + `SeletorLogo` + 'Salvar'.
  - `AbaComunicacao` — usuário, senha, `SegmentedButton<Ambiente>`, URLs (validação `Validadores.urlValida` quando não vazio), 'Testar conexão' (`BotaoSecundario`, carregando durante teste), 'Salvar'.
  - `PaginaConfiguracoes` — `DefaultTabController(length: 5)`, `AppBar` 'Configurações' com voltar → `/splash`, `TabBar` ['Geral', 'Comunicação', 'Aparência', 'Propaganda', 'Diagnóstico'] com `isScrollable: true`, `TabBarView` com as abas. Mensagens do estado viram `mostrarSnackbarPadrao` via `ref.listen`.

- [ ] **Step 1: Escrever os testes que falham**

`test/funcionalidades/configuracoes/controlador_configuracoes_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_configuracoes.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/casos_uso/caso_uso_testar_conexao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/credencial.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_credencial.dart';
import 'package:constel_pay/nucleo/configuracao/ambiente.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CredencialFake implements RepositorioCredencial {
  Credencial? salva;

  @override
  Future<Credencial?> obter() async => salva;

  @override
  Future<void> salvar(Credencial credencial) async => salva = credencial;

  @override
  Future<void> remover() async => salva = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RepositorioConfiguracaoImpl repositorioConfiguracao;
  late _CredencialFake repositorioCredencial;
  late ControladorConfiguracoes controlador;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    repositorioConfiguracao = RepositorioConfiguracaoImpl(preferencias);
    repositorioCredencial = _CredencialFake();
    controlador = ControladorConfiguracoes(
      repositorioConfiguracao: repositorioConfiguracao,
      repositorioCredencial: repositorioCredencial,
      casoUsoTestarConexao: CasoUsoTestarConexao(
        clienteApi: ClienteApi(repositorioConfiguracao: repositorioConfiguracao, dio: Dio()),
        repositorioConfiguracao: repositorioConfiguracao,
        preferencias: preferencias,
      ),
    );
    await controlador.carregar();
  });

  test('carregar preenche configuracao e credencial', () async {
    expect(controlador.state.carregando, isFalse);
    expect(controlador.state.configuracao.nomeRestaurante, 'Constel Pay');
  });

  test('salvarConfiguracao persiste os novos dados', () async {
    final nova = controlador.state.configuracao
        .copyWith(nomeRestaurante: 'Durango Burgers', identificadorDispositivo: 'TOTEM-07');
    await controlador.salvarConfiguracao(nova);
    expect((await repositorioConfiguracao.obter()).nomeRestaurante, 'Durango Burgers');
    expect(controlador.state.mensagem, isNotNull);
    expect(controlador.state.mensagemErro, isFalse);
  });

  test('salvarComunicacao grava credencial e urls', () async {
    await controlador.salvarComunicacao(
      usuario: 'operador',
      senha: 's3nh4',
      ambiente: Ambiente.producao,
      urlProducao: 'https://api.constel.com.br',
      urlHomologacao: 'https://homolog.constel.com.br',
    );
    expect(repositorioCredencial.salva,
        const Credencial(usuario: 'operador', senha: 's3nh4'));
    final configuracao = await repositorioConfiguracao.obter();
    expect(configuracao.ambiente, Ambiente.producao);
    expect(configuracao.urlBaseAtiva, 'https://api.constel.com.br');
  });

  test('testarConexao sem URL valida gera mensagem de erro', () async {
    await controlador.testarConexao();
    expect(controlador.state.mensagemErro, isTrue);
    expect(controlador.state.mensagem, contains('URL'));
  });
}
```

`test/funcionalidades/configuracoes/abas_basicas_test.dart`:

```dart
import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/paginas/pagina_configuracoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('pagina de configuracoes mostra as 5 abas e salva a aba Geral',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final roteador = GoRouter(
      initialLocation: '/configuracoes',
      routes: [
        GoRoute(path: '/configuracoes', builder: (_, __) => const PaginaConfiguracoes()),
        GoRoute(path: '/splash', builder: (_, __) => const Scaffold(body: Text('SPLASH'))),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: MaterialApp.router(routerConfig: roteador),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Geral'), findsOneWidget);
    expect(find.text('Comunicação'), findsOneWidget);
    expect(find.text('Aparência'), findsOneWidget);
    expect(find.text('Propaganda'), findsOneWidget);
    expect(find.text('Diagnóstico'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do restaurante'), 'Durango Burgers');
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final repositorio = ProviderScope.containerOf(
            tester.element(find.byType(PaginaConfiguracoes)))
        .read(provedorRepositorioConfiguracao);
    expect((await repositorio.obter()).nomeRestaurante, 'Durango Burgers');
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/controlador_configuracoes_test.dart test/funcionalidades/configuracoes/abas_basicas_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar o controlador**

`lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_configuracoes.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../nucleo/configuracao/ambiente.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../../nucleo/formatadores/formatador_data.dart';
import '../../dominio/casos_uso/caso_uso_testar_conexao.dart';
import '../../dominio/entidades/configuracao_terminal.dart';
import '../../dominio/entidades/credencial.dart';
import '../../dominio/repositorios/repositorio_configuracao.dart';
import '../../dominio/repositorios/repositorio_credencial.dart';

part 'controlador_configuracoes.freezed.dart';

@freezed
class EstadoConfiguracoes with _$EstadoConfiguracoes {
  const factory EstadoConfiguracoes({
    @Default(ConfiguracaoTerminal()) ConfiguracaoTerminal configuracao,
    @Default('') String usuario,
    @Default('') String senha,
    @Default(true) bool carregando,
    @Default(false) bool salvando,
    @Default(false) bool testando,
    String? mensagem,
    @Default(false) bool mensagemErro,
  }) = _EstadoConfiguracoes;
}

class ControladorConfiguracoes extends StateNotifier<EstadoConfiguracoes> {
  ControladorConfiguracoes({
    required RepositorioConfiguracao repositorioConfiguracao,
    required RepositorioCredencial repositorioCredencial,
    required CasoUsoTestarConexao casoUsoTestarConexao,
  })  : _repositorioConfiguracao = repositorioConfiguracao,
        _repositorioCredencial = repositorioCredencial,
        _casoUsoTestarConexao = casoUsoTestarConexao,
        super(const EstadoConfiguracoes());

  final RepositorioConfiguracao _repositorioConfiguracao;
  final RepositorioCredencial _repositorioCredencial;
  final CasoUsoTestarConexao _casoUsoTestarConexao;

  Future<void> carregar() async {
    final configuracao = await _repositorioConfiguracao.obter();
    final credencial = await _repositorioCredencial.obter();
    state = state.copyWith(
      configuracao: configuracao,
      usuario: credencial?.usuario ?? '',
      senha: credencial?.senha ?? '',
      carregando: false,
    );
  }

  Future<void> salvarConfiguracao(ConfiguracaoTerminal nova) async {
    state = state.copyWith(salvando: true, mensagem: null);
    await _repositorioConfiguracao.salvar(nova);
    state = state.copyWith(
      configuracao: nova,
      salvando: false,
      mensagem: 'Configurações salvas.',
      mensagemErro: false,
    );
  }

  Future<void> salvarComunicacao({
    required String usuario,
    required String senha,
    required Ambiente ambiente,
    required String urlProducao,
    required String urlHomologacao,
  }) async {
    state = state.copyWith(salvando: true, mensagem: null);
    if (usuario.isNotEmpty || senha.isNotEmpty) {
      await _repositorioCredencial.salvar(Credencial(usuario: usuario, senha: senha));
    }
    final nova = state.configuracao.copyWith(
      ambiente: ambiente,
      urlBaseProducao: urlProducao.trim(),
      urlBaseHomologacao: urlHomologacao.trim(),
    );
    await _repositorioConfiguracao.salvar(nova);
    state = state.copyWith(
      configuracao: nova,
      usuario: usuario,
      senha: senha,
      salvando: false,
      mensagem: 'Comunicação salva.',
      mensagemErro: false,
    );
  }

  Future<void> testarConexao() async {
    state = state.copyWith(testando: true, mensagem: null);
    final resultado = await _casoUsoTestarConexao.executar();
    state = resultado.quando(
      sucesso: (momento) => state.copyWith(
        testando: false,
        mensagem: 'Conexão OK · ${FormatadorData.hora(momento)}',
        mensagemErro: false,
      ),
      erro: (falha) => state.copyWith(
        testando: false,
        mensagem: falha.mensagem,
        mensagemErro: true,
      ),
    );
  }

  void limparMensagem() => state = state.copyWith(mensagem: null);
}

final provedorConfiguracoes = StateNotifierProvider.autoDispose<ControladorConfiguracoes,
    EstadoConfiguracoes>((ref) {
  final controlador = ControladorConfiguracoes(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    repositorioCredencial: ref.watch(provedorRepositorioCredencial),
    casoUsoTestarConexao: ref.watch(provedorCasoUsoTestarConexao),
  );
  controlador.carregar();
  return controlador;
});
```

- [ ] **Step 4: Implementar as abas e a página**

`lib/funcionalidades/configuracoes/apresentacao/componentes/seletor_logo.dart`:

```dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';

class SeletorLogo extends ConsumerWidget {
  const SeletorLogo({super.key});

  Future<void> _escolher(WidgetRef ref) async {
    final resultado = await FilePicker.platform.pickFiles(type: FileType.image);
    final caminho = resultado?.files.single.path;
    if (caminho == null) return;
    final tema = ref.read(provedorTema);
    await ref.read(provedorTema.notifier).atualizar(tema.copyWith(logoPath: caminho));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = ref.watch(provedorTema);
    final logoPath = tema.logoPath;
    final temLogo = logoPath != null && File(logoPath).existsSync();
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: CoresApp.lilasClaro,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: temLogo
              ? Image.file(File(logoPath), fit: BoxFit.cover)
              : const Text('🍽️', style: TextStyle(fontSize: 28)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: BotaoSecundario(rotulo: 'Escolher logo', aoTocar: () => _escolher(ref)),
        ),
        if (temLogo) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: CoresApp.erro),
            onPressed: () => ref
                .read(provedorTema.notifier)
                .atualizar(tema.copyWith(logoPath: null)),
          ),
        ],
      ],
    );
  }
}
```

`lib/funcionalidades/configuracoes/apresentacao/componentes/aba_geral.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/campo_texto.dart';
import '../controladores/controlador_configuracoes.dart';
import 'seletor_logo.dart';

class AbaGeral extends ConsumerStatefulWidget {
  const AbaGeral({super.key});

  @override
  ConsumerState<AbaGeral> createState() => _AbaGeralState();
}

class _AbaGeralState extends ConsumerState<AbaGeral> {
  final _nome = TextEditingController();
  final _identificador = TextEditingController();
  bool _preenchido = false;

  @override
  void dispose() {
    _nome.dispose();
    _identificador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorConfiguracoes);
    if (!estado.carregando && !_preenchido) {
      _nome.text = estado.configuracao.nomeRestaurante;
      _identificador.text = estado.configuracao.identificadorDispositivo;
      _preenchido = true;
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CampoTexto(rotulo: 'Nome do restaurante', controlador: _nome),
        const SizedBox(height: 14),
        CampoTexto(rotulo: 'Identificador do dispositivo', controlador: _identificador),
        const SizedBox(height: 18),
        const SeletorLogo(),
        const SizedBox(height: 24),
        BotaoPrimario(
          rotulo: 'Salvar',
          carregando: estado.salvando,
          aoTocar: () => ref.read(provedorConfiguracoes.notifier).salvarConfiguracao(
                estado.configuracao.copyWith(
                  nomeRestaurante: _nome.text.trim(),
                  identificadorDispositivo: _identificador.text.trim(),
                ),
              ),
        ),
      ],
    );
  }
}
```

`lib/funcionalidades/configuracoes/apresentacao/componentes/aba_comunicacao.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/campo_senha.dart';
import '../../../../compartilhado/widgets/campo_texto.dart';
import '../../../../nucleo/configuracao/ambiente.dart';
import '../../../../nucleo/utils/validadores.dart';
import '../controladores/controlador_configuracoes.dart';

class AbaComunicacao extends ConsumerStatefulWidget {
  const AbaComunicacao({super.key});

  @override
  ConsumerState<AbaComunicacao> createState() => _AbaComunicacaoState();
}

class _AbaComunicacaoState extends ConsumerState<AbaComunicacao> {
  final _formulario = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _senha = TextEditingController();
  final _urlProducao = TextEditingController();
  final _urlHomologacao = TextEditingController();
  Ambiente _ambiente = Ambiente.homologacao;
  bool _preenchido = false;

  @override
  void dispose() {
    _usuario.dispose();
    _senha.dispose();
    _urlProducao.dispose();
    _urlHomologacao.dispose();
    super.dispose();
  }

  String? _validarUrl(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    return Validadores.urlValida(valor) ? null : 'Informe uma URL válida (http/https).';
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorConfiguracoes);
    final controlador = ref.read(provedorConfiguracoes.notifier);
    if (!estado.carregando && !_preenchido) {
      _usuario.text = estado.usuario;
      _senha.text = estado.senha;
      _urlProducao.text = estado.configuracao.urlBaseProducao;
      _urlHomologacao.text = estado.configuracao.urlBaseHomologacao;
      _ambiente = estado.configuracao.ambiente;
      _preenchido = true;
    }
    return Form(
      key: _formulario,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CampoTexto(rotulo: 'Usuário', controlador: _usuario),
          const SizedBox(height: 14),
          CampoSenha(rotulo: 'Senha', controlador: _senha),
          const SizedBox(height: 20),
          SegmentedButton<Ambiente>(
            segments: Ambiente.values
                .map((a) => ButtonSegment(value: a, label: Text(a.rotulo)))
                .toList(),
            selected: {_ambiente},
            onSelectionChanged: (selecao) => setState(() => _ambiente = selecao.first),
          ),
          const SizedBox(height: 20),
          CampoTexto(
              rotulo: 'URL Base Produção',
              controlador: _urlProducao,
              validador: _validarUrl,
              tipoTeclado: TextInputType.url),
          const SizedBox(height: 14),
          CampoTexto(
              rotulo: 'URL Base Homologação',
              controlador: _urlHomologacao,
              validador: _validarUrl,
              tipoTeclado: TextInputType.url),
          const SizedBox(height: 24),
          BotaoSecundario(
            rotulo: estado.testando ? 'Testando...' : 'Testar conexão',
            aoTocar: estado.testando ? null : controlador.testarConexao,
          ),
          const SizedBox(height: 12),
          BotaoPrimario(
            rotulo: 'Salvar',
            carregando: estado.salvando,
            aoTocar: () {
              if (!(_formulario.currentState?.validate() ?? false)) return;
              controlador.salvarComunicacao(
                usuario: _usuario.text.trim(),
                senha: _senha.text,
                ambiente: _ambiente,
                urlProducao: _urlProducao.text,
                urlHomologacao: _urlHomologacao.text,
              );
            },
          ),
        ],
      ),
    );
  }
}
```

`lib/funcionalidades/configuracoes/apresentacao/paginas/pagina_configuracoes.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../compartilhado/feedback/estado_vazio.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../componentes/aba_comunicacao.dart';
import '../componentes/aba_geral.dart';
import '../controladores/controlador_configuracoes.dart';

class PaginaConfiguracoes extends ConsumerWidget {
  const PaginaConfiguracoes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(provedorConfiguracoes.select((e) => e.mensagem), (_, mensagem) {
      if (mensagem == null) return;
      final erro = ref.read(provedorConfiguracoes).mensagemErro;
      mostrarSnackbarPadrao(context, mensagem, erro: erro);
      ref.read(provedorConfiguracoes.notifier).limparMensagem();
    });

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configurações'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.go('/splash'),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Geral'),
              Tab(text: 'Comunicação'),
              Tab(text: 'Aparência'),
              Tab(text: 'Propaganda'),
              Tab(text: 'Diagnóstico'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AbaGeral(),
            AbaComunicacao(),
            // Substituídas nas Tasks 21-23:
            EstadoVazio(emoji: '🎨', titulo: 'Aparência', mensagem: 'Em construção'),
            EstadoVazio(emoji: '🎬', titulo: 'Propaganda', mensagem: 'Em construção'),
            EstadoVazio(emoji: '🩺', titulo: 'Diagnóstico', mensagem: 'Em construção'),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Gerar código e rodar os testes**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/funcionalidades/configuracoes/controlador_configuracoes_test.dart test/funcionalidades/configuracoes/abas_basicas_test.dart
```
Expected: PASS (5 testes).

- [ ] **Step 6: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: configuracoes com abas Geral e Comunicacao protegidas por PIN" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 21: Configurações — Aba Aparência

**Files:**
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/seletor_cor.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_aparencia.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/paginas/pagina_configuracoes.dart` (trocar o placeholder pela `AbaAparencia`)
- Test: `test/funcionalidades/configuracoes/aba_aparencia_test.dart`

**Interfaces:**
- Consumes: `provedorTema`/`ControladorTema` (Task 7), `TemaConstel` (Task 5), `SeletorLogo` (Task 20), `BotaoPrimario` (Task 6).
- Produces:
  - `SeletorCor({rotulo, valorHex, aoMudar})` — círculo de preview + 8 amostras predefinidas (`#5E52D6, #7367F0, #FFD166, #F7F7FB, #2F2B3D, #2E7D32, #D32F2F, #1565C0`) + campo hex editável.
  - `AbaAparencia` — rascunho local de `TemaPersonalizado` (4 `SeletorCor`: primária, secundária, fundo, botões + `SeletorLogo`), seção 'Pré-visualização' (amostra de botão e card com as cores do rascunho) e 'Aplicar tema' → `provedorTema.atualizar(rascunho)` (aplicação dinâmica: o `MaterialApp` observa `provedorTema`). Botão 'Restaurar padrão' → `TemaPersonalizado()` preservando o logo.

- [ ] **Step 1: Escrever o teste que falha**

`test/funcionalidades/configuracoes/aba_aparencia_test.dart`:

```dart
import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/aba_aparencia.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/seletor_cor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SeletorCor propaga o hex digitado', (tester) async {
    var recebido = '';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SeletorCor(
            rotulo: 'Cor primária', valorHex: '#5E52D6', aoMudar: (hex) => recebido = hex),
      ),
    ));
    await tester.enterText(find.byType(TextFormField), '#112233');
    expect(recebido, '#112233');
  });

  testWidgets('Aplicar tema atualiza o provedorTema', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    late final ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: AbaAparencia())),
      ),
    );
    await tester.pump();
    container = ProviderScope.containerOf(tester.element(find.byType(AbaAparencia)));

    await tester.enterText(find.byType(TextFormField).first, '#112233');
    await tester.ensureVisible(find.text('Aplicar tema'));
    await tester.tap(find.text('Aplicar tema'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(container.read(provedorTema).corPrimaria, '#112233');
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/aba_aparencia_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/funcionalidades/configuracoes/apresentacao/componentes/seletor_cor.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';

class SeletorCor extends StatefulWidget {
  const SeletorCor({
    super.key,
    required this.rotulo,
    required this.valorHex,
    required this.aoMudar,
  });

  final String rotulo;
  final String valorHex;
  final void Function(String hex) aoMudar;

  static const List<String> amostras = [
    '#5E52D6', '#7367F0', '#FFD166', '#F7F7FB',
    '#2F2B3D', '#2E7D32', '#D32F2F', '#1565C0',
  ];

  @override
  State<SeletorCor> createState() => _SeletorCorState();
}

class _SeletorCorState extends State<SeletorCor> {
  late final TextEditingController _campo = TextEditingController(text: widget.valorHex);

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _selecionar(String hex) {
    _campo.text = hex;
    widget.aoMudar(hex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final corAtual = TemaConstel.corDeHex(_campo.text, CoresApp.primariaPadrao);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.rotulo,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: corAtual,
                shape: BoxShape.circle,
                border: Border.all(color: CoresApp.bordaCard, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _campo,
                decoration: const InputDecoration(hintText: '#RRGGBB'),
                onChanged: (valor) {
                  widget.aoMudar(valor);
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: SeletorCor.amostras
              .map(
                (hex) => GestureDetector(
                  onTap: () => _selecionar(hex),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: TemaConstel.corDeHex(hex, Colors.grey),
                      shape: BoxShape.circle,
                      border: Border.all(color: CoresApp.bordaCard),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
```

`lib/funcionalidades/configuracoes/apresentacao/componentes/aba_aparencia.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../dominio/entidades/tema_personalizado.dart';
import 'seletor_cor.dart';
import 'seletor_logo.dart';

class AbaAparencia extends ConsumerStatefulWidget {
  const AbaAparencia({super.key});

  @override
  ConsumerState<AbaAparencia> createState() => _AbaAparenciaState();
}

class _AbaAparenciaState extends ConsumerState<AbaAparencia> {
  TemaPersonalizado? _rascunho;

  TemaPersonalizado get _tema => _rascunho ?? ref.read(provedorTema);

  Future<void> _aplicar() async {
    await ref.read(provedorTema.notifier).atualizar(_tema);
    if (mounted) mostrarSnackbarPadrao(context, 'Tema aplicado.');
  }

  Future<void> _restaurar() async {
    final atual = ref.read(provedorTema);
    setState(() => _rascunho = TemaPersonalizado(logoPath: atual.logoPath));
    await ref.read(provedorTema.notifier).atualizar(_tema);
    if (mounted) mostrarSnackbarPadrao(context, 'Cores padrão restauradas.');
  }

  @override
  Widget build(BuildContext context) {
    final tema = _tema;
    final primaria = TemaConstel.corDeHex(tema.corPrimaria, CoresApp.primariaPadrao);
    final botoes = TemaConstel.corDeHex(tema.corBotoes, CoresApp.botoesPadrao);
    final fundo = TemaConstel.corDeHex(tema.corFundo, CoresApp.fundoPadrao);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SeletorCor(
          rotulo: 'Cor principal',
          valorHex: tema.corPrimaria,
          aoMudar: (hex) => setState(() => _rascunho = tema.copyWith(corPrimaria: hex)),
        ),
        const SizedBox(height: 18),
        SeletorCor(
          rotulo: 'Cor secundária',
          valorHex: tema.corSecundaria,
          aoMudar: (hex) => setState(() => _rascunho = tema.copyWith(corSecundaria: hex)),
        ),
        const SizedBox(height: 18),
        SeletorCor(
          rotulo: 'Cor de fundo',
          valorHex: tema.corFundo,
          aoMudar: (hex) => setState(() => _rascunho = tema.copyWith(corFundo: hex)),
        ),
        const SizedBox(height: 18),
        SeletorCor(
          rotulo: 'Cor dos botões',
          valorHex: tema.corBotoes,
          aoMudar: (hex) => setState(() => _rascunho = tema.copyWith(corBotoes: hex)),
        ),
        const SizedBox(height: 20),
        const Text('Logo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const SeletorLogo(),
        const SizedBox(height: 24),
        const Text('Pré-visualização',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: fundo,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CoresApp.bordaCard),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: CoresApp.bordaCard),
                ),
                child: Text(
                  'Exemplo de card',
                  style: TextStyle(fontWeight: FontWeight.w800, color: primaria),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: botoes,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const Text('Exemplo de botão',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        BotaoPrimario(rotulo: 'Aplicar tema', aoTocar: _aplicar),
        const SizedBox(height: 10),
        BotaoSecundario(rotulo: 'Restaurar padrão', aoTocar: _restaurar),
      ],
    );
  }
}
```

Em `pagina_configuracoes.dart`, substituir o placeholder de Aparência por `AbaAparencia()` (adicionar import). O `TabBarView` deixa de ser `const`.

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/funcionalidades/configuracoes/aba_aparencia_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: aba de aparencia com tema dinamico e pre-visualizacao" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 22: Configurações — Aba Propaganda

**Files:**
- Create: `lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/paginas/pagina_configuracoes.dart` (trocar o placeholder pela `AbaPropaganda`)
- Test: `test/funcionalidades/configuracoes/controlador_midias_test.dart`

**Interfaces:**
- Consumes: `RepositorioPropaganda` (Task 9), `MidiaPropaganda`/`TipoMidia` (Task 4), `PaginaPropaganda` (Task 18), `mostrarDialogoConfirmacao` (Task 6), `file_picker`, `uuid`.
- Produces:
  - `EstadoMidias` (Freezed): `{midias=[], carregando=true}`.
  - `ControladorMidias(RepositorioPropaganda)` com `carregar()`, `adicionarArquivos(List<String> caminhos)` (tipo por extensão: mp4/mov/webm/mkv = vídeo, senão imagem; `ordem` = maior+1; id via `Uuid().v4()`), `alternarAtivo(String id)`, `mover(String id, int delta)` (troca `ordem` com o vizinho e reordena), `remover(String id)`, `definirDuracao(String id, int segundos)` (mínimo 1) — toda mutação persiste via `salvarTodas` e recarrega o estado ordenado por `ordem`.
  - `provedorMidias` (`StateNotifierProvider.autoDispose`).
  - `AbaPropaganda` — lista de cards por mídia (thumb 🖼️/🎬, nome do arquivo, campo duração para imagens, `Switch` ativo, setas ↑/↓, lixeira com confirmação), `EstadoVazio` quando lista vazia, botões 'Adicionar mídias' (FilePicker `allowMultiple`, extensões `jpg,jpeg,png,webp,mp4,mov,webm,mkv`) e 'Visualizar' (push `PaginaPropaganda(preview: true)`).

- [ ] **Step 1: Escrever o teste que falha**

`test/funcionalidades/configuracoes/controlador_midias_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart';
import 'package:constel_pay/funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ControladorMidias controlador;
  late RepositorioPropagandaImpl repositorio;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repositorio = RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    controlador = ControladorMidias(repositorio);
    await controlador.carregar();
  });

  test('adicionarArquivos infere tipo e ordem', () async {
    await controlador.adicionarArquivos(['/m/foto.png', '/m/video.mp4']);
    final midias = controlador.state.midias;
    expect(midias, hasLength(2));
    expect(midias[0].tipo, TipoMidia.imagem);
    expect(midias[1].tipo, TipoMidia.video);
    expect(midias[0].ordem, 1);
    expect(midias[1].ordem, 2);
    expect(await repositorio.obterTodas(), hasLength(2));
  });

  test('alternarAtivo inverte o flag e persiste', () async {
    await controlador.adicionarArquivos(['/m/foto.png']);
    final id = controlador.state.midias.single.id;
    await controlador.alternarAtivo(id);
    expect(controlador.state.midias.single.ativo, isFalse);
    expect((await repositorio.obterAtivasOrdenadas()), isEmpty);
  });

  test('mover troca a posicao com o vizinho', () async {
    await controlador.adicionarArquivos(['/m/a.png', '/m/b.png', '/m/c.png']);
    final idC = controlador.state.midias[2].id;
    await controlador.mover(idC, -1);
    expect(controlador.state.midias[1].id, idC);
    await controlador.mover(idC, -1);
    expect(controlador.state.midias[0].id, idC);
    await controlador.mover(idC, -1); // ja esta no topo: no-op
    expect(controlador.state.midias[0].id, idC);
  });

  test('remover exclui e definirDuracao atualiza', () async {
    await controlador.adicionarArquivos(['/m/a.png', '/m/b.png']);
    final idA = controlador.state.midias[0].id;
    await controlador.remover(idA);
    expect(controlador.state.midias, hasLength(1));
    final idB = controlador.state.midias.single.id;
    await controlador.definirDuracao(idB, 15);
    expect(controlador.state.midias.single.duracaoSegundos, 15);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/controlador_midias_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar o controlador**

`lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';
import '../../../propaganda/dominio/repositorios/repositorio_propaganda.dart';

part 'controlador_midias.freezed.dart';

@freezed
class EstadoMidias with _$EstadoMidias {
  const factory EstadoMidias({
    @Default([]) List<MidiaPropaganda> midias,
    @Default(true) bool carregando,
  }) = _EstadoMidias;
}

class ControladorMidias extends StateNotifier<EstadoMidias> {
  ControladorMidias(this._repositorio) : super(const EstadoMidias());

  final RepositorioPropaganda _repositorio;

  static const Uuid _uuid = Uuid();
  static const Set<String> _extensoesVideo = {'mp4', 'mov', 'webm', 'mkv'};

  Future<void> carregar() async {
    final midias = [...await _repositorio.obterTodas()]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
    state = EstadoMidias(midias: midias, carregando: false);
  }

  Future<void> _persistir(List<MidiaPropaganda> midias) async {
    await _repositorio.salvarTodas(midias);
    state = state.copyWith(midias: midias);
  }

  Future<void> adicionarArquivos(List<String> caminhos) async {
    var proximaOrdem = state.midias.isEmpty
        ? 1
        : state.midias.map((m) => m.ordem).reduce((a, b) => a > b ? a : b) + 1;
    final novas = caminhos.map((caminho) {
      final extensao = caminho.split('.').last.toLowerCase();
      return MidiaPropaganda(
        id: _uuid.v4(),
        tipo: _extensoesVideo.contains(extensao) ? TipoMidia.video : TipoMidia.imagem,
        caminho: caminho,
        ordem: proximaOrdem++,
      );
    }).toList();
    await _persistir([...state.midias, ...novas]);
  }

  Future<void> alternarAtivo(String id) async {
    await _persistir([
      for (final midia in state.midias)
        midia.id == id ? midia.copyWith(ativo: !midia.ativo) : midia,
    ]);
  }

  Future<void> mover(String id, int delta) async {
    final midias = [...state.midias];
    final indice = midias.indexWhere((m) => m.id == id);
    final destino = indice + delta;
    if (indice < 0 || destino < 0 || destino >= midias.length) return;
    final ordemA = midias[indice].ordem;
    final ordemB = midias[destino].ordem;
    midias[indice] = midias[indice].copyWith(ordem: ordemB);
    midias[destino] = midias[destino].copyWith(ordem: ordemA);
    midias.sort((a, b) => a.ordem.compareTo(b.ordem));
    await _persistir(midias);
  }

  Future<void> remover(String id) async {
    await _persistir(state.midias.where((m) => m.id != id).toList());
  }

  Future<void> definirDuracao(String id, int segundos) async {
    if (segundos < 1) return;
    await _persistir([
      for (final midia in state.midias)
        midia.id == id ? midia.copyWith(duracaoSegundos: segundos) : midia,
    ]);
  }
}

final provedorMidias =
    StateNotifierProvider.autoDispose<ControladorMidias, EstadoMidias>((ref) {
  final controlador = ControladorMidias(ref.watch(provedorRepositorioPropaganda));
  controlador.carregar();
  return controlador;
});
```

- [ ] **Step 4: Implementar a aba**

`lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart`:

```dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/feedback/estado_vazio.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../../propaganda/apresentacao/paginas/pagina_propaganda.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';
import '../controladores/controlador_midias.dart';

class AbaPropaganda extends ConsumerWidget {
  const AbaPropaganda({super.key});

  Future<void> _adicionar(WidgetRef ref) async {
    final resultado = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'mp4', 'mov', 'webm', 'mkv'],
    );
    final caminhos =
        resultado?.files.map((f) => f.path).whereType<String>().toList() ?? const [];
    if (caminhos.isNotEmpty) {
      await ref.read(provedorMidias.notifier).adicionarArquivos(caminhos);
    }
  }

  Widget _cardMidia(BuildContext context, WidgetRef ref, MidiaPropaganda midia) {
    final controlador = ref.read(provedorMidias.notifier);
    final nomeArquivo = midia.caminho.split(RegExp(r'[\\/]')).last;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CoresApp.bordaCard),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CoresApp.lilasClaro,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(midia.tipo == TipoMidia.video ? '🎬' : '🖼️',
                style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nomeArquivo,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                if (midia.tipo == TipoMidia.imagem)
                  Row(
                    children: [
                      const Text('Duração:',
                          style: TextStyle(
                              fontSize: 11.5, color: CoresApp.textoSecundario)),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 44,
                        child: TextFormField(
                          initialValue: '${midia.duracaoSegundos}',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6)),
                          onFieldSubmitted: (valor) => controlador.definirDuracao(
                              midia.id, int.tryParse(valor) ?? midia.duracaoSegundos),
                        ),
                      ),
                      const Text(' s',
                          style: TextStyle(
                              fontSize: 11.5, color: CoresApp.textoSecundario)),
                    ],
                  ),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(Icons.arrow_upward, size: 18),
              onPressed: () => controlador.mover(midia.id, -1)),
          IconButton(
              icon: const Icon(Icons.arrow_downward, size: 18),
              onPressed: () => controlador.mover(midia.id, 1)),
          Switch(value: midia.ativo, onChanged: (_) => controlador.alternarAtivo(midia.id)),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: CoresApp.erro, size: 20),
            onPressed: () async {
              final confirmar = await mostrarDialogoConfirmacao(
                context,
                titulo: 'Remover mídia?',
                mensagem: '"$nomeArquivo" sairá da playlist de propaganda.',
                confirmar: 'Remover',
                destrutivo: true,
              );
              if (confirmar) await controlador.remover(midia.id);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(provedorMidias);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (estado.midias.isEmpty && !estado.carregando)
          const EstadoVazio(
            emoji: '🎬',
            titulo: 'Nenhuma mídia configurada',
            mensagem:
                'Sem mídias, a tela de espera mostra a chamada padrão "Toque para pagar".',
          )
        else
          ...estado.midias.map((midia) => _cardMidia(context, ref, midia)),
        const SizedBox(height: 12),
        BotaoPrimario(rotulo: 'Adicionar mídias', aoTocar: () => _adicionar(ref)),
        const SizedBox(height: 10),
        BotaoSecundario(
          rotulo: 'Visualizar',
          aoTocar: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
                builder: (_) => const PaginaPropaganda(preview: true)),
          ),
        ),
      ],
    );
  }
}
```

Em `pagina_configuracoes.dart`, substituir o placeholder de Propaganda por `AbaPropaganda()` (adicionar import).

- [ ] **Step 5: Gerar código e rodar os testes**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/funcionalidades/configuracoes/controlador_midias_test.dart
```
Expected: PASS (4 testes).

- [ ] **Step 6: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: aba de propaganda com playlist gerenciavel" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 23: Configurações — Aba Diagnóstico

**Files:**
- Create: `lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_diagnostico.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_diagnostico.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/paginas/pagina_configuracoes.dart` (trocar o placeholder pela `AbaDiagnostico`)
- Test: `test/funcionalidades/configuracoes/controlador_diagnostico_test.dart`

**Interfaces:**
- Consumes: `provedorRepositorioConfiguracao`, `provedorCasoUsoTestarConexao`, `provedorSharedPreferences`, `provedorArmazenamentoSeguro`, `registrador`/`saidaMemoria` (Task 10), `FormatadorData` (Task 3), `package_info_plus`, `connectivity_plus`, `path_provider`.
- Produces:
  - `EstadoDiagnostico` (Freezed): `{versaoApp='—', versaoApi='não disponível (mock)', ambienteRotulo='', identificador='', ip='—', conectado=false, ultimaSincronizacao?, testando=false, mensagem?, mensagemErro=false}`.
  - `ControladorDiagnostico({repositorioConfiguracao, casoUsoTestarConexao, preferencias, obterVersaoApp, obterIp, fluxoConectividade})` — funções injetáveis para testes:
    - `obterVersaoApp: Future<String> Function()` (padrão: `PackageInfo.fromPlatform()` → `'versao+build'`)
    - `obterIp: Future<String> Function()` (padrão: primeiro IPv4 não-loopback de `NetworkInterface.list()`; falha → `'—'`)
    - `fluxoConectividade: Stream<bool>` (padrão: `Connectivity().onConnectivityChanged` mapeado para `!contains(ConnectivityResult.none)`)
    - Métodos: `carregar()`, `testarApi()`, `exportarLogs(Future<String> Function() obterDiretorio)` (grava `constel-pay-logs-<epoch>.txt` com `saidaMemoria.linhas`, retorna o caminho), `limparDadosLocais(FlutterSecureStorage armazenamento)` (`preferencias.clear()` + `armazenamento.deleteAll()`).
  - `provedorDiagnostico` (`StateNotifierProvider.autoDispose`).
  - `AbaDiagnostico` — linhas somente leitura (versão do app, versão da API, ambiente, identificador, IP, status da conexão com bolinha verde/vermelha, última sincronização formatada ou 'nunca') + botões: 'Testar API', 'Exportar logs' (snackbar com o caminho), 'Limpar dados locais' (diálogo de confirmação destrutivo; após limpar → `context.go('/pin')`).

- [ ] **Step 1: Escrever o teste que falha**

`test/funcionalidades/configuracoes/controlador_diagnostico_test.dart`:

```dart
import 'dart:io';

import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_diagnostico.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/casos_uso/caso_uso_testar_conexao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
import 'package:constel_pay/nucleo/utils/registrador.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ControladorDiagnostico> criar() async {
    SharedPreferences.setMockInitialValues(
        {'ultima_sincronizacao': '2026-07-06T10:00:00.000'});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioConfiguracaoImpl(preferencias);
    await repositorio.salvar(const ConfiguracaoTerminal(identificadorDispositivo: 'TOTEM-07'));
    final controlador = ControladorDiagnostico(
      repositorioConfiguracao: repositorio,
      casoUsoTestarConexao: CasoUsoTestarConexao(
        clienteApi: ClienteApi(repositorioConfiguracao: repositorio, dio: Dio()),
        repositorioConfiguracao: repositorio,
        preferencias: preferencias,
      ),
      preferencias: preferencias,
      obterVersaoApp: () async => '1.0.0+1',
      obterIp: () async => '192.168.1.50',
      fluxoConectividade: Stream<bool>.value(true),
    );
    await controlador.carregar();
    return controlador;
  }

  test('carregar preenche versao, ip, identificador, ambiente e sincronizacao', () async {
    final controlador = await criar();
    final estado = controlador.state;
    expect(estado.versaoApp, '1.0.0+1');
    expect(estado.ip, '192.168.1.50');
    expect(estado.identificador, 'TOTEM-07');
    expect(estado.ambienteRotulo, 'Homologação');
    expect(estado.ultimaSincronizacao, DateTime(2026, 7, 6, 10));
    expect(estado.versaoApi, contains('mock'));
  });

  test('testarApi sem URL valida marca mensagem de erro', () async {
    final controlador = await criar();
    await controlador.testarApi();
    expect(controlador.state.mensagemErro, isTrue);
  });

  test('exportarLogs grava arquivo com as linhas do registrador', () async {
    final controlador = await criar();
    registrador.i('linha de teste do diagnostico');
    final diretorio = Directory.systemTemp.createTempSync('constel_logs');
    final caminho = await controlador.exportarLogs(() async => diretorio.path);
    expect(caminho, isNotNull);
    final conteudo = File(caminho!).readAsStringSync();
    expect(conteudo, contains('linha de teste do diagnostico'));
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/controlador_diagnostico_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar o controlador**

`lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_diagnostico.dart`:

```dart
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../nucleo/configuracao/ambiente.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../../nucleo/utils/registrador.dart';
import '../../dominio/casos_uso/caso_uso_testar_conexao.dart';
import '../../dominio/repositorios/repositorio_configuracao.dart';

part 'controlador_diagnostico.freezed.dart';

@freezed
class EstadoDiagnostico with _$EstadoDiagnostico {
  const factory EstadoDiagnostico({
    @Default('—') String versaoApp,
    @Default('não disponível (mock)') String versaoApi,
    @Default('') String ambienteRotulo,
    @Default('') String identificador,
    @Default('—') String ip,
    @Default(false) bool conectado,
    DateTime? ultimaSincronizacao,
    @Default(false) bool testando,
    String? mensagem,
    @Default(false) bool mensagemErro,
  }) = _EstadoDiagnostico;
}

Future<String> _versaoAppPadrao() async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
}

Future<String> _ipPadrao() async {
  try {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final interface in interfaces) {
      for (final endereco in interface.addresses) {
        if (!endereco.isLoopback) return endereco.address;
      }
    }
  } catch (_) {}
  return '—';
}

Stream<bool> _conectividadePadrao() => Connectivity()
    .onConnectivityChanged
    .map((resultados) => !resultados.contains(ConnectivityResult.none));

class ControladorDiagnostico extends StateNotifier<EstadoDiagnostico> {
  ControladorDiagnostico({
    required RepositorioConfiguracao repositorioConfiguracao,
    required CasoUsoTestarConexao casoUsoTestarConexao,
    required SharedPreferences preferencias,
    Future<String> Function()? obterVersaoApp,
    Future<String> Function()? obterIp,
    Stream<bool>? fluxoConectividade,
  })  : _repositorioConfiguracao = repositorioConfiguracao,
        _casoUsoTestarConexao = casoUsoTestarConexao,
        _preferencias = preferencias,
        _obterVersaoApp = obterVersaoApp ?? _versaoAppPadrao,
        _obterIp = obterIp ?? _ipPadrao,
        super(const EstadoDiagnostico()) {
    _assinatura = (fluxoConectividade ?? _conectividadePadrao())
        .listen((conectado) => state = state.copyWith(conectado: conectado));
  }

  final RepositorioConfiguracao _repositorioConfiguracao;
  final CasoUsoTestarConexao _casoUsoTestarConexao;
  final SharedPreferences _preferencias;
  final Future<String> Function() _obterVersaoApp;
  final Future<String> Function() _obterIp;
  late final StreamSubscription<bool> _assinatura;

  @override
  void dispose() {
    _assinatura.cancel();
    super.dispose();
  }

  Future<void> carregar() async {
    final configuracao = await _repositorioConfiguracao.obter();
    final versao = await _obterVersaoApp();
    final ip = await _obterIp();
    final sincronizacaoTexto =
        _preferencias.getString(ConstantesApp.chaveUltimaSincronizacao);
    state = state.copyWith(
      versaoApp: versao,
      ambienteRotulo: configuracao.ambiente.rotulo,
      identificador: configuracao.identificadorDispositivo,
      ip: ip,
      ultimaSincronizacao:
          sincronizacaoTexto != null ? DateTime.tryParse(sincronizacaoTexto) : null,
    );
  }

  Future<void> testarApi() async {
    state = state.copyWith(testando: true, mensagem: null);
    final resultado = await _casoUsoTestarConexao.executar();
    state = resultado.quando(
      sucesso: (momento) => state.copyWith(
          testando: false,
          ultimaSincronizacao: momento,
          mensagem: 'API respondeu com sucesso.',
          mensagemErro: false),
      erro: (falha) => state.copyWith(
          testando: false, mensagem: falha.mensagem, mensagemErro: true),
    );
  }

  Future<String?> exportarLogs([Future<String> Function()? obterDiretorio]) async {
    try {
      final diretorio = obterDiretorio != null
          ? await obterDiretorio()
          : (await getApplicationDocumentsDirectory()).path;
      final arquivo = File(
          '$diretorio${Platform.pathSeparator}constel-pay-logs-${DateTime.now().millisecondsSinceEpoch}.txt');
      await arquivo.writeAsString(saidaMemoria.linhas.join('\n'));
      state = state.copyWith(mensagem: 'Logs exportados: ${arquivo.path}', mensagemErro: false);
      return arquivo.path;
    } catch (_) {
      state = state.copyWith(mensagem: 'Não foi possível exportar os logs.', mensagemErro: true);
      return null;
    }
  }

  Future<void> limparDadosLocais(FlutterSecureStorage armazenamento) async {
    await _preferencias.clear();
    await armazenamento.deleteAll();
    registrador.i('Dados locais limpos pelo operador');
  }
}

final provedorDiagnostico =
    StateNotifierProvider.autoDispose<ControladorDiagnostico, EstadoDiagnostico>((ref) {
  final controlador = ControladorDiagnostico(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    casoUsoTestarConexao: ref.watch(provedorCasoUsoTestarConexao),
    preferencias: ref.watch(provedorSharedPreferences),
  );
  controlador.carregar();
  return controlador;
});
```

- [ ] **Step 4: Implementar a aba**

`lib/funcionalidades/configuracoes/apresentacao/componentes/aba_diagnostico.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../../../nucleo/formatadores/formatador_data.dart';
import '../controladores/controlador_diagnostico.dart';

class AbaDiagnostico extends ConsumerWidget {
  const AbaDiagnostico({super.key});

  Widget _linha(String rotulo, String valor, {Widget? extra}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(rotulo,
                  style: const TextStyle(
                      fontSize: 13,
                      color: CoresApp.textoSecundario,
                      fontWeight: FontWeight.w600)),
            ),
            if (extra != null) ...[extra, const SizedBox(width: 6)],
            Text(valor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(provedorDiagnostico);
    final controlador = ref.read(provedorDiagnostico.notifier);
    ref.listen(provedorDiagnostico.select((e) => e.mensagem), (_, mensagem) {
      if (mensagem == null) return;
      mostrarSnackbarPadrao(context, mensagem,
          erro: ref.read(provedorDiagnostico).mensagemErro);
    });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Cartao(
          filho: Column(
            children: [
              _linha('Versão do aplicativo', estado.versaoApp),
              _linha('Versão da API', estado.versaoApi),
              _linha('Ambiente atual', estado.ambienteRotulo),
              _linha('Identificador do dispositivo', estado.identificador),
              _linha('IP', estado.ip),
              _linha(
                'Status da conexão',
                estado.conectado ? 'Conectado' : 'Sem conexão',
                extra: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: estado.conectado ? CoresApp.sucesso : CoresApp.erro,
                  ),
                ),
              ),
              _linha(
                'Última sincronização',
                estado.ultimaSincronizacao != null
                    ? FormatadorData.dataHora(estado.ultimaSincronizacao!)
                    : 'nunca',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        BotaoPrimario(
          rotulo: 'Testar API',
          carregando: estado.testando,
          aoTocar: controlador.testarApi,
        ),
        const SizedBox(height: 10),
        BotaoSecundario(
          rotulo: 'Exportar logs',
          aoTocar: () => controlador.exportarLogs(),
        ),
        const SizedBox(height: 10),
        BotaoSecundario(
          rotulo: 'Limpar dados locais',
          aoTocar: () async {
            final confirmar = await mostrarDialogoConfirmacao(
              context,
              titulo: 'Limpar dados locais?',
              mensagem:
                  'Todas as configurações, tema, mídias e credenciais serão apagados. O PIN precisará ser criado de novo.',
              confirmar: 'Apagar tudo',
              destrutivo: true,
            );
            if (!confirmar || !context.mounted) return;
            await controlador.limparDadosLocais(ref.read(provedorArmazenamentoSeguro));
            if (context.mounted) context.go('/pin');
          },
        ),
      ],
    );
  }
}
```

Em `pagina_configuracoes.dart`, substituir o placeholder de Diagnóstico por `AbaDiagnostico()` (adicionar import; remover o import de `EstadoVazio` se não sobrar uso).

- [ ] **Step 5: Gerar código e rodar os testes**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/funcionalidades/configuracoes/controlador_diagnostico_test.dart
```
Expected: PASS (3 testes).

- [ ] **Step 6: Validar e commitar**

```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: aba de diagnostico com status, teste de API, logs e limpeza" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 24: Rotas, inatividade, app e teste de integração final

**Files:**
- Create: `lib/aplicativo/rotas.dart`
- Create: `lib/compartilhado/widgets/detector_inatividade.dart`
- Create: `lib/aplicativo/constel_pay_app.dart`
- Modify: `lib/main.dart` (substituir o provisório)
- Test: `test/integracao/fluxo_completo_test.dart`

**Interfaces:**
- Consumes: todas as páginas (Tasks 16–23), `provedorTema`, `TemaConstel`, `provedorFluxoPagamento`, `ConstantesApp`.
- Produces:
  - `GoRouter criarRoteador({required String localInicial})` — rotas: `/` → redirect `/splash`; `/splash`; `/propaganda`; `/chat` (envolto em `DetectorInatividade`); `/pin` (query `destino`); `/configuracoes`.
  - `DetectorInatividade({filho})` (ConsumerStatefulWidget) — `Listener` global que reinicia um `Timer(ConstantesApp.tempoInatividade)` a cada toque; ao expirar chama `novaOperacao()` e `context.go('/splash')`.
  - `ConstelPayApp({roteador})` — `MaterialApp.router` com `theme: TemaConstel.criar(ref.watch(provedorTema))` (tema dinâmico), `locale: Locale('pt', 'BR')`, `supportedLocales`, `localizationsDelegates: GlobalMaterialLocalizations.delegates`, `debugShowCheckedModeBanner: false`.
  - `main()` — inicializa `SharedPreferences`, cria `ProviderContainer` com override, carrega o tema, decide `localInicial` (`/pin` se `pinHash` vazio, senão `/splash`) e roda com `UncontrolledProviderScope`.

- [ ] **Step 1: Escrever o teste de integração que falha**

`test/integracao/fluxo_completo_test.dart`:

```dart
import 'package:constel_pay/aplicativo/constel_pay_app.dart';
import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/aplicativo/rotas.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('fluxo completo: splash -> propaganda -> chat -> pagamento -> novo',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    // Terminal ja provisionado (PIN criado)
    await RepositorioConfiguracaoImpl(preferencias)
        .salvar(const ConfiguracaoTerminal(pinHash: 'hash-existente'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
          provedorAtrasoBot.overrideWithValue(Duration.zero),
          provedorFonteLeituraMock.overrideWithValue(FonteLeituraMock(atraso: Duration.zero)),
          provedorFontePagamentoMock
              .overrideWithValue(FontePagamentoMock(atraso: Duration.zero)),
        ],
        child: ConstelPayApp(roteador: criarRoteador(localInicial: '/splash')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Splash -> Propaganda (timer de 4s)
    expect(find.text('Terminal de autoatendimento'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Propaganda (sem midias) -> CTA
    expect(find.text('Toque para pagar'), findsOneWidget);
    await tester.tap(find.text('Toque para pagar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Chat: leitura, pagamento, encerramento
    await tester.tap(find.textContaining('Simular leitura'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.textContaining('Ir para o pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Sem taxa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Pix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Já fiz o pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('aprovado'), findsWidgets);

    // Encerrar -> comprovante -> novo pagamento volta ao splash
    await tester.ensureVisible(find.text('Encerrar'));
    await tester.tap(find.text('Encerrar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Comprovante de pagamento'), findsOneWidget);
    await tester.ensureVisible(find.text('Novo pagamento'));
    await tester.tap(find.text('Novo pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Terminal de autoatendimento'), findsOneWidget);

    // Descarrega o timer do splash para o teste encerrar sem timers pendentes.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 100));
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/integracao/fluxo_completo_test.dart`
Expected: FAIL — URIs inexistentes.

- [ ] **Step 3: Implementar**

`lib/aplicativo/rotas.dart`:

```dart
import 'package:go_router/go_router.dart';

import '../compartilhado/widgets/detector_inatividade.dart';
import '../funcionalidades/chat/apresentacao/paginas/pagina_chat.dart';
import '../funcionalidades/configuracoes/apresentacao/paginas/pagina_configuracoes.dart';
import '../funcionalidades/configuracoes/apresentacao/paginas/pagina_pin.dart';
import '../funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart';
import '../funcionalidades/splash/apresentacao/paginas/pagina_splash.dart';

GoRouter criarRoteador({required String localInicial}) => GoRouter(
      initialLocation: localInicial,
      routes: [
        GoRoute(path: '/', redirect: (_, __) => '/splash'),
        GoRoute(path: '/splash', builder: (_, __) => const PaginaSplash()),
        GoRoute(path: '/propaganda', builder: (_, __) => const PaginaPropaganda()),
        GoRoute(
          path: '/chat',
          builder: (_, __) => const DetectorInatividade(filho: PaginaChat()),
        ),
        GoRoute(
          path: '/pin',
          builder: (_, estado) => PaginaPin(destino: estado.uri.queryParameters['destino']),
        ),
        GoRoute(path: '/configuracoes', builder: (_, __) => const PaginaConfiguracoes()),
      ],
    );
```

`lib/compartilhado/widgets/detector_inatividade.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart';
import '../../nucleo/constantes/constantes_app.dart';

/// Volta para o splash e descarta a operação após inatividade prolongada.
class DetectorInatividade extends ConsumerStatefulWidget {
  const DetectorInatividade({super.key, required this.filho});

  final Widget filho;

  @override
  ConsumerState<DetectorInatividade> createState() => _DetectorInatividadeState();
}

class _DetectorInatividadeState extends ConsumerState<DetectorInatividade> {
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _reiniciar();
  }

  void _reiniciar() {
    _temporizador?.cancel();
    _temporizador = Timer(ConstantesApp.tempoInatividade, _expirar);
  }

  void _expirar() {
    if (!mounted) return;
    ref.read(provedorFluxoPagamento.notifier).novaOperacao();
    context.go('/splash');
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _reiniciar(),
      behavior: HitTestBehavior.translucent,
      child: widget.filho,
    );
  }
}
```

`lib/aplicativo/constel_pay_app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'injecao.dart';
import 'tema/tema_constel.dart';

class ConstelPayApp extends ConsumerWidget {
  const ConstelPayApp({super.key, required this.roteador});

  final GoRouter roteador;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = ref.watch(provedorTema);
    return MaterialApp.router(
      title: 'Constel Pay',
      debugShowCheckedModeBanner: false,
      theme: TemaConstel.criar(tema),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: roteador,
    );
  }
}
```

`lib/main.dart` (substituir o conteúdo):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aplicativo/constel_pay_app.dart';
import 'aplicativo/injecao.dart';
import 'aplicativo/rotas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferencias = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
  );
  await container.read(provedorTema.notifier).carregar();
  final configuracao = await container.read(provedorRepositorioConfiguracao).obter();
  final roteador = criarRoteador(
    localInicial: configuracao.pinHash.isEmpty ? '/pin' : '/splash',
  );
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: ConstelPayApp(roteador: roteador),
    ),
  );
}
```

- [ ] **Step 4: Rodar o teste de integração**

Run: `flutter test test/integracao/fluxo_completo_test.dart`
Expected: PASS (1 teste).

- [ ] **Step 5: Validação final completa**

```bash
dart format .
flutter analyze
flutter test
```
Expected: formatação sem mudanças pendentes, "No issues found!", todos os testes verdes.

Verificação opcional de build (demorada; requer Android SDK):

```bash
flutter build apk --debug
```
Expected: APK gerado em `build/app/outputs/flutter-apk/app-debug.apk`. Se o Android SDK não estiver disponível, registrar como pendência na resposta final.

- [ ] **Step 6: Review adversarial (checklist do CLAUDE.md)**

Percorrer o checklist obrigatório: nenhuma tela extra? fidelidade visual? valores financeiros como int? ações críticas idempotentes? logs sem dados sensíveis? URLs centralizadas? estados de erro tratados? arquivos < 600 linhas (conferir com `Get-ChildItem lib -Recurse -Filter *.dart | ForEach-Object { [PSCustomObject]@{ Linhas = (Get-Content $_.FullName | Measure-Object -Line).Lines; Arquivo = $_.FullName } } | Where-Object { $_.Linhas -gt 600 }` — deve retornar vazio, ignorando arquivos gerados `.freezed.dart`/`.g.dart`)? Corrigir o que falhar antes do commit final.

- [ ] **Step 7: Commit final**

```bash
git add -A
git commit -m "feat: rotas, tema dinamico, inatividade e integracao final" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```
