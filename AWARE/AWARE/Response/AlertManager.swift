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

    
class AlertManager: ObservableObject {
    public let contactManager = ContactsManager()
    public let twilioManager = TwilioSMSManager()
    
    @Published var intoxLevel = 0
    
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
