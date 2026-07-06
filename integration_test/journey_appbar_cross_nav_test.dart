// E2E journey: hop directly between screens using the AppBar nav buttons
// (PNR / Schedule / Seats / Fare) instead of going back to Home each time —
// exercising the pushed-route nav stack the way a power user clicks around.
//
// Run with:
//   flutter test integration_test/journey_appbar_cross_nav_test.dart -d <simulator_udid>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ir_app/main.dart' as app;

import 'support/ir_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: cross-navigate all screens via AppBar nav buttons', (
    tester,
  ) async {
    itStep('launch app');
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Indian Railways Passenger Enquiry'), findsOneWidget);

    // Jump into PNR from Home via the AppBar.
    await tapNavButton(tester, 'PNR');
    expect(find.text('PNR Status Enquiry'), findsOneWidget);

    // From PNR straight to Schedule (pushes on top).
    await tapNavButton(tester, 'Schedule');
    expect(find.byKey(const Key('schedule_info_bar')), findsOneWidget);
    expect(find.textContaining('12951'), findsOneWidget);

    // Schedule -> Seats.
    await tapNavButton(tester, 'Seats');
    expect(find.byKey(const Key('seats_info_bar')), findsOneWidget);
    expect(find.textContaining('15-Jul-2026'), findsOneWidget);

    // Seats -> Fare, then actually use the fare form here.
    await tapNavButton(tester, 'Fare');
    expect(find.byKey(const Key('fare_from')), findsOneWidget);
    await submitFare(tester, from: 'PUNE JN', to: 'JAMMU TAWI', distance: '500');
    expect(find.byKey(const Key('fare_table')), findsOneWidget);
    // SL: 0.9 * 500 = 450 base + 40 = 490 total.
    expect(find.text('₹490'), findsOneWidget);

    // Walk the pushed stack back down to Home.
    await returnHome(tester);
    expect(find.text('Indian Railways Passenger Enquiry'), findsOneWidget);
    itStep('cross-nav journey complete');
  });
}
