//
//  ApiManager.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-21.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

enum DataProviderError: Error {
    case invalidBaseURL
    case noData(Error?)
    case decodingFailure(Error?)
}

struct Endpoint {
    static let employees = "employees.json"    
}

/// Test data for SwifUI previews
let employeesPreviewData: [Employee] = {
    guard let url = Bundle.main.url(forResource: "employees", withExtension: "json") else {
        return []
    }

    let data = try? Data(contentsOf: url)
    return DataProvider.shared.parseEmployeeData(data, error: nil).employees ?? []
}()

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

class ApiManager: EmployeeDataProvider {
    var baseURL: String { "https://s3.amazonaws.com/sq-mobile-interview/" } // FIXME: testability?

    private let defaultSession = URLSession(configuration: .default)

    private var dataTask: URLSessionDataTask?

    private lazy var persistentImageCache = PersistentImageCache()

    func getEmployees(_ completion: @escaping (_ employees: [Employee]?, _ error: DataProviderError?) -> Void) {
        guard var url = URL(string: baseURL) else {
            completion(nil, .invalidBaseURL)
            return
        }

        url.appendPathComponent(Endpoint.employees)

        // Cancel any previously running tasks
        dataTask?.cancel()

        let request = URLRequest(url: url)

        dataTask = defaultSession.dataTask(with: request) { data, response, error in
            let result = self.parseEmployeeData(data, error: error)
            completion(result.employees, result.error)
        }

        dataTask?.resume()
    }

    func getImageData(with url: URL, completion: @escaping (_ image: Data?, _ error: DataProviderError?) -> Void) {
        if let imageData = persistentImageCache.getImageData(forRemoteURL: url) {
            completion(imageData, nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                self.persistentImageCache.saveImageToDocuments(remoteURL: url, data: data)
                completion(data, nil)
            } else {
                completion(nil, .noData(error))
            }
        }

        task.resume()
    }
}
