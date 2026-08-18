import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String currency = 'EGP', bool compact = false}) {
    final formatter = compact
        ? NumberFormat.compact(locale: 'en_US')
        : NumberFormat('#,##0.##', 'en_US');

    final formattedNumber = formatter.format(amount);
    final symbol = getSymbol(currency);

    return '$formattedNumber $symbol';
  }

  static String getSymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'EGP':
        return 'ج.م';
      case 'USD':
        return '\$';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }
}
