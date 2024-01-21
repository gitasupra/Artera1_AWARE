// Sources: -Login/Signup:https://www.youtube.com/watch?v=QJHmhLGv-_0
//  File.swift
//  AWARE
//
//  Created by Gita Supramaniam on 1/11/24.
//

import Combine
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
        
        Task{
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws{
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession=result.user
            await fetchUser()
        }catch{
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
        }
        
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws{
        do{
            
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("Success")
            self.userSession = result.user
            //use Codable protocol: map User object to JSON data
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            try await Database.database().reference().child("users").child(user.id).setValue(from:user)
            
        }
        catch{
            print("DEBUG: Failed to create user \(error.localizedDescription)")
        }
        
    }
    func signOut(){
        do{
            try Auth.auth().signOut() //signs out user on backend
            self.userSession = nil //wipes out user session --> take back to login screen
            self.currentUser = nil //wipes out current user data model
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    func deleteAccount(){
        
    }
    func fetchUser() async{
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        guard let snapshot = try? await Database.database().reference().child("users").child(uid).getData() else {return}
        print(snapshot)
        //use Codable protocol: map JSON data to User object
        self.currentUser = try? snapshot.data(as: User.self)
        //print("DEBUG: Current user is \(String(describing: self.currentUser))")
        
    }
}
