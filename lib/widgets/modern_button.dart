import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import '../logic/theme_provider.dart';

// We change this to a StatefulWidget so it can track when your finger is holding it down
class ModernButton extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const ModernButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton> {
  bool _isPressed = false; // Tracks the physical press state

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // When finger touches down, shrink the button
      onTapDown: (_) => setState(() => _isPressed = true),
      // When finger lifts up, do the math and bounce back
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact(); 
        
        // Triggers the native click sound
        Provider.of<ThemeProvider>(context, listen: false).playClickSound();
        
        widget.onTap();
      },
      // If the user drags their finger away, cancel the press
      onTapCancel: () => setState(() => _isPressed = false),
      
      // ---> THE ANIMATION MAGIC <---
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0, // Shrinks to 90% size when pressed
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutBack, // Gives it a slight physical "spring" effect
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(24),
            // The shadow disappears when pressed, making it look like it sank into the board!
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.0 : 0.3),
                blurRadius: _isPressed ? 0 : 6,
                offset: Offset(0, _isPressed ? 0 : 6),
              )
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: ['sin', 'cos', 'tan', 'log', 'ln', '√'].contains(widget.text) ? 22 : 32,
                fontWeight: FontWeight.w400,
                color: widget.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}