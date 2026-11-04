import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final settingsBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError('settingsBoxProvider must be overridden');
});

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';
  late Box<dynamic> _box;

  @override
  ThemeMode build() {
    _box = ref.watch(settingsBoxProvider);
    return switch (_box.get(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _box.put(_key, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }

  Future<void> toggle(Brightness currentBrightness) {
    return setMode(
      currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
