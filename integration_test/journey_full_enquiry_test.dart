// E2E journey: a passenger plans a trip, visiting every service from the Home
// grid and returning Home between each — clicking around the whole app.
//
// Run with:
//   flutter test integration_test/journey_full_enquiry_test.dart -d <simulator_udid>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ir_app/main.dart' as app;

import 'support/ir_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: passenger visits PNR, Schedule, Seats and Fare from Home', (
    tester,
  ) async {
    itStep('launch app');
    app.main();
    await tester.pumpAndSettle();

    // Home shows all four service cards.
    await waitFor(
      tester,
      find.text('Indian Railways Passenger Enquiry'),
      description: 'Home hero',
    );
    expect(find.byKey(const Key('card_PNR Status')), findsOneWidget);

    // 1) PNR: check a confirmed ticket.
    await tapServiceCard(tester, 'PNR Status');
    expect(find.text('PNR Status Enquiry'), findsOneWidget);
    await submitPnr(tester, '1234567890');
    expect(find.byKey(const Key('pnr_result')), findsOneWidget);
    expect(find.textContaining('12951 - Mumbai Rajdhani'), findsOneWidget);
    await returnHome(tester);

    // 2) Schedule: the Mumbai Rajdhani stop table.
    await tapServiceCard(tester, 'Train Schedule');
    expect(find.byKey(const Key('schedule_table')), findsOneWidget);
    expect(find.text('SURAT'), findsOneWidget);
    expect(find.text('NEW DELHI'), findsAtLeastNWidgets(1));
    await returnHome(tester);

    // 3) Seats: availability grid with status badges.
    await tapServiceCard(tester, 'Seat Availability');
    expect(find.byKey(const Key('seats_table')), findsOneWidget);
    expect(find.byKey(const Key('badge_SL — Sleeper')), findsOneWidget);
    expect(find.text('Available'), findsAtLeastNWidgets(1));
    await returnHome(tester);

    // 4) Fare: calculate the full Mumbai -> Delhi fare.
    await tapServiceCard(tester, 'Fare Enquiry');
    await submitFare(
      tester,
      from: 'MUMBAI CENTRAL',
      to: 'NEW DELHI',
      distance: '1384',
    );
    expect(find.byKey(const Key('fare_table')), findsOneWidget);
    // 1A: 4.5 * 1384 = 6228 base + 40 reservation = 6268 total.
    expect(find.text('₹6268'), findsOneWidget);
    await returnHome(tester);

    // Back at Home, ready for the next enquiry.
    expect(find.text('Indian Railways Passenger Enquiry'), findsOneWidget);
    itStep('journey complete — returned Home');
  });
}
