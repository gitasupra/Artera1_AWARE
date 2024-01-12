// Sources: -Login/Signup:https://www.youtube.com/watch?v=QJHmhLGv-_0
//  File.swift
//  AWARE
//
//  Created by Gita Supramaniam on 1/11/24.
//

import Foundation
import Firebase
import FirebaseAuth


//publish UI changes on main thread
@MainActor
class AuthViewModel: ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    
    //custom user class, not Firebase's
    @Published var currentUser: User?
    
    init(){
        self.userSession=Auth.auth().currentUser 
    }
    
    func signIn(withEmail email: String, password: String) async throws{
        print("Sign in...")
        
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws{
        do{
            
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("Success")
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encoder=JSONEncoder()
            if let jsonData=try? encoder.encode(user){
                if let jsonString=String(data: jsonData, encoding: .utf8){
                    try await Database.database().reference().child("users").child(user.id).setValue(jsonString)
                }
            }
            
        }
        catch{
            print("DEBUG: Failed to create user \(error.localizedDescription)")
        }
        
    }
    func signOut(){
        
    }
    func deleteAccount(){
        
    }
    func fetchUser() async{
        
    }
}
