import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/wish_colors.dart';
import '../../core/utils/app_feedback.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/reveal_on_mount.dart';
import '../../core/widgets/tier_badge.dart';
import '../../data/models/wish_item.dart';
import '../../providers/wish_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key, required this.onOpenWishlist});

  final VoidCallback onOpenWishlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(purchasedItemsProvider);
    final summary = ref.watch(wishSummaryProvider);
    final colors = context.colors;

    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
        children: [
          _EmptyHistory(
            hasActiveItems: summary.activeCount > 0,
            onOpenWishlist: onOpenWishlist,
          ),
        ],
      );
    }

    final groups = <String, List<WishItem>>{};
    for (final item in items) {
      final date = item.purchasedAt ?? item.createdAt;
      final label = formatMonthYear(date);
      groups.putIfAbsent(label, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
      children: [
        RevealOnMount(
          child: _SpentBanner(
            count: summary.purchasedCount,
            total: summary.purchasedTotal,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Text(
              'Riwayat pembelian',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            Text(
              '${items.length} item',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.inkSecondary),
            ),
          ],
        ),
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 18, 4, 9),
            child: Row(
              children: [
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10.5,
                    letterSpacing: 1.1,
                    color: colors.inkTertiary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${entry.value.length} item',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontSize: 10.5, color: colors.inkTertiary),
                ),
              ],
            ),
          ),
          for (var i = 0; i < entry.value.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            RevealOnMount(
              key: ValueKey('history-${entry.value[i].id}'),
              child: _HistoryCard(
                item: entry.value[i],
                onRestore: () => _restore(context, ref, entry.value[i]),
                onDelete: () => _delete(context, ref, entry.value[i]),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    WishItem item,
  ) async {
    await ref.read(wishListProvider.notifier).restore(item.id);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      '“${item.name}” dipulihkan ke wishlist.',
      actionLabel: 'Lihat',
      onAction: onOpenWishlist,
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WishItem item,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus dari riwayat?',
      message: '“${item.name}” akan dihapus permanen dari riwayat pembelian.',
    );
    if (!confirmed || !context.mounted) return;

    await ref.read(wishListProvider.notifier).delete(item.id);
    if (!context.mounted) return;
    showAppSnackBar(context, 'Item dihapus dari riwayat.');
  }
}

class _SpentBanner extends StatelessWidget {
  const _SpentBanner({required this.count, required this.total});

  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.tierBSoft,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 23,
              color: colors.tierB,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total pengeluaran',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.inkSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatRupiah(total),
                      maxLines: 1,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count keinginan sudah dibeli',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    color: colors.inkTertiary,
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.item,
    required this.onRestore,
    required this.onDelete,
  });

  final WishItem item;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final purchasedAt = item.purchasedAt ?? item.createdAt;
    final hasPhoto = item.hasPhoto && File(item.photoPath!).existsSync();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          if (hasPhoto) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(item.photoPath!),
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                cacheWidth: 160,
                errorBuilder: (context, error, stackTrace) {
                  return _fallback(colors);
                },
              ),
            ),
            const SizedBox(width: 11),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 14.5,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    TierBadge(tier: item.tier, size: 19),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Dibeli ${formatDate(purchasedAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: colors.inkTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.price > 0 ? formatRupiah(item.price) : 'Tanpa harga',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: item.price > 0 ? colors.ink : colors.inkTertiary,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Aksi item',
            icon: Icon(
              Icons.more_horiz_rounded,
              size: 21,
              color: colors.inkSecondary,
            ),
            onSelected: (value) {
              if (value == 'restore') {
                onRestore();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Icons.undo_rounded, size: 19),
                    SizedBox(width: 10),
                    Text('Pulihkan ke wishlist'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 19,
                      color: colors.danger,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Hapus dari riwayat',
                      style: TextStyle(color: colors.danger),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallback(WishColors colors) {
    return Container(
      width: 48,
      height: 48,
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: 18, color: colors.inkTertiary),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({
    required this.hasActiveItems,
    required this.onOpenWishlist,
  });

  final bool hasActiveItems;
  final VoidCallback onOpenWishlist;

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
            child: Icon(
              Icons.receipt_long_outlined,
              size: 34,
              color: colors.inkSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            hasActiveItems
                ? 'Saat keinginan sudah dibeli, tandai dengan tombol centang. '
                      'Item akan pindah ke sini.'
                : 'Keinginan yang sudah kamu tandai terbeli akan muncul di sini.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.inkSecondary,
              height: 1.5,
            ),
          ),
          if (hasActiveItems) ...[
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onOpenWishlist,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Lihat wishlist'),
            ),
          ],
        ],
      ),
    );
  }
}
