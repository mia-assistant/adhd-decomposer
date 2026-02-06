import 'package:flutter_test/flutter_test.dart';

import 'package:adhd_decomposer/main.dart';
import 'package:adhd_decomposer/data/services/settings_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    final settings = SettingsService();
    await settings.initialize();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(ADHDDecomposerApp(settings: settings));

    // Verify that the onboarding welcome page shows
    expect(find.text('Tiny Steps'), findsOneWidget);
  });
}
