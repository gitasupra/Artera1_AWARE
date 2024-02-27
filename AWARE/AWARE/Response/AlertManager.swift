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
import Alamofire


//struct CSVFileRead {
//    let csvFile: CSV
//}


struct APIResponse: Codable {
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
    guard let url = URL(string: "https://jessicalieu.pythonanywhere.com/uploadCSV") else {
        print("Invalid URL")
        completion(-1)
        return
    }

    guard let fileURL = Bundle.main.url(forResource: accData, withExtension: "csv") else {
        print("CSV file not found.")
        completion(-2)
        return
    }
    
    
    // Create URLRequest
    // Create URLRequest with error handling
    do {
        var urlRequest = try URLRequest(url: url, method: .post)
        
        // Set custom timeout interval (e.g., 60 seconds)
        urlRequest.timeoutInterval = 60
        
        // Upload request with custom timeout
        AF.upload(
            multipartFormData: { multipartFormData in
                // Append the CSV file to the multipart form data
                multipartFormData.append(fileURL, withName: "file", fileName: "uploaded_file.csv", mimeType: "text/csv")
            },
            with: urlRequest // Use the custom URLRequest
        )
        .uploadProgress { progress in
            // Handle upload progress if needed
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .responseDecodable(of: APIResponse.self) { response in
            switch response.result {
            case .success(let value):
                // Handle successful response
                print("Parsed Response: \(value)")
                // You can access response properties directly using value.key1, value.key2, etc.
                completion(0) // or pass appropriate success code
            case .failure(let error):
                // Handle error
                print("Upload failed: \(error)")
                completion(-3) // or pass appropriate error code
            }
        }
    } catch {
        // Handle URLRequest creation error
        print("Error creating URLRequest: \(error)")
        completion(-4) // or pass appropriate error code
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
