//
//  EmployeeViewModel.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-27.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

struct EmployeeViewModel: Hashable {
    let uuid: String
    let fullName: String
    let team: String
    let photoURLSmall: String?
    var imageHash: Int?

    // Detail properties
    let phoneNumber: String?
    let emailAddress: String
    let biography: String?
    let photoURLLarge: String?
    let type: Employee.EmployeeType

    init(with employee: Employee) {
        self.uuid = employee.uuid
        self.fullName = employee.fullName
        self.team = employee.team
        self.photoURLSmall = employee.photoURLSmall
        
        self.phoneNumber = employee.phoneNumber
        self.emailAddress = employee.emailAddress
        self.biography = employee.biography
        self.photoURLLarge = employee.photoURLLarge
        self.type = employee.type
    }
}
