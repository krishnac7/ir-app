#!/usr/bin/env bash
#
# Run the ir_app integration suite on an iPhone 17 Pro AND an iPad simulator
# IN PARALLEL. The run is green only if BOTH devices pass.
#
# Two `flutter test` runs in the SAME project folder collide on the shared
# build/ output and the Flutter startup lock ("Unable to start the app on the
# device"). To run genuinely in parallel we build the second device from an
# isolated copy of the project.
#
# Usage:
#   ./integration_test/run_on_iphone_and_ipad.sh                 # whole suite
#   ./integration_test/run_on_iphone_and_ipad.sh integration_test/journey_full_enquiry_test.dart
#
# Override device ids if your UDIDs differ:
#   IR_IPHONE_UDID=... IR_IPAD_UDID=... ./integration_test/run_on_iphone_and_ipad.sh
#
# See integration_test/TESTING.md for details.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
APP_DIR="$(pwd)"

TARGET="${1:-integration_test}"

# Pinned simulator UDIDs for this machine (override via env).
IPHONE_UDID="${IR_IPHONE_UDID:-10A49895-43BC-4CE0-9F15-27D78E4CE514}"  # iPhone 17 Pro
IPAD_UDID="${IR_IPAD_UDID:-1380B2B5-0CBA-4837-ADC9-620F596CF3CF}"      # iPad Pro 13-inch (M5)

echo "Target        : $TARGET"
echo "iPhone 17 Pro : $IPHONE_UDID"
echo "iPad          : $IPAD_UDID"
echo

# Boot both simulators (ignore "already booted") and reveal the Simulator window.
xcrun simctl boot "$IPHONE_UDID" 2>/dev/null || true
xcrun simctl boot "$IPAD_UDID"   2>/dev/null || true
open -a Simulator || true

# Isolated copy of the project for the iPad so the two builds don't collide.
IPAD_DIR="$(mktemp -d -t ir_app_ipad)"
cleanup() { rm -rf "$IPAD_DIR"; }
trap cleanup EXIT
echo "▶️  cloning project for the iPad build → $IPAD_DIR"
rsync -a --exclude build --exclude .dart_tool --exclude .git "$APP_DIR"/ "$IPAD_DIR"/

IPHONE_LOG="$(mktemp -t ir_iphone.XXXX).log"
IPAD_LOG="$(mktemp -t ir_ipad.XXXX).log"

echo "▶️  launching both devices in parallel…"
( cd "$APP_DIR"  && flutter test "$TARGET" -d "$IPHONE_UDID" ) >"$IPHONE_LOG" 2>&1 &
PID_IPHONE=$!
( cd "$IPAD_DIR" && flutter test "$TARGET" -d "$IPAD_UDID" )   >"$IPAD_LOG"   2>&1 &
PID_IPAD=$!

wait "$PID_IPHONE"; RC_IPHONE=$?
wait "$PID_IPAD";   RC_IPAD=$?

echo
echo "──────── iPhone 17 Pro ────────"
tail -4 "$IPHONE_LOG"
echo "exit: $RC_IPHONE   (log: $IPHONE_LOG)"
echo
echo "──────── iPad ─────────────────"
tail -4 "$IPAD_LOG"
echo "exit: $RC_IPAD   (log: $IPAD_LOG)"
echo

if [[ $RC_IPHONE -eq 0 && $RC_IPAD -eq 0 ]]; then
  echo "✅ BOTH devices passed."
  exit 0
fi
echo "❌ FAILED — iPhone 17 Pro exit=$RC_IPHONE, iPad exit=$RC_IPAD (both must be 0)."
exit 1
