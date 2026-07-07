import XCTest

final class Watch WinderUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddItemFlow() throws {
        app.buttons["addButton"].tap()
        let field = app.textFields["field_title"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.tap()
        field.typeText("Test Watch")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.staticTexts["Test Watch"].waitForExistence(timeout: 2))
    }

    func testPaywallTriggersAtFreeLimit() throws {
        for i in 0..<(Store_freeLimitForUITests + 1) {
            app.buttons["addButton"].tap()
            let field = app.textFields["field_title"]
            if field.waitForExistence(timeout: 2) {
                field.tap()
                field.typeText("Item \(i)")
                app.buttons["saveButton"].tap()
            } else {
                break
            }
        }
        XCTAssertTrue(app.buttons["unlockProButton"].waitForExistence(timeout: 3))
    }

    func testKeyboardDismissOnTapOutside() throws {
        app.buttons["addButton"].tap()
        let field = app.textFields["field_title"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.tap()
        field.typeText("Dismiss Me")
        app.navigationBars.firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.exists)
        app.buttons["cancelButton"].tap()
    }

    func testSettingsOpens() throws {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }
}

private let Store_freeLimitForUITests = 25
