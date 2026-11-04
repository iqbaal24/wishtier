import 'package:flutter_test/flutter_test.dart';
import 'package:wishtier/core/constants/wish_tier.dart';
import 'package:wishtier/data/models/wish_item.dart';

void main() {
  group('WishItem', () {
    test('survives a JSON round trip with every field', () {
      final item = WishItem(
        id: 'item-1',
        name: 'Laptop',
        price: 8499000,
        tier: WishTier.s,
        note: 'RAM 16GB',
        link: 'https://example.com/laptop',
        photoPath: '/tmp/photo.jpg',
        isPurchased: true,
        purchasedAt: DateTime(2026, 11, 2, 10, 30),
        createdAt: DateTime(2026, 10, 1, 8, 15),
        sortOrder: 4,
      );

      final decoded = WishItem.fromJson(item.toJson());

      expect(decoded.id, item.id);
      expect(decoded.name, item.name);
      expect(decoded.price, item.price);
      expect(decoded.tier, item.tier);
      expect(decoded.note, item.note);
      expect(decoded.link, item.link);
      expect(decoded.photoPath, item.photoPath);
      expect(decoded.isPurchased, isTrue);
      expect(decoded.purchasedAt, item.purchasedAt);
      expect(decoded.createdAt, item.createdAt);
      expect(decoded.sortOrder, item.sortOrder);
    });

    test('falls back to safe defaults for incomplete data', () {
      final decoded = WishItem.fromMap({
        'id': 'item-2',
        'name': 'Headphone',
        'createdAt': '2026-10-01T08:15:00.000',
      });

      expect(decoded.price, 0);
      expect(decoded.tier, WishTier.b);
      expect(decoded.isPurchased, isFalse);
      expect(decoded.sortOrder, 0);
      expect(decoded.note, isNull);
      expect(decoded.hasNote, isFalse);
    });

    test('copyWith can clear nullable fields', () {
      final item = WishItem(
        id: 'item-3',
        name: 'Kamera',
        price: 4200000,
        tier: WishTier.b,
        note: 'Bekas',
        link: 'https://example.com',
        photoPath: '/tmp/kamera.jpg',
        createdAt: DateTime(2026, 1, 1),
        purchasedAt: DateTime(2026, 2, 1),
        isPurchased: true,
      );

      final cleared = item.copyWith(
        clearNote: true,
        clearLink: true,
        clearPhoto: true,
        clearPurchasedAt: true,
        isPurchased: false,
      );

      expect(cleared.note, isNull);
      expect(cleared.link, isNull);
      expect(cleared.photoPath, isNull);
      expect(cleared.purchasedAt, isNull);
      expect(cleared.isPurchased, isFalse);
      expect(cleared.name, item.name);
      expect(cleared.createdAt, item.createdAt);
    });
  });
}
