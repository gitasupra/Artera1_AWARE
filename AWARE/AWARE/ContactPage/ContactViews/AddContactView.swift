//
//  AddContactView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/18/24.
//

import SwiftUI
import Contacts

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
                        // Check if the contact name is being edited
                        return isEditingContactName ? editableContactName : "\(givenName) \(familyName)"
                    } else {
                        return editableContactName
                    }
                },
                set: { newValue in
                    editableContactName = newValue
                    isEditingContactName = true // Set the flag when editing
                }
            ))
            .padding()
            .textFieldStyle(RoundBorderStyle())
            
            TextField("Enter phone number", text: Binding<String>(
                get: {
                    if let phoneNumber = importedPhoneNumber {
                        // Check if the phone number is being edited
                        return isEditingPhoneNumber ? editablePhoneNumber : "\(phoneNumber)"
                    } else {
                        return editablePhoneNumber
                    }
                },
                set: { newValue in
                    editablePhoneNumber = newValue
                    isEditingPhoneNumber = true // Set the flag when editing
                }
            ))
            .padding()
            .textFieldStyle(RoundBorderStyle())

            Button("Add contact") {
                addContact()
            }
            ContactPickerButton(contact: $importedContact, phoneNumber: $importedPhoneNumber, onCancel: {}) {
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
        if let formattedPhoneNumber = formatPhoneNumber(name: editableContactName, phoneNumber: editablePhoneNumber) {
            let newContact = Contact(imageName: editableContactName, name: editableContactName, phone: formattedPhoneNumber, image: selectedImage)
            contactsManager.contacts.append(newContact)
            contactName = ""
            editableContactName = ""
            editablePhoneNumber = ""
            importedPhoneNumber = nil
            importedContact = nil
            selectedImage = nil
        } else {
            debugPrint("Invalid phone number format")
        }
    }
    
    func formatPhoneNumber(name: String, phoneNumber: String) -> String? {
        let numericPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        guard !numericPhoneNumber.isEmpty else {
            return nil
        }

        let formattedPhoneNumber = numericPhoneNumber

        print("Name: \(name), Formatted Phone Number: \(formattedPhoneNumber)")

        return formattedPhoneNumber
    }
}
