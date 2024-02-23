//
//  ContactDetailView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/18/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

struct ContactDetailView: View {
    let contact: Contact
    @State private var isEditing: Bool = false
    @State private var editedName: String = ""
    @State private var editedPhone: String = ""
    @State private var editedImage: UIImage? = nil
    
    @ObservedObject var contactsManager: ContactsManager
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType?
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    
    var contactIndex: Int
    
    var body: some View {
        NavigationView {
            VStack {
                // Profile Picture
                if let image = selectedImage ?? contact.image {
                    Button(action: {
                        isImagePickerPresented.toggle()
                    }) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipped()
                            .cornerRadius(75)
                            .shadow(radius: 3)
                            .foregroundColor(Color.gray)
                            .overlay(
                                Group {
                                    if isEditing {
                                        Circle()
                                            .stroke(Color.accentColor, lineWidth: 2)
                                        Image(systemName: "plus.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color.white)
                                            .background(Color.accentColor)
                                            .clipShape(Circle())
                                            .offset(y: 45)
                                    }
                                }
                            )
                    }
                    .padding(.bottom, 20)
                    .disabled(!isEditing)
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(selectedImage: $selectedImage, sourceType: $sourceType)
                            .onDisappear {
                                if let selectedImage = selectedImage {
                                    editedImage = selectedImage
                                }
                            }
                    }
                } else {
                    Button(action: {
                        isImagePickerPresented.toggle()
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipped()
                            .cornerRadius(75)
                            .shadow(radius: 3)
                            .foregroundColor(Color.gray)
                            .overlay(
                                Group {
                                    if isEditing {
                                        Circle()
                                            .stroke(Color.accentColor, lineWidth: 2)
                                        Image(systemName: "plus.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color.white)
                                            .background(Color.accentColor)
                                            .clipShape(Circle())
                                            .offset(y: 45)
                                    }
                                }
                            )
                    }
                    .padding(.bottom, 20)
                    .disabled(!isEditing)
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(selectedImage: $selectedImage, sourceType: $sourceType)
                            .onDisappear {
                                if let selectedImage = selectedImage {
                                    editedImage = selectedImage
                                }
                            }
                    }
                }
                
                // Contact Name
                TextField("Enter name", text: $editedName)
                    .font(.title)
                    .padding()
                    .disabled(!isEditing)
                    .disableAutocorrection(true)
                    .onAppear {
                        editedName = contact.name
                    }
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.purple, lineWidth: isEditing ? 2 : 0)
                                .background(isEditing ? Color.accentColor.opacity(0.1) : Color.clear)
                        }
                    )
                
