import 'package:flutter_test/flutter_test.dart';
import 'package:wishtier/core/constants/wish_tier.dart';
import 'package:wishtier/data/models/wish_item.dart';
import 'package:wishtier/providers/wish_providers.dart';

WishItem _item({
  required String id,
  required WishTier tier,
  required int price,
  bool purchased = false,
}) {
  return WishItem(
    id: id,
    name: id,
    price: price,
    tier: tier,
    createdAt: DateTime(2026, 1, 1),
    isPurchased: purchased,
    purchasedAt: purchased ? DateTime(2026, 2, 1) : null,
  );
}

void main() {
  group('summarizeWishList', () {
    test('splits active and purchased totals per tier', () {
      final summary = summarizeWishList([
        _item(id: 'a', tier: WishTier.s, price: 100000),
        _item(id: 'b', tier: WishTier.s, price: 50000),
        _item(id: 'c', tier: WishTier.b, price: 30000),
        _item(id: 'd', tier: WishTier.a, price: 200000, purchased: true),
      ]);

      expect(summary.activeCount, 3);
      expect(summary.activeTotal, 180000);
      expect(summary.purchasedCount, 1);
      expect(summary.purchasedTotal, 200000);
      expect(summary.allTotal, 380000);

      expect(summary.tier(WishTier.s).count, 2);
      expect(summary.tier(WishTier.s).total, 150000);
      expect(summary.tier(WishTier.a).count, 0);
      expect(summary.tier(WishTier.a).total, 0);
      expect(summary.tier(WishTier.c), TierBreakdown.empty);
    });

    test('returns an empty summary for an empty list', () {
      final summary = summarizeWishList([]);
      expect(summary.activeCount, 0);
      expect(summary.activeTotal, 0);
      expect(summary.purchasedCount, 0);
      expect(summary.purchasedTotal, 0);
      for (final tier in WishTier.values) {
        expect(summary.tier(tier), TierBreakdown.empty);
      }
    });
  });
}
