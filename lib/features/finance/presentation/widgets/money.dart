import 'package:intl/intl.dart';

final NumberFormat _moneyFormat = NumberFormat.currency(
  symbol: '',
  decimalDigits: 2,
);

/// Formats a monetary amount with thousands separators and two decimals.
String formatMoney(double value) => _moneyFormat.format(value);
