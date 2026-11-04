import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wishtier/app.dart';
import 'package:wishtier/core/utils/formatters.dart';
import 'package:wishtier/data/models/wish_item.dart';
import 'package:wishtier/data/repositories/wish_repository.dart';
import 'package:wishtier/providers/theme_provider.dart';
import 'package:wishtier/providers/wish_providers.dart';

class _InMemoryWishRepository implements WishRepository {
  final Map<String, WishItem> _items = {};

  @override
  List<WishItem> loadAll() => _items.values.toList();

  @override
  Future<void> upsert(WishItem item) async {
    _items[item.id] = item;
  }

  @override
  Future<void> upsertAll(Iterable<WishItem> items) async {
    for (final item in items) {
      _items[item.id] = item;
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.remove(id);
  }
}

void main() {
  late Directory tempDir;
  late Box<dynamic> settingsBox;

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
    tempDir = await Directory.systemTemp.createTemp('wishtier_settings_');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox<dynamic>('settings_test');
  });

  setUp(() async {
    await settingsBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        wishRepositoryProvider.overrideWithValue(_InMemoryWishRepository()),
        settingsBoxProvider.overrideWithValue(settingsBox),
      ],
      child: const WishTierApp(),
    );
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
  }

  testWidgets('shows the empty state and loads sample data', (tester) async {
    await pumpApp(tester);

    expect(find.text('WishTier'), findsOneWidget);
    expect(find.text('Wishlist pertamamu menanti'), findsOneWidget);
    expect(find.text('Tambah keinginan'), findsOneWidget);

    await tester.tap(find.text('Coba dengan data contoh'));
    await tester.pumpAndSettle();

    expect(find.text('Laptop untuk kuliah & kerja'), findsOneWidget);
    expect(find.text('Wishlist pertamamu menanti'), findsNothing);
  });

  testWidgets('adds a new wish through the form', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Tambah keinginan'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah keinginan'), findsWidgets);

    await tester.enterText(find.byType(TextFormField).first, 'Buku catatan');
    await tester.enterText(find.byType(TextFormField).at(1), '45000');
    await tester.tap(find.text('Tambah ke wishlist'));
    await tester.pumpAndSettle();

    expect(find.text('Buku catatan'), findsOneWidget);
    expect(find.text(formatRupiah(45000)), findsWidgets);
  });

  testWidgets('switches between tabs', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Coba dengan data contoh'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ringkasan'));
    await tester.pumpAndSettle();
    expect(find.text('TOTAL KEINGINAN AKTIF'), findsOneWidget);
    expect(find.text('Sebaran per tier'), findsOneWidget);

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Total pengeluaran'), findsOneWidget);
    expect(find.text('Riwayat pembelian'), findsOneWidget);
  });
}
