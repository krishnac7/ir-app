// E2E adversarial journey: hammer the PNR screen with bad input, then confirm
// it recovers and re-queries cleanly — the way a fumbling user clicks around.
//
// Run with:
//   flutter test integration_test/journey_adversarial_pnr_test.dart -d <simulator_udid>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ir_app/main.dart' as app;

import 'support/ir_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E adversarial: PNR bad input then recovery and re-query', (
    tester,
  ) async {
    itStep('launch app');
    app.main();
    await tester.pumpAndSettle();

    await tapServiceCard(tester, 'PNR Status');
    expect(find.text('PNR Status Enquiry'), findsOneWidget);

    // Empty submit -> error card, no result.
    await submitPnr(tester, '');
    expect(find.byKey(const Key('pnr_error')), findsOneWidget);
    expect(find.byKey(const Key('pnr_result')), findsNothing);

    // Unknown PNR -> still an error.
    await submitPnr(tester, '0000000000');
    expect(find.byKey(const Key('pnr_error')), findsOneWidget);
    expect(find.textContaining('No record found'), findsOneWidget);

    // Recover with a valid PNR -> result replaces the error.
    await submitPnr(tester, '9876543210');
    expect(find.byKey(const Key('pnr_result')), findsOneWidget);
    expect(find.byKey(const Key('pnr_error')), findsNothing);
    expect(find.textContaining('12002 - Bhopal Shatabdi'), findsOneWidget);

    // Re-query a different valid PNR -> result switches (waitlisted ticket).
    await submitPnr(tester, '5555555555');
    expect(find.byKey(const Key('pnr_result')), findsOneWidget);
    expect(find.textContaining('WL / 12'), findsOneWidget);
    expect(find.textContaining('Bhopal Shatabdi'), findsNothing);

    // Double-submit the same PNR stays stable (single result card).
    await submitPnr(tester, '5555555555');
    expect(find.byKey(const Key('pnr_result')), findsOneWidget);

    await returnHome(tester);
    expect(find.text('Indian Railways Passenger Enquiry'), findsOneWidget);
    itStep('adversarial PNR journey complete');
  });
}
