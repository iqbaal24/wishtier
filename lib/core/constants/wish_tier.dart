enum WishTier { s, a, b, c }

extension WishTierX on WishTier {
  String get letter => switch (this) {
    WishTier.s => 'S',
    WishTier.a => 'A',
    WishTier.b => 'B',
    WishTier.c => 'C',
  };

  String get label => switch (this) {
    WishTier.s => 'Sangat penting',
    WishTier.a => 'Penting',
    WishTier.b => 'Cukup penting',
    WishTier.c => 'Bisa ditunda',
  };

  String get tagline => switch (this) {
    WishTier.s => 'Prioritas utama',
    WishTier.a => 'Masuk rencana dekat',
    WishTier.b => 'Kalau memungkinkan',
    WishTier.c => 'Nice to have',
  };

  String get description => switch (this) {
    WishTier.s => 'Butuh segera, jangan ditunda',
    WishTier.a => 'Penting, masuk rencana dekat',
    WishTier.b => 'Cukup penting, bisa menyusul',
    WishTier.c => 'Boleh nanti, bukan prioritas',
  };

  static WishTier fromName(String? value) {
    return WishTier.values.firstWhere(
      (tier) => tier.name == value,
      orElse: () => WishTier.b,
    );
  }
}
