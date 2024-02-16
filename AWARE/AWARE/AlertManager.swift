//
//  AlertManager.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/15/24.
//

import SwiftUI
import CoreHaptics

class AlertManager: ObservableObject {
    let contactManager = ContactsManager()
    let twilioManager = TwilioSMSManager()
    @Published var intoxLevel: Int = 0 {
        didSet {
            if intoxLevel == 0 {
                twilioManager.sendSMS(level: 0, contactsManager: contactManager)
            } else if intoxLevel == 1 {
                twilioManager.sendSMS(level: 1, contactsManager: contactManager)
            } else if intoxLevel == 2 {
                twilioManager.sendSMS(level: 2, contactsManager: contactManager)
            } else if intoxLevel == 3 {
                AlertManager.triggerHapticFeedback()
                //twilioManager.sendSMS(level: 3, contactsManager: contactManager)
            }
        }
    }
    
    static func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
