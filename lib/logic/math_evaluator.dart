import 'package:function_tree/function_tree.dart';

class MathEvaluator {
  static String evaluate(String expression) {
    try {
      // Step 1: Clean up the visual text into code-friendly math
      String mathString = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', 'pi')
          .replaceAll('√', 'sqrt')
          .replaceAll('%', '/100'); // Makes 50% act like 50/100

      // Step 2: The magic package solves the entire equation instantly!
      num result = mathString.interpret();

      // Step 3: Format the output so it looks clean
      if (result == result.toInt()) {
        // If it's a clean whole number (like 5.0), just show "5"
        return result.toInt().toString();
      } else {
        // Keep up to 8 decimal places to avoid messy numbers like 0.3000000000004
        String formattedStr = result.toStringAsFixed(8);

        // Remove any trailing zeros at the end of the decimals
        return formattedStr
            .replaceAll(RegExp(r'0*$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }
    } catch (e) {
      // If the user typed an incomplete equation like "5 + *" it catches the crash
      return 'Error';
    }
  }
}
