import SwiftUI
import HealthKit
import CoreMotion
import CoreLocation

@main
struct AWAREApp: App {
    
    private let healthStore: HKHealthStore
    private let motion: CMMotionManager
    
    init() {
           guard HKHealthStore.isHealthDataAvailable() else {  fatalError("This app requires a device that supports HealthKit") }
           healthStore = HKHealthStore()
           motion = CMMotionManager()
           requestHealthkitPermissions()
    }
    
    private func requestHealthkitPermissions() {
        
        let sampleTypesToReadShare = Set([
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent)!,
//            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
//            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
//            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
//            HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)!,
        ])
        
        let sampleTypesToReadOnly = Set([
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
//            HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent)!,
//            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
//            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness)!,
//            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
//            HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)!,
        ])
        
        healthStore.requestAuthorization(toShare: sampleTypesToReadShare, read: sampleTypesToReadOnly) { (success, error) in
            print("Request Authorization -- Success: ", success, " Error: ", error ?? "nil")
        }
    }


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthStore)
                .environmentObject(motion)

        }
    }
}


extension HKHealthStore: ObservableObject{}
extension CMMotionManager: ObservableObject{}
