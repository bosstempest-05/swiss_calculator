import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/calculator_home.dart';
import 'logic/theme_provider.dart';

void main() async {
  // ---> CHANGED: main() is now async so it can await local storage
  WidgetsFlutterBinding.ensureInitialized();

  // ---> NEW: Pre-load the theme settings before the app starts drawing
  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();

  runApp(
    // ---> CHANGED: Since we already created the provider, we use .value
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const SwissCalculatorApp(),
    ),
  );
}

class SwissCalculatorApp extends StatelessWidget {
  const SwissCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Swiss Calculator',
          debugShowCheckedModeBanner: false,
          // Since the theme is pre-loaded, it is 100% safe to access directly!
          theme: themeProvider.themeData,
          home: const CalculatorHome(),
        );
      },
    );
  }
}
