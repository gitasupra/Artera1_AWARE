//Sources:
//  -Login/Signup:https://www.youtube.com/watch?v=QJHmhLGv-_0
//  LoginView.swift
//  AWARE
//
//  Created by Gita Supramaniam on 1/10/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email=""
    @State private var password=""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                
                // AWARE logo
                Image("testlogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                Image("testicon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 75)
                    .padding(.bottom, 20)
                
                //form fields
                VStack(spacing: 24){
                    InputView(text: $email, title: "Email Address", placeholder:"name@example.com")
                        .autocapitalization(.none)
                    
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                }
                .padding(.horizontal)
                
                //sign in button
                Button{
                    //async/await must be wrapped in Task
                    Task{
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    
                }
                .background(Color.accentColor)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                
                //sign up
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3){
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size:14))
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
