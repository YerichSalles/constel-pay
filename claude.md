# Constel Pay - Regras e Skills para Claude

Use este arquivo como regra principal do Claude no projeto Constel Pay. Ele deve orientar implementacao, revisao, testes e decisoes tecnicas do projeto.

## Identidade do projeto

Constel Pay e um aplicativo do ecossistema Constel focado em pagamento. O projeto deve seguir a base visual ja definida pelo HTML fornecido pelo usuario e preservar o comportamento das telas existentes.

Regras principais:

- Stack alvo: Flutter >= 3.22 e Dart >= 3.4.
- O app nao possui login.
- O app nao possui dashboard.
- As telas devem ser somente as existentes no HTML/base visual, com excecao da tela de configuracoes, que ainda precisa ser criada.
- A referencia visual oficial fica em `base_visual/constel-pay.html`.
- Nao criar telas extras, fluxos extras, onboarding, area administrativa, marketing page ou dashboard sem pedido explicito.
- Priorizar app funcional, direto e operacional, nao uma apresentacao comercial.
- Idioma padrao: pt-BR.
- Moeda padrao: Real brasileiro, com formatacao `R$ 0,00`.
- O app deve parecer parte do ecossistema Constel, com visual consistente, limpo e profissional.

## Papel do Claude no projeto

Claude deve atuar como engenheiro senior Flutter, revisor adversarial e guardiao de escopo.

Responsabilidades:

- Ler o codigo existente antes de alterar.
- Entender a base visual antes de implementar.
- Implementar somente o que foi solicitado.
- Evitar refatoracoes grandes quando uma alteracao pequena resolve.
- Manter arquivos organizados, legiveis e pequenos.
- Preservar padroes existentes do projeto.
- Validar build, testes e comportamento visual apos alterar.
- Apontar riscos antes de seguir quando houver ambiguidade real.
- Nunca inventar endpoints, regras de pagamento ou fluxos financeiros sem confirmacao.

## Regras de escopo

O escopo do Constel Pay deve ser protegido com rigor.

Nao fazer:

- Criar login.
- Criar dashboard.
- Criar cadastro de usuario.
- Criar permissao por perfil.
- Criar menu lateral complexo.
- Criar telas nao previstas.
- Criar fluxo financeiro novo sem especificacao.
- Trocar a arquitetura sem necessidade.
- Substituir a identidade visual por tema generico.
- Usar componentes visuais que nao combinem com a base HTML.

Fazer:

- Reproduzir fielmente as telas do HTML.
- Criar a tela de configuracoes no mesmo padrao visual.
- Implementar navegacao simples entre as telas existentes.
- Deixar estados de carregamento, erro, vazio e sucesso quando fizer sentido.
- Manter a experiencia rapida, clara e adequada para uso operacional.

## Arquitetura recomendada

Use uma estrutura simples, previsivel e facil de manter.

As pastas de `lib/` usam nomes em pt-BR. Nao criar pastas em ingles (`core`, `features`, `shared`) — usar as existentes:

- `lib/aplicativo/` — app, rotas e `tema/`.
- `lib/nucleo/` — `configuracao/`, `constantes/`, `dispositivo/`, `erros/`, `formatadores/`, `utils/`.
- `lib/funcionalidades/` — uma pasta por tela/fluxo.
- `lib/compartilhado/` — `widgets/`, `layout/`, `feedback/`.

Regras:

- Separar `nucleo`, `funcionalidades` e `compartilhado`.
- Evitar arquivos gigantes. Preferir arquivos com menos de 600 linhas.
- Nao usar BLoC por padrao, a menos que o projeto ja tenha adotado.
- Para estado simples, preferir `ValueNotifier`, `ChangeNotifier` ou padrao ja existente.
- Centralizar tema, cores, textos reutilizaveis e rotas.
- Centralizar configuracoes de ambiente.
- Evitar URLs, chaves, textos repetidos e numeros magicos espalhados.

## Regras visuais

A interface deve seguir a base visual entregue no HTML.

Obrigatorio:

- Respeitar cores, espacamentos, bordas, sombras, tipografia e hierarquia visual da base.
- Preservar a experiencia das telas originais.
- Criar componentes reutilizaveis somente quando houver repeticao real.
- Garantir responsividade para diferentes tamanhos de tela.
- Evitar overflow, textos cortados e botoes fora da area visivel.
- Garantir contraste adequado.
- Usar pt-BR em todos os textos visiveis.
- Usar mensagens objetivas, sem linguagem tecnica para o usuario final.

Evitar:

- Gradientes genericos sem relacao com a identidade Constel.
- Telas muito vazias.
- Cards aninhados desnecessarios.
- Elementos decorativos que atrapalham o fluxo.
- Icones ou componentes inconsistentes entre telas.

## Tela de configuracoes

A tela de configuracoes deve seguir o mesmo estilo visual do HTML.

Ela pode conter, quando aplicavel:

- Dados do ambiente atual.
- Configuracao de endpoint ou ambiente, se o projeto exigir.
- Preferencias do dispositivo.
- Informacoes da versao do app.
- Botao de limpar dados/cache local, se fizer sentido.
- Status de conectividade, se fizer sentido.

Regras:

