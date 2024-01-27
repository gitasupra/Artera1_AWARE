//
//  ContactsView.swift
//  AWARE
//
//  Created by Jessica Lieu on 1/23/24.
//

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        VStack(alignment: .center) {
            NavigationStack {
                Text("Contacts")
                    .font(.system(size: 36))
                    .multilineTextAlignment(.leading)
                    .padding()
                
                Spacer()
                
                Button(action: {}) {
                    NavigationLink(destination: ContactListView()) {
                        Text("Contact List")
                    }
                    .buttonStyle(Theme.CustomButtonStyle())
                }
                
                NavigationLink(destination: Text("Call Uber")) {
                    Button("Call Uber") {}
                        .buttonStyle(Theme.CustomButtonStyle())
                }
                
                NavigationLink(destination: Text("Call 911")) {
                    Button("Call Emergency Services") {}
                        .buttonStyle(Theme.CustomButtonStyle())
                }
            }
            
            Spacer()
        }
    }
}


struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView()
    }
}
