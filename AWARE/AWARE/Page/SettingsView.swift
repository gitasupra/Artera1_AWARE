//
//  SettingsView.swift
//  AWARE
//
//  Created by Jessica Lieu on 1/23/24.
//

import SwiftUI

struct SettingsView: View {
    
    // setting toggles
    @State private var name = ""
    @State private var isNotificationEnabled = true
    @State private var isContactListEnabled = true
    @State private var isUberEnabled = false
    @State private var isEmergencyContacts = false
    @State private var isHelpTipsEnabled = true
    @State var showAccChart: Bool = true
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Form {
            Section(header: Text("User Profile")) {
                TextField("Name", text: $name).disableAutocorrection(true)
            }.tint(accentColor)
            
            Section(header: Text("Contacts")) {
                Toggle(isOn: $isContactListEnabled) {
                    Text("Enable contact list")
                    Text("Contact others when intoxicated")
                }
                Toggle(isOn: $isUberEnabled) {
                    Text("Enable Uber")
                    Text("Open the Uber app when driving impaired")
                }
                Toggle(isOn: $isEmergencyContacts) {
                    Text("Enable emergency services")
                    Text("Call 911 in case of extreme emergencies")
                }
            }.tint(accentColor)
            
            Section(header: Text("Notifications")) {
                Toggle(isOn: $isNotificationEnabled) {
                    Text("Allow notifications")
                    Text("Receive updates on your intoxication level")
                }
            }.tint(accentColor)
            
            Section(header: Text("Miscellaneous")) {
                Toggle(isOn: $isHelpTipsEnabled) {
                    Text("Enable help tips")
                    Text("Receive tips on drinking safely")
                }
            }.tint(accentColor)
            
            Section {
                Button("Reset to default") {
                    isNotificationEnabled = true
                    isContactListEnabled = true
                    isUberEnabled = false
                    isEmergencyContacts = false
                    isHelpTipsEnabled = true
                }
            }.tint(accentColor)
            
            Section {
                Button("Log out") {
                    viewModel.signOut()
                }
            }.tint(.red)
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
