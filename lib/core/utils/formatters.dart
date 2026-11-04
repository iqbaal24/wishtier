import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final NumberFormat _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

final NumberFormat _decimal = NumberFormat.decimalPattern('id_ID');

String formatRupiah(num amount) => _rupiah.format(amount);

String formatNumber(num value) => _decimal.format(value);

String formatDate(DateTime date) {
  return DateFormat('d MMM yyyy', 'id_ID').format(date);
}

String formatMonthYear(DateTime date) {
  return DateFormat('MMMM yyyy', 'id_ID').format(date);
}

String itemCountLabel(int count) => '$count keinginan';

int? parsePrice(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return int.tryParse(digits);
}

class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }
    final trimmed = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final formatted = _decimal.format(int.parse(trimmed));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
