//
//  MockApiManager.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-24.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

class MockApiManager: EmployeeDataProvider {
    var employeeData: Data?
    var employeeError: Error?

    func getEmployees(_ completion: @escaping ([Employee]?, DataProviderError?) -> Void) {
        let result = parseEmployeeData(employeeData, error: employeeError)
        completion(result.employees, result.error)
    }

    var imageData: Data?
    var imageError: DataProviderError?

    func getImageData(with url: URL, completion: @escaping (Data?, DataProviderError?) -> Void) {
        completion(imageData, imageError)
    }
}
