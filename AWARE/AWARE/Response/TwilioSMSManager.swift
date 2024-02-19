//
//  TwilioSMSManager.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/16/24.
//

import Foundation
import Alamofire
import Firebase
import FirebaseAuth

class TwilioSMSManager {
    private var TwilioSID: String = ""
    private var TwilioToken: String = ""
    private var username: String = ""
    
    private var locationManager: LocationManager
    private var latitude: Double
    private var longitude: Double
    
    init() {
        self.locationManager = LocationManager.shared
        self.latitude = self.locationManager.userLocation?.coordinate.latitude ?? 38.898150
        self.longitude = self.locationManager.userLocation?.coordinate.longitude ?? -77.034340
        
        let twilioRef = Database.database().reference().child("twilio_credentials")
        
        // read the data from the "twilio_credentials" in Firebase
        twilioRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("No data available")
                return
            }
            
            // extract account SID and auth token from the snapshot
            if let accountSID = value["account_sid"] as? String,
               let authToken = value["auth_token"] as? String {
                self.TwilioSID = accountSID
                self.TwilioToken = authToken
            } else {
                print("Missing account SID or auth token")
            }
        }) { error in
            print("Error reading data: \(error.localizedDescription)")
        }
        
        if let user = Auth.auth().currentUser {
            self.username = user.displayName ?? ""
        }
    }
    
    func sendSMS(level: Int, contactsManager: ContactsManager) {
        // set different messages based on intoxication level
        var message: String
        if level == 0 {
            message = "AWARE Alert: \(self.username) has added you as an emergency contact. Please stay alert for future updates."
        } else if level == 1 {
            message = "Attention: Our analysis indicates that \(self.username) is tipsy. Please keep an eye out for any changes in their condition. Open Google Maps to view their current location: https://www.google.com/maps/dir/?api=1&destination=\(self.latitude),\(self.longitude)&travelmode=driving"
        } else if level == 2 {
            message = "URGENT: \(self.username) is estimated to have high levels of intoxication. Immediate assistance may be required. Please check in or offer support as needed. Open Google Maps to view their current location: https://www.google.com/maps/dir/?api=1&destination=\(self.latitude),\(self.longitude)&travelmode=driving"
        } else if level == 3 {
            message = "EMERGENCY: \(self.username)'s vital signs indicate a critical condition. Emergency services have been alerted. Please respond immediately. Open Google Maps to view their current location: https://www.google.com/maps/dir/?api=1&destination=\(self.latitude),\(self.longitude)&travelmode=driving"
        } else {
            return
        }
        
        // pull list of phone numbers from user's contact list
        let phoneNumbers = contactsManager.contacts.compactMap { contact -> String? in
            guard let firstCharacter = contact.phone.first else { return nil }
            let processedPhoneNumber = contact.phone.dropFirst().replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            return String(firstCharacter) + processedPhoneNumber
        }
        
        // send SMS to all contacts using Twilio's API
        if !self.TwilioSID.isEmpty && !self.TwilioToken.isEmpty {
            let url = "https://api.twilio.com/2010-04-01/Accounts/\(self.TwilioSID)/Messages"
            
            for phoneNumber in phoneNumbers {
                let parameters = ["From": "+18667644137", "To": "\(phoneNumber)", "Body": message]
                AF.request(url, method: .post, parameters: parameters)
                    .authenticate(username: self.TwilioSID, password: self.TwilioToken)
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            if let xmlString = String(data: data, encoding: .utf8) {
                                debugPrint(xmlString)
                            } else {
                                print("Error converting data to string")
                            }
                        case .failure(let error):
                            print("Request failed with error: \(error.localizedDescription)")
                        }
                    }
            }
        } else {
            debugPrint("ERROR: Unable to get TWILIO_ACCOUNT_SID or TWILIO_AUTH_TOKEN from environment variables")
        }
    }
}

