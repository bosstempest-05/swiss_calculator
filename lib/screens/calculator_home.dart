import 'package:flutter/material.dart';
// ---> NEW: Added SharedPreferences to load the custom PIN <---
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/modern_button.dart';
import '../logic/math_evaluator.dart';
import 'secret_vault.dart';
import 'converter_menu.dart';
import 'settings_menu.dart';

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _display = '0';
  String _equation = '';

  // ---> CHANGED: No longer final! It can be updated dynamically <---
  String _secretPin = '7777';

  bool _showScientific = false;
  final List<String> _history = [];

  final List<String> buttons = [
    'C',
    '⌫',
    '%',
    '÷',
    '7',
    '8',
    '9',
    '×',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '+/-',
    '0',
    '.',
    '=',
  ];

  final List<String> scientificButtons = [
    'sin',
    'cos',
    'tan',
    'log',
    'ln',
    '√',
    '^',
    'π',
    '(',
    ')',
    'e',
    '!',
  ];

  // ---> NEW: Load the custom PIN when the app boots <---
  @override
  void initState() {
    super.initState();
    _loadSecretPin();
  }

  Future<void> _loadSecretPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // If a custom PIN was saved, use it. Otherwise, default to 7777.
      _secretPin = prefs.getString('vault_pin') ?? '7777';
    });
  }

  void _onButtonTap(String value) async {
    if (value == '=' && _display == _secretPin) {
      setState(() {
        _display = '0';
        _equation = '';
      });
      // ---> CHANGED: Await the vault so we can reload the PIN when we come back <---
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SecretVault()),
      );
      // Reload the PIN just in case the user changed it while inside the vault!
      _loadSecretPin();
      return;
    }

    setState(() {
      if (value == 'C') {
        _display = '0';
        _equation = '';
      } else if (value == '⌫') {
        if (_display == 'Error') {
          _display = '0';
        } else {
          _display = _display.length > 1
              ? _display.substring(0, _display.length - 1)
              : '0';
        }
      } else if (value == '+/-') {
        if (_display != '0' && _display != 'Error') {
          _display = _display.startsWith('-')
              ? _display.substring(1)
              : '-$_display';
        }
      } else if (value == '=') {
        String currentEquation = _display;
        String result = MathEvaluator.evaluate(_display);

        if (result != 'Error') {
          _history.insert(0, '$currentEquation = $result');
          _equation = currentEquation;
        }
        _display = result;
      } else {
        String input = value;
        if (['sin', 'cos', 'tan', 'log', 'ln', '√'].contains(value)) {
          input = '$value(';
        }

        if (_display == '0' || _display == 'Error') {
          _display = input;
        } else {
          _display += input;
        }
      }
    });
  }

  Color _getButtonColor(String value) {
    if (['÷', '×', '-', '+', '='].contains(value)) {
      return Theme.of(context).colorScheme.secondary;
    }
    if (['C', '⌫', '%', '+/-'].contains(value)) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.2);
    }
    return Theme.of(context).colorScheme.surface;
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _history.clear());
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _history.isEmpty
                    ? const Center(
                        child: Text(
                          'No history yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _history[index],
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLightMode = Theme.of(context).brightness == Brightness.light;
    Color adaptiveTextColor = isLightMode ? Colors.black87 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: adaptiveTextColor),
        leading: IconButton(
          icon: Icon(
            Icons.grid_view_rounded,
            size: 28,
            color: adaptiveTextColor,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConverterMenu()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showScientific ? Icons.science : Icons.science_outlined,
              size: 28,
            ),
            color: _showScientific
                ? Theme.of(context).colorScheme.primary
                : adaptiveTextColor,
            onPressed: () => setState(() => _showScientific = !_showScientific),
          ),
          IconButton(
            icon: Icon(Icons.history, size: 28, color: adaptiveTextColor),
            onPressed: _showHistory,
          ),
          IconButton(
            icon: Icon(Icons.settings, size: 28, color: adaptiveTextColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsMenu()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Display Area
            Expanded(
              flex: _showScientific ? 2 : 3,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _equation,
                        style: TextStyle(
                          fontSize: 32,
                          color: isLightMode ? Colors.black54 : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        child: Text(
                          _display,
                          key: ValueKey<String>(_display),
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w300,
                            color: adaptiveTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Keypad Area
            Expanded(
              flex: _showScientific ? 6 : 5,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Column(
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _showScientific
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: scientificButtons.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 1.8,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemBuilder: (context, index) {
                                  return ModernButton(
                                    text: scientificButtons[index],
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    textColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    onTap: () =>
                                        _onButtonTap(scientificButtons[index]),
                                  );
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Standard Grid
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: buttons.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: _showScientific ? 1.5 : 1.15,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) {
                          return ModernButton(
                            text: buttons[index],
                            backgroundColor: _getButtonColor(buttons[index]),
                            textColor:
                                [
                                  '÷',
                                  '×',
                                  '-',
                                  '+',
                                  '=',
                                ].contains(buttons[index])
                                ? Colors.black
                                : adaptiveTextColor,
                            onTap: () => _onButtonTap(buttons[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
