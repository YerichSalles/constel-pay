// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcomeMessage =>
      '¡Hola! Te damos la bienvenida. Te ayudaré a pagar tu cuenta en pocos segundos. 😊';

  @override
  String get scanInstruction =>
      'Para comenzar, apunta la cámara al código de tu tarjeta de consumo 👇';

  @override
  String get addAnotherCardQuestion =>
      '¿Deseas agregar otra tarjeta a esta cuenta?';

  @override
  String get lastCardOpenMessage => 'Esa fue la última tarjeta pendiente.';

  @override
  String get cardReadErrorTitle => 'No pudimos leer la tarjeta';

  @override
  String clientCardEcho(String reference) {
    return 'Tarjeta $reference';
  }

  @override
  String get noOpenItemsTitle => 'No hay consumos pendientes';

  @override
  String noOpenItemsMessage(String reference) {
    return 'No encontramos consumos pendientes para la tarjeta $reference.';
  }

  @override
  String get cardAlreadyAddedTitle => 'Tarjeta ya agregada';

  @override
  String cardAlreadyAddedMessage(String reference) {
    return 'La tarjeta $reference ya está incluida en esta cuenta.';
  }

  @override
  String get addAnotherCard => 'Agregar otra tarjeta';

  @override
  String get nextCardInstruction =>
      '¡Genial! Apunta la cámara al siguiente código 👇';

  @override
  String get tryAnotherCard => 'Probar otra tarjeta';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get continueToPayment => 'Continuar al pago';

  @override
  String continueToPaymentWithAmount(String amount) {
    return 'Continuar al pago · $amount';
  }

  @override
  String get continueWithAddedCards => 'Continuar con las tarjetas agregadas';

  @override
  String continueWithAddedCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Continuar con $count tarjetas agregadas',
      one: 'Continuar con 1 tarjeta agregada',
    );
    return '$_temp0';
  }

  @override
  String howWouldYouLikePay(String amount) {
    return '¿Cómo deseas pagar $amount?';
  }

  @override
  String includesServiceFee(String amount) {
    return 'Incluye $amount de servicio.';
  }

  @override
  String get methodNotAvailable =>
      'Este método aún no está disponible en este terminal. Usa Pix por ahora. 😉';

  @override
  String get pixReadyMessage =>
      '¡Listo! Escanea el código QR o copia el código Pix 👇';

  @override
  String paymentNotApproved(String status) {
    return 'Pago $status. Inténtalo de nuevo.';
  }

  @override
  String remainingCardsQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Todavía quedan $count tarjetas pendientes. ¿Quieres pagar ahora?',
      one: 'Todavía queda 1 tarjeta pendiente. ¿Quieres pagar ahora?',
    );
    return '$_temp0';
  }

  @override
  String get allCardsSettled => '¡Listo! Todas las tarjetas fueron pagadas.';

  @override
  String get payRemaining => 'Pagar el resto';

  @override
  String get endService => 'Finalizar';

  @override
  String get thankYouMessage => '¡Gracias por tu visita! Vuelve pronto 💜';

  @override
  String get receiptMessage => 'Aquí tienes tu comprobante.';

  @override
  String get newPayment => 'Nuevo pago';

  @override
  String get tapOptionHint => '👆 Toca una opción arriba para continuar';

  @override
  String totalBarCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarjetas',
      one: '1 tarjeta',
    );
    return '$_temp0';
  }

  @override
  String get totalBarServiceSuffix => ' · incluye servicio';

  @override
  String get scanPositionHint =>
      'Coloca el código de la tarjeta dentro del área';

  @override
  String get simulateScanButton => '📷 Simular lectura del código';

  @override
  String get cardNumberHint => 'N.º de tarjeta';

  @override
  String get searchButton => 'Buscar';

  @override
  String get paidLabel => 'Pagado ✓';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String serviceFeeLabel(String percent) {
    return 'Tarifa de servicio ($percent)';
  }

  @override
  String get discountLabel => 'Descuento';

  @override
  String get cardTotalLabel => 'Total de la tarjeta';

  @override
  String itemQuantityLabel(int quantity, String amount) {
    return '$quantity un · $amount c/u';
  }

  @override
  String get payWithPix => 'Paga con Pix';

  @override
  String get validFor5Minutes => 'Válido por 5 minutos';

  @override
  String get codeCopied => 'Código copiado ✓';

  @override
  String get copyPixCode => '📋 Copiar código Pix';

  @override
  String get paymentDoneButton => 'Ya realicé el pago';

  @override
  String get paymentApprovedTitle => '¡Pago aprobado! 🎉';

  @override
  String get settledOrdersLabel => 'TARJETAS PAGADAS';

  @override
  String get selfCheckoutSubtitle => 'Autopago · Tarjetas de consumo';

  @override
  String get receiptTitle => 'Comprobante de pago';

  @override
  String get dateTimeLabel => 'Fecha y hora';

  @override
  String get ordersLabel => 'Tarjetas';

  @override
  String get paymentMethodLabel => 'Forma de pago';

  @override
  String get identifierLabel => 'Identificador';

  @override
  String get amountPaidLabel => 'Monto pagado';

  @override
  String get cancelOperationTitle => '¿Cancelar operación?';

  @override
  String get cancelOperationMessage =>
      'La atención actual se cerrará y no se cobrará nada.';

  @override
  String get confirmCancel => 'Sí, cancelar';

  @override
  String get continueHere => 'Continuar aquí';

  @override
  String get stillThereTitle => '¿Sigues ahí?';

  @override
  String inactivityMessage(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds segundos',
      one: '1 segundo',
    );
    return 'Sin actividad por un momento. Volveremos a la pantalla inicial en $_temp0.';
  }

  @override
  String get selfCheckoutTerminal => 'Terminal de Autopago';

  @override
  String get errorNetwork =>
      'Fallo de comunicación con la API. Verifica la URL configurada, la red y si el servicio está en línea.';

  @override
  String get errorTimeout =>
      'El servidor tardó en responder. Inténtalo de nuevo.';

  @override
  String get errorServer => 'Error al comunicarse con el servidor.';

  @override
  String get errorUnauthorized =>
      'Acceso no autorizado. Verifica el usuario y la contraseña.';

  @override
  String get errorUnknown => 'Ocurrió un error inesperado.';

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
  String get paymentMethodVoucher => 'Vale';

  @override
  String get paymentMethodCash => 'Efectivo';

  @override
  String get paymentMethodPixDescription => 'Aprobación al instante';

  @override
  String get paymentMethodCreditDescription => 'Hasta 12 cuotas';

  @override
  String get paymentMethodDebitDescription => 'Pago único';

  @override
  String get paymentMethodTefDescription => 'Terminal integrado';

  @override
  String get paymentMethodPosDescription => 'Terminal de tarjeta';

  @override
  String get paymentMethodVoucherDescription => 'Vale de comida';

  @override
  String get paymentMethodCashDescription => 'En caja';

  @override
  String get paymentStatusWaiting => 'Esperando';

  @override
  String get paymentStatusProcessing => 'Procesando';

  @override
  String get paymentStatusApproved => 'Aprobado';

  @override
  String get paymentStatusDeclined => 'Rechazado';

  @override
  String get paymentStatusCancelled => 'Cancelado';

  @override
  String get paymentStatusExpired => 'Expirado';

  @override
  String get paymentStatusError => 'Error';

  @override
  String get tapToPay => 'Toca para pagar';

  @override
  String get chooseLanguageTitle => 'Elige tu idioma';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String changeLanguageSemantics(String languageName) {
    return 'Cambiar idioma. Idioma actual: $languageName.';
  }
}
