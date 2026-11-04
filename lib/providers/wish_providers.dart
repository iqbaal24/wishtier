import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/wish_tier.dart';
import '../core/utils/image_storage.dart';
import '../data/models/wish_item.dart';
import '../data/repositories/wish_repository.dart';
import '../data/sample_data.dart';

final wishRepositoryProvider = Provider<WishRepository>((ref) {
  throw UnimplementedError('wishRepositoryProvider must be overridden');
});

final wishListProvider = NotifierProvider<WishListNotifier, List<WishItem>>(
  WishListNotifier.new,
);

class WishListNotifier extends Notifier<List<WishItem>> {
  late WishRepository _repository;

  @override
  List<WishItem> build() {
    _repository = ref.watch(wishRepositoryProvider);
    return _repository.loadAll();
  }

  int _nextOrder(WishTier tier, {String? excludingId}) {
    var highest = -1;
    for (final item in state) {
      if (item.tier != tier || item.isPurchased || item.id == excludingId) {
        continue;
      }
      if (item.sortOrder > highest) highest = item.sortOrder;
    }
    return highest + 1;
  }

  Future<void> add(WishItem item) async {
    final prepared = item.copyWith(
      sortOrder: _nextOrder(item.tier),
      isPurchased: false,
      clearPurchasedAt: true,
    );
    state = [...state, prepared];
    await _repository.upsert(prepared);
  }

  Future<void> update(WishItem item) async {
    final index = state.indexWhere((existing) => existing.id == item.id);
    if (index == -1) return;

    final existing = state[index];
    final movedTier = existing.tier != item.tier;
    final prepared = movedTier
        ? item.copyWith(sortOrder: _nextOrder(item.tier, excludingId: item.id))
        : item;

    state = [
      for (final current in state)
        if (current.id == prepared.id) prepared else current,
    ];
    await _repository.upsert(prepared);
  }

  Future<void> delete(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final removed = state[index];
    state = [
      for (final item in state)
        if (item.id != id) item,
    ];
    await _repository.delete(id);
    await ImageStorage.deleteIfExists(removed.photoPath);
  }

  Future<void> moveToTier(String id, WishTier tier) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = state[index];
    if (item.tier == tier || item.isPurchased) return;

    final updated = item.copyWith(
      tier: tier,
      sortOrder: _nextOrder(tier, excludingId: id),
    );
    state = [
      for (final current in state)
        if (current.id == id) updated else current,
    ];
    await _repository.upsert(updated);
  }

  Future<void> markPurchased(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final updated = state[index].copyWith(
      isPurchased: true,
      purchasedAt: DateTime.now(),
    );
    state = [
      for (final current in state)
        if (current.id == id) updated else current,
    ];
    await _repository.upsert(updated);
  }

  Future<void> restore(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = state[index];
    final updated = item.copyWith(
      isPurchased: false,
      clearPurchasedAt: true,
      sortOrder: _nextOrder(item.tier, excludingId: id),
    );
    state = [
      for (final current in state)
        if (current.id == id) updated else current,
    ];
    await _repository.upsert(updated);
  }

  Future<void> seedSamples() async {
    if (state.isNotEmpty) return;
    final samples = buildSampleItems();
    state = samples;
    await _repository.upsertAll(samples);
  }
}

final activeItemsProvider = Provider<List<WishItem>>((ref) {
  final items = ref
      .watch(wishListProvider)
      .where((item) => !item.isPurchased)
      .toList();
  items.sort((a, b) {
    final byTier = a.tier.index.compareTo(b.tier.index);
    if (byTier != 0) return byTier;
    final byOrder = a.sortOrder.compareTo(b.sortOrder);
    if (byOrder != 0) return byOrder;
    return a.createdAt.compareTo(b.createdAt);
  });
  return items;
});

final purchasedItemsProvider = Provider<List<WishItem>>((ref) {
  final items = ref
      .watch(wishListProvider)
      .where((item) => item.isPurchased)
      .toList();
  items.sort((a, b) {
    final aDate = a.purchasedAt ?? a.createdAt;
    final bDate = b.purchasedAt ?? b.createdAt;
    return bDate.compareTo(aDate);
  });
  return items;
});

@immutable
class TierBreakdown {
  const TierBreakdown({required this.count, required this.total});

  final int count;
  final int total;

  static const empty = TierBreakdown(count: 0, total: 0);

  @override
  bool operator ==(Object other) {
    return other is TierBreakdown &&
        other.count == count &&
        other.total == total;
  }

  @override
  int get hashCode => Object.hash(count, total);
}

@immutable
class WishSummary {
  const WishSummary({
    required this.tiers,
    required this.activeCount,
    required this.activeTotal,
    required this.purchasedCount,
    required this.purchasedTotal,
  });

  final Map<WishTier, TierBreakdown> tiers;
  final int activeCount;
  final int activeTotal;
  final int purchasedCount;
  final int purchasedTotal;

  TierBreakdown tier(WishTier tier) => tiers[tier] ?? TierBreakdown.empty;

  int get allTotal => activeTotal + purchasedTotal;

  static const empty = WishSummary(
    tiers: {},
    activeCount: 0,
    activeTotal: 0,
    purchasedCount: 0,
    purchasedTotal: 0,
  );
}

WishSummary summarizeWishList(List<WishItem> items) {
  final tiers = <WishTier, TierBreakdown>{};
  var activeCount = 0;
  var activeTotal = 0;
  var purchasedCount = 0;
  var purchasedTotal = 0;

  for (final tier in WishTier.values) {
    var count = 0;
    var total = 0;
    for (final item in items) {
      if (item.tier != tier) continue;
      if (item.isPurchased) continue;
      count += 1;
      total += item.price;
    }
    tiers[tier] = TierBreakdown(count: count, total: total);
    activeCount += count;
    activeTotal += total;
  }

  for (final item in items.where((item) => item.isPurchased)) {
    purchasedCount += 1;
    purchasedTotal += item.price;
  }

  return WishSummary(
    tiers: tiers,
    activeCount: activeCount,
    activeTotal: activeTotal,
    purchasedCount: purchasedCount,
    purchasedTotal: purchasedTotal,
  );
}

final wishSummaryProvider = Provider<WishSummary>((ref) {
  return summarizeWishList(ref.watch(wishListProvider));
});

final topActiveItemsProvider = Provider<List<WishItem>>((ref) {
  final items = [...ref.watch(activeItemsProvider)]
    ..removeWhere((item) => item.price <= 0)
    ..sort((a, b) => b.price.compareTo(a.price));
  return items.take(3).toList();
});
