//
//  ContactDetailView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/18/24.
//

import SwiftUI

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
                            // TODO: open user's messaging app
                        }) {
                            Text("Send message")
                        }.disabled(isEditing)
                        Button(action: {
                            // TODO: open user's phone app
                        }) {
                            Text("Call")
                        }.disabled(isEditing)
                    }
                }
            }
            .padding()
            .navigationBarItems(leading: Group {
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
            }, trailing: Button(action: {
                if isEditing {
                    if validateChanges(name: editedName, phoneNumber: editedPhone) {
                        let formattedPhoneNumber = formatPhoneNumber(phoneNumber: editedPhone)
                        contactsManager.contacts[contactIndex].image = editedImage
                        contactsManager.contacts[contactIndex].name = editedName
                        contactsManager.contacts[contactIndex].phone = formattedPhoneNumber!
                        showAlert = true
                        alertTitle = "Success"
                        alertMessage = "Saved new contact details."
                    } else {
                        editedImage = contact.image
                        editedName = contact.name
                        editedPhone = contact.phone
                        selectedImage = nil
                    }
                }
                isEditing.toggle()
            }) {
                Text(isEditing ? "Save" : "Edit")
                    .padding(.horizontal)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            })
        }
    }
    
    private func formatPhoneNumber(phoneNumber: String) -> String? {
        let numericPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let formattedPhoneNumber = "+\(numericPhoneNumber.dropLast(10))(\(numericPhoneNumber.suffix(10).dropLast(7)))-\(numericPhoneNumber.suffix(7))"
        return formattedPhoneNumber
    }
    
    private func validateChanges(name: String, phoneNumber: String) -> Bool {
        let numericPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard name != "" else {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Contact name cannot be blank."
            return false
        }
        
        guard !numericPhoneNumber.isEmpty else {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Phone number cannot be blank."
            return false
        }
        
        guard numericPhoneNumber.count > 10 else {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Phone number must have country code and 10 digits."
            return false
        }
        
        return true
    }
}
