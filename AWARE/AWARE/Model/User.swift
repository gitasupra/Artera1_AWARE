//Sources:
//  -Login/Signup:https://www.youtube.com/watch?v=QJHmhLGv-_0
//  User.swift
//  AWARE
//
//  Created by Gita Supramaniam on 1/11/24.
//

import Foundation

struct User: Identifiable, Codable{
    let id: String
    let fullname: String
    let email: String
    
    var initials: String{
        let formatter=PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension User{
    static var MOCK_USER=User(id: NSUUID().uuidString, fullname: "FName LName", email: "test@gmail.com")
}
