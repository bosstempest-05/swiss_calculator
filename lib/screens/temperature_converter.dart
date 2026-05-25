import 'package:flutter/material.dart';

class TemperatureConverter extends StatefulWidget {
  const TemperatureConverter({super.key});

  @override
  State<TemperatureConverter> createState() => _TemperatureConverterState();
}

class _TemperatureConverterState extends State<TemperatureConverter> {
  final List<String> _units = ['Celsius (°C)', 'Fahrenheit (°F)', 'Kelvin (K)'];
  late String _fromUnit;
  late String _toUnit;

  final TextEditingController _inputController = TextEditingController(
    text: '0',
  );
  String _result = '';

  @override
  void initState() {
    super.initState();
    _fromUnit = _units[0]; // Celsius
    _toUnit = _units[1]; // Fahrenheit
    _calculate();
  }

  void _calculate() {
    if (_inputController.text.isEmpty) {
      setState(() => _result = '-');
      return;
    }

    double? inputValue = double.tryParse(_inputController.text);
    if (inputValue == null) {
      setState(() => _result = 'Error');
      return;
    }

    // Step 1: Convert everything to Celsius as a baseline
    double tempInCelsius;
    if (_fromUnit == 'Fahrenheit (°F)') {
      tempInCelsius = (inputValue - 32) * 5 / 9;
    } else if (_fromUnit == 'Kelvin (K)') {
      tempInCelsius = inputValue - 273.15;
    } else {
      tempInCelsius = inputValue;
    }

    // Step 2: Convert from Celsius to the target unit
    double finalValue;
    if (_toUnit == 'Fahrenheit (°F)') {
      finalValue = (tempInCelsius * 9 / 5) + 32;
    } else if (_toUnit == 'Kelvin (K)') {
      finalValue = tempInCelsius + 273.15;
    } else {
      finalValue = tempInCelsius;
    }

    setState(() {
      _result = finalValue.toStringAsFixed(2);
      // Clean up trailing zeros (e.g., turn 32.00 into 32)
      if (_result.endsWith('.00')) {
        _result = _result.substring(0, _result.length - 3);
      }
    });
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
        title: Text('Temperature', style: TextStyle(color: adaptiveTextColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Makes the back arrow visible in light mode
        iconTheme: IconThemeData(color: adaptiveTextColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildConversionBox(
              label: 'From',
              unit: _fromUnit,
              isInput: true,
              onUnitChanged: (val) {
                setState(() => _fromUnit = val!);
                _calculate();
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: IconButton(
                icon: const Icon(Icons.swap_vert_circle, size: 48),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _swapUnits,
              ),
            ),

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
              Expanded(
                child: isInput
                    ? TextField(
                        controller: _inputController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ), // 'signed' allows negative numbers
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