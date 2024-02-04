//
//  ContactsManager.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/18/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

class ContactsManager: ObservableObject {
    @Published var contacts: [Contact] = []

    init() {
        fetchContacts()
    }

    func fetchContacts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users").child(uid).child("contacts")
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            var fetchedContacts: [Contact] = []

            for case let childSnapshot as DataSnapshot in snapshot.children {
                if let contactDict = childSnapshot.value as? [String: Any],
                   let name = contactDict["name"] as? String,
                   let phone = contactDict["phone"] as? String,
                   let imageUrl = contactDict["imageUrl"] as? String {
                    let contact = Contact(imageName: imageUrl, name: name, phone: phone)
                    fetchedContacts.append(contact)
                }
            }

            DispatchQueue.main.async {
                self.contacts = fetchedContacts
            }
        }
    }

    func updateContactImage(_ contact: Contact, image: UIImage) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index].image = image
        }
    }
}
