import 'package:intl/intl.dart';

/// Utilidades de formato para la app.
class AppFormatters {
  AppFormatters._();

  /// Formateador de moneda USD (estilo México).
  static final currency = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 0,
  );

  /// Formateador de moneda con decimales.
  static final currencyWithDecimals = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Formateador de fecha corta.
  static final dateShort = DateFormat('dd MMM yyyy', 'es');

  /// Formateador de fecha larga.
  static final dateLong = DateFormat("d 'de' MMMM, yyyy", 'es');
}
