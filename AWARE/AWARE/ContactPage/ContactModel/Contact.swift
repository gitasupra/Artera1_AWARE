//
//  Contact.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/18/24.
//

import SwiftUI
import Contacts

class Contact: ObservableObject, Identifiable {
    @Published var id: String
    @Published var imageName: String
    @Published var name: String
    @Published var phone: String
    @Published var image: UIImage?
    
    init(id: String, imageName: String, name: String, phone: String, image: UIImage? = nil) {
        self.id = id
        self.imageName = imageName
        self.name = name
        self.phone = phone
        self.image = image
    }
}
