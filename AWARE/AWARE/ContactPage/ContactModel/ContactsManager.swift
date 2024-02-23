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
    static let shared=ContactsManager()
    @Published var contacts: [Contact] = []
    
    init() {
        fetchContacts()
    }
    
    func fetchContacts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users").child(uid).child("contacts")
        let dispatchGroup = DispatchGroup() // Create a dispatch group
        
        databaseRef.observeSingleEvent(of: .value) { snapshot in
            var fetchedContacts: [Contact] = []
            
            for case let childSnapshot as DataSnapshot in snapshot.children {
                if let contactDict = childSnapshot.value as? [String: Any],
                   let id = contactDict["id"] as? String,
                   let name = contactDict["name"] as? String,
                   let phone = contactDict["phone"] as? String,
                   let imageUrl = contactDict["imageUrl"] as? String {
                    
                    dispatchGroup.enter()
                    
                    // Load the image asynchronously
                    DispatchQueue.global().async {
                        if !imageUrl.isEmpty{
                            if let imageURL = URL(string: imageUrl) {
                                do {
                                    let imageData = try Data(contentsOf: imageURL)
                                    if let image = UIImage(data: imageData) {
                                        let contact = Contact(id: id, imageName: imageUrl, name: name, phone: phone, image: image)
                                        
                                        // Update UI on the main thread
                                        DispatchQueue.main.async {
                                            fetchedContacts.append(contact)
                                            dispatchGroup.leave() // Leave the dispatch group
                                        }
                                    } else {
                                        print("Failed to create UIImage from data")
                                        dispatchGroup.leave() // Leave the dispatch group even if image creation fails
                                    }
                                } catch {
                                    print("Error loading image data:", error)
                                    dispatchGroup.leave() // Leave the dispatch group if there's an error loading image data
                                }
                            } else {
                                print("Invalid image URL:", imageUrl)
                                dispatchGroup.leave() // Leave the dispatch group for invalid image URLs
                            }
                        }
                        else{
                            let contact = Contact(id: id, imageName: "", name: name, phone: phone)
                            
                            // Update UI on the main thread
                            DispatchQueue.main.async {
                                fetchedContacts.append(contact)
                                dispatchGroup.leave() // Leave the dispatch group
                            }
                        }
                        
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.contacts = fetchedContacts
                print("contacts added")
                print(fetchedContacts)
                print(self.contacts)
            }
        }
    }
    
    func updateContactImage(_ contact: Contact, image: UIImage) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index].image = image
        }
    }
}
