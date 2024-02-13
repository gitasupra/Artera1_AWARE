//
//  AWAREApp.swift
//  AWARE Watch App
//
//  Created by Jessica Lieu on 11/5/23.
//

import SwiftUI
import HealthKit
import CoreMotion

@main
struct AWARE_Watch_AppApp: App {
    private let healthStore: HKHealthStore
    private let motion: CMMotionManager
        
    init() {
        motion = CMMotionManager()
        healthStore = HKHealthStore()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(motion)
                .environmentObject(healthStore)
        }
    }
}

extension CMMotionManager: ObservableObject{}
extension HKHealthStore: ObservableObject{}
