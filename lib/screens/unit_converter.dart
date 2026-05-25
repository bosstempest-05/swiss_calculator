import 'package:flutter/material.dart';

class UnitConverter extends StatefulWidget {
  final String category; // 'Length' or 'Weight'

  const UnitConverter({super.key, required this.category});

  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  // This map acts as our universal math brain.
  // Everything is converted relative to a base unit (Meters for Length, Grams for Weight).
  final Map<String, Map<String, double>> _conversionRates = {
    'Length': {
      'Meters': 1.0,
      'Kilometers': 1000.0,
      'Centimeters': 0.01,
      'Millimeters': 0.001,
      'Miles': 1609.344,
      'Yards': 0.9144,
      'Feet': 0.3048,
      'Inches': 0.0254,
    },
    'Weight': {
      'Grams': 1.0,
      'Kilograms': 1000.0,
      'Milligrams': 0.001,
      'Pounds (lbs)': 453.59237,
      'Ounces (oz)': 28.34952,
    },
  };

  late List<String> _units;
  late String _fromUnit;
  late String _toUnit;

  final TextEditingController _inputController = TextEditingController(
    text: '1',
  );
  String _result = '';

  @override
  void initState() {
    super.initState();
    // Load the correct units based on what button they pressed in the menu
    _units = _conversionRates[widget.category]!.keys.toList();
    _fromUnit = _units[0]; // First item in list
    _toUnit = _units[1]; // Second item in list
    _calculate();
  }

  void _calculate() {
    if (_inputController.text.isEmpty) {
      setState(() => _result = '0');
      return;
    }

    double? inputValue = double.tryParse(_inputController.text);
    if (inputValue == null) {
      setState(() => _result = 'Error');
      return;
    }

    // The Magic Formula: (Input * From_Rate) / To_Rate
    double fromRate = _conversionRates[widget.category]![_fromUnit]!;
    double toRate = _conversionRates[widget.category]![_toUnit]!;

    double finalValue = (inputValue * fromRate) / toRate;

    setState(() {
      // Clean up the formatting so it doesn't show 5.00000000
      _result = _formatResult(finalValue);
    });
  }

  String _formatResult(double value) {
    // If it's a very tiny or very large number, show a few more decimals, otherwise keep it clean
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else if (value < 0.01) {
      return value.toStringAsFixed(6);
    } else {
      return value.toStringAsFixed(3);
    }
  }

  void _swapUnits() {
    setState(() {
      String temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _calculate();
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
          '${widget.category} Converter',
          style: TextStyle(color: adaptiveTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Makes the back arrow visible in light mode
        iconTheme: IconThemeData(color: adaptiveTextColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // FROM BOX
            _buildConversionBox(
              label: 'From',
              unit: _fromUnit,
              isInput: true,
              onUnitChanged: (val) {
                setState(() => _fromUnit = val!);
                _calculate();
              },
            ),

            // SWAP BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: IconButton(
                icon: const Icon(Icons.swap_vert_circle, size: 48),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _swapUnits,
              ),
            ),

            // TO BOX
            _buildConversionBox(
              label: 'To',
              unit: _toUnit,
              isInput: false,
              onUnitChanged: (val) {
                setState(() => _toUnit = val!);
                _calculate();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionBox({
    required String label,
    required String unit,
    required bool isInput,
    required ValueChanged<String?> onUnitChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              // TEXT FIELD OR TEXT DISPLAY
              Expanded(
                child: isInput
                    ? TextField(
                        controller: _inputController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        // ---> FIXED: Removed the const keyword here <---
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        onChanged: (val) => _calculate(),
                      )
                    : FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _result,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // DROPDOWN MENU
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: unit,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    // ---> FIXED: Removed the const keyword here <---
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    items: _units.map((String u) {
                      return DropdownMenuItem(value: u, child: Text(u));
                    }).toList(),
                    onChanged: onUnitChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
