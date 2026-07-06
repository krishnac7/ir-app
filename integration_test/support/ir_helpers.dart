// Shared helpers for ir_app integration ("click around the simulator") tests.
//
// Mirrors the BookQuilt mobile integration-test style: a small set of
// step-logging + polling + tap helpers so the journey tests read as a sequence
// of user actions rather than raw widget plumbing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Emit a step marker so the simulator run log reads as a user journey.
void itStep(String message) {
  // ignore: avoid_print
  print('IT_STEP: $message');
}

/// Deliberate pause so each action is visible when watching on a simulator.
/// Set to [Duration.zero] (e.g. in CI) to run at full speed.
Duration watchPace = const Duration(milliseconds: 450);

/// Hold the current frame for [watchPace] so a human can see what just happened.
Future<void> pace(WidgetTester tester) async {
  if (watchPace == Duration.zero) return;
  await tester.pump(watchPace);
}

/// Poll until [finder] matches at least one widget, or fail after [timeout].
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  String? description,
  Duration timeout = const Duration(seconds: 10),
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(interval);
  }
  throw TestFailure(
    'Timed out waiting for ${description ?? finder.toString()}.',
  );
}

/// Tap one of the Home service cards ('PNR Status', 'Train Schedule',
/// 'Seat Availability', 'Fare Enquiry') and settle.
Future<void> tapServiceCard(WidgetTester tester, String title) async {
  final card = find.byKey(Key('card_$title'));
  await waitFor(tester, card, description: 'Home service card "$title"');
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  itStep('tap Home card "$title"');
  await tester.tap(card, warnIfMissed: false);
  await tester.pumpAndSettle();
  await pace(tester);
}

/// Tap an AppBar nav button ('PNR', 'Schedule', 'Seats', 'Fare') and settle.
Future<void> tapNavButton(WidgetTester tester, String label) async {
  final btn = find.byKey(Key('nav_$label'));
  await waitFor(tester, btn, description: 'AppBar nav button "$label"');
  itStep('tap AppBar nav "$label"');
  await tester.tap(btn.first, warnIfMissed: false);
  await tester.pumpAndSettle();
  await pace(tester);
}

/// Pop the current route (via the AppBar back arrow when present).
Future<void> goBack(WidgetTester tester) async {
  final back = find.byTooltip('Back');
  if (back.evaluate().isNotEmpty) {
    itStep('tap Back');
    await tester.tap(back.first, warnIfMissed: false);
  } else {
    await tester.binding.handlePopRoute();
  }
  await tester.pumpAndSettle();
  await pace(tester);
}

/// Pop back until the Home hero banner is visible again.
Future<void> returnHome(WidgetTester tester, {int maxBacks = 8}) async {
  const homeHero = 'Indian Railways Passenger Enquiry';
  for (var i = 0; i < maxBacks; i++) {
    if (find.text(homeHero).evaluate().isNotEmpty) return;
    await goBack(tester);
  }
  await waitFor(
    tester,
    find.text(homeHero),
    description: 'Home hero after returning',
  );
}

/// Enter a PNR number and tap "Check Status".
Future<void> submitPnr(WidgetTester tester, String pnr) async {
  final input = find.byKey(const Key('pnr_input'));
  await waitFor(tester, input, description: 'PNR input field');
  itStep('enter PNR "$pnr"');
  await tester.enterText(input, pnr);
  await tester.pumpAndSettle();
  await pace(tester);
  itStep('tap Check Status');
  await tester.tap(find.byKey(const Key('pnr_submit')), warnIfMissed: false);
  await tester.pumpAndSettle();
  await pace(tester);
}

/// Fill the fare form and tap "Calculate Fare".
Future<void> submitFare(
  WidgetTester tester, {
  required String from,
  required String to,
  required String distance,
}) async {
  await waitFor(
    tester,
    find.byKey(const Key('fare_from')),
    description: 'Fare form',
  );
  itStep('fill fare form: $from -> $to ($distance km)');
  await tester.enterText(find.byKey(const Key('fare_from')), from);
  await tester.enterText(find.byKey(const Key('fare_to')), to);
  await tester.enterText(find.byKey(const Key('fare_dist')), distance);
  await tester.pumpAndSettle();
  await pace(tester);
  itStep('tap Calculate Fare');
  await tester.tap(find.byKey(const Key('fare_submit')), warnIfMissed: false);
  await tester.pumpAndSettle();
  await pace(tester);
}
