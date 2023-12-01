import SwiftUI
import HealthKit

@main
struct AWAREApp: App {
    
    private let healthStore: HKHealthStore
    
    init() {
           guard HKHealthStore.isHealthDataAvailable() else {  fatalError("This app requires a device that supports HealthKit") }
           healthStore = HKHealthStore()
           requestHealthkitPermissions()
    }
    
    private func requestHealthkitPermissions() {
        
        let sampleTypesToReadShare = Set([
            //height weight sex (bmi) // Make these Required manual inputs
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,

            HKObjectType.quantityType(forIdentifier: .heartRate)!,
//            HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent)!,
//            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
//            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,

        ])
        
        let sampleTypesToReadOnly = Set([
            //height weight sex (bmi) // Make these Required manual inputs
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
//            HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent)!,
//            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
//            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness)!,
//            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,

        ])
        
        

        
        healthStore.requestAuthorization(toShare: sampleTypesToReadShare, read: sampleTypesToReadOnly) { (success, error) in
            print("Request Authorization -- Success: ", success, " Error: ", error ?? "nil")
        }
    }


    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(healthStore)
        }
    }
}


extension HKHealthStore: ObservableObject{}

