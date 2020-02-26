//
//  EmployeeCell.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-23.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

class EmployeeCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var teamLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!

    var id: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        profileImageView.layer.cornerRadius = 5
        profileImageView.layer.borderColor = UIColor.label.cgColor
        profileImageView.layer.borderWidth = 1
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        profileImageView.layer.borderColor = UIColor.label.cgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        id = nil
        profileImageView.image = UIImage(systemName: "person")
    }
}

