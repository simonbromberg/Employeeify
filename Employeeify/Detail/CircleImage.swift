//
//  CircleImage.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-23.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
    var image: Image

    var body: some View {
        image
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.primary, lineWidth: 4))
            .shadow(radius: 10)
    }
}

struct CircleImage_Preview: PreviewProvider {
    static var previews: some View {
        CircleImage(image: Image("sample_image"))
    }
}
