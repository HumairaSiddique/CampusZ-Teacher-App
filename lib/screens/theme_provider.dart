import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide theme state (Light / Dark / System), persisted across app
/// restarts via SharedPreferences.
///
/// Wrap the app root with:
/// ```dart
/// ChangeNotifierProvider(create: (_) => ThemeProvider(), child: const CampusZApp())
/// ```
/// and read it anywhere with `context.watch<ThemeProvider>()` (to rebuild on
/// change) or `context.read<ThemeProvider>()` (to just call a method).
class ThemeProvider extends ChangeNotifier {
  static const _prefsKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      _themeMode = ThemeMode.values.firstWhere(
            (mode) => mode.name == saved,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}