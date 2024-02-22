//
//  AlertManager.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/15/24.
//

import SwiftUI
import CoreHaptics

struct Response: Codable {
    let predict: Int
}

func sendCSVToServer(accData) {
    guard let url = URL(string: "http://127.0.0.1:5000/uploadCSV") else {
        print("Invalid URL")
        return
    }
    
    URLSession.shared.uploadTask(with: URLRequest(url: url, method: "POST"), from: accData) { data, response, error in{
        
    let predict = try! JSONDecoder().decode(Response.self, from: json)

    }.resume()
        
        return (Response.predict)
}

class AlertManager: ObservableObject {
    let prediction_result = sendCSVToServer("BK7610")
    public let contactManager = ContactsManager()
    public let twilioManager = TwilioSMSManager()
    @Published var intoxLevel: Int = result {
        print("Printing intoxication level: ")
        didSet {
            if intoxLevel == 0 {
                print(intoxLevel)
                sendUpdate(level: 0)
            } else if intoxLevel == 1 {
                print(intoxLevel)
                sendUpdate(level: 1)
            } else if intoxLevel == 2 {
                print(intoxLevel)
                sendUpdate(level: 2)
            } else if intoxLevel == 3 {
                AlertManager.triggerHapticFeedback()
            }
        }
    }
    
    static func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func sendUpdate(level: Int) {
        twilioManager.sendSMS(level: level, contactsManager: contactManager)
    }
}
