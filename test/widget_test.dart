import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adhd_decomposer/main.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ADHDDecomposerApp());

    // Verify that the home screen shows the app name
    expect(find.text('Tiny Steps'), findsOneWidget);
  });
}
