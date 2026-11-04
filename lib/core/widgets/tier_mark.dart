import 'package:flutter/material.dart';

import '../theme/wish_colors.dart';

class TierMark extends StatelessWidget {
  const TierMark({super.key, this.size = 38});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final padding = size * 0.22;
    final inner = size - (padding * 2);
    final gap = size * 0.055;
    final barWidth = (inner - (gap * 3)) / 4;
    final barColors = [colors.tierS, colors.tierA, colors.tierB, colors.tierC];
    final factors = [1.0, 0.78, 0.56, 0.36];

    return Semantics(
      label: 'WishTier',
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? colors.heroInk
              : colors.heroStart,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < 4; i++) ...[
              Container(
                width: barWidth,
                height: inner * factors[i],
                decoration: BoxDecoration(
                  color: barColors[i],
                  borderRadius: BorderRadius.circular(barWidth),
                ),
              ),
              if (i != 3) SizedBox(width: gap),
            ],
          ],
        ),
      ),
    );
  }
}
