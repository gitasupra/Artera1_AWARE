//
//  ContactsManager.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/18/24.
//

import Foundation
import SwiftUI

class ContactsManager: ObservableObject {
    @Published var contacts: [Contact] = [
        Contact(imageName: "hollyHuey", name: "Holly F. Huey", phone: "+1(242)-8110134"),
        Contact(imageName: "roseAcker", name: "Rose Acker", phone: "+1(656)-1881047"),
        Contact(imageName: "leonardoLongNecker", name: "Leonardo Longnecker", phone: "+1(545)-3442899"),
        Contact(imageName: "quentinJoplin", name: "Quentin F. Joplin", phone: "+1(434)-7448466"),
        Contact(imageName: "christineClapper", name: "Christine Clapper", phone: "+1(141)-5115553"),
        Contact(imageName: "joyCordon", name: "Joy Cordon", phone: "+1(353)-0663954")
    ]
    
    func updateContactImage(_ contact: Contact, image: UIImage) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index].image = image
        }
    }
}
