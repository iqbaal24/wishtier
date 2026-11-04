import 'package:flutter/material.dart';

import '../../../core/constants/wish_tier.dart';
import '../../../core/theme/wish_colors.dart';
import '../../../providers/wish_providers.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.query,
    required this.selectedTier,
    required this.summary,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onTierChanged,
  });

  final TextEditingController controller;
  final String query;
  final WishTier? selectedTier;
  final WishSummary summary;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<WishTier?> onTierChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onQueryChanged,
          textInputAction: TextInputAction.search,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600, color: colors.ink),
          decoration: InputDecoration(
            hintText: 'Cari keinginan atau catatan...',
            prefixIcon: const Icon(Icons.search_rounded, size: 21),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Hapus pencarian',
                    onPressed: onClearQuery,
                    icon: const Icon(Icons.close_rounded, size: 19),
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _FilterPill(
                label: 'Semua',
                count: summary.activeCount,
                selected: selectedTier == null,
                onTap: () => onTierChanged(null),
              ),
              for (final tier in WishTier.values) ...[
                const SizedBox(width: 8),
                _FilterPill(
                  label: tier.letter,
                  count: summary.tier(tier).count,
                  selected: selectedTier == tier,
                  color: colors.tier(tier),
                  semanticLabel: 'Filter tier ${tier.letter}, ${tier.label}',
                  onTap: () => onTierChanged(tier),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.color,
    this.semanticLabel,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = selected ? colors.onAccent : colors.inkSecondary;
    final countColor = selected
        ? colors.onAccent.withValues(alpha: 0.62)
        : colors.inkTertiary;

    return Semantics(
      button: true,
      selected: selected,
      label: '${semanticLabel ?? 'Semua tier'}, $count keinginan',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(99),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? colors.accent : colors.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: selected ? colors.accent : colors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (color != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: countColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
