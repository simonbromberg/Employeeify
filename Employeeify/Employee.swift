//
//  Employee.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-20.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

/// Wrapper struct fo
struct EmployeeResult: Decodable {
    let employees: [Employee]
}

/// Main model for importing Employee JSON
struct Employee: Decodable, Hashable {
    /// unique identifier for the employee. Represented as a UUID
    let uuid: String

    /// full name of the employee
    let fullName: String

    /// phone number of the employee, sent as an unformatted string (eg, 5556661234)
    let phoneNumber: String?

    /// email address of the employee
    let emailAddress: String

    /// short, tweet-length (~300 chars) string that the employee provided to describe themselves
    let biography: String?

    /// URL of the employee’s small photo. Useful for list view
    let photoURLSmall: String?

    /// URL of the employee’s full-size photo
    let photoURLLarge: String?

    /// team employee is on, represented as a human readable string
    let team: String

    /// how the employee is classified
    let type: EmployeeType

    enum EmployeeType: String, Decodable {
        case fullTime = "FULL_TIME"
        case partTime = "PART_TIME"
        case contractor = "CONTRACTOR"

        /// No need to fail loading employee if type isn't in the example data provided, but in a production app you would probably agree with API / product team on the possible values so this doesn't happen
        case unknown

        var localized: String {
            switch self {
            case .fullTime:
                return NSLocalizedString("Full Time", comment: "Employee type")
            case .partTime:
                return NSLocalizedString("Part Time", comment: "Employee type")
            case .contractor:
                return NSLocalizedString("Contractor", comment: "Employee type")
            case .unknown:
                return NSLocalizedString("<Invalid Type>", comment: "Employee type")
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case emailAddress = "email_address"
        case biography
        case photoURLSmall = "photo_url_small"
        case photoURLLarge = "photo_url_large"
        case team
        case type = "employee_type"
    }

    enum PhotoSize {
        case small, large
    }

    func photoURL(forSize size: PhotoSize) -> URL? {
        var urlString: String?
        switch size {
        case .small:
            urlString = photoURLSmall
        case .large:
            urlString = photoURLLarge
        }

        if let urlString = urlString {
            return URL(string: urlString)
        }

        return nil
    }
}
