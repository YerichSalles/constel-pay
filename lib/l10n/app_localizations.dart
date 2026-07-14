import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// Primeira mensagem do bot ao iniciar o atendimento.
  ///
  /// In pt, this message translates to:
  /// **'Olá! Bem-vindo(a). Vou fechar sua conta em segundos. 😊'**
  String get welcomeMessage;

  /// Instrução do bot para escanear o cartão.
  ///
  /// In pt, this message translates to:
  /// **'Para começar, aponte a câmera para o código do seu cartão de consumo 👇'**
  String get scanInstruction;

  /// Pergunta do bot após ler um cartão com sucesso.
  ///
  /// In pt, this message translates to:
  /// **'Deseja incluir outro cartão nesta conta?'**
  String get addAnotherCardQuestion;

  /// Aviso do bot quando não há mais cartões em aberto no mock.
  ///
  /// In pt, this message translates to:
  /// **'Esse foi o último cartão em aberto.'**
  String get lastCardOpenMessage;

  /// Título da mensagem de erro de leitura do cartão.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível ler o cartão'**
  String get cardReadErrorTitle;

  /// Eco do cliente ao digitar o número da comanda (fluxo temporário de teste).
  ///
  /// In pt, this message translates to:
  /// **'Comanda {reference}'**
  String clientCardEcho(String reference);

  /// Título quando a comanda digitada não tem itens pendentes.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum consumo em aberto'**
  String get noOpenItemsTitle;

  /// Subtexto quando a comanda digitada não tem itens pendentes.
  ///
  /// In pt, this message translates to:
  /// **'Não encontramos itens pendentes para o cartão {reference}.'**
  String noOpenItemsMessage(String reference);

  /// Título quando a comanda digitada já foi incluída.
  ///
  /// In pt, this message translates to:
  /// **'Cartão já adicionado'**
  String get cardAlreadyAddedTitle;

  /// Subtexto quando a comanda digitada já foi incluída.
  ///
  /// In pt, this message translates to:
  /// **'A comanda {reference} já está incluída nesta conta.'**
  String cardAlreadyAddedMessage(String reference);

  /// Chip de ação e eco do cliente para ler mais um cartão.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar outro cartão'**
  String get addAnotherCard;

  /// Instrução do bot para ler o próximo cartão (reaparece em vários pontos do fluxo).
  ///
  /// In pt, this message translates to:
  /// **'Beleza! Aponte a câmera para o próximo código 👇'**
  String get nextCardInstruction;

  /// Chip/eco quando não há consumo em aberto e o cliente tenta outro cartão.
  ///
  /// In pt, this message translates to:
  /// **'Tentar outro cartão'**
  String get tryAnotherCard;

  /// Chip/eco após erro de leitura do cartão.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// Rótulo do chip que avança para a escolha do método de pagamento.
  ///
  /// In pt, this message translates to:
  /// **'Continuar para pagamento'**
  String get continueToPayment;

  /// Eco do cliente ao tocar em avançar para pagamento, com o valor já formatado.
  ///
  /// In pt, this message translates to:
  /// **'Continuar para pagamento · {amount}'**
  String continueToPaymentWithAmount(String amount);

  /// Chip discreto exibido durante a leitura de mais cartões, sem quantidade.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com os cartões já adicionados'**
  String get continueWithAddedCards;

  /// Chip/eco para continuar com os cartões já adicionados, com a contagem.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{Continuar com 1 cartão adicionado} other{Continuar com {count} cartões adicionados}}'**
  String continueWithAddedCardsCount(int count);

  /// Pergunta do bot ao chegar na escolha do método de pagamento.
  ///
  /// In pt, this message translates to:
  /// **'Como você quer pagar {amount}?'**
  String howWouldYouLikePay(String amount);

  /// Subtexto informando o valor da taxa de serviço incluída no total.
  ///
  /// In pt, this message translates to:
  /// **'Inclui {amount} de serviço.'**
  String includesServiceFee(String amount);

  /// Aviso quando o cliente escolhe um método diferente de Pix.
  ///
  /// In pt, this message translates to:
  /// **'Este método ainda não está disponível neste terminal. Use o Pix por enquanto. 😉'**
  String get methodNotAvailable;

  /// Mensagem do bot ao gerar o Pix com sucesso.
  ///
  /// In pt, this message translates to:
  /// **'Pronto! Escaneie o QR Code ou copie o código Pix 👇'**
  String get pixReadyMessage;

  /// Mensagem quando o pagamento não foi aprovado; status já vem traduzido e em minúsculas.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento {status}. Tente novamente.'**
  String paymentNotApproved(String status);

  /// Mensagem do bot após um pagamento aprovado quando ainda há cartões em aberto.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{Ainda há 1 cartão em aberto. Quer pagar agora?} other{Ainda há {count} cartões em aberto. Quer pagar agora?}}'**
  String remainingCardsQuestion(int count);

  /// Mensagem do bot quando o pagamento aprovado quita todos os cartões.
  ///
  /// In pt, this message translates to:
  /// **'Tudo certo! Todos os cartões foram quitados.'**
  String get allCardsSettled;

  /// Chip/eco para pagar os cartões restantes.
  ///
  /// In pt, this message translates to:
  /// **'Pagar restante'**
  String get payRemaining;

  /// Chip/eco para encerrar o atendimento.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar'**
  String get endService;

  /// Mensagem de despedida do bot ao encerrar o atendimento.
  ///
  /// In pt, this message translates to:
  /// **'Obrigado pela visita! Volte sempre 💜'**
  String get thankYouMessage;

  /// Subtexto que antecede o cartão de comprovante.
  ///
  /// In pt, this message translates to:
  /// **'Aqui está o seu comprovante.'**
  String get receiptMessage;

  /// Chip para iniciar um novo atendimento a partir da tela de encerramento.
  ///
  /// In pt, this message translates to:
  /// **'Novo pagamento'**
  String get newPayment;

  /// Dica exibida na área de ações quando não há chips visíveis.
  ///
  /// In pt, this message translates to:
  /// **'👆 Toque em uma opção acima para continuar'**
  String get tapOptionHint;

  /// Contagem de cartões selecionados exibida na barra de total.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, one{1 cartão} other{{count} cartões}}'**
  String totalBarCards(int count);

  /// Sufixo concatenado ao rótulo da barra de total quando há taxa de serviço.
  ///
  /// In pt, this message translates to:
  /// **' · inclui serviço'**
  String get totalBarServiceSuffix;

  /// Texto sobreposto ao visor do scanner simulado.
  ///
  /// In pt, this message translates to:
  /// **'Posicione o código do cartão dentro da área'**
  String get scanPositionHint;

  /// Botão que simula a leitura do código de barras.
  ///
  /// In pt, this message translates to:
  /// **'📷 Simular leitura do código'**
  String get simulateScanButton;

  /// Hint do campo temporário de digitação do número da comanda.
  ///
  /// In pt, this message translates to:
  /// **'Nº do cartão'**
  String get cardNumberHint;

  /// Botão de busca ao lado do campo temporário de comanda digitada.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get searchButton;

  /// Rótulo exibido no cartão de comanda quando ela já foi paga.
  ///
  /// In pt, this message translates to:
  /// **'Pago ✓'**
  String get paidLabel;

  /// Rótulo da linha de subtotal no cartão de comanda.
  ///
  /// In pt, this message translates to:
  /// **'Subtotal'**
  String get subtotalLabel;

  /// Rótulo da linha de taxa de serviço, com o percentual já formatado.
  ///
  /// In pt, this message translates to:
  /// **'Taxa de serviço ({percent})'**
  String serviceFeeLabel(String percent);

  /// Rótulo da linha de desconto no cartão de comanda.
  ///
  /// In pt, this message translates to:
  /// **'Desconto'**
  String get discountLabel;

  /// Rótulo do total da comanda individual.
  ///
  /// In pt, this message translates to:
  /// **'Total da comanda'**
  String get cardTotalLabel;

  /// Linha de quantidade e valor unitário de um item consumido.
  ///
  /// In pt, this message translates to:
  /// **'{quantity} un · {amount} cada'**
  String itemQuantityLabel(int quantity, String amount);

  /// Título do cartão de pagamento via Pix.
  ///
  /// In pt, this message translates to:
  /// **'Pague com Pix'**
  String get payWithPix;

  /// Aviso de validade do QR Code Pix.
  ///
  /// In pt, this message translates to:
  /// **'Válido por 5 minutos'**
  String get validFor5Minutes;

  /// Confirmação após copiar o código Pix.
  ///
  /// In pt, this message translates to:
  /// **'Código copiado ✓'**
  String get codeCopied;

  /// Botão para copiar o código Pix.
  ///
  /// In pt, this message translates to:
  /// **'📋 Copiar código Pix'**
  String get copyPixCode;

  /// Botão para confirmar que o pagamento Pix foi feito.
  ///
  /// In pt, this message translates to:
  /// **'Já fiz o pagamento'**
  String get paymentDoneButton;

  /// Título do cartão de sucesso do pagamento.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento aprovado! 🎉'**
  String get paymentApprovedTitle;

  /// Rótulo acima da lista de comandas quitadas no cartão de sucesso.
  ///
  /// In pt, this message translates to:
  /// **'COMANDAS QUITADAS'**
  String get settledOrdersLabel;

  /// Subtítulo abaixo do nome do restaurante no banner de boas-vindas.
  ///
  /// In pt, this message translates to:
  /// **'AutoPagamento · Cartões de consumo'**
  String get selfCheckoutSubtitle;

  /// Título do cartão de comprovante.
  ///
  /// In pt, this message translates to:
  /// **'Comprovante de pagamento'**
  String get receiptTitle;

  /// Rótulo da linha de data e hora no comprovante.
  ///
  /// In pt, this message translates to:
  /// **'Data e hora'**
  String get dateTimeLabel;

  /// Rótulo da linha de comandas no comprovante.
  ///
  /// In pt, this message translates to:
  /// **'Comandas'**
  String get ordersLabel;

  /// Rótulo da linha de forma de pagamento no comprovante.
  ///
  /// In pt, this message translates to:
  /// **'Forma de pagamento'**
  String get paymentMethodLabel;

  /// Rótulo da linha de identificador do comprovante.
  ///
  /// In pt, this message translates to:
  /// **'Identificador'**
  String get identifierLabel;

  /// Rótulo do valor total pago no comprovante.
  ///
  /// In pt, this message translates to:
  /// **'Valor pago'**
  String get amountPaidLabel;

  /// Título do diálogo de confirmação de saída do atendimento.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar operação?'**
  String get cancelOperationTitle;

  /// Mensagem do diálogo de confirmação de saída do atendimento.
  ///
  /// In pt, this message translates to:
  /// **'O atendimento atual será encerrado e nada será cobrado.'**
  String get cancelOperationMessage;

  /// Botão de confirmar a saída do atendimento.
  ///
  /// In pt, this message translates to:
  /// **'Sim, cancelar'**
  String get confirmCancel;

  /// Botão para permanecer no atendimento; reaparece no aviso de inatividade.
  ///
  /// In pt, this message translates to:
  /// **'Continuar aqui'**
  String get continueHere;

  /// Título do diálogo de aviso de inatividade.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda está aí?'**
  String get stillThereTitle;

  /// Mensagem do diálogo de inatividade com a contagem regressiva.
  ///
  /// In pt, this message translates to:
  /// **'Sem atividade há algum tempo. Voltaremos à tela inicial em {seconds, plural, one{1 segundo} other{{seconds} segundos}}.'**
  String inactivityMessage(int seconds);

  /// Subtítulo exibido na tela de splash.
  ///
  /// In pt, this message translates to:
  /// **'Terminal de AutoPagamento'**
  String get selfCheckoutTerminal;

  /// Mensagem padrão de FalhaRede.
  ///
  /// In pt, this message translates to:
  /// **'Falha de comunicação com a API. Verifique a URL configurada, a rede e se o serviço está no ar.'**
  String get errorNetwork;

  /// Mensagem padrão de FalhaTimeout.
  ///
  /// In pt, this message translates to:
  /// **'O servidor demorou para responder. Tente novamente.'**
  String get errorTimeout;

  /// Mensagem padrão de FalhaServidor.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao comunicar com o servidor.'**
  String get errorServer;

  /// Mensagem padrão de FalhaNaoAutorizado.
  ///
  /// In pt, this message translates to:
  /// **'Acesso não autorizado. Verifique usuário e senha.'**
  String get errorUnauthorized;

  /// Mensagem padrão de FalhaDesconhecida e chave genérica de fallback para FalhaValidacao sem mensagem customizada.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro inesperado.'**
  String get errorUnknown;

  /// Rótulo do método de pagamento Pix.
  ///
  /// In pt, this message translates to:
  /// **'Pix'**
  String get paymentMethodPix;

  /// Rótulo do método de pagamento Crédito.
  ///
  /// In pt, this message translates to:
  /// **'Crédito'**
  String get paymentMethodCredit;

  /// Rótulo do método de pagamento Débito.
  ///
  /// In pt, this message translates to:
  /// **'Débito'**
  String get paymentMethodDebit;

  /// Rótulo do método de pagamento TEF.
  ///
  /// In pt, this message translates to:
  /// **'TEF'**
  String get paymentMethodTef;

  /// Rótulo do método de pagamento POS.
  ///
  /// In pt, this message translates to:
  /// **'POS'**
  String get paymentMethodPos;

  /// Rótulo do método de pagamento Voucher.
  ///
  /// In pt, this message translates to:
  /// **'Voucher'**
  String get paymentMethodVoucher;

  /// Rótulo do método de pagamento Dinheiro.
  ///
  /// In pt, this message translates to:
  /// **'Dinheiro'**
  String get paymentMethodCash;

  /// Descrição do método de pagamento Pix.
  ///
  /// In pt, this message translates to:
  /// **'Aprovação na hora'**
  String get paymentMethodPixDescription;

  /// Descrição do método de pagamento Crédito.
  ///
  /// In pt, this message translates to:
  /// **'Em até 12x'**
  String get paymentMethodCreditDescription;

  /// Descrição do método de pagamento Débito.
  ///
  /// In pt, this message translates to:
  /// **'À vista'**
  String get paymentMethodDebitDescription;

  /// Descrição do método de pagamento TEF.
  ///
  /// In pt, this message translates to:
  /// **'Terminal integrado'**
  String get paymentMethodTefDescription;

  /// Descrição do método de pagamento POS.
  ///
  /// In pt, this message translates to:
  /// **'Maquininha'**
  String get paymentMethodPosDescription;

  /// Descrição do método de pagamento Voucher.
  ///
  /// In pt, this message translates to:
  /// **'Vale-refeição'**
  String get paymentMethodVoucherDescription;

  /// Descrição do método de pagamento Dinheiro.
  ///
  /// In pt, this message translates to:
  /// **'No caixa'**
  String get paymentMethodCashDescription;

  /// Rótulo de StatusPagamento.aguardando.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando'**
  String get paymentStatusWaiting;

  /// Rótulo de StatusPagamento.processando.
  ///
  /// In pt, this message translates to:
  /// **'Processando'**
  String get paymentStatusProcessing;

  /// Rótulo de StatusPagamento.aprovado.
  ///
  /// In pt, this message translates to:
  /// **'Aprovado'**
  String get paymentStatusApproved;

  /// Rótulo de StatusPagamento.recusado.
  ///
  /// In pt, this message translates to:
  /// **'Recusado'**
  String get paymentStatusDeclined;

  /// Rótulo de StatusPagamento.cancelado.
  ///
  /// In pt, this message translates to:
  /// **'Cancelado'**
  String get paymentStatusCancelled;

  /// Rótulo de StatusPagamento.expirado.
  ///
  /// In pt, this message translates to:
  /// **'Expirado'**
  String get paymentStatusExpired;

  /// Rótulo de StatusPagamento.erro.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get paymentStatusError;

  /// Texto padrão da faixa de chamada na tela inicial (textoFaixaPadrao).
  ///
  /// In pt, this message translates to:
  /// **'Toque para pagar'**
  String get tapToPay;

  /// Título do diálogo do seletor de idioma.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o idioma'**
  String get chooseLanguageTitle;

  /// Nome do idioma português, sempre no próprio idioma.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// Nome do idioma inglês, sempre no próprio idioma.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Nome do idioma espanhol, sempre no próprio idioma.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Texto de acessibilidade do botão seletor de idioma.
  ///
  /// In pt, this message translates to:
  /// **'Alterar idioma. Idioma atual: {languageName}.'**
  String changeLanguageSemantics(String languageName);

  /// Progresso do encerramento: ação 10 em andamento.
  ///
  /// In pt, this message translates to:
  /// **'Preparando encerramento…'**
  String get closingPreparing;

  /// Progresso do encerramento: fatura sendo criada.
  ///
  /// In pt, this message translates to:
  /// **'Gerando fatura…'**
  String get closingGeneratingInvoice;

  /// Progresso do encerramento: ação 30 em andamento.
  ///
  /// In pt, this message translates to:
  /// **'Confirmando encerramento…'**
  String get closingConfirming;

  /// Título da mensagem quando o encerramento financeiro falha; o detalhe vem da falha.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível encerrar a conta'**
  String get closingErrorTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
