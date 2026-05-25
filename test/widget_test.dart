import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swiss_calculator/main.dart';

void main() {
  testWidgets('Calculator loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SwissCalculatorApp());

    // Verify that our calculator display loads and contains a '0'.
    // (We use findsWidgets because '0' appears on the display and on a button)
    expect(find.text('0'), findsWidgets);
  });
}
