//
//  AppDelegate.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-20.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if isRunningTests {
            let mockApiManager = MockApiManager()
            mockApiManager.employeeData = employeeDataForCommandLineArguments()
            mockApiManager.imageData = UIImage(named: "sample_image")?.jpegData(compressionQuality: 1)
            
            DataProvider.shared = mockApiManager
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Tests

    /// Check environment variables for testing flag
    var isRunningTests: Bool {
        return CommandLine.arguments.contains("-running_tests") 
    }

    /// Modify mock api for bad data
    func employeeDataForCommandLineArguments() -> Data? {
        var resourceName: String?
        if CommandLine.arguments.contains("-malformed_data") {
            resourceName = "employees_malformed"
        } else if CommandLine.arguments.contains("-empty_data") {
            resourceName = "employees_empty"
        } else {
            resourceName = "employees"
        }

        if let name = resourceName,
            let url = Bundle.main.url(forResource: name, withExtension: "json") {
            return try? Data(contentsOf: url)
        }

        return nil
    }
}

#if DEBUG
/// Test data for SwifUI previews
let employeesPreviewData: [EmployeeViewModel] = {
    guard let url = Bundle.main.url(forResource: "employees", withExtension: "json") else {
        return []
    }

    let data = try? Data(contentsOf: url)
    let employees = DataProvider.shared.parseEmployeeData(data, error: nil).employees ?? []

    return employees.map({ EmployeeViewModel(with: $0) })
}()
#endif
