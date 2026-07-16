// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeMessage =>
      'Hello! Welcome. I\'ll help you pay your bill in just a few seconds. 😊';

  @override
  String get scanInstruction =>
      'To get started, scan the code on your consumption card with the reader 👇';

  @override
  String get addAnotherCardQuestion =>
      'Would you like to add another card to this bill?';

  @override
  String get lastCardOpenMessage => 'That was the last open card.';

  @override
  String get cardReadErrorTitle => 'We couldn\'t read the card';

  @override
  String clientCardEcho(String reference) {
    return 'Card $reference';
  }

  @override
  String get noOpenItemsTitle => 'No open items';

  @override
  String noOpenItemsMessage(String reference) {
    return 'We couldn\'t find any pending items for card $reference.';
  }

  @override
  String get cardAlreadyAddedTitle => 'Card already added';

  @override
  String cardAlreadyAddedMessage(String reference) {
    return 'Card $reference is already included in this bill.';
  }

  @override
  String get addAnotherCard => 'Add another card';

  @override
  String get nextCardInstruction =>
      'Great! Point the camera at the next code 👇';

  @override
  String get tryAnotherCard => 'Try another card';

  @override
  String get tryAgain => 'Try again';

  @override
  String get continueToPayment => 'Continue to payment';

  @override
  String continueToPaymentWithAmount(String amount) {
    return 'Continue to payment · $amount';
  }

  @override
  String get continueWithAddedCards => 'Continue with the added cards';

  @override
  String continueWithAddedCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Continue with $count added cards',
      one: 'Continue with 1 added card',
    );
    return '$_temp0';
  }

  @override
  String howWouldYouLikePay(String amount) {
    return 'How would you like to pay $amount?';
  }

  @override
  String includesServiceFee(String amount) {
    return 'Includes $amount in service fee.';
  }

  @override
  String get methodNotAvailable =>
      'This method isn\'t available on this terminal yet. Please use Pix for now. 😉';

  @override
  String get pixReadyMessage =>
      'All set! Scan the QR code or copy the Pix code 👇';

  @override
  String paymentNotApproved(String status) {
    return 'Payment $status. Please try again.';
  }

  @override
  String remainingCardsQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'There are still $count open cards. Want to pay now?',
      one: 'There is still 1 open card. Want to pay now?',
    );
    return '$_temp0';
  }

  @override
  String get allCardsSettled => 'All done! Every card has been paid.';

  @override
  String get payRemaining => 'Pay remaining';

  @override
  String get endService => 'Finish';

  @override
  String get thankYouMessage => 'Thanks for visiting! Come back soon 💜';

  @override
  String get receiptMessage => 'Here\'s your receipt.';

  @override
  String get newPayment => 'New payment';

  @override
  String get tapOptionHint => '👆 Tap an option above to continue';

  @override
  String totalBarCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get totalBarServiceSuffix => ' · includes service';

  @override
  String get scanPositionHint => 'Position the card code inside the frame';

  @override
  String get simulateScanButton => 'Simulate code scan';

  @override
  String get cardNumberHint => 'Card number';

  @override
  String get searchButton => 'Search';

  @override
  String get paidLabel => 'Paid ✓';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String serviceFeeLabel(String percent) {
    return 'Service fee ($percent)';
  }

  @override
  String get discountLabel => 'Discount';

  @override
  String get cardTotalLabel => 'Card total';

  @override
  String itemQuantityLabel(int quantity, String amount) {
    return '$quantity pcs · $amount each';
  }

  @override
  String get payWithPix => 'Pay with Pix';

  @override
  String get validFor5Minutes => 'Valid for 5 minutes';

  @override
  String get codeCopied => 'Code copied ✓';

  @override
  String get copyPixCode => '📋 Copy Pix code';

  @override
  String get paymentDoneButton => 'I\'ve already paid';

  @override
  String get paymentApprovedTitle => 'Payment approved! 🎉';

  @override
  String get settledOrdersLabel => 'SETTLED CARDS';

  @override
  String get selfCheckoutSubtitle => 'Self-Checkout · Consumption cards';

  @override
  String get receiptTitle => 'Payment receipt';

  @override
  String get dateTimeLabel => 'Date and time';

  @override
  String get ordersLabel => 'Cards';

  @override
  String get paymentMethodLabel => 'Payment method';

  @override
  String get identifierLabel => 'Identifier';

  @override
  String get amountPaidLabel => 'Amount paid';

  @override
  String get cancelOperationTitle => 'Cancel operation?';

  @override
  String get cancelOperationMessage =>
      'The current session will end and nothing will be charged.';

  @override
  String get confirmCancel => 'Yes, cancel';

  @override
  String get continueHere => 'Stay here';

  @override
  String get stillThereTitle => 'Are you still there?';

  @override
  String inactivityMessage(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return 'No activity for a while. We will return to the home screen in $_temp0.';
  }

  @override
  String get selfCheckoutTerminal => 'Self-Checkout Terminal';

  @override
  String get errorNetwork =>
      'Failed to communicate with the API. Check the configured URL, the network, and whether the service is online.';

  @override
  String get errorTimeout =>
      'The server took too long to respond. Please try again.';

  @override
  String get errorServer => 'Error communicating with the server.';

  @override
  String get errorUnauthorized =>
      'Unauthorized access. Check your username and password.';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String get paymentMethodPix => 'Pix';

  @override
  String get paymentMethodCredit => 'Credit';

  @override
  String get paymentMethodDebit => 'Debit';

  @override
  String get paymentMethodTef => 'TEF';

  @override
  String get paymentMethodPos => 'POS';

  @override
  String get paymentMethodVoucher => 'Voucher';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodPixDescription => 'Instant approval';

  @override
  String get paymentMethodCreditDescription => 'Up to 12 installments';

  @override
  String get paymentMethodDebitDescription => 'One-time payment';

  @override
  String get paymentMethodTefDescription => 'Integrated terminal';

  @override
  String get paymentMethodPosDescription => 'Card machine';

  @override
  String get paymentMethodVoucherDescription => 'Meal voucher';

  @override
  String get paymentMethodCashDescription => 'At the register';

  @override
  String get paymentStatusWaiting => 'Waiting';

  @override
  String get paymentStatusProcessing => 'Processing';

  @override
  String get paymentStatusApproved => 'Approved';

  @override
  String get paymentStatusDeclined => 'Declined';

  @override
  String get paymentStatusCancelled => 'Cancelled';

  @override
  String get paymentStatusExpired => 'Expired';

  @override
  String get paymentStatusError => 'Error';

  @override
  String get tapToPay => 'Tap to pay';

  @override
  String get chooseLanguageTitle => 'Choose your language';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String changeLanguageSemantics(String languageName) {
    return 'Change language. Current language: $languageName.';
  }

  @override
  String get closingPreparing => 'Preparing closure…';

  @override
  String get closingGeneratingInvoice => 'Generating invoice…';

  @override
  String get closingConfirming => 'Confirming closure…';

  @override
  String get closingErrorTitle => 'We couldn\'t close your bill';
}
