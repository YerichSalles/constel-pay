import 'package:intl/intl.dart';

abstract final class FormatadorData {
  static String dataHora(DateTime data) =>
      DateFormat('dd/MM/yyyy HH:mm').format(data);

  static String hora(DateTime data) => DateFormat('HH:mm').format(data);
}
