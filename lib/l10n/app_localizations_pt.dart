// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get welcomeMessage =>
      'Olá! Bem-vindo(a). Vou fechar sua conta em segundos. 😊';

  @override
  String get scanInstruction =>
      'Para começar, aponte a câmera para o código do seu cartão de consumo 👇';

  @override
  String get addAnotherCardQuestion =>
      'Deseja incluir outro cartão nesta conta?';

  @override
  String get lastCardOpenMessage => 'Esse foi o último cartão em aberto.';

  @override
  String get cardReadErrorTitle => 'Não foi possível ler o cartão';

  @override
  String clientCardEcho(String reference) {
    return 'Comanda $reference';
  }

  @override
  String get noOpenItemsTitle => 'Nenhum consumo em aberto';

  @override
  String noOpenItemsMessage(String reference) {
    return 'Não encontramos itens pendentes para o cartão $reference.';
  }

  @override
  String get cardAlreadyAddedTitle => 'Cartão já adicionado';

  @override
  String cardAlreadyAddedMessage(String reference) {
    return 'A comanda $reference já está incluída nesta conta.';
  }

  @override
  String get addAnotherCard => 'Adicionar outro cartão';

  @override
  String get nextCardInstruction =>
      'Beleza! Aponte a câmera para o próximo código 👇';

  @override
  String get tryAnotherCard => 'Tentar outro cartão';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get continueToPayment => 'Continuar para pagamento';

  @override
  String continueToPaymentWithAmount(String amount) {
    return 'Continuar para pagamento · $amount';
  }

  @override
  String get continueWithAddedCards =>
      'Continuar com os cartões já adicionados';

  @override
  String continueWithAddedCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Continuar com $count cartões adicionados',
      one: 'Continuar com 1 cartão adicionado',
    );
    return '$_temp0';
  }

  @override
  String howWouldYouLikePay(String amount) {
    return 'Como você quer pagar $amount?';
  }

  @override
  String includesServiceFee(String amount) {
    return 'Inclui $amount de serviço.';
  }

  @override
  String get methodNotAvailable =>
      'Este método ainda não está disponível neste terminal. Use o Pix por enquanto. 😉';

  @override
  String get pixReadyMessage =>
      'Pronto! Escaneie o QR Code ou copie o código Pix 👇';

  @override
  String paymentNotApproved(String status) {
    return 'Pagamento $status. Tente novamente.';
  }

  @override
  String remainingCardsQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ainda há $count cartões em aberto. Quer pagar agora?',
      one: 'Ainda há 1 cartão em aberto. Quer pagar agora?',
    );
    return '$_temp0';
  }

  @override
  String get allCardsSettled => 'Tudo certo! Todos os cartões foram quitados.';

  @override
  String get payRemaining => 'Pagar restante';

  @override
  String get endService => 'Encerrar';

  @override
  String get thankYouMessage => 'Obrigado pela visita! Volte sempre 💜';

  @override
  String get receiptMessage => 'Aqui está o seu comprovante.';

  @override
  String get newPayment => 'Novo pagamento';

  @override
  String get tapOptionHint => '👆 Toque em uma opção acima para continuar';

  @override
  String totalBarCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartões',
      one: '1 cartão',
    );
    return '$_temp0';
  }

  @override
  String get totalBarServiceSuffix => ' · inclui serviço';

  @override
  String get scanPositionHint => 'Posicione o código do cartão dentro da área';

  @override
  String get simulateScanButton => '📷 Simular leitura do código';

  @override
  String get cardNumberHint => 'Nº do cartão';

  @override
  String get searchButton => 'Buscar';

  @override
  String get paidLabel => 'Pago ✓';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String serviceFeeLabel(String percent) {
    return 'Taxa de serviço ($percent)';
  }

  @override
  String get discountLabel => 'Desconto';

  @override
  String get cardTotalLabel => 'Total da comanda';

  @override
  String itemQuantityLabel(int quantity, String amount) {
    return '$quantity un · $amount cada';
  }

  @override
  String get payWithPix => 'Pague com Pix';

  @override
  String get validFor5Minutes => 'Válido por 5 minutos';

  @override
  String get codeCopied => 'Código copiado ✓';

  @override
  String get copyPixCode => '📋 Copiar código Pix';

  @override
  String get paymentDoneButton => 'Já fiz o pagamento';

  @override
  String get paymentApprovedTitle => 'Pagamento aprovado! 🎉';

  @override
  String get settledOrdersLabel => 'COMANDAS QUITADAS';

  @override
  String get selfCheckoutSubtitle => 'AutoPagamento · Cartões de consumo';

  @override
  String get receiptTitle => 'Comprovante de pagamento';

  @override
  String get dateTimeLabel => 'Data e hora';

  @override
  String get ordersLabel => 'Comandas';

  @override
  String get paymentMethodLabel => 'Forma de pagamento';

  @override
  String get identifierLabel => 'Identificador';

  @override
  String get amountPaidLabel => 'Valor pago';

  @override
  String get cancelOperationTitle => 'Cancelar operação?';

  @override
  String get cancelOperationMessage =>
      'O atendimento atual será encerrado e nada será cobrado.';

  @override
  String get confirmCancel => 'Sim, cancelar';

  @override
  String get continueHere => 'Continuar aqui';

  @override
  String get stillThereTitle => 'Você ainda está aí?';

  @override
  String inactivityMessage(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds segundos',
      one: '1 segundo',
    );
    return 'Sem atividade há algum tempo. Voltaremos à tela inicial em $_temp0.';
  }

  @override
  String get selfCheckoutTerminal => 'Terminal de AutoPagamento';

  @override
  String get errorNetwork =>
      'Falha de comunicação com a API. Verifique a URL configurada, a rede e se o serviço está no ar.';

  @override
  String get errorTimeout =>
      'O servidor demorou para responder. Tente novamente.';

  @override
  String get errorServer => 'Erro ao comunicar com o servidor.';

  @override
  String get errorUnauthorized =>
      'Acesso não autorizado. Verifique usuário e senha.';

  @override
  String get errorUnknown => 'Ocorreu um erro inesperado.';

  @override
  String get paymentMethodPix => 'Pix';

  @override
  String get paymentMethodCredit => 'Crédito';

  @override
  String get paymentMethodDebit => 'Débito';

  @override
  String get paymentMethodTef => 'TEF';

  @override
  String get paymentMethodPos => 'POS';

  @override
  String get paymentMethodVoucher => 'Voucher';

  @override
  String get paymentMethodCash => 'Dinheiro';

  @override
  String get paymentMethodPixDescription => 'Aprovação na hora';

  @override
  String get paymentMethodCreditDescription => 'Em até 12x';

  @override
  String get paymentMethodDebitDescription => 'À vista';

  @override
  String get paymentMethodTefDescription => 'Terminal integrado';

  @override
  String get paymentMethodPosDescription => 'Maquininha';

  @override
  String get paymentMethodVoucherDescription => 'Vale-refeição';

  @override
  String get paymentMethodCashDescription => 'No caixa';

  @override
  String get paymentStatusWaiting => 'Aguardando';

  @override
  String get paymentStatusProcessing => 'Processando';

  @override
  String get paymentStatusApproved => 'Aprovado';

  @override
  String get paymentStatusDeclined => 'Recusado';

  @override
  String get paymentStatusCancelled => 'Cancelado';

  @override
  String get paymentStatusExpired => 'Expirado';

  @override
  String get paymentStatusError => 'Erro';

  @override
  String get tapToPay => 'Toque para pagar';

  @override
  String get chooseLanguageTitle => 'Escolha o idioma';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String changeLanguageSemantics(String languageName) {
    return 'Alterar idioma. Idioma atual: $languageName.';
  }
}
