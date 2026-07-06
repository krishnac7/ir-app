// E2E journey: sweep every known PNR record in a single session, re-querying
// the same screen and confirming each result replaces the previous one.
//
// Run with:
//   flutter test integration_test/journey_pnr_all_records_test.dart -d <simulator_udid>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ir_app/main.dart' as app;

import 'support/ir_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: sweep all known PNR records plus an unknown one', (
    tester,
  ) async {
    itStep('launch app');
    app.main();
    await tester.pumpAndSettle();

    await tapServiceCard(tester, 'PNR Status');
    expect(find.text('PNR Status Enquiry'), findsOneWidget);

    // 1) Rajdhani — confirmed, sleeper berth.
    await submitPnr(tester, '1234567890');
    expect(find.byKey(const Key('pnr_result')), findsOneWidget);
    expect(find.textContaining('12951 - Mumbai Rajdhani'), findsOneWidget);
    expect(find.textContaining('CNF / Coach S4 / Berth 32'), findsOneWidget);

    // 2) Shatabdi — confirmed chair-car seat (replaces the Rajdhani result).
    await submitPnr(tester, '9876543210');
    expect(find.textContaining('12002 - Bhopal Shatabdi'), findsOneWidget);
    expect(find.textContaining('Mumbai Rajdhani'), findsNothing);

    // 3) Jhelum — waitlisted.
    await submitPnr(tester, '5555555555');
    expect(find.textContaining('11077 - Jhelum Express'), findsOneWidget);
    expect(find.textContaining('JAMMU TAWI'), findsOneWidget);
    expect(find.textContaining('WL / 12'), findsOneWidget);

    // 4) Unknown — error card, and the previous result is gone.
    await submitPnr(tester, '1111111111');
    expect(find.byKey(const Key('pnr_error')), findsOneWidget);
    expect(find.byKey(const Key('pnr_result')), findsNothing);
    expect(find.textContaining('No record found'), findsOneWidget);

    await returnHome(tester);
    expect(find.text('Indian Railways Passenger Enquiry'), findsOneWidget);
    itStep('PNR sweep complete');
  });
}
