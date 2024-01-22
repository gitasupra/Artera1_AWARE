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
        guard HKHealthStore.isHealthDataAvailable() else {  fatalError("This app requires a device that supports HealthKit") }
            healthStore = HKHealthStore()
        motion = CMMotionManager()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(healthStore)
            .environmentObject(motion)
        }
    }
}

extension CMMotionManager: ObservableObject{}
extension HKHealthStore: ObservableObject{}
