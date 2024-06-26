//
//  UserContacts.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/3/24.
//

import SwiftUI
import Contacts

struct UserContact: Identifiable {
    let id: String
    let uid: String
    var name: String
    var phone: String
    var imageUrl: String
    
    init(id: String, uid: String, name: String, phone: String, imageUrl: String) {
        self.id = id
        self.uid = uid
        self.name = name
        self.phone = phone
        self.imageUrl = imageUrl
    }
}

extension UserContact {
    static var MOCK_USERCONTACT: UserContact {
        UserContact(id: "123", uid: NSUUID().uuidString, name: "First Last", phone: "+1234567890", imageUrl: "testImage")
    }
}
