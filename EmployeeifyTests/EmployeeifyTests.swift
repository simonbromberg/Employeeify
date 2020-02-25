//
//  EmployeeifyTests.swift
//  EmployeeifyTests
//
//  Created by Simon Bromberg on 2020-02-20.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import XCTest
@testable import Employeeify

class EmployeeifyTests: XCTestCase {
    func testNormalEmployeeJSON() {
        guard let data = loadDataFromJSONResource("employees") else {
            return
        }

        let exp = expectation(description: "Mock API")

        let apiManager = MockApiManager()
        apiManager.employeeData = data

        apiManager.getEmployees { (employees, error) in
            do {
                let employees = try XCTUnwrap(employees)
                XCTAssertEqual(employees.count, 11, "employee count does not match expected")

                let employee = try XCTUnwrap(employees.first, "unable to get first employee")
                XCTAssertEqual(employee.fullName, "Justine Mason", "employee name does not match expected")
                XCTAssertEqual(employee.type, .fullTime, "employee type does not match expected")                
            } catch { }

            exp.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testEmptyEmployeeJSON() {
        guard let data = loadDataFromJSONResource("employees_empty") else {
            return
        }

        let exp = expectation(description: "Mock API")

        let apiManager = MockApiManager()
        apiManager.employeeData = data

        apiManager.getEmployees { (employees, error) in
            do {
                let employees = try XCTUnwrap(employees)
                XCTAssertEqual(employees.count, 0, "employee list should be empty")
            } catch { }

            exp.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testMalformedEmployeeJSON() {
        guard let data = loadDataFromJSONResource("employees_malformed") else {
            return
        }

        let exp = expectation(description: "Mock API")

        let apiManager = MockApiManager()
        apiManager.employeeData = data

        apiManager.getEmployees { (employees, error) in
            XCTAssertNil(employees, "malformed employee list should not be imported")

            do {
                let unwrappedError = try XCTUnwrap(error, "error should not be nil")
                switch unwrappedError {
                case .decodingFailure(_):
                    break
                default:
                    XCTFail("Incorrect error thrown for malformed response")
                }
            } catch { }

            exp.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    // MARK: - Helper

    private func loadDataFromJSONResource(_ filename: String, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let url = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "json") else {
            XCTFail("Unable to extract JSON data from file \(filename)", file: file, line: line)
            return nil
        }

        do {
            return try XCTUnwrap(Data(contentsOf: url), "Data in file \(filename) was nil", file: file, line: line)
        } catch { return nil }
    }
}
