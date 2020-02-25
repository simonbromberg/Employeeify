//
//  EmployeeDetailView.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-23.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import SwiftUI

struct EmployeeDetailView: View {
    var employee: Employee
    @ObservedObject var imageLoader: ImageLoader

    init(employee: Employee) {
        self.employee = employee
        imageLoader = ImageLoader(urlString: employee.photoURLLarge)
    }

    var body: some View {
        NavigationView {
            VStack {
                Text(employee.team)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text(employee.type.localized)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)

                CircleImage(image: imageLoader.image.resizable())
                    .aspectRatio(contentMode: .fit)
                    .padding()

                Button(action: {
                    if let url = URL(string: "mailto://\(self.employee.emailAddress)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text(employee.emailAddress)
                }

                employee.phoneNumber.map { phone in
                    Button(action: {                        
                        if let url = URL(string: "tel://\(phone)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(phone)
                    }
                }

                employee.biography.map { Text($0) }
                    .padding()
            }
            .navigationBarTitle(employee.fullName)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

class ImageLoader: ObservableObject {
    @Published var image = Image(systemName: "person")

    init(urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }

        DataProvider.shared.getImageData(with: url, completion: { [weak self] (data, error) in
            if let data = data,
                let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = Image(uiImage: uiImage)
                }
            }
        })
    }
}

#if DEBUG
struct EmployeeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let view = EmployeeDetailView(employee: employeesPreviewData[0])
        view.imageLoader.image = Image("sample_image")
        return view
    }
}
#endif
