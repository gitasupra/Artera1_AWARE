//
//  AWAREApp.swift
//  AWARE Watch App
//
//  Created by Jessica Lieu on 11/5/23.
//

import SwiftUI
import HealthKit
import CoreMotion
import WatchConnectivity

@main
struct AWARE_Watch_AppApp: App {
    private let motion: CMMotionManager
        
    init() {
        motion = CMMotionManager()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(motion)
        }
    }
}

extension CMMotionManager: ObservableObject{}
