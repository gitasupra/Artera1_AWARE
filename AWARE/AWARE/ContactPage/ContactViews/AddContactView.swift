//
//  AddContactView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/18/24.
//

import SwiftUI
import Contacts
import Firebase
import FirebaseAuth
import FirebaseStorage

struct AddContactView: View {
    @ObservedObject var contactsManager: ContactsManager
    @State fileprivate var contactName = ""
    @State fileprivate var phoneNumber = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType?
    
    @State var importedContact: CNContact?
    @State var importedPhoneNumber: String?
    @State private var editableContactName = ""
    @State private var editablePhoneNumber = ""
    @State private var isEditingContactName = false
    @State private var isEditingPhoneNumber = false
    
    let countryCodes = ["+1", "+44", "+81", "+86", "+91", "+254", "+"]
    @State private var selectedCountryCode = "+1"
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            // Profile Picture Section
            Button(action: {
                isImagePickerPresented.toggle()
            }) {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 2)
                                .overlay(
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color.white)
                                        .background(Color.accentColor)
                                        .clipShape(Circle())
                                        .offset(y: 25)
                                )
                        )
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 2)
                                .overlay(
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color.white)
                                        .background(Color.accentColor)
                                        .clipShape(Circle())
                                        .offset(y: 25)
                                )
                        )
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: $sourceType)
            }
            .padding()
            
            // Contact Information Section
            TextField("Enter contact name", text: Binding<String>(
                get: {
                    if let givenName = importedContact?.givenName, let familyName = importedContact?.familyName {
                        return isEditingContactName ? editableContactName : "\(givenName) \(familyName)"
                    } else {
                        return editableContactName
                    }
                },
                set: { newValue in
                    editableContactName = newValue
                    isEditingContactName = true
                }
            ))
            .padding()
            .textFieldStyle(RoundBorderStyle())
            
            HStack {
                // Country code dropdown
                Picker("", selection: $selectedCountryCode) {
                    ForEach(countryCodes, id: \.self) { code in
                        Text(code)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 90)
                
                TextField("Enter phone number", text: Binding<String>(
                    get: {
                        if let phoneNumber = importedPhoneNumber {
                            return isEditingPhoneNumber ? editablePhoneNumber : "\(phoneNumber)"
                        } else {
                            return editablePhoneNumber
                        }
                    },
                    set: { newValue in
                        editablePhoneNumber = newValue
                        isEditingPhoneNumber = true
                    }
                )).padding(.leading, -20)
            }
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.accentColor, lineWidth: 1)
            )

            Button("Add contact") {
                addContact()
            }
            .alert(isPresented: $showAlert) {
                if alertTitle == "Error" {
                    return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                else {
                    return Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        primaryButton: .default(
                            Text("Done"),
                            action: {
                                presentationMode.wrappedValue.dismiss()
                            }
                        ),
                        secondaryButton: .default(
                            Text("Add another")
                        )
                    )
                }
            }
            
            ContactPickerButton(contact: $importedContact, phoneNumber: $importedPhoneNumber, onCancel: {
                isEditingContactName = false
                isEditingPhoneNumber = false
            }) {
                Label("Import from contacts", systemImage: "")
                    .fixedSize()
            }
            .fixedSize()
        }
        .padding()
        .onDisappear {
            contactsManager.objectWillChange.send()
        }
    }

    private func addContact() {
        let finalContactName: String = {
            if !editableContactName.isEmpty {
                return editableContactName
            } else if let givenName = importedContact?.givenName, let familyName = importedContact?.familyName {
                return "\(givenName) \(familyName)"
            } else {
                return contactName
            }
        }()
        
        guard !finalContactName.isEmpty else {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Contact name cannot be blank."
            return
        }
        
        let finalPhoneNumber: String = {
            if !editablePhoneNumber.isEmpty {
                return editablePhoneNumber
            } else if let importedPhoneNumber = importedPhoneNumber {
                return importedPhoneNumber
            } else {
                return phoneNumber
            }
        }()
        
        guard let formattedPhoneNumber = formatPhoneNumber(name: finalContactName, phoneNumber: finalPhoneNumber, countryCode: selectedCountryCode),
              let uid = Auth.auth().currentUser?.uid else {
                  return
              }

        // Get a reference to the user's contacts in the database
        let contactsRef = Database.database().reference().child("users").child(uid).child("contacts")

        // Generate a unique key for the new contact
        guard let contactKey = contactsRef.childByAutoId().key else { return }

        // Initialize imageUrl to an empty string
        var contact = UserContact(id: contactKey, uid: uid, name: finalContactName, phone: formattedPhoneNumber, imageUrl: "")

        // Ensure parent folders in Firebase Storage exist
        let storageRef = Storage.storage().reference()
        let userRef = storageRef.child("contact_pics").child(uid)
        let contactRef = userRef.child(contactKey)

        // Save the contact picture
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.5) {
            let profileImgReference = contactRef.child("\(contact.id).png")

            let uploadTask = profileImgReference.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                } else {
                    // Wait for the image upload and URL retrieval to complete
                    profileImgReference.downloadURL { (url, error) in
                        if let imageUrl = url?.absoluteString {
                            // Update the image URL and id in the contact object
                            contact.imageUrl = imageUrl

                            // Set the contact data under the unique key using setValue
                            let contactData: [String: Any] = [
                                "id": contact.id,
                                "name": contact.name,
                                "phone": contact.phone,
                                "imageUrl": contact.imageUrl
                            ]

                            // Set the contact data under the unique key
                            contactsRef.child(contactKey).setValue(contactData)

                            // Append the contact to the local array
                            let newContact = Contact(id: contactKey, imageName: finalContactName, name: finalContactName, phone: formattedPhoneNumber, image: selectedImage)
                            contactsManager.contacts.append(newContact)

                            // Reset all fields
                            contactName = ""
                            editableContactName = ""
                            editablePhoneNumber = ""
                            importedPhoneNumber = nil
                            importedContact = nil
                            selectedImage = nil
                            showAlert = true

                            // Send success alert
                            alertTitle = "Success"
                            alertMessage = "Added new contact"
                        }
                    }
                }
            }
        } else {
            let contactData: [String: Any] = [
                "id": contact.id,
                "name": contact.name,
                "phone": contact.phone,
                "imageUrl": contact.imageUrl
            ]
            
            contactsRef.child(contactKey).setValue(contactData)
            
            // Append the contact to the local array
            let newContact = Contact(id: contactKey, imageName: finalContactName, name: finalContactName, phone: formattedPhoneNumber, image: selectedImage)
            contactsManager.contacts.append(newContact)
            
            // Reset all fields
            contactName = ""
            editableContactName = ""
            editablePhoneNumber = ""
            importedPhoneNumber = nil
            importedContact = nil
            selectedImage = nil
            showAlert = true
            
            // Send success alert
            alertTitle = "Success"
            alertMessage = "Added new contact"
        }
    }
    
    func formatPhoneNumber(name: String, phoneNumber: String, countryCode: String) -> String? {
        let numericPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard !numericPhoneNumber.isEmpty else {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Phone number cannot be blank."
            return nil
        }
        
        guard numericPhoneNumber.count == 10 || countryCode == "+" else {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Phone number must have 10 digits."
            return nil
        }
        
        guard numericPhoneNumber.count > 10 || countryCode != "+" else {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Phone number must have country code and 10 digits."
            return nil
        }
        
        let formattedPhoneNumber: String = {
            if countryCode != "+" {
                return countryCode + "(\(numericPhoneNumber.prefix(3)))-\(numericPhoneNumber.dropFirst(3))"
            } else {
                return countryCode + "\(numericPhoneNumber.dropLast(10))(\(numericPhoneNumber.suffix(10).dropLast(7)))-\(numericPhoneNumber.suffix(7))"
            }
        }()
        
        return formattedPhoneNumber
    }
}
