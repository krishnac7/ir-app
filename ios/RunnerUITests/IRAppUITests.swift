import XCTest

/// XCUITest regression suite for the Indian Railways Flutter app.
/// Uses XCUIApplication (Xcode UI Driver / XCDriver) to tap, type, and assert
/// against the live app running on the iOS simulator.
///
/// Lifecycle note:
///   setUp: launches the app once and waits for the hero headline.
///   tearDown: does NOT terminate the app — XCTest relaunches it fresh via
///             app.launch() at the next setUp call. Terminating between tests
///             causes DerivedData runner stub issues with Flutter.

final class IRAppUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        XCTAssertTrue(
            app.staticTexts["Indian Railways Passenger Enquiry"].waitForExistence(timeout: 15),
            "App did not reach home screen within 15 s"
        )
    }

    // No tearDown — app.launch() in setUp handles restarting cleanly.

    // ─── Navigation helpers ──────────────────────────────────────────

    private func goTo(_ route: String) {
        // route: "PNR" | "Schedule" | "Seats" | "Fare"
        let btn = app.buttons.matching(NSPredicate(format: "label == %@", route)).firstMatch
        XCTAssertTrue(btn.waitForExistence(timeout: 10), "AppBar button '\(route)' not found")
        btn.tap()
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: – 1. Home Screen
    // ────────────────────────────────────────────────────────────────

    func testHome_HeroBannerVisible() {
        XCTAssertTrue(app.staticTexts["Indian Railways Passenger Enquiry"].exists)
    }

    /// Card titles appear in the body — short labels like "PNR" are in the AppBar.
    /// The full titles ("PNR Status", "Train Schedule" …) only appear as card text.
    func testHome_AllFourCardTitlesPresent() {
        let titles = ["PNR Status", "Train Schedule", "Seat Availability", "Fare Enquiry"]
        for title in titles {
            XCTAssertTrue(
                app.staticTexts.matching(NSPredicate(format: "label == %@", title))
                    .firstMatch.waitForExistence(timeout: 10),
                "Card title '\(title)' not found"
            )
        }
    }

    func testHome_CardDescriptionsVisible() {
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'PNR number'"))
            .firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'train schedule'"))
            .firstMatch.exists)
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'seat availability'"))
            .firstMatch.exists)
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'Calculate fare'"))
            .firstMatch.exists)
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: – 2. Navigation via AppBar buttons
    // ────────────────────────────────────────────────────────────────

    func testNav_AppBarPnrButton() {
        goTo("PNR")
        XCTAssertTrue(app.staticTexts["PNR Status Enquiry"].waitForExistence(timeout: 8))
    }

    func testNav_AppBarScheduleButton() {
        goTo("Schedule")
        XCTAssertTrue(app.staticTexts["Train Schedule"].waitForExistence(timeout: 8))
    }

    func testNav_AppBarSeatsButton() {
        goTo("Seats")
        XCTAssertTrue(app.staticTexts["Seat Availability"].waitForExistence(timeout: 8))
    }

    func testNav_AppBarFareButton() {
        goTo("Fare")
        XCTAssertTrue(app.staticTexts["Fare Enquiry"].waitForExistence(timeout: 8))
    }

    func testNav_CrossNavigation_AllScreensReachable() {
        goTo("PNR");      XCTAssertTrue(app.staticTexts["PNR Status Enquiry"].waitForExistence(timeout: 8))
        goTo("Schedule"); XCTAssertTrue(app.staticTexts["Train Schedule"].waitForExistence(timeout: 8))
        goTo("Seats");    XCTAssertTrue(app.staticTexts["Seat Availability"].waitForExistence(timeout: 8))
        goTo("Fare");     XCTAssertTrue(app.staticTexts["Fare Enquiry"].waitForExistence(timeout: 8))
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: – 3. PNR Status Screen
    // ────────────────────────────────────────────────────────────────

    private func openPnr() {
        goTo("PNR")
        XCTAssertTrue(app.staticTexts["PNR Status Enquiry"].waitForExistence(timeout: 8))
    }

    private func submitPnr(_ pnr: String) {
        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(pnr)
        app.buttons["Check Status"].tap()
    }

    func testPNR_ValidPnr_1234567890_MumbaiRajdhani() {
        openPnr()
        submitPnr("1234567890")
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS '12951'"))
            .firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'MUMBAI CENTRAL'"))
            .firstMatch.exists)
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'S4'"))
            .firstMatch.exists)
    }

    func testPNR_ValidPnr_9876543210_BhopalShatabdi() {
        openPnr()
        submitPnr("9876543210")
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'Bhopal Shatabdi'"))
            .firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'BHOPAL JN'"))
            .firstMatch.exists)
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'C3'"))
            .firstMatch.exists)
    }

    func testPNR_ValidPnr_5555555555_JhelumWaitlist() {
        openPnr()
        submitPnr("5555555555")
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'Jhelum'"))
            .firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'WL'"))
            .firstMatch.exists)
    }

    func testPNR_UnknownPnr_ShowsErrorMessage() {
        openPnr()
        submitPnr("0000000000")
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'No record found'"))
            .firstMatch.waitForExistence(timeout: 8))
    }

    func testPNR_FromDestinationCorrect_1234567890() {
        openPnr()
        submitPnr("1234567890")
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'NEW DELHI'"))
            .firstMatch.waitForExistence(timeout: 8))
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: – 4. Train Schedule Screen
    // ────────────────────────────────────────────────────────────────

    private func openSchedule() {
        goTo("Schedule")
        XCTAssertTrue(app.staticTexts["Train Schedule"].waitForExistence(timeout: 8))
    }

    func testSchedule_InfoBarShowsRajdhaniExpress() {
        openSchedule()
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'Mumbai Rajdhani Express'"))
            .firstMatch.waitForExistence(timeout: 8))
    }

    func testSchedule_OriginAndDestination() {
        openSchedule()
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'MUMBAI CENTRAL'"))
            .firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'NEW DELHI'"))
            .firstMatch.exists)
    }

    func testSchedule_IntermediateStops() {
        openSchedule()
        for stop in ["SURAT", "VADODARA JN", "KOTA JN", "MATHURA JN"] {
            XCTAssertTrue(
                app.staticTexts.matching(NSPredicate(format: "label == %@", stop))
                    .firstMatch.waitForExistence(timeout: 8),
                "Stop '\(stop)' not visible"
            )
        }
    }

    func testSchedule_DepartureTimes() {
        openSchedule()
        XCTAssertTrue(app.staticTexts["16:35"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["09:55"].exists)
    }

    func testSchedule_ColumnHeaders() {
        openSchedule()
        XCTAssertTrue(app.staticTexts["Station"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Arrival"].exists)
        XCTAssertTrue(app.staticTexts["Departure"].exists)
    }

    func testSchedule_NineStops() {
        openSchedule()
        // Row numbers 1–9 verify all 9 stops are rendered
        for i in 1...9 {
            XCTAssertTrue(app.staticTexts["\(i)"].waitForExistence(timeout: 8),
                          "Row \(i) not found in schedule")
        }
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: – 5. Seat Availability Screen
    // ────────────────────────────────────────────────────────────────

    private func openSeats() {
        goTo("Seats")
        XCTAssertTrue(app.staticTexts["Seat Availability"].waitForExistence(timeout: 8))
    }

    func testSeats_JourneyDateVisible() {
        openSeats()
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS '15-Jul-2026'"))
            .firstMatch.waitForExistence(timeout: 8))
    }

    func testSeats_AllSixClassesPresent() {
        openSeats()
        for cls in ["1A — First AC", "2A — Second AC", "3A — Third AC",
                    "SL — Sleeper", "CC — Chair Car", "2S — Second Sitting"] {
            XCTAssertTrue(
                app.staticTexts.matching(NSPredicate(format: "label == %@", cls))
                    .firstMatch.waitForExistence(timeout: 8),
                "Class '\(cls)' not found"
            )
        }
    }

    func testSeats_FirstAC_AlmostFull_2Seats() {
        openSeats()
        XCTAssertTrue(app.staticTexts["Almost Full"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["2"].exists)
    }

    func testSeats_Sleeper_Available_42Seats() {
        openSeats()
        XCTAssertTrue(app.staticTexts["Available"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["42"].exists)
    }

    func testSeats_SecondSitting_110Seats() {
        openSeats()
        XCTAssertTrue(app.staticTexts["110"].waitForExistence(timeout: 8))
    }

    func testSeats_StatusAndAvailableColumns() {
        openSeats()
        XCTAssertTrue(app.staticTexts["Status"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Available Seats"].exists)
    }

    // ────────────────────────────────────────────────────────────────
    // MARK: – 6. Fare Enquiry Screen
    // ────────────────────────────────────────────────────────────────

    private func openFare() {
        goTo("Fare")
        XCTAssertTrue(app.staticTexts["Fare Enquiry"].waitForExistence(timeout: 8))
    }

    private func fillFare(from: String, to: String, distance: String) {
        let fields = app.textFields.allElementsBoundByIndex
        XCTAssertGreaterThanOrEqual(fields.count, 3, "Expected 3 text fields on Fare screen")
        fields[0].tap(); fields[0].typeText(from)
        fields[1].tap(); fields[1].typeText(to)
        fields[2].tap(); fields[2].typeText(distance)
        app.buttons["Calculate Fare"].tap()
        app.swipeUp() // scroll to reveal result table
    }

    func testFare_CalculateButtonAndFieldsPresent() {
        openFare()
        XCTAssertTrue(app.buttons["Calculate Fare"].waitForExistence(timeout: 8))
        XCTAssertGreaterThanOrEqual(app.textFields.count, 3)
    }

    func testFare_1384km_FirstAC_BaseFare6228() {
        openFare()
        fillFare(from: "MUMBAI CENTRAL", to: "NEW DELHI", distance: "1384")
        // 1A: round(4.5 × 1384) = 6228
        XCTAssertTrue(app.staticTexts["₹6228"].waitForExistence(timeout: 8))
    }

    func testFare_1384km_FirstAC_Total6268() {
        openFare()
        fillFare(from: "MUMBAI CENTRAL", to: "NEW DELHI", distance: "1384")
        // 6228 + 40 = 6268
        XCTAssertTrue(app.staticTexts["₹6268"].waitForExistence(timeout: 8))
    }

    func testFare_1384km_Sleeper_Base1246_Total1286() {
        openFare()
        fillFare(from: "MUMBAI CENTRAL", to: "NEW DELHI", distance: "1384")
        // SL: round(0.9 × 1384) = 1246; total = 1286
        XCTAssertTrue(app.staticTexts["₹1246"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["₹1286"].exists)
    }

    func testFare_AllSixClassRowsPresent() {
        openFare()
        fillFare(from: "A", to: "B", distance: "500")
        for cls in ["1A — First AC", "2A — Second AC", "3A — Third AC",
                    "SL — Sleeper", "CC — Chair Car", "2S — Second Sitting"] {
            XCTAssertTrue(
                app.staticTexts.matching(NSPredicate(format: "label == %@", cls))
                    .firstMatch.waitForExistence(timeout: 8),
                "Missing class '\(cls)'"
            )
        }
    }

    func testFare_RouteBarShowsFromTo() {
        openFare()
        fillFare(from: "PUNE JN", to: "JAMMU TAWI", distance: "2000")
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'PUNE JN'"))
            .firstMatch.waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'JAMMU TAWI'"))
            .firstMatch.exists)
    }

    func testFare_ReservationIsAlways40_AllClasses() {
        openFare()
        fillFare(from: "X", to: "Y", distance: "100")
        let fortyLabels = app.staticTexts.matching(NSPredicate(format: "label == '₹40'"))
        XCTAssertTrue(fortyLabels.firstMatch.waitForExistence(timeout: 8))
        XCTAssertEqual(fortyLabels.count, 6,
                       "All 6 classes must show ₹40 reservation")
    }

    func testFare_TableHeaders_ClassBaseFareReservationTotal() {
        openFare()
        fillFare(from: "A", to: "B", distance: "300")
        XCTAssertTrue(app.staticTexts["Class"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Base Fare"].exists)
        XCTAssertTrue(app.staticTexts["Reservation"].exists)
        XCTAssertTrue(app.staticTexts["Total (₹)"].exists)
    }

    func testFare_DistanceShownInRouteBar() {
        openFare()
        fillFare(from: "A", to: "B", distance: "750")
        XCTAssertTrue(app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS '750 km'"))
            .firstMatch.waitForExistence(timeout: 8))
    }
}
