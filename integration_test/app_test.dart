// Integration tests for the Indian Railways Flutter app.
// Covers: Home → PNR → Schedule → Seats → Fare screens.
// Run with:
//   flutter test integration_test/app_test.dart -d <simulator_udid>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ir_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─── 1. Home Screen ────────────────────────────────────────────────────────
  group('Home Screen', () {
    testWidgets('shows 4 service cards', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Indian Railways Passenger Enquiry'), findsOneWidget);
      expect(find.byKey(const Key('card_PNR Status')),        findsOneWidget);
      expect(find.byKey(const Key('card_Train Schedule')),    findsOneWidget);
      expect(find.byKey(const Key('card_Seat Availability')), findsOneWidget);
      expect(find.byKey(const Key('card_Fare Enquiry')),      findsOneWidget);
    });
  });

  // ─── 2. PNR Screen ─────────────────────────────────────────────────────────
  group('PNR Screen', () {
    testWidgets('navigates to PNR screen via card', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('card_PNR Status')));
      await tester.pumpAndSettle();

      expect(find.text('PNR Status Enquiry'), findsOneWidget);
      expect(find.byKey(const Key('pnr_input')), findsOneWidget);
    });

    testWidgets('valid PNR 1234567890 shows correct result', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_PNR Status')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('pnr_input')), '1234567890');
      await tester.tap(find.byKey(const Key('pnr_submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pnr_result')), findsOneWidget);
      expect(find.textContaining('12951 - Mumbai Rajdhani'),   findsOneWidget);
      expect(find.textContaining('MUMBAI CENTRAL'),             findsOneWidget);
      expect(find.textContaining('NEW DELHI'),                  findsOneWidget);
      expect(find.textContaining('CNF / Coach S4 / Berth 32'), findsOneWidget);
    });

    testWidgets('valid PNR 9876543210 shows Bhopal Shatabdi', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_PNR Status')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('pnr_input')), '9876543210');
      await tester.tap(find.byKey(const Key('pnr_submit')));
      await tester.pumpAndSettle();

      expect(find.textContaining('12002 - Bhopal Shatabdi'), findsOneWidget);
    });

    testWidgets('valid PNR 5555555555 shows waitlist', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_PNR Status')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('pnr_input')), '5555555555');
      await tester.tap(find.byKey(const Key('pnr_submit')));
      await tester.pumpAndSettle();

      expect(find.textContaining('WL / 12'), findsOneWidget);
    });

    testWidgets('unknown PNR shows error card', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_PNR Status')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('pnr_input')), '0000000000');
      await tester.tap(find.byKey(const Key('pnr_submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pnr_error')), findsOneWidget);
      expect(find.textContaining('No record found'), findsOneWidget);
    });
  });

  // ─── 3. Schedule Screen ────────────────────────────────────────────────────
  group('Schedule Screen', () {
    testWidgets('shows Mumbai Rajdhani 9-stop table', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_Train Schedule')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('schedule_info_bar')), findsOneWidget);
      expect(find.textContaining('12951'),             findsOneWidget);
      expect(find.byKey(const Key('schedule_table')),  findsOneWidget);
      expect(find.text('MUMBAI CENTRAL'),              findsAtLeastNWidgets(1));
      expect(find.text('NEW DELHI'),                   findsAtLeastNWidgets(1));
      expect(find.text('SURAT'),                       findsOneWidget);
      expect(find.text('VADODARA JN'),                 findsOneWidget);
      expect(find.text('KOTA JN'),                     findsOneWidget);
    });

    testWidgets('shows 9 rows in schedule', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_Train Schedule')));
      await tester.pumpAndSettle();

      // Row numbers 1–9 in the # column
      for (int i = 1; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });
  });

  // ─── 4. Seat Availability Screen ───────────────────────────────────────────
  group('Seats Screen', () {
    testWidgets('shows info bar and seat table', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_Seat Availability')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('seats_info_bar')), findsOneWidget);
      expect(find.textContaining('15-Jul-2026'),       findsOneWidget);
      expect(find.byKey(const Key('seats_table')),     findsOneWidget);
    });

    testWidgets('1A shows Almost Full badge', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_Seat Availability')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('badge_1A — First AC')), findsOneWidget);
      expect(find.text('Almost Full'),                      findsAtLeastNWidgets(1));
    });

    testWidgets('SL Sleeper shows Available badge (42 seats)', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_Seat Availability')));
      await tester.pumpAndSettle();

      expect(find.text('42'),        findsOneWidget);
      expect(find.text('Available'), findsAtLeastNWidgets(1));
    });
  });

  // ─── 5. Fare Enquiry Screen ────────────────────────────────────────────────
  group('Fare Screen', () {
    testWidgets('shows fare form fields', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_Fare Enquiry')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fare_from')),   findsOneWidget);
      expect(find.byKey(const Key('fare_to')),     findsOneWidget);
      expect(find.byKey(const Key('fare_dist')),   findsOneWidget);
      expect(find.byKey(const Key('fare_submit')), findsOneWidget);
    });

    testWidgets('calculates correct fare for 1384 km', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_Fare Enquiry')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('fare_from')), 'MUMBAI CENTRAL');
      await tester.enterText(find.byKey(const Key('fare_to')),   'NEW DELHI');
      await tester.enterText(find.byKey(const Key('fare_dist')), '1384');
      await tester.tap(find.byKey(const Key('fare_submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fare_table')),    findsOneWidget);
      expect(find.byKey(const Key('fare_route_bar')), findsOneWidget);
      // 1A: 4.5 * 1384 = 6228 base + 40 rsv = 6268 total
      expect(find.text('₹6228'), findsOneWidget);
      expect(find.text('₹6268'), findsOneWidget);
      // SL: 0.9 * 1384 = 1246 base + 40 = 1286
      expect(find.text('₹1246'), findsOneWidget);
      expect(find.text('₹1286'), findsOneWidget);
    });

    testWidgets('shows 6 fare rows for all classes', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('card_Fare Enquiry')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('fare_from')), 'A');
      await tester.enterText(find.byKey(const Key('fare_to')),   'B');
      await tester.enterText(find.byKey(const Key('fare_dist')), '500');
      await tester.tap(find.byKey(const Key('fare_submit')));
      await tester.pumpAndSettle();

      // Verify all 6 class labels are present
      expect(find.text('1A — First AC'),       findsOneWidget);
      expect(find.text('2A — Second AC'),      findsOneWidget);
      expect(find.text('3A — Third AC'),       findsOneWidget);
      expect(find.text('SL — Sleeper'),        findsOneWidget);
      expect(find.text('CC — Chair Car'),      findsOneWidget);
      expect(find.text('2S — Second Sitting'), findsOneWidget);
    });
  });

  // ─── 6. Navigation ─────────────────────────────────────────────────────────
  group('Navigation', () {
    testWidgets('AppBar nav buttons navigate to correct screens', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap PNR nav button in AppBar
      await tester.tap(find.byKey(const Key('nav_PNR')));
      await tester.pumpAndSettle();
      expect(find.text('PNR Status Enquiry'), findsOneWidget);

      // Navigate back via Schedule button
      await tester.tap(find.byKey(const Key('nav_Schedule')));
      await tester.pumpAndSettle();
      expect(find.text('Train Schedule'), findsOneWidget);

      await tester.tap(find.byKey(const Key('nav_Seats')));
      await tester.pumpAndSettle();
      expect(find.text('Seat Availability'), findsOneWidget);

      await tester.tap(find.byKey(const Key('nav_Fare')));
      await tester.pumpAndSettle();
      expect(find.text('Fare Enquiry'), findsOneWidget);
    });
  });
}
