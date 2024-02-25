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

//func sendCSVToServer(accData: String) -> Int { // accData is filename, type stirng
//    guard let url = URL(string: "http://jessicalieu.pythonanywhere.com/uploadCSV") else {
//        print("Invalid URL")
//        return -1
//    }
//    
//    
//    let csvFile = try! SwiftCSV.CSV<Named>(url: URL(fileURLWithPath: accData))
//    
//    
//    
//    URLSession.shared.uploadTask(with: URLRequest(url: url, method: .post), from: csvFile) { data, response, error in{
//        
//        
//        let predict = try! JSONDecoder().decode(Response.self, from: json)
//        
//    }()
//        
//        return (Response.predict)
//    }
//}
func sendCSVToServer(accData: String, completion: @escaping (Int) -> Void) {
    guard let url = URL(string: "http://jessicalieu.pythonanywhere.com/uploadCSV") else {
        print("Invalid URL")
        completion(-1)
        return
    }

    do {
        //let csvFile = try SwiftCSV.CSV<Named>(url: URL(fileURLWithPath: accData))
        
        
        // Get the raw CSV data
        let csvData = try Data(contentsOf: URL(fileURLWithPath: accData))

        URLSession.shared.uploadTask(with: try URLRequest(url: url, method: .post), from: csvData) { data, response, error in
            guard let data = data, error == nil else {
                // Handle error
                completion(-1)
                return
            }

            do {
                let predict = try JSONDecoder().decode(Response.self, from: data)
                completion(predict.predict)
            } catch {
                // Handle decoding error
                completion(-1)
            }
        }.resume()
    } catch {
        // Handle CSV parsing error
        completion(-1)
    }
}



    
class AlertManager: ObservableObject {
    public let contactManager = ContactsManager()
    public let twilioManager = TwilioSMSManager()
    
    @Published var intoxLevel = 0
    
    init() {
        sendCSVToServer(accData: "BK7610") { [weak self] predictionResult in
            self?.intoxLevel = predictionResult
            self?.handleIntoxLevelChange()
        }
    }

    static func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func sendUpdate(level: Int) {
        twilioManager.sendSMS(level: level, contactsManager: contactManager)
    }

    private func handleIntoxLevelChange() {
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
