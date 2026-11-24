import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_aura/screens/home_screen.dart';
import 'package:rabbit_aura/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('HomeScreen unlocks panel and generates sensitivity values', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'selected_language': 'en',
      'isFirstLaunch': false,
    });
    final appState = AppState();
    await appState.init();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(appState: appState),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RABBITX'), findsOneWidget);
    expect(find.text('PANEL OFF'), findsOneWidget);

    // Toggle panel ON
    await tester.tap(find.text('PANEL OFF'));
    await tester.pumpAndSettle();
    expect(find.text('PANEL ON'), findsOneWidget);

    // Generate sensitivity
    await tester.tap(find.text('GENERATE SENSI'));
    await tester.pumpAndSettle();

    // All 5 scope values should now be populated (no longer '--')
    expect(find.text('--'), findsNothing);
  });
}
