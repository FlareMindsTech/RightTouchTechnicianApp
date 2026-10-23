import 'package:flutter_test/flutter_test.dart';
import 'package:right_touch/utils/money.dart';

void main() {
  group('Money Value Type Tests', () {
    test('Constructors and conversion to/from rupees and paise', () {
      const m1 = Money.fromPaise(15050);
      expect(m1.paise, equals(15050));
      expect(m1.inRupees, equals(150.50));

      final m2 = Money.fromRupees(150.50);
      expect(m2.paise, equals(15050));
      expect(m2.inRupees, equals(150.50));

      expect(Money.zero.paise, equals(0));
      expect(Money.zero.isZero, isTrue);
    });

    test('Arithmetic operations (+, -, *, /)', () {
      final a = Money.fromRupees(100.50);
      final b = Money.fromRupees(49.50);

      expect((a + b).inRupees, equals(150.00));
      expect((a - b).inRupees, equals(51.00));
      expect((a * 2).inRupees, equals(201.00));
      expect((a / 2).inRupees, equals(50.25));
    });

    test('Comparisons (<, <=, >, >=, ==)', () {
      final a = Money.fromRupees(100);
      final b = Money.fromRupees(200);
      final c = Money.fromRupees(100);

      expect(a < b, isTrue);
      expect(b > a, isTrue);
      expect(a == c, isTrue);
      expect(a <= c, isTrue);
      expect(a >= c, isTrue);
    });

    test('Dynamic parsing from String, int, double, null', () {
      expect(Money.fromDynamic(null), equals(Money.zero));
      expect(Money.fromDynamic(''), equals(Money.zero));
      expect(Money.fromDynamic(500), equals(Money.fromRupees(500)));
      expect(Money.fromDynamic(123.45), equals(Money.fromRupees(123.45)));
      expect(Money.fromDynamic('₹1,250.75'), equals(Money.fromRupees(1250.75)));
      expect(Money.fromDynamic('500.00'), equals(Money.fromRupees(500)));
    });

    test('Formatting with Indian Rupee symbol and 2 decimal places', () {
      final m = Money.fromRupees(1234.50);
      expect(m.formatted, contains('₹'));
      expect(m.formatted, contains('1,234.50'));

      const zero = Money.zero;
      expect(zero.formatted, contains('₹'));
      expect(zero.formatted, contains('0.00'));
    });
  });
}
