//Sources:
//  -Login/Signup:https://www.youtube.com/watch?v=QJHmhLGv-_0
//  InputView.swift
//  AWARE
//
//  Created by Gita Supramaniam on 1/10/24.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            if isSecureField{
                SecureField(placeholder, text: $text)
                    .font(.system(size:14))
            }
            else{
                TextField(placeholder, text: $text)
                    .font(.system(size:14))

            }
            Divider()
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
}
