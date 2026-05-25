import 'package:flutter/material.dart';

// Your exact correct imports!
import 'bmi_calculator.dart';
import 'age_calculator.dart';
import 'unit_converter.dart';
import 'temperature_converter.dart';
import 'currency_converter.dart';
import 'quadratic_calculator.dart';
import 'pomodoro_timer.dart';

class ConverterMenu extends StatelessWidget {
  const ConverterMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // We map your actual files and classes to the tools list
    final List<Map<String, dynamic>> tools = [
      {'name': 'Age', 'icon': Icons.cake, 'route': const AgeCalculator()},
      {
        'name': 'BMI',
        'icon': Icons.monitor_weight,
        'route': const BmiCalculator(),
      },
      {
        'name': 'Currency',
        'icon': Icons.attach_money,
        'route': const CurrencyConverter(),
      },
      // Using your UnitConverter class for both Length and Weight
      {
        'name': 'Length',
        'icon': Icons.straighten,
        'route': const UnitConverter(category: 'Length'),
      },
      {
        'name': 'Weight',
        'icon': Icons.scale,
        'route': const UnitConverter(category: 'Weight'),
      },
      {
        'name': 'Temperature',
        'icon': Icons.thermostat,
        'route': const TemperatureConverter(),
      },
      {
        'name': 'Quadratic',
        'icon': Icons.functions,
        'route': const QuadraticCalculator(),
      },
      {'name': 'Pomodoro', 'icon': Icons.timer, 'route': const PomodoroTimer()},
    ];

    // Detect theme brightness for Light/Dark mode text
    bool isLightMode = Theme.of(context).brightness == Brightness.light;
    Color adaptiveTextColor = isLightMode ? Colors.black87 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Converters & Tools',
          style: TextStyle(color: adaptiveTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: adaptiveTextColor),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tools.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3, // Matches your previous layout
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          // ---> THE ANIMATION: A staggered "Pop In" effect! <---
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            // Each box waits 50 milliseconds longer than the last one before popping in
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // The new simple routing logic!
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => tools[index]['route'],
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isLightMode ? 0.05 : 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tools[index]['icon'],
                      size: 42,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tools[index]['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        // ---> TEXT COLOR FIX <---
                        color: adaptiveTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
