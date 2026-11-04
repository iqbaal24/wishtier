import 'package:flutter/material.dart';

import '../../../core/constants/wish_tier.dart';
import '../../../core/theme/wish_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_icon_button.dart';
import '../../../core/widgets/reveal_on_mount.dart';
import '../../../core/widgets/tier_badge.dart';
import '../../../data/models/wish_item.dart';
import 'wish_card.dart';

class TierSection extends StatelessWidget {
  const TierSection({
    super.key,
    required this.tier,
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onPurchased,
    required this.onMove,
  });

  final WishTier tier;
  final List<WishItem> items;
  final ValueChanged<WishTier> onAdd;
  final ValueChanged<WishItem> onEdit;
  final ValueChanged<WishItem> onPurchased;
  final void Function(String itemId, WishTier tier) onMove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = items.fold<int>(0, (sum, item) => sum + item.price);

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data.isNotEmpty,
      onAcceptWithDetails: (details) => onMove(details.data, tier),
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: isActive ? colors.tierSoft(tier) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive ? colors.tier(tier) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                child: Row(
                  children: [
                    TierBadge(tier: tier, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tier.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontSize: 16.5, color: colors.ink),
                          ),
                          const SizedBox(height: 2),
                          if (isActive)
                            Text(
                              'Lepas di sini untuk memindahkan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colors.tier(tier),
                                  ),
                            )
                          else
                            Text(
                              '${items.length} item · ${formatRupiah(total)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 12,
                                    color: colors.inkSecondary,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppIconButton(
                      icon: Icons.add_rounded,
                      tooltip: 'Tambah ke tier ${tier.letter}',
                      onPressed: () => onAdd(tier),
                      size: 44,
                      iconSize: 21,
                      background: colors.tierSoft(tier),
                      foreground: colors.tier(tier),
                      borderColor: colors.tier(tier).withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (items.isEmpty)
                _EmptyTierHint(tier: tier, isActive: isActive)
              else
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  RevealOnMount(
                    key: ValueKey('reveal-${items[i].id}'),
                    child: WishCard(
                      item: items[i],
                      onTap: () => onEdit(items[i]),
                      onPurchased: () => onPurchased(items[i]),
                    ),
                  ),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _EmptyTierHint extends StatelessWidget {
  const _EmptyTierHint({required this.tier, required this.isActive});

  final WishTier tier;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: isActive
            ? colors.surface.withValues(alpha: 0.6)
            : colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? colors.tier(tier).withValues(alpha: 0.35)
              : colors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.south_rounded : Icons.bookmark_border_rounded,
            size: 18,
            color: isActive ? colors.tier(tier) : colors.inkTertiary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              isActive
                  ? 'Lepas item di tier ${tier.letter}'
                  : 'Belum ada item di tier ini. Tambah atau tarik ke sini.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12.5,
                color: isActive ? colors.tier(tier) : colors.inkTertiary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
