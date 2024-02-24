//
//  AlertManager.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/15/24.
//

import SwiftUI
import CoreHaptics
import SwiftCSV
import CSV


//struct CSVFileRead {
//    let csvFile: CSV
//}


struct Response: Codable {
    let predict: Int
}

func sendCSVToServer(accData: String) { // accData is filename, type stirng
    guard let url = URL(string: "http://jessicalieu.pythonanywhere.com/uploadCSV") else {
        print("Invalid URL")
        return
    }
    

        let csvFile = try! SwiftCSV.CSV<Named>(url: URL(fileURLWithPath: accData))
        

    
    URLSession.shared.uploadTask(with: URLRequest(url: url, method: .post), from: csvFile) { data, response, error in{
        
        let predict = try! JSONDecoder().decode(Response.self, from: json)
        
    }.resume()
        
        return (Response.predict)
    }

    
    class AlertManager: ObservableObject {
        let prediction_result = sendCSVToServer(accData: "BK7610")
        public let contactManager = ContactsManager()
        public let twilioManager = TwilioSMSManager()
        @Published var intoxLevel: Int = prediction_result {
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
}
