import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/wish_colors.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/tier_mark.dart';
import '../../providers/theme_provider.dart';
import '../../providers/wish_providers.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../item/item_form_sheet.dart';
import '../summary/summary_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  void _goTo(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final hasActiveItems = ref.watch(activeItemsProvider).isNotEmpty;

    final overlayStyle =
        (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: colors.surface,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
            );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _ShellHeader(index: _index),
              Expanded(
                child: IndexedStack(
                  index: _index,
                  children: [
                    HomeScreen(onOpenSummary: () => _goTo(1)),
                    SummaryScreen(onOpenHistory: () => _goTo(2)),
                    HistoryScreen(onOpenWishlist: () => _goTo(0)),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _index == 0 && hasActiveItems
            ? FloatingActionButton(
                onPressed: () => openWishItemForm(context),
                tooltip: 'Tambah keinginan',
                child: const Icon(Icons.add_rounded, size: 24),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _goTo,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.bookmark_border_rounded),
                selectedIcon: Icon(Icons.bookmark_rounded),
                label: 'Wishlist',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_rounded),
                selectedIcon: Icon(Icons.bar_chart_rounded),
                label: 'Ringkasan',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_rounded),
                selectedIcon: Icon(Icons.history_rounded),
                label: 'Riwayat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellHeader extends ConsumerWidget {
  const _ShellHeader({required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final (title, subtitle) = switch (index) {
      0 => ('WishTier', 'WISHLIST BERTINGKAT'),
      1 => ('Ringkasan', 'BIAYA PER TIER'),
      _ => ('Riwayat', 'YANG SUDAH DIBELI'),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 10),
      child: Row(
        children: [
          const TierMark(size: 38),
          const SizedBox(width: 11),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                key: ValueKey(index),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: colors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: colors.inkTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AppIconButton(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: isDark ? 'Gunakan tema terang' : 'Gunakan tema gelap',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggle(brightness);
            },
            background: colors.surface,
          ),
        ],
      ),
    );
  }
}
