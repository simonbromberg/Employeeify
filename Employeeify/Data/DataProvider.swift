//
//  DataProvider.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-25.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

enum DataProviderError: Error {
    case invalidBaseURL
    case noData(Error?)
    case decodingFailure(Error?)
}

struct DataProvider {
    static var shared: EmployeeDataProvider = ApiManager()
}

protocol EmployeeDataProvider {
    func getEmployees(_ completion: @escaping (_ employees: [Employee]?, _ error: DataProviderError?) -> Void)

    func getImageData(with url: URL, completion: @escaping (_ image: Data?, _ error: DataProviderError?) -> Void)
}

extension EmployeeDataProvider {
    typealias EmployeeParseResult = (employees: [Employee]?, error: DataProviderError?)

    func parseEmployeeData(_ data: Data?, error: Error?) -> EmployeeParseResult {
        guard let data = data else {
            return (nil, .noData(error))
        }

        do {
            let results = try JSONDecoder().decode(EmployeeResult.self, from: data)
            return (results.employees, nil)
        } catch {
            return (nil, .decodingFailure(error))
        }
    }
}
