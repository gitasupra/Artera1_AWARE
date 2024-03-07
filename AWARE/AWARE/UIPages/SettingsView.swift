//
//  SettingsView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/20/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var name: String
    
    @State private var isNotificationEnabled = true
    @State private var isContactListEnabled = true
    @State private var isUberEnabled = true
    @State private var isEmergencyContacts = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Profile")) {
                    TextField("Name", text: $name).disableAutocorrection(true)
                }.tint(Style.accentColor)
                
                Section(header: Text("Contacts")) {
                    Toggle(isOn: $isContactListEnabled) {
                        Text("Enable contact list")
                        Text("Contact others when intoxicated")
                    }
                    Toggle(isOn: $isUberEnabled) {
                        Text("Enable Uber")
                        Text("Open the Uber app when too impaired to drive")
                    }
                    Toggle(isOn: $isEmergencyContacts) {
                        Text("Enable emergency services")
                        Text("Contact 911 in case of extreme emergencies")
                    }
                }.tint(Style.accentColor)
                
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $isNotificationEnabled) {
                        Text("Allow notifications")
                        Text("Receive updates on your intoxication level")
                    }
                }.tint(Style.accentColor)
                
                Section {
                    Button("Reset to default") {
                        isNotificationEnabled = true
                        isContactListEnabled = true
                        isUberEnabled = true
                        isEmergencyContacts = false
                    }
                }.tint(Style.accentColor)
                
                Section {
                    Button("Log out") {
                        viewModel.signOut()
                    }
                }.tint(.red)
            }.navigationBarTitle(Text("Settings"))
        }
    }
}
