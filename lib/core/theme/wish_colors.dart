import 'package:flutter/material.dart';

import '../constants/wish_tier.dart';

@immutable
class WishColors {
  const WishColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceElevated,
    required this.border,
    required this.ink,
    required this.inkSecondary,
    required this.inkTertiary,
    required this.accent,
    required this.onAccent,
    required this.tierS,
    required this.tierA,
    required this.tierB,
    required this.tierC,
    required this.tierSSoft,
    required this.tierASoft,
    required this.tierBSoft,
    required this.tierCSoft,
    required this.success,
    required this.danger,
    required this.heroStart,
    required this.heroEnd,
    required this.heroInk,
    required this.heroMuted,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceElevated;
  final Color border;
  final Color ink;
  final Color inkSecondary;
  final Color inkTertiary;
  final Color accent;
  final Color onAccent;

  final Color tierS;
  final Color tierA;
  final Color tierB;
  final Color tierC;
  final Color tierSSoft;
  final Color tierASoft;
  final Color tierBSoft;
  final Color tierCSoft;

  final Color success;
  final Color danger;

  final Color heroStart;
  final Color heroEnd;
  final Color heroInk;
  final Color heroMuted;
  final Color shadow;

  Color tier(WishTier tier) => switch (tier) {
    WishTier.s => tierS,
    WishTier.a => tierA,
    WishTier.b => tierB,
    WishTier.c => tierC,
  };

  Color tierSoft(WishTier tier) => switch (tier) {
    WishTier.s => tierSSoft,
    WishTier.a => tierASoft,
    WishTier.b => tierBSoft,
    WishTier.c => tierCSoft,
  };

  static const WishColors light = WishColors(
    background: Color(0xFFF5F3EE),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEDEAE3),
    surfaceElevated: Color(0xFFFFFFFF),
    border: Color(0xFFE4E0D6),
    ink: Color(0xFF191C22),
    inkSecondary: Color(0xFF4E5563),
    inkTertiary: Color(0xFF626A78),
    accent: Color(0xFF191C22),
    onAccent: Color(0xFFFFFDF8),
    tierS: Color(0xFFC22B3B),
    tierA: Color(0xFF9A5800),
    tierB: Color(0xFF0B7A63),
    tierC: Color(0xFF4F6479),
    tierSSoft: Color(0xFFFCE8EA),
    tierASoft: Color(0xFFFCF0DA),
    tierBSoft: Color(0xFFE2F3EE),
    tierCSoft: Color(0xFFEAEFF4),
    success: Color(0xFF0D8A70),
    danger: Color(0xFFC5343F),
    heroStart: Color(0xFF262C38),
    heroEnd: Color(0xFF12161E),
    heroInk: Color(0xFFFFFBF3),
    heroMuted: Color(0xFFADB5C2),
    shadow: Color(0xFF1A1D24),
  );

  static const WishColors dark = WishColors(
    background: Color(0xFF0D0F13),
    surface: Color(0xFF161920),
    surfaceMuted: Color(0xFF1E222B),
    surfaceElevated: Color(0xFF1C2029),
    border: Color(0xFF2C313C),
    ink: Color(0xFFF7F4EC),
    inkSecondary: Color(0xFFAAB2BE),
    inkTertiary: Color(0xFF8993A2),
    accent: Color(0xFFF7F4EC),
    onAccent: Color(0xFF14171D),
    tierS: Color(0xFFFB7185),
    tierA: Color(0xFFF6B840),
    tierB: Color(0xFF3ACCA9),
    tierC: Color(0xFF9BAFC3),
    tierSSoft: Color(0xFF33191F),
    tierASoft: Color(0xFF332612),
    tierBSoft: Color(0xFF0F2F29),
    tierCSoft: Color(0xFF202A35),
    success: Color(0xFF3ACCA9),
    danger: Color(0xFFFB7185),
    heroStart: Color(0xFF232936),
    heroEnd: Color(0xFF141821),
    heroInk: Color(0xFFFFFBF3),
    heroMuted: Color(0xFFA9B1BE),
    shadow: Color(0xFF000000),
  );
}

extension WishColorsContext on BuildContext {
  WishColors get colors => Theme.of(this).brightness == Brightness.dark
      ? WishColors.dark
      : WishColors.light;
}