                // Phone Number and Contact Options
                Form {
                    HStack {
                        Text("Phone")
                        Spacer()
                        
                        TextField("Enter phone", text: Binding<String>(
                            get: {
                                return isEditing ? editedPhone : formatPhoneNumber(phoneNumber: editedPhone) ?? ""
                            },
                            set: { newValue in
                                editedPhone = newValue
                            }
                        ))
                        .foregroundColor(.gray)
                        .font(.callout)
                        .padding(.horizontal)
                        .disabled(!isEditing)
                        .onAppear {
                            editedPhone = contact.phone
                        }
                    }
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.purple, lineWidth: isEditing ? 2 : 0)
                                .background(isEditing ? Color.accentColor.opacity(0.1) : Color.clear)
                                .padding(-10)
                        }
                    )
                    
                    Section {
                        Button(action: {
                            // TODO: open user's phone app
                        }) {
                            Text("Call")
                        }.disabled(isEditing)
                        Button(action: {
                            // TODO: open user's messaging app
                        }) {
                            Text("Send message")
                        }.disabled(isEditing)
                        Button(action: {
                            showAlert = true
                            alertTitle = "Delete Contact"
                            alertMessage = "Are you sure you want to delete this contact?"
                        }) {
                            Text("Delete")
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .navigationBarItems(
                    leading: Group {
                        if isEditing {
                            Button(action: {
                                isEditing.toggle()
                                editedImage = contact.image
                                editedName = contact.name
                                editedPhone = contact.phone
                                selectedImage = nil
                            }) {
                                Text("Cancel")
                                    .padding(.horizontal)
                            }
                        }
                    },
                    trailing: HStack {
                        Button(action: {
                            withAnimation {
                                isEditing.toggle()
                            }
                            if !isEditing {
                                updateContactData()
                            }
                        }) {
                            Text(isEditing ? "Save" : "Edit")
                                .padding(.horizontal)
                        }
                    }
                )
                .alert(isPresented: $showAlert) {
                    if alertTitle == "Delete Contact"{
                        return Alert(
                            title: Text(alertTitle),
                            message: Text(alertMessage),
                            primaryButton: .destructive (
                                Text("Delete"),
                                action: {
                                    deleteContact()
                                }
                            ),
                            secondaryButton: .cancel()
                        )
                    } else if alertMessage == "Contact deleted successfully" {
                        return Alert(
                            title: Text(alertTitle),
                            message: Text(alertMessage),
                            dismissButton: .default (
                                Text("OK"),
                                action: {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            )
                        )
                    } else {
                        return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                }
            }
        }
    }
    
    private func updateContactData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        // Get a reference to the user's contacts in the database
        let contactsRef = Database.database().reference().child("users").child(uid).child("contacts")
        
        // Create a dictionary to update only changed values
        var updatedData: [String: Any] = [:]
        
        // Update the contact in the local array
        if let index = contactsManager.contacts.firstIndex(where: { $0.id == contact.id }) {
            let localContact = contactsManager.contacts[index]
            
            // Check for changes and update the dictionary
            if editedName != contact.name {
                updatedData["name"] = editedName
                localContact.name = editedName
            }
            
            if editedImage != contact.image {
                if let image = editedImage, let imageData = image.jpegData(compressionQuality: 0.5) {
                    let profileimgref = Storage.storage().reference().child("contact_pics").child(uid).child("\(contact.id).png")
                    profileimgref.putData(imageData, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading image: \(error.localizedDescription)")
                            showAlertWithError(error)
                        } else {
                            profileimgref.downloadURL { (url, error) in
                                if let imageUrl = url?.absoluteString {
                                    localContact.imageName = imageUrl
                                    // Update the contact data in the database
                                    DispatchQueue.global().async {
                                        localContact.image = UIImage(data: try! Data(contentsOf: url!))
                                        // Update the contact data in the database
                                        contactsRef.child(contact.id).updateChildValues(["imageUrl":imageUrl]) { error, _ in
                                            DispatchQueue.main.async {
                                                if let error = error {
                                                    showAlertWithError(error)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            let formattedPhoneNumber = formatPhoneNumber(phoneNumber: editedPhone)!
            if formattedPhoneNumber != contact.phone {
                updatedData["phone"] = formattedPhoneNumber
                localContact.phone = formattedPhoneNumber
            }
            
            // Validate changes
            if let validationError = validateChanges(name: editedName, phoneNumber: editedPhone) {
                showAlertWithError(validationError)
                editedName = contact.name
                editedImage = contact.image
                editedPhone = contact.phone
                isEditing = true
                return
            }
            
            contactsRef.child(contact.id).updateChildValues(updatedData) { error, _ in
                DispatchQueue.main.async {
                    if let error = error {
                        showAlertWithError(error)
                    } else {
                        showAlertWithSuccess("Saved new contact details")
                        // Update the contact in the local array
                        contactsManager.contacts[index] = localContact
                    }
                }
            }
        }
    }

    private func deleteContact() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        // Get a reference to the user's contacts in the database
        let contactsRef = Database.database().reference().child("users").child(uid).child("contacts")
        
        // Get a reference to the contact image in the storage
        let profileImgRef = Storage.storage().reference().child("contact_pics").child(uid).child("\(contact.id).png")
        
        // Remove the contact from the database
        contactsRef.child(contact.id).removeValue { [self] error, _ in
            if let error = error {
                self.showAlertWithError(error)
            } else {
                profileImgRef.delete { error in
                    if let error = error {
                        self.showAlertWithError(error)
                    } else {
                        self.showAlertWithSuccess("Contact deleted successfully")
                        
                        // Remove the contact from the local array
                        if let index = self.contactsManager.contacts.firstIndex(where: { $0.id == contact.id }) {
                            self.contactsManager.contacts.remove(at: index)
                        }
                    }
                }
            }
        }
        
        // Reset contact detail page
        editedImage = nil
    }
    
    func showAlertWithError(_ error: Error) {
        showAlert = true
        alertTitle = "Error"
        alertMessage = "Failed to delete contact: \(error.localizedDescription)"
    }

    func showAlertWithSuccess(_ message: String) {
        showAlert = true
        alertTitle = "Success"
        alertMessage = message
    }
                        
    private func formatPhoneNumber(phoneNumber: String) -> String? {
        let numericPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let formattedPhoneNumber = "+\(numericPhoneNumber.dropLast(10))(\(numericPhoneNumber.suffix(10).dropLast(7)))-\(numericPhoneNumber.suffix(7))"
        return formattedPhoneNumber
    }
    
    private func validateChanges(name: String, phoneNumber: String) -> Error? {
        let numericPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard name != "" else {
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Contact name cannot be blank."])
        }
        
        guard !numericPhoneNumber.isEmpty else {
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Phone number cannot be blank."])
        }
        
        guard numericPhoneNumber.count > 10 else {
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Phone number must have country code and 10 digits."])
        }
        
        return nil
    }
}