- Nao transformar configuracoes em dashboard.
- Nao criar login ou usuario aqui.
- Nao expor dados sensiveis.
- Nao permitir alteracoes perigosas sem confirmacao visual clara.
- Não criar arquivos com mais de 600 linhas.

## Pagamentos e seguranca

Como o projeto envolve pagamento, toda alteracao deve ser tratada como area sensivel.

Regras:

- Nunca simular sucesso de pagamento como comportamento final sem deixar claro que e mock/homologacao.
- Nunca armazenar dados sensiveis de cartao.
- Nunca logar token, senha, payload sensivel, dados de cartao ou dados pessoais desnecessarios.
- Separar claramente ambiente de homologacao e producao.
- Centralizar configuracoes de API em arquivo proprio.
- Validar valores antes de enviar.
- Tratar centavos com cuidado. Evitar `double` para calculos financeiros criticos quando houver regra de negocio.
- Exibir valores sempre formatados em moeda brasileira.
- Toda acao critica precisa de estado claro: aguardando, aprovado, recusado, cancelado, erro ou expirado.
- Mensagens de erro devem ser claras para o operador, mas sem expor detalhes internos sensiveis.

## Integracao com API

Quando houver integracao:

- Nao espalhar URL pelo codigo.
- Nao inventar endpoint.
- Criar camada de service/repository.
- Centralizar headers, timeout, interceptadores e tratamento de erro.
- Separar ambiente de homologacao e producao.
- Criar logs seguros para diagnostico.
- Tratar timeout e falta de internet.
- Prever retry apenas quando a operacao for segura para repeticao.
- Em pagamentos, cuidado com duplicidade: nunca repetir operacao critica sem idempotencia.

Padrao minimo:

```text
UI -> Controller/ViewModel -> Repository -> ApiClient -> API
```

## Estados obrigatorios de tela

Sempre que uma tela depender de carregamento ou operacao externa, implementar:

- Estado inicial.
- Carregando.
- Sucesso.
- Erro.
- Vazio, quando aplicavel.
- Cancelado/expirado, quando aplicavel ao pagamento.

O usuario nunca deve ficar sem retorno visual depois de tocar em um botao importante.

## Regras de codigo

Obrigatorio:

- Codigo claro e idiomatico em Dart.
- Nomes descritivos.
- Componentes pequenos.
- Funcoes pequenas e objetivas.
- Comentarios apenas quando explicarem uma regra nao obvia.
- Sem codigo morto.
- Sem imports nao usados.
- Sem prints soltos em producao.
- Sem TODO generico deixado para tras.
- Sem hardcode desnecessario.
- Sem duplicacao visual grande.
- Jamais ultrapasse 600 linhas nos arquivos de codigo.

Antes de finalizar uma tarefa:

- Rodar formatacao.
- Rodar analise estatica.
- Rodar testes existentes.
- Corrigir warnings relevantes.
- Validar se a tela continua fiel ao HTML.

Comandos esperados:

```bash
dart format .
flutter analyze
flutter test
```

Se o projeto tiver build configurado:

```bash
flutter build apk --debug
flutter build web
```

Use apenas os comandos aplicaveis ao projeto atual.

## Regras para mocks

Mocks sao permitidos no esqueleto inicial, desde que estejam bem isolados.

Regras:

- Dados mockados devem ficar em arquivos claros, como `mock_payment_data.dart`.
- Nunca misturar mock com regra real de API.
- Nomear visualmente ou tecnicamente quando algo for mock.
- Facilitar troca posterior por repository/API real.
- Nao deixar mock escondido em widget de tela.

## Review adversarial obrigatorio

Ao concluir qualquer implementacao, Claude deve fazer uma revisao adversarial contra o proprio trabalho.

Checklist:

- Criei alguma tela que nao foi pedida?
- Criei login ou dashboard por engano?
- Mantive a fidelidade visual do HTML?
- Algum texto esta cortando ou causando overflow?
- Algum valor financeiro pode ser calculado errado?
- Alguma acao critica pode ser enviada duas vezes?
- Algum log expoe dado sensivel?
- Alguma URL ficou hardcoded?
- Algum estado de erro ficou sem tratamento?
- A tela funciona em tamanhos diferentes?
- O codigo ficou mais complexo do que precisava?
- Existe codigo morto, import inutil ou TODO esquecido?
- Rodei formatacao, analise e testes possiveis?

Se encontrar problema, corrigir antes de responder.

## Criterios de aceite por tarefa

Toda tarefa deve terminar com:

- Implementacao feita.
- Arquivos alterados listados.
- Comandos executados.
- Resultado dos comandos.
- Pendencias reais, se existirem.
- Observacoes de risco, se existirem.

Nao responder apenas "feito" quando houver mudanca de codigo.

## Padrao de resposta do Claude

Responder em pt-BR, de forma direta.

Formato recomendado:

```text
Feito.

Alterei:
- arquivo X: ...
- arquivo Y: ...

Validei:
- flutter analyze: ok
- flutter test: ok

Observacao:
- ...
```

Se nao conseguiu rodar algo, explicar claramente:

```text
Nao consegui rodar o build porque ...
```

## Regra de ouro

O Constel Pay deve ser pequeno, rapido, fiel ao visual aprovado e seguro para evoluir. Se uma decisao deixar o app maior, mais confuso ou fora do fluxo definido, ela provavelmente esta errada.
