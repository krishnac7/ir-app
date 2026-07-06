// E2E adversarial journey: invalid distances are rejected (no table), then a
// valid calculation renders and a re-calculation updates every row.
//
// Run with:
//   flutter test integration_test/journey_adversarial_fare_test.dart -d <simulator_udid>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ir_app/main.dart' as app;

import 'support/ir_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E adversarial: fare rejects bad distance then recalculates', (
    tester,
  ) async {
    itStep('launch app');
    app.main();
    await tester.pumpAndSettle();

    await tapServiceCard(tester, 'Fare Enquiry');
    expect(find.byKey(const Key('fare_from')), findsOneWidget);

    // Zero distance -> no table rendered.
    await submitFare(tester, from: 'A', to: 'B', distance: '0');
    expect(find.byKey(const Key('fare_table')), findsNothing);

    // Non-numeric distance -> still no table.
    await submitFare(tester, from: 'A', to: 'B', distance: 'abc');
    expect(find.byKey(const Key('fare_table')), findsNothing);

    // Valid distance -> full table with all six classes.
    await submitFare(tester, from: 'MUMBAI CENTRAL', to: 'NEW DELHI', distance: '500');
    expect(find.byKey(const Key('fare_table')), findsOneWidget);
    expect(find.byKey(const Key('fare_route_bar')), findsOneWidget);
    expect(find.textContaining('Distance: 500 km'), findsOneWidget);
    for (final cls in const [
      '1A — First AC',
      '2A — Second AC',
      '3A — Third AC',
      'SL — Sleeper',
      'CC — Chair Car',
      '2S — Second Sitting',
    ]) {
      expect(find.text(cls), findsOneWidget);
    }
    // 1A: 4.5 * 500 = 2250 base + 40 = 2290 total.
    expect(find.text('₹2290'), findsOneWidget);

    // Recalculate with a longer distance -> every fare updates.
    await submitFare(tester, from: 'MUMBAI CENTRAL', to: 'NEW DELHI', distance: '1000');
    // 1A: 4.5 * 1000 = 4500 base + 40 = 4540 total.
    expect(find.text('₹4540'), findsOneWidget);
    expect(find.text('₹2290'), findsNothing);
    expect(find.textContaining('Distance: 1000 km'), findsOneWidget);

    await returnHome(tester);
    expect(find.text('Indian Railways Passenger Enquiry'), findsOneWidget);
    itStep('adversarial fare journey complete');
  });
}
