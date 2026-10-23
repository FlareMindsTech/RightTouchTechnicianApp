import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:right_touch/features/map/models/map_theme.dart';

const String _kMapThemePrefKey = 'selected_map_theme_type';

class MapThemeNotifier extends Notifier<AppMapTheme> {
  @override
  AppMapTheme build() {
    _loadSavedTheme();
    return AppMapTheme.getTheme(MapThemeType.streets);
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt(_kMapThemePrefKey);
      if (savedIndex != null &&
          savedIndex >= 0 &&
          savedIndex < MapThemeType.values.length) {
        state = AppMapTheme.getTheme(MapThemeType.values[savedIndex]);
      }
    } catch (_) {}
  }

  Future<void> setTheme(MapThemeType type) async {
    state = AppMapTheme.getTheme(type);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kMapThemePrefKey, type.index);
    } catch (_) {}
  }
}

final mapThemeProvider =
    NotifierProvider<MapThemeNotifier, AppMapTheme>(MapThemeNotifier.new);
