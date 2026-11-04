import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/wish_tier.dart';
import '../../../core/theme/wish_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/wish_providers.dart';

class SummaryHero extends ConsumerWidget {
  const SummaryHero({super.key, required this.onOpenSummary});

  final VoidCallback onOpenSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(wishSummaryProvider);
    final colors = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final heroTierColors = WishColors.dark;
    final segments = <Widget>[];
    for (final tier in WishTier.values) {
      final breakdown = summary.tier(tier);
      final flex = summary.activeTotal > 0 ? breakdown.total : breakdown.count;
      if (flex <= 0) continue;
      if (segments.isNotEmpty) segments.add(const SizedBox(width: 2));
      segments.add(
        Expanded(
          flex: flex,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: heroTierColors.tier(tier),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.heroStart, colors.heroEnd],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.45
                    : 0.18,
              ),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -50,
              child: _Glow(color: heroTierColors.tierS, size: 190),
            ),
            Positioned(
              bottom: -90,
              left: -60,
              child: _Glow(color: heroTierColors.tierB, size: 210),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'TOTAL WISHLIST',
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: colors.heroMuted,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: summary.activeCount > 0
                                    ? colors.success
                                    : colors.heroMuted,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${summary.activeCount} aktif',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.1,
                                fontWeight: FontWeight.w700,
                                color: colors.heroInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: summary.activeTotal.toDouble(),
                      ),
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatRupiah(value.round()),
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 35,
                              height: 1.05,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.0,
                              color: colors.heroInk,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    summary.activeCount == 0
                        ? 'Belum ada keinginan aktif. Yuk mulai isi wishlist.'
                        : 'Perkiraan biaya ${summary.activeCount} keinginan aktif'
                              '${summary.purchasedCount > 0 ? ' · ${summary.purchasedCount} sudah terbeli' : ''}.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: colors.heroMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: segments.isEmpty
                            ? [
                                Expanded(
                                  child: Container(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                              ]
                            : segments,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    children: [
                      for (final tier in WishTier.values)
                        _TierLegend(
                          tier: tier,
                          count: summary.tier(tier).count,
                          color: heroTierColors.tier(tier),
                          textColor: colors.heroInk,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.09),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onOpenSummary,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Lihat ringkasan biaya',
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: colors.heroInk,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 17,
                              color: colors.heroInk,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.32), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _TierLegend extends StatelessWidget {
  const _TierLegend({
    required this.tier,
    required this.count,
    required this.color,
    required this.textColor,
  });

  final WishTier tier;
  final int count;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tier ${tier.letter}: $count keinginan',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '${tier.letter}  ',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
