import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/wish_tier.dart';
import '../../core/theme/wish_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/reveal_on_mount.dart';
import '../../core/widgets/tier_badge.dart';
import '../../core/widgets/tier_mark.dart';
import '../../data/models/wish_item.dart';
import '../../providers/wish_providers.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key, required this.onOpenHistory});

  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(wishSummaryProvider);
    final topItems = ref.watch(topActiveItemsProvider);
    final colors = context.colors;

    if (summary.activeCount == 0 && summary.purchasedCount == 0) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
        children: const [_EmptySummary()],
      );
    }

    WishTier? heaviestTier;
    var heaviestValue = -1;
    for (final tier in WishTier.values) {
      final breakdown = summary.tier(tier);
      final value = breakdown.total > 0 ? breakdown.total : breakdown.count;
      if (value > heaviestValue) {
        heaviestValue = value;
        heaviestTier = tier;
      }
    }

    final average = summary.activeCount == 0
        ? 0
        : summary.activeTotal ~/ summary.activeCount;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
      children: [
        RevealOnMount(
          child: _TotalCard(
            summary: summary,
            heaviestTier: heaviestTier,
            average: average,
          ),
        ),
        const SizedBox(height: 16),
        RevealOnMount(child: _TierBreakdownCard(summary: summary)),
        if (topItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          RevealOnMount(child: _TopItemsCard(items: topItems)),
        ],
        if (summary.purchasedCount > 0) ...[
          const SizedBox(height: 16),
          RevealOnMount(
            child: _SpentCard(
              count: summary.purchasedCount,
              total: summary.purchasedTotal,
              onOpenHistory: onOpenHistory,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: colors.inkTertiary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Harga adalah perkiraan yang kamu isi sendiri dan bisa '
                  'berubah kapan saja.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontSize: 11.5, color: colors.inkTertiary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.summary,
    required this.heaviestTier,
    required this.average,
  });

  final WishSummary summary;
  final WishTier? heaviestTier;
  final int average;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.stacked_line_chart_rounded,
                  size: 18,
                  color: colors.inkSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'TOTAL KEINGINAN AKTIF',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.3,
                  color: colors.inkTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: summary.activeTotal.toDouble()),
              duration: MediaQuery.disableAnimationsOf(context)
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
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 36,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 5),
          Text(
            summary.activeCount == 0
                ? 'Belum ada keinginan aktif.'
                : 'Kalau semua keinginan aktif dibeli sekarang.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.inkSecondary,
            ),
          ),
          if (summary.activeCount > 0) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _InsightTile(
                    label: 'Rata-rata/item',
                    value: formatRupiah(average),
                    icon: Icons.calculate_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InsightTile(
                    label: 'Tier terbesar',
                    value: heaviestTier == null
                        ? '—'
                        : 'Tier ${heaviestTier!.letter}',
                    icon: Icons.workspace_premium_outlined,
                    accent: heaviestTier == null
                        ? null
                        : colors.tier(heaviestTier!),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: accent ?? colors.inkTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10.5,
                    color: colors.inkTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: accent ?? colors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierBreakdownCard extends StatelessWidget {
  const _TierBreakdownCard({required this.summary});

  final WishSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sebaran per tier', style: theme.textTheme.titleMedium),
          const SizedBox(height: 3),
          Text(
            'Lihat ke mana sebagian besar biaya pergi.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.inkSecondary,
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < WishTier.values.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _TierRow(tier: WishTier.values[i], summary: summary),
          ],
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier, required this.summary});

  final WishTier tier;
  final WishSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final breakdown = summary.tier(tier);
    final total = summary.activeTotal;
    final share = total > 0
        ? breakdown.total / total
        : summary.activeCount > 0
        ? breakdown.count / summary.activeCount
        : 0.0;
    final percent = total > 0 ? (share * 100).round() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TierBadge(tier: tier, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    percent == null
                        ? '${breakdown.count} item'
                        : '${breakdown.count} item · $percent% dari total',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: colors.inkTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatRupiah(breakdown.total),
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: breakdown.total > 0 ? colors.ink : colors.inkTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Container(
            height: 7,
            color: colors.surfaceMuted,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: share.clamp(0.0, 1.0)),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.tier(tier),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TopItemsCard extends StatelessWidget {
  const _TopItemsCard({required this.items});

  final List<WishItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paling mahal', style: theme.textTheme.titleMedium),
          const SizedBox(height: 3),
          Text(
            'Tiga keinginan dengan biaya terbesar.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.inkSecondary,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 20, color: colors.border),
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: colors.inkSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    items[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: colors.tier(items[i].tier),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  formatRupiah(items[i].price),
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SpentCard extends StatelessWidget {
  const _SpentCard({
    required this.count,
    required this.total,
    required this.onOpenHistory,
  });

  final int count;
  final int total;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.tierBSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 21,
              color: colors.tierB,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sudah dibelanjakan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.inkSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatRupiah(total),
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 17),
                ),
                Text(
                  '$count item di riwayat',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: colors.inkTertiary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onOpenHistory, child: const Text('Lihat')),
        ],
      ),
    );
  }
}

class _EmptySummary extends StatelessWidget {
  const _EmptySummary();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const TierMark(size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada yang bisa diringkas',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Tambahkan keinginan dari tab Wishlist. Ringkasan biaya per tier '
            'akan muncul otomatis di sini.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.inkSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
