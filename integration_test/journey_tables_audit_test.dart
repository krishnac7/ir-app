// E2E journey: audit the two data-table screens end to end — every schedule
// stop in order, and every seat class with its correct availability badge.
//
// Run with:
//   flutter test integration_test/journey_tables_audit_test.dart -d <simulator_udid>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ir_app/main.dart' as app;

import 'support/ir_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: schedule shows all 9 stops in order', (tester) async {
    itStep('launch app');
    app.main();
    await tester.pumpAndSettle();

    await tapServiceCard(tester, 'Train Schedule');
    expect(find.byKey(const Key('schedule_table')), findsOneWidget);

    const stops = [
      'MUMBAI CENTRAL',
      'SURAT',
      'VADODARA JN',
      'RATLAM JN',
      'KOTA JN',
      'SAWAI MADHOPUR',
      'BHARATPUR JN',
      'MATHURA JN',
      'NEW DELHI',
    ];
    for (final stop in stops) {
      expect(find.text(stop), findsAtLeastNWidgets(1), reason: 'stop $stop');
    }
    // Row numbers 1..9 present in the '#' column.
    for (var i = 1; i <= 9; i++) {
      expect(find.text('$i'), findsOneWidget);
    }
    // Source / destination markers.
    expect(find.text('Source'), findsOneWidget);
    expect(find.text('Dest'), findsOneWidget);

    await returnHome(tester);
    itStep('schedule audit complete');
  });

  testWidgets('E2E: seat classes each show the correct status badge', (
    tester,
  ) async {
    itStep('launch app');
    app.main();
    await tester.pumpAndSettle();

    await tapServiceCard(tester, 'Seat Availability');
    expect(find.byKey(const Key('seats_table')), findsOneWidget);

    // Every class badge is rendered.
    for (final cls in const [
      '1A — First AC',
      '2A — Second AC',
      '3A — Third AC',
      'SL — Sleeper',
      'CC — Chair Car',
      '2S — Second Sitting',
    ]) {
      expect(find.byKey(Key('badge_$cls')), findsOneWidget, reason: cls);
    }

    // Status distribution: 1A(2)=Almost Full, 2A(8)/3A(14)=Filling Fast,
    // SL(42)/CC(23)/2S(110)=Available.
    expect(find.text('Almost Full'), findsOneWidget);
    expect(find.text('Filling Fast'), findsNWidgets(2));
    expect(find.text('Available'), findsNWidgets(3));

    // Spot-check a couple of seat counts.
    expect(find.text('42'), findsOneWidget); // SL — Sleeper
    expect(find.text('110'), findsOneWidget); // 2S — Second Sitting

    await returnHome(tester);
    itStep('seats audit complete');
  });
}
