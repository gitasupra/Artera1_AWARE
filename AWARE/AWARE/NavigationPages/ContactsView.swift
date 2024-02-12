//
//  ContactsView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/12/24.
//

import SwiftUI

struct GraphView: View {
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
                    .buttonStyle(Style.CustomButtonStyle())
                }
                
                NavigationLink(destination: Text("Call Uber")) {
                    Button("Call Uber") {}
                        .buttonStyle(Style.CustomButtonStyle())
                }
                
                NavigationLink(destination: Text("Call 911")) {
                    Button("Call Emergency Services") {}
                        .buttonStyle(Style.CustomButtonStyle())
                }
            }
            
            Spacer()
        }

    }
}
