//
//  Contact.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/18/24.
//

import Foundation
import SwiftUI
import Contacts

class Contact: ObservableObject, Identifiable {
    let id = UUID()
    @Published var imageName: String
    @Published var name: String
    @Published var phone: String
    @Published var image: UIImage?
    
    init(imageName: String, name: String, phone: String, image: UIImage? = nil) {
        self.imageName = imageName
        self.name = name
        self.phone = phone
        self.image = image
    }
}
