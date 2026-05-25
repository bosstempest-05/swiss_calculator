import 'package:flutter/material.dart';
import 'dart:math';

class BmiCalculator extends StatefulWidget {
  const BmiCalculator({super.key});

  @override
  State<BmiCalculator> createState() => _BmiCalculatorState();
}

class _BmiCalculatorState extends State<BmiCalculator> {
  double _height = 170.0;
  double _weight = 70.0;
  double _bmi = 0;
  String _category = '';
  Color _categoryColor = Colors.white;

  void _calculateBMI() {
    setState(() {
      _bmi = _weight / pow(_height / 100, 2);

      if (_bmi < 18.5) {
        _category = 'Underweight';
        _categoryColor = Colors.blueAccent;
      } else if (_bmi < 25) {
        _category = 'Normal Weight';
        _categoryColor = Colors.greenAccent;
      } else if (_bmi < 30) {
        _category = 'Overweight';
        _categoryColor = Colors.orangeAccent;
      } else {
        _category = 'Obese';
        _categoryColor = Colors.redAccent;
      }
    });
  }

  // The pop-up dialog for exact manual entry
  Future<void> _showManualEntryDialog(
    String title,
    double currentValue,
    double min,
    double max,
    Function(double) onSaved,
  ) async {
    TextEditingController controller = TextEditingController(
      text: currentValue.toStringAsFixed(1),
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // Adaptive title color
          title: Text('Enter exactly $title', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            // ---> FIXED: Removed 'const' so the dynamic color works <---
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
            ),
            decoration: InputDecoration(
              hintText: 'Between $min and $max',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                double? parsed = double.tryParse(controller.text);
                if (parsed != null) {
                  if (parsed < min) parsed = min;
                  if (parsed > max) parsed = max;
                  onSaved(parsed);
                }
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'SAVE',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Grab the adaptive color once for clean access
    final adaptiveTextColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        // ---> FIXED: Removed const, added adaptive color <---
        title: Text('BMI Calculator', style: TextStyle(color: adaptiveTextColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Makes the back arrow visible in light mode!
        iconTheme: IconThemeData(color: adaptiveTextColor), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Height Slider Card
            _buildSliderCard('Height (cm)', _height, 100.0, 250.0, (val) {
              setState(() => _height = val);
            }, adaptiveTextColor),
            const SizedBox(height: 16),

            // Weight Slider Card
            _buildSliderCard('Weight (kg)', _weight, 30.0, 200.0, (val) {
              setState(() => _weight = val);
            }, adaptiveTextColor),
            const SizedBox(height: 24),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _calculateBMI,
                child: Text(
                  'CALCULATE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Result Display
            if (_bmi > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your BMI is',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bmi.toStringAsFixed(1),
                      // ---> FIXED: Removed const so text adapts <---
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: adaptiveTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _category,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: _categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Updated helper widget passing the adaptive text color down
  Widget _buildSliderCard(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),

          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              _showManualEntryDialog(label, value, min, max, onChanged);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.toStringAsFixed(1), 
                    // ---> FIXED: Removed const so text adapts <---
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Colors.grey.shade400, // Adjusted slightly so it's visible on white
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}