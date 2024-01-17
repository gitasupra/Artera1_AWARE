//
//  TwilioSMSManager.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/16/24.
//

import Foundation
import Alamofire 

class TwilioSMSManager {
    func sendSMS(_ phoneNumberArr: [String]) {
        if let accountSID = ProcessInfo.processInfo.environment["TWILIO_ACCOUNT_SID"],
           let authToken = ProcessInfo.processInfo.environment["TWILIO_AUTH_TOKEN"] {

          let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
        
            for phoneNumber in phoneNumberArr {
                let parameters = ["From": "+18667644137", "To": "\(phoneNumber)", "Body": "Hello from AWARE!"]

                AF.request(url, method: .post, parameters: parameters)
                  .authenticate(username: accountSID, password: authToken)
                  .responseDecodable(of:String.self) { response in
                    debugPrint(response)
                }
            }
    
          RunLoop.main.run()
        }
        else {
            debugPrint("ERROR: Unable to get TWILIO_ACCOUNT_SID or TWILIO_AUTH_TOKEN from environment variables")
        }
    }
}
