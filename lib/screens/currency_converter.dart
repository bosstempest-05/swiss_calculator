import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  bool _isLoading = true;

  // We start with some offline fallback rates just in case they have no internet
  Map<String, dynamic> _rates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'INR': 83.50,
    'JPY': 155.0,
    'AUD': 1.50,
    'CAD': 1.36,
  };

  late List<String> _currencies;
  String _fromCurrency = 'USD';
  String _toCurrency = 'INR';

  final TextEditingController _inputController = TextEditingController(
    text: '1',
  );
  String _result = '';

  @override
  void initState() {
    super.initState();
    _currencies = _rates.keys.toList();
    _fetchLiveRates();
  }

  // Grabs live, up-to-the-minute exchange rates from a free API
  Future<void> _fetchLiveRates() async {
    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/USD'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _rates = data['rates'];
          _currencies = _rates.keys.toList();
          // Ensure our selected currencies still exist in the new data
          if (!_currencies.contains(_fromCurrency))
            _fromCurrency = _currencies[0];
          if (!_currencies.contains(_toCurrency)) _toCurrency = _currencies[1];
          _isLoading = false;
        });
        _calculate();
      }
    } catch (e) {
      // If the internet is off, just use the fallback rates and hide the loading spinner
      setState(() {
        _isLoading = false;
      });
      _calculate();
    }
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

    // All rates in the API are relative to USD, so we convert through USD
    double fromRate = (_rates[_fromCurrency] as num).toDouble();
    double toRate = (_rates[_toCurrency] as num).toDouble();

    // Math: (Input / FromRate) * ToRate
    double finalValue = (inputValue / fromRate) * toRate;

    setState(() {
      _result = finalValue.toStringAsFixed(2);
    });
  }

  void _swapCurrencies() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
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
          'Live Currency',
          style: TextStyle(color: adaptiveTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Makes the back arrow visible in light mode
        iconTheme: IconThemeData(color: adaptiveTextColor),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildConversionBox(
              label: 'You Pay',
              currency: _fromCurrency,
              isInput: true,
              onCurrencyChanged: (val) {
                setState(() => _fromCurrency = val!);
                _calculate();
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: IconButton(
                icon: const Icon(Icons.swap_vert_circle, size: 48),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _swapCurrencies,
              ),
            ),

            _buildConversionBox(
              label: 'You Get',
              currency: _toCurrency,
              isInput: false,
              onCurrencyChanged: (val) {
                setState(() => _toCurrency = val!);
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
    required String currency,
    required bool isInput,
    required ValueChanged<String?> onCurrencyChanged,
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
                    value: currency,
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
                    menuMaxHeight: 400,
                    items: _currencies.map<DropdownMenuItem<String>>((
                      String c,
                    ) {
                      return DropdownMenuItem<String>(value: c, child: Text(c));
                    }).toList(),
                    onChanged: onCurrencyChanged,
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
