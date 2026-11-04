import 'package:flutter_test/flutter_test.dart';
import 'package:wishtier/core/utils/formatters.dart';

void main() {
  group('formatRupiah', () {
    test('formats rupiah with dot thousands separators', () {
      final result = formatRupiah(8499000);
      expect(result, contains('8.499.000'));
      expect(result.toLowerCase(), contains('rp'));
    });

    test('formats zero', () {
      expect(formatRupiah(0), contains('0'));
    });
  });

  group('parsePrice', () {
    test('strips currency and separators', () {
      expect(parsePrice('Rp 1.250.000'), 1250000);
    });

    test('returns null when there are no digits', () {
      expect(parsePrice(''), isNull);
      expect(parsePrice('tidak ada'), isNull);
    });
  });

  test('ThousandsInputFormatter groups digits as they are typed', () {
    final formatter = ThousandsInputFormatter();
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '1250000'),
    );

    expect(result.text, '1.250.000');
    expect(result.selection.baseOffset, result.text.length);
  });

  test('ThousandsInputFormatter removes leading zeroes', () {
    final formatter = ThousandsInputFormatter();
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '0001234'),
    );

    expect(result.text, '1.234');
  });
}
