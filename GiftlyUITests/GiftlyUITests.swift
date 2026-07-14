//
//  GiftlyUITests.swift
//  GiftlyUITests
//
//  Created by MacMini4 on 2026/7/6.
//

import XCTest

final class GiftlyUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testAddPersonButtonOpensSheetAndTextFieldAcceptsInput() throws {
        let app = XCUIApplication()
        app.launch()

        let addButton = app.buttons["addPersonButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add person button should exist")
        addButton.tap()

        let fullNameField = app.textFields["Full name"]
        XCTAssertTrue(fullNameField.waitForExistence(timeout: 5), "Full name text field should appear")

        fullNameField.tap()
        fullNameField.typeText("Test Name")

        XCTAssertEqual(fullNameField.value as? String, "Test Name", "Full name field should contain entered text")

        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Save button should exist")
        saveButton.tap()

        let personCell = app.staticTexts["Test Name"]
        XCTAssertTrue(personCell.waitForExistence(timeout: 5), "Created person should appear in the list")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
