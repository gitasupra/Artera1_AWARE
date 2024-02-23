//
//  ContactListView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/17/24.
//
import SwiftUI

struct ContactListView: View {
    @ObservedObject private var contactsManager = ContactsManager.shared
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    NavigationLink(destination: AddContactView(contactsManager: contactsManager)) {
                        Image(systemName: "person.badge.plus")
                        Text("Create New Contact")
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
                
                List {
                    ForEach(contactsManager.contacts.indices, id: \.self) { index in
                        NavigationLink(destination: ContactDetailView(contact: contactsManager.contacts[index], contactsManager: contactsManager, contactIndex: index)) {
                            ContactRow(contact: contactsManager.contacts[index])
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Contact List", displayMode: .large)
    }
}
