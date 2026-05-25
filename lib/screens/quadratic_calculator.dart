import 'package:flutter/material.dart';
import 'dart:math';

class QuadraticCalculator extends StatefulWidget {
  const QuadraticCalculator({super.key});

  @override
  State<QuadraticCalculator> createState() => _QuadraticCalculatorState();
}

class _QuadraticCalculatorState extends State<QuadraticCalculator> {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _cController = TextEditingController();

  String _resultType = '';
  String _root1 = '';
  String _root2 = '';

  void _calculateRoots() {
    // Hide the keyboard when calculate is pressed
    FocusManager.instance.primaryFocus?.unfocus();

    double? a = double.tryParse(_aController.text);
    double? b = double.tryParse(_bController.text);
    double? c = double.tryParse(_cController.text);

    if (a == null || b == null || c == null) {
      setState(() {
        _resultType = 'Invalid Input';
        _root1 = 'Please enter numbers';
        _root2 = '';
      });
      return;
    }

    if (a == 0) {
      setState(() {
        _resultType = 'Not Quadratic';
        _root1 = 'Value "a" cannot be 0';
        _root2 = '';
      });
      return;
    }

    // Calculate the discriminant (b^2 - 4ac)
    double discriminant = (b * b) - (4 * a * c);

    setState(() {
      if (discriminant > 0) {
        _resultType = 'Two Real Roots';
        double r1 = (-b + sqrt(discriminant)) / (2 * a);
        double r2 = (-b - sqrt(discriminant)) / (2 * a);
        _root1 = 'x = ${r1.toStringAsFixed(3)}';
        _root2 = 'x = ${r2.toStringAsFixed(3)}';
      } else if (discriminant == 0) {
        _resultType = 'One Real Root';
        double r1 = -b / (2 * a);
        _root1 = 'x = ${r1.toStringAsFixed(3)}';
        _root2 = '';
      } else {
        _resultType = 'Complex (Imaginary) Roots';
        double realPart = -b / (2 * a);
        double imaginaryPart = sqrt(-discriminant) / (2 * a);

        String realStr = realPart.toStringAsFixed(3);
        String imagStr = imaginaryPart.toStringAsFixed(3);

        _root1 = 'x = $realStr + ${imagStr}i';
        _root2 = 'x = $realStr - ${imagStr}i';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Grab the adaptive color once for clean access
    final adaptiveTextColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        // ---> FIXED: Added adaptive color to title and removed const <---
        title: Text(
          'Quadratic Solver',
          style: TextStyle(color: adaptiveTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Makes the back arrow visible in light mode
        iconTheme: IconThemeData(color: adaptiveTextColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'ax² + bx + c = 0',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Input Fields
            _buildInputField('a', _aController),
            const SizedBox(height: 16),
            _buildInputField('b', _bController),
            const SizedBox(height: 16),
            _buildInputField('c', _cController),
            const SizedBox(height: 32),

            // Calculate Button
            SizedBox(
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _calculateRoots,
                child: Text(
                  'SOLVE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Results Area
            if (_resultType.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _resultType,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _root1,
                      // ---> FIXED: Removed the const keyword here <---
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (_root2.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _root2,
                        // ---> FIXED: Removed the const keyword here <---
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      // ---> FIXED: Removed the const keyword here <---
      style: TextStyle(
        fontSize: 24,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'Value $label',
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
