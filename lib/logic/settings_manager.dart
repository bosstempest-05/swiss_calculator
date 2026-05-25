import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _themeIndex = 0; // 0 = Default Blue, 1 = Matrix Green, 2 = Minimal Mono

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  int get themeIndex => _themeIndex;

  SettingsManager() {
    _loadSettings();
  }

  Future _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound') ?? true;
    _vibrationEnabled = prefs.getBool('vibration') ?? true;
    _themeIndex = prefs.getInt('theme') ?? 0;
    notifyListeners(); // Tells the app to update immediately
  }

  void toggleSound(bool val) async {
    _soundEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('sound', val);
    notifyListeners();
  }

  void toggleVibration(bool val) async {
    _vibrationEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('vibration', val);
    notifyListeners();
  }

  void setTheme(int index) async {
    _themeIndex = index;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('theme', index);
    notifyListeners();
  }
}

// A global instance so any file can easily access it
final settingsManager = SettingsManager();
