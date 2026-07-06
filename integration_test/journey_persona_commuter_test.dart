// E2E persona journey: a daily commuter does a quick two-tap check —
// confirm today's PNR, then glance at seat availability — and heads out.
//
// Run with:
//   flutter test integration_test/journey_persona_commuter_test.dart -d <simulator_udid>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ir_app/main.dart' as app;

import 'support/ir_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E persona: commuter checks PNR then seat availability', (
    tester,
  ) async {
    itStep('launch app');
    app.main();
    await tester.pumpAndSettle();

    // Confirm today's reserved ticket.
    await tapServiceCard(tester, 'PNR Status');
    await submitPnr(tester, '9876543210');
    expect(find.byKey(const Key('pnr_result')), findsOneWidget);
    expect(find.textContaining('12002 - Bhopal Shatabdi'), findsOneWidget);
    expect(find.textContaining('BHOPAL JN'), findsOneWidget);
    expect(find.textContaining('CNF / Coach C3 / Seat 14'), findsOneWidget);
    await returnHome(tester);

    // Quick glance at seat availability before leaving.
    await tapServiceCard(tester, 'Seat Availability');
    expect(find.byKey(const Key('seats_table')), findsOneWidget);
    expect(find.text('Available'), findsAtLeastNWidgets(1));
    await returnHome(tester);

    expect(find.text('Indian Railways Passenger Enquiry'), findsOneWidget);
    itStep('commuter journey complete');
  });
}
