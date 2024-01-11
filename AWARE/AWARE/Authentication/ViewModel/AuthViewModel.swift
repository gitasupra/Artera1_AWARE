// Sources: -Login/Signup:https://www.youtube.com/watch?v=QJHmhLGv-_0
//  File.swift
//  AWARE
//
//  Created by Gita Supramaniam on 1/11/24.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    
    //custom user class, not Firebase's
    @Published var currentUser: User?
    
    init(){
        
    }
    
    func signIn(withEmail email: String, password: String) async throws{
        print("Sign in...")
        
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws{
        print("Create user")
        
    }
    func signOut(){
        
    }
    func deleteAccount(){
        
    }
    func fetchUser() async{
        
    }
}
