//
//  ApiManager.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-21.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

class ApiManager: EmployeeDataProvider {
    struct Endpoint {
        static let employees = "employees.json"
    }

    var baseURL: String { "https://s3.amazonaws.com/sq-mobile-interview/" }

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
