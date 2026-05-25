import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../logic/theme_provider.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  void _showColorPicker(
    BuildContext context,
    String title,
    Color currentColor,
    Function(Color) onColorPicked,
  ) {
    Color tempColor = currentColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Pick $title'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => tempColor = color,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                'SAVE',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () {
                onColorPicked(tempColor);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ---> THE FIX: We use a Consumer builder which is completely immune to chat-window copy errors!
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'Audio & Haptics',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.volume_up,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Key Click Sound'),
                  trailing: Switch(
                    value: themeProvider.soundEnabled,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (value) => themeProvider.toggleSound(value),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Appearance',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.dark_mode,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Preset Theme'),
                      trailing: DropdownButton<String>(
                        value: themeProvider.themeName,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        underline: const SizedBox(),
                        items: ['Dark', 'Light', 'Custom'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null)
                            themeProvider.setTheme(newValue);
                        },
                      ),
                    ),

                    if (themeProvider.themeName == 'Custom') ...[
                      const Divider(),
                      ListTile(
                        title: const Text('Primary Color (Accent)'),
                        trailing: CircleAvatar(
                          backgroundColor: themeProvider.customPrimary,
                          radius: 15,
                        ),
                        onTap: () {
                          _showColorPicker(
                            context,
                            'Primary Color',
                            themeProvider.customPrimary,
                            (color) {
                              themeProvider.setCustomColors(
                                color,
                                themeProvider.customSurface,
                              );
                            },
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('Surface Color (Buttons)'),
                        trailing: CircleAvatar(
                          backgroundColor: themeProvider.customSurface,
                          radius: 15,
                        ),
                        onTap: () {
                          _showColorPicker(
                            context,
                            'Surface Color',
                            themeProvider.customSurface,
                            (color) {
                              themeProvider.setCustomColors(
                                themeProvider.customPrimary,
                                color,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
