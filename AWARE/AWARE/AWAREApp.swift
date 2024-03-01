import SwiftUI
import HealthKit
import CoreMotion
import Firebase
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool{
        FirebaseApp.configure()
        Analytics.logEvent("ios_app_launched", parameters: nil)
        return true
    }
}

@main
struct AWAREApp: App {
    //create AuthViewModel once to use for all pages
    @StateObject var viewModel = AuthViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)!,
        ])
        
        let sampleTypesToReadOnly = Set([
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)!,
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
                .environmentObject(viewModel)
                .accentColor(Style.accentColor)
//                .preferredColorScheme(.dark)
        }
    }
}

extension HKHealthStore: ObservableObject{}
extension CMMotionManager: ObservableObject{}
