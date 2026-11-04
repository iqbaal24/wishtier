import 'package:uuid/uuid.dart';

import '../core/constants/wish_tier.dart';
import 'models/wish_item.dart';

List<WishItem> buildSampleItems() {
  final now = DateTime.now();
  const uuid = Uuid();

  WishItem item({
    required String name,
    required int price,
    required WishTier tier,
    required int order,
    required int createdDaysAgo,
    String? note,
    String? link,
  }) {
    return WishItem(
      id: uuid.v4(),
      name: name,
      price: price,
      tier: tier,
      note: note,
      link: link,
      createdAt: now.subtract(Duration(days: createdDaysAgo)),
      sortOrder: order,
    );
  }

  return [
    item(
      name: 'Laptop untuk kuliah & kerja',
      price: 8499000,
      tier: WishTier.s,
      order: 0,
      createdDaysAgo: 21,
      note: 'Cari RAM 16GB, baterai tahan lama, layar 14 inci.',
    ),
    item(
      name: 'Kacamata minus baru',
      price: 750000,
      tier: WishTier.s,
      order: 1,
      createdDaysAgo: 12,
      note: 'Resep sudah keluar, tinggal pilih frame.',
    ),
    item(
      name: 'Headphone noise cancelling',
      price: 1799000,
      tier: WishTier.a,
      order: 0,
      createdDaysAgo: 18,
      note: 'Buat fokus belajar di kafe dan saat commuting.',
    ),
    item(
      name: 'Kursi kerja ergonomis',
      price: 1450000,
      tier: WishTier.a,
      order: 1,
      createdDaysAgo: 9,
    ),
    item(
      name: 'Mechanical keyboard 65%',
      price: 650000,
      tier: WishTier.b,
      order: 0,
      createdDaysAgo: 15,
      note: 'Switch tactile, layout compact.',
    ),
    item(
      name: 'Kamera mirrorless bekas',
      price: 4200000,
      tier: WishTier.b,
      order: 1,
      createdDaysAgo: 30,
      note: 'Untuk mulai belajar fotografi.',
    ),
    item(
      name: 'Langganan Spotify 6 bulan',
      price: 329000,
      tier: WishTier.c,
      order: 0,
      createdDaysAgo: 7,
    ),
    item(
      name: 'Tanaman monstera',
      price: 120000,
      tier: WishTier.c,
      order: 1,
      createdDaysAgo: 4,
      note: 'Biar kamar terasa lebih hidup.',
    ),
    WishItem(
      id: uuid.v4(),
      name: 'Tote bag kanvas',
      price: 149000,
      tier: WishTier.b,
      note: 'Sudah dibeli di bazar kampus.',
      createdAt: now.subtract(const Duration(days: 26)),
      isPurchased: true,
      purchasedAt: now.subtract(const Duration(days: 6)),
      sortOrder: 2,
    ),
    WishItem(
      id: uuid.v4(),
      name: 'Keyboard wireless slim',
      price: 249000,
      tier: WishTier.a,
      createdAt: now.subtract(const Duration(days: 58)),
      isPurchased: true,
      purchasedAt: now.subtract(const Duration(days: 38)),
      sortOrder: 3,
    ),
    WishItem(
      id: uuid.v4(),
      name: 'Buku Atomic Habits',
      price: 98000,
      tier: WishTier.c,
      createdAt: now.subtract(const Duration(days: 92)),
      isPurchased: true,
      purchasedAt: now.subtract(const Duration(days: 72)),
      sortOrder: 4,
    ),
  ];
}
