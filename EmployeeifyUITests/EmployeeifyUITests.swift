//
//  EmployeeifyUITests.swift
//  EmployeeifyUITests
//
//  Created by Simon Bromberg on 2020-02-20.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import XCTest

class EmployeeifyUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    var app: XCUIApplication = {
        let app = XCUIApplication()
        app.launchArguments = ["-running_tests"]
        return app
    }()

    func testLoadNormal() {
        app.launch()

        let name = app.tables.cells.element(boundBy: 0).staticTexts["Alaina Daly"]
        XCTAssertTrue(name.waitForExistence(timeout: 5), "Incorrect employee in 1st row")

        let team = app.tables.cells.element(boundBy: 3).staticTexts["Core"]
        XCTAssertTrue(team.exists, "Incorrect team in 4th row")
    }

    func testSort() {
        app.launch()

        app.navigationBars["Employees"].buttons["Sort"].tap()
        app.sheets["Sort"].scrollViews.otherElements.buttons["By Team"].tap()

        let name = app.tables.cells.element(boundBy: 0).staticTexts["Kaitlyn Spindel"]
        XCTAssertTrue(name.waitForExistence(timeout: 5), "Incorrect employee in 1st row when sorting by team")
    }

    func testLoadMalformed() {
        app.launchArguments.append("-malformed_data")
        app.launch()

        let header = app.staticTexts["Error Loading!"]
        XCTAssertTrue(header.waitForExistence(timeout: 5), "Missing error header")
        XCTAssertEqual(app.tables.cells.count, 0, "App should not load any data when json is bad")
    }

    func testLoadEmpty() {
        app.launchArguments.append("-empty_data")
        app.launch()

        let header = app.staticTexts["No Employees!"]
        XCTAssertTrue(header.waitForExistence(timeout: 5), "Missing error header")
        XCTAssertEqual(app.tables.cells.count, 0, "App should not load any data when json is empty")
    }
}
