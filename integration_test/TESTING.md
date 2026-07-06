# Integration Test Guide — Indian Railways Flutter App

## Running on iPhone & iPad simultaneously

```bash
cd ir_app
./integration_test/run_on_iphone_and_ipad.sh
```

This script:
1. Boots `iPhone 17 Pro` (`10A49895-43BC-4CE0-9F15-27D78E4CE514`) and `iPad Pro 13-inch M5` (`1380B2B5-0CBA-4837-ADC9-620F596CF3CF`).
2. `rsync`-copies the project to a temp directory so both `flutter test` runs build independently without colliding on `build/` or `.dart_tool/`.
3. Runs both in parallel and exits **0** only if BOTH pass.

Override UDIDs:
```bash
IR_IPHONE_UDID=<udid> IR_IPAD_UDID=<udid> ./integration_test/run_on_iphone_and_ipad.sh
```

Run a single test file:
```bash
./integration_test/run_on_iphone_and_ipad.sh integration_test/app_test.dart
```

## Running on a single device

```bash
flutter test integration_test/ -d <udid>
```

## XCUITest (Xcode UI Driver / XCDriver)

The `RunnerUITests` target in `ios/Runner.xcodeproj` contains Swift XCUITests that
drive the real app on the simulator via `XCUIApplication`. Build and run from Xcode,
or via the command line after `flutter build ios --simulator`:

```bash
# 1. Build the Flutter app
cd ir_app && flutter build ios --simulator --no-codesign

# 2. Copy into DerivedData (replace the DerivedData path with yours)
DERIVED=$(ls -d ~/Library/Developer/Xcode/DerivedData/Runner-* | head -1)
cp -Rf build/ios/iphonesimulator/Runner.app "$DERIVED/Build/Products/Debug-iphonesimulator/"

# 3. Run only UITests
cd ios && xcodebuild test-without-building \
  -workspace Runner.xcworkspace -scheme Runner \
  -destination "platform=iOS Simulator,id=10A49895-43BC-4CE0-9F15-27D78E4CE514" \
  -only-testing RunnerUITests \
  CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""
```

## Test inventory

| File | Framework | Covers |
|------|-----------|--------|
| `integration_test/app_test.dart` | Flutter `integration_test` | All 5 screens, navigation, PNR lookup, fare calculation |
| `ios/RunnerUITests/IRAppUITests.swift` | XCUITest (XCDriver) | 30 regression tests across all screens |
