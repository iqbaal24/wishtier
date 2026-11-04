import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/wish_tier.dart';
import '../../core/theme/wish_colors.dart';
import '../../core/utils/app_feedback.dart';
import '../../core/widgets/tier_mark.dart';
import '../../data/models/wish_item.dart';
import '../../providers/wish_providers.dart';
import '../item/item_form_sheet.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/summary_hero.dart';
import 'widgets/tier_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.onOpenSummary});

  final VoidCallback onOpenSummary;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  WishTier? _selectedTier;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({WishItem? item, WishTier? tier}) {
    return openWishItemForm(context, item: item, initialTier: tier);
  }

  Future<void> _markPurchased(WishItem item) async {
    await ref.read(wishListProvider.notifier).markPurchased(item.id);
    if (!mounted) return;
    showAppSnackBar(
      context,
      '“${item.name}” dipindah ke riwayat.',
      actionLabel: 'Urungkan',
      onAction: () {
        unawaited(ref.read(wishListProvider.notifier).restore(item.id));
      },
    );
  }

  Future<void> _moveItem(String id, WishTier targetTier) async {
    final item = ref
        .read(wishListProvider)
        .where((entry) => entry.id == id)
        .firstOrNull;
    if (item == null || item.tier == targetTier) return;

    final previousTier = item.tier;
    await ref.read(wishListProvider.notifier).moveToTier(id, targetTier);
    if (!mounted) return;
    showAppSnackBar(
      context,
      'Dipindah ke Tier ${targetTier.letter} · ${targetTier.label}.',
      actionLabel: 'Urungkan',
      onAction: () {
        unawaited(
          ref.read(wishListProvider.notifier).moveToTier(id, previousTier),
        );
      },
    );
  }

  Future<void> _seedSamples() async {
    await ref.read(wishListProvider.notifier).seedSamples();
    if (!mounted) return;
    showAppSnackBar(
      context,
      'Data contoh dimuat. Silakan ubah atau hapus sesuai kebutuhan.',
    );
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedTier = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeItems = ref.watch(activeItemsProvider);
    final summary = ref.watch(wishSummaryProvider);
    final colors = context.colors;

    final query = _query.trim().toLowerCase();
    final filtered = activeItems.where((item) {
      if (_selectedTier != null && item.tier != _selectedTier) return false;
      if (query.isEmpty) return true;
      return item.name.toLowerCase().contains(query) ||
          (item.note?.toLowerCase().contains(query) ?? false);
    }).toList();

    final tiers = _selectedTier == null
        ? WishTier.values
        : <WishTier>[_selectedTier!];

    final visibleTiers = <WishTier>[];
    final sectionItems = <WishTier, List<WishItem>>{};
    for (final tier in tiers) {
      final items = filtered.where((item) => item.tier == tier).toList();
      sectionItems[tier] = items;
      if (query.isNotEmpty && items.isEmpty) continue;
      visibleTiers.add(tier);
    }

    final noResults = query.isNotEmpty && filtered.isEmpty;
    final hasActiveItems = activeItems.isNotEmpty;

    final sectionTitle = query.isNotEmpty
        ? 'Hasil pencarian'
        : _selectedTier != null
        ? 'Tier ${_selectedTier!.letter} · ${_selectedTier!.label}'
        : 'Wishlist per tier';
    final sectionSubtitle = query.isNotEmpty
        ? '${filtered.length} item cocok dengan pencarianmu.'
        : _selectedTier != null
        ? _selectedTier!.description
        : 'Tahan dan geser item untuk memindahkan tier.';

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (hasActiveItems)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            sliver: SliverToBoxAdapter(
              child: SummaryHero(onOpenSummary: widget.onOpenSummary),
            ),
          ),
        if (!hasActiveItems)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _EmptyWishlistCard(
                onAdd: () => _openForm(),
                onSeed: _seedSamples,
              ),
            ),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverToBoxAdapter(
              child: SearchFilterBar(
                controller: _searchController,
                query: _query,
                selectedTier: _selectedTier,
                summary: summary,
                onQueryChanged: (value) => setState(() => _query = value),
                onClearQuery: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                onTierChanged: (tier) => setState(() => _selectedTier = tier),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sectionTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          sectionSubtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (noResults)
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: const Text('Reset'),
                    ),
                ],
              ),
            ),
          ),
          if (noResults)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _NoResultsCard(onReset: _clearAllFilters),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  for (final tier in visibleTiers)
                    TierSection(
                      key: ValueKey('tier-${tier.name}'),
                      tier: tier,
                      items: sectionItems[tier] ?? const [],
                      onAdd: (selected) => _openForm(tier: selected),
                      onEdit: (item) => _openForm(item: item),
                      onPurchased: _markPurchased,
                      onMove: _moveInBackground,
                    ),
                ]),
              ),
            ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  void _moveInBackground(String itemId, WishTier tier) {
    unawaited(_moveItem(itemId, tier));
  }
}

class _EmptyWishlistCard extends StatelessWidget {
  const _EmptyWishlistCard({required this.onAdd, required this.onSeed});

  final VoidCallback onAdd;
  final Future<void> Function() onSeed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const TierMark(size: 52),
          ),
          const SizedBox(height: 18),
          Text(
            'Wishlist pertamamu menanti',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontSize: 21),
          ),
          const SizedBox(height: 7),
          Text(
            'Mulai dari yang paling penting. Setiap keinginan punya tier, '
            'jadi kamu tahu apa yang perlu dibeli lebih dulu.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.inkSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final tier in WishTier.values)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.tierSoft(tier),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: colors.tier(tier).withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tier.letter,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: colors.tier(tier),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tier.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: colors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 19),
              label: const Text('Tambah keinginan'),
            ),
          ),
          TextButton.icon(
            onPressed: () => onSeed(),
            icon: const Icon(Icons.auto_awesome_outlined, size: 17),
            label: const Text('Coba dengan data contoh'),
          ),
        ],
      ),
    );
  }
}

class _NoResultsCard extends StatelessWidget {
  const _NoResultsCard({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 24,
              color: colors.inkSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Text('Tidak ditemukan', style: theme.textTheme.titleLarge),
          const SizedBox(height: 5),
          Text(
            'Coba kata kunci lain atau tampilkan semua tier.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.inkSecondary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reset pencarian'),
          ),
        ],
      ),
    );
  }
}
