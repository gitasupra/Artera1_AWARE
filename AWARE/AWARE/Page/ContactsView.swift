//
//  ContactsView.swift
//  AWARE
//
//  Created by Jessica Lieu on 1/23/24.
//

import SwiftUI

struct ContactsView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Contacts")
                .font(.system(size: 36))
                .multilineTextAlignment(.leading)
                .padding()
            
            Spacer()
            
            NavigationLink(destination: Text("Contact List")) {
                Button("Edit Contact List") {}
                    .buttonStyle(CustomButtonStyle())
            }
            
            NavigationLink(destination: Text("Call Uber")) {
                Button("Call Uber") {}
                    .buttonStyle(CustomButtonStyle())
            }
            
            NavigationLink(destination: Text("Call 911")) {
                Button("Call Emergency Services") {}
                    .buttonStyle(CustomButtonStyle())
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
