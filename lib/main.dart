import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/repositories/wish_repository.dart';
import 'providers/theme_provider.dart';
import 'providers/wish_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final wishBox = await Hive.openBox<String>(HiveWishRepository.boxName);
  final settingsBox = await Hive.openBox<dynamic>('app_settings');
  await initializeDateFormatting('id_ID');

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    ProviderScope(
      overrides: [
        wishRepositoryProvider.overrideWithValue(HiveWishRepository(wishBox)),
        settingsBoxProvider.overrideWithValue(settingsBox),
      ],
      child: const WishTierApp(),
    ),
  );
}
