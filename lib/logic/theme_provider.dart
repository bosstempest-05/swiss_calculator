import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- ADDED IMPORT

class ThemeProvider extends ChangeNotifier {
  String _themeName = 'Dark';
  bool _soundEnabled = true;

  Color _customPrimary = Colors.blueAccent;
  Color _customSurface = const Color(0xFF1E1E1E);

  String get themeName => _themeName;
  bool get soundEnabled => _soundEnabled;
  Color get customPrimary => _customPrimary;
  Color get customSurface => _customSurface;

  // ---> NEW: Loads saved preferences from the device <---
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _themeName = prefs.getString('themeName') ?? 'Dark';
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;

    // Colors are saved as Integers (memory efficient!)
    int? savedPrimary = prefs.getInt('customPrimary');
    if (savedPrimary != null) _customPrimary = Color(savedPrimary);

    int? savedSurface = prefs.getInt('customSurface');
    if (savedSurface != null) _customSurface = Color(savedSurface);

    notifyListeners();
  }

  // ---> UPDATED: Saves the theme when changed <---
  void setTheme(String theme) async {
    _themeName = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeName', theme);
  }

  // ---> UPDATED: Saves custom colors when changed <---
  void setCustomColors(Color primary, Color surface) async {
    _customPrimary = primary;
    _customSurface = surface;
    _themeName = 'Custom';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeName', 'Custom');
    await prefs.setInt('customPrimary', primary.value);
    await prefs.setInt('customSurface', surface.value);
  }

  // ---> UPDATED: Saves sound preference when toggled <---
  void toggleSound(bool enabled) async {
    _soundEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', enabled);
  }

  void playClickSound() {
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  ThemeData get themeData {
    if (_themeName == 'Custom') {
      return ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: _customPrimary,
          secondary: _customPrimary.withOpacity(0.8),
          surface: _customSurface,
        ),
        useMaterial3: true,
      );
    } else if (_themeName == 'Light') {
      return ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.orange,
          surface: Colors.white,
        ),
        useMaterial3: true,
      );
    }

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Colors.cyanAccent,
        secondary: Colors.pinkAccent,
        surface: Color(0xFF1E1E1E),
      ),
      useMaterial3: true,
    );
  }
}
