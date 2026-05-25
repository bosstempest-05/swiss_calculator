import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'vault_notes.dart';
import 'vault_camera.dart';
import 'vault_gallery.dart';

class SecretVault extends StatefulWidget {
  const SecretVault({super.key});

  @override
  State<SecretVault> createState() => _SecretVaultState();
}

class _SecretVaultState extends State<SecretVault>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _changePin() async {
    final TextEditingController pinController = TextEditingController();
    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isLightMode ? Colors.white : const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Change Secret PIN',
            style: TextStyle(
              color: isLightMode ? Colors.black87 : Colors.white,
            ),
          ),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: isLightMode ? Colors.black87 : Colors.white,
              fontSize: 24,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
            maxLength: 8,
            decoration: InputDecoration(
              hintText: 'Enter new PIN',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                letterSpacing: 0,
              ),
              // ---> FIXED: Wrapped BorderSide inside UnderlineInputBorder <---
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              counterStyle: const TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                if (pinController.text.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('vault_pin', pinController.text.trim());

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'PIN successfully changed!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }
                }
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
    bool isLightMode = Theme.of(context).brightness == Brightness.light;
    Color adaptiveBgColor = isLightMode
        ? Colors.grey[100]!
        : const Color(0xFF0A0A0A);
    Color adaptiveCardColor = isLightMode
        ? Colors.white
        : const Color(0xFF1A1A1A);
    Color adaptiveTextColor = isLightMode ? Colors.black87 : Colors.white;
    Color adaptiveBorderColor = isLightMode
        ? Colors.black.withOpacity(0.05)
        : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: adaptiveBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () {
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.security,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Private Space',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: adaptiveTextColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Everything here is encrypted and stored locally. It will not appear anywhere else on this device.',
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 48),

              _buildVaultCard(
                context,
                title: 'Secure Notes',
                icon: Icons.edit_note,
                color: Colors.orangeAccent,
                cardBg: adaptiveCardColor,
                textBg: adaptiveTextColor,
                borderBg: adaptiveBorderColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VaultNotes()),
                  );
                },
              ),
              const SizedBox(height: 20),

              _buildVaultCard(
                context,
                title: 'Hidden Camera',
                icon: Icons.camera_alt_outlined,
                color: Theme.of(context).colorScheme.primary,
                cardBg: adaptiveCardColor,
                textBg: adaptiveTextColor,
                borderBg: adaptiveBorderColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VaultCamera(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              _buildVaultCard(
                context,
                title: 'Private Gallery',
                icon: Icons.photo_library_outlined,
                color: Colors.pinkAccent,
                cardBg: adaptiveCardColor,
                textBg: adaptiveTextColor,
                borderBg: adaptiveBorderColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VaultGallery(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              _buildVaultCard(
                context,
                title: 'Change PIN',
                icon: Icons.password_rounded,
                color: Colors.amberAccent,
                cardBg: adaptiveCardColor,
                textBg: adaptiveTextColor,
                borderBg: adaptiveBorderColor,
                onTap: _changePin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color textBg,
    required Color borderBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderBg),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textBg,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
