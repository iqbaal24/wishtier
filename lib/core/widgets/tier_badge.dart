import 'package:flutter/material.dart';

import '../constants/wish_tier.dart';
import '../theme/wish_colors.dart';

class TierBadge extends StatelessWidget {
  const TierBadge({super.key, required this.tier, this.size = 40});

  final WishTier tier;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = colors.tier(tier);

    return Semantics(
      label: 'Tier ${tier.letter}, ${tier.label}',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.tierSoft(tier),
          borderRadius: BorderRadius.circular(size * 0.3),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(
          tier.letter,
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: size * 0.46,
            height: 1,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
