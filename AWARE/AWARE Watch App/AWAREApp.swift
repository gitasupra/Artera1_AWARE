import SwiftUI
import HealthKit
import WatchConnectivity // Import WatchConnectivity

@main
struct AWAREApp: App {
    @StateObject private var healthStoreWrapper = HealthStoreWrapper()
    @StateObject private var watchCoordinator = WatchAppCoordinator() // Add this line

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthStoreWrapper)
                .environmentObject(watchCoordinator) // Add this line
        }
    }
}
