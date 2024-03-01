//
//  AlertManager.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/15/24.
//

import SwiftUI
import CoreHaptics

class AlertManager: ObservableObject {
    public let contactManager = ContactsManager()
    public let twilioManager = TwilioSMSManager()
    @Published var intoxLevel: Int = 0 {
        didSet {
            if intoxLevel == 0 {
                sendUpdate(level: 0)
            } else if intoxLevel == 1 {
                sendUpdate(level: 1)
            } else if intoxLevel == 2 {
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
    
    func contactEmergencyServices() {
        twilioManager.text911(contactsManager: contactManager)
    }
}
