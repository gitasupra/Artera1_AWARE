//
//  ContactsManager.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/18/24.
//

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
                   let id = contactDict["id"] as? String,
                   let name = contactDict["name"] as? String,
                   let phone = contactDict["phone"] as? String,
                   let imageUrl = contactDict["imageUrl"] as? String {

                    // Load the image asynchronously
                    DispatchQueue.global().async {
                        if let imageURL = URL(string: imageUrl),
                           let imageData = try? Data(contentsOf: imageURL),
                           let image = UIImage(data: imageData) {
                            let contact = Contact(id: id, imageName: imageUrl, name: name, phone: phone, image: image)

                            // Update UI on the main thread
                            DispatchQueue.main.async {
                                fetchedContacts.append(contact)
                                self.contacts = fetchedContacts
                            }
                        }
                    }
                }
            }
        }
    }

    func updateContactImage(_ contact: Contact, image: UIImage) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index].image = image
        }
    }
}
