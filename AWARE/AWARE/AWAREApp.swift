import SwiftUI
import HealthKit
import WatchConnectivity // Import WatchConnectivity

class HealthStoreWrapper: ObservableObject {
    private let healthStore: HKHealthStore

    init() {
        self.healthStore = HKHealthStore()
        requestHealthkitPermissions()
        setupWatchConnectivity()
    }

    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            let watchSessionDelegate = WatchSessionDelegate()
            session.delegate = watchSessionDelegate
            session.activate()
        }
    }

    func requestHealthkitPermissions() {
        let sampleTypesToReadShare = Set([
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        ])

        let sampleTypesToReadOnly = Set([
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .appleWalkingSteadiness)!,
            HKObjectType.categoryType(forIdentifier: .shortnessOfBreath)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        ])

        healthStore.requestAuthorization(toShare: sampleTypesToReadShare, read: sampleTypesToReadOnly) { (success, error) in
            print("Request Authorization -- Success: ", success, " Error: ", error ?? "nil")
        }
    }
}

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
          // Implement as needed
      }

      func sessionDidBecomeInactive(_ session: WCSession) {
          // Implement as needed
      }

      func sessionDidDeactivate(_ session: WCSession) {
          // Implement as needed
      }

      func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
          // Implement as needed
      }
}

@main
struct AWAREApp: App {
    @StateObject private var healthStoreWrapper = HealthStoreWrapper()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(healthStoreWrapper)
        }
    }
}

extension HKHealthStore: ObservableObject {}
