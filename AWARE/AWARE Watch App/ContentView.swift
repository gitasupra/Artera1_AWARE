// ContentView.swift
import SwiftUI
import CoreMotion
import WatchConnectivity

// Create a MotionManager class to conform to ObservableObject
class MotionManager: ObservableObject {
    let motion = CMMotionManager()

    init() {
        motion.deviceMotionUpdateInterval = 1.0 / 50.0
        motion.showsDeviceMovementDisplay = true
        motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
    }
}

// WatchConnectivityManager to handle WatchConnectivity
class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var wcSession: WCSession?

    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle session activation completion
    }

//    func sessionDidBecomeInactive(_ session: WCSession) {
//        // Handle session did become inactive
//    }

//    func sessionDidDeactivate(_ session: WCSession) {
//        // Handle session did deactivate
//        wcSession?.activate()
//    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle received message from Watch
    }

    // Implement WCSessionDelegate methods if needed
    // ...
}

struct ContentView: View {
    @State private var enableDataCollection: Bool = false
    @State private var shouldHide: Bool = false
    @ObservedObject private var motion = MotionManager()
    @StateObject private var watchConnectivityManager = WatchConnectivityManager()

    var body: some View {
        NavigationView {
            TabView {
                // Page 1
                Page1View()
                    .tabItem {
                        Label("AWARE", systemImage: "person.circle.fill")
                    }

                // Page 2
                Page2View(enableDataCollection: $enableDataCollection, shouldHide: $shouldHide, motion: motion, watchConnectivityManager: watchConnectivityManager)
                    .tabItem {
                        Label("Page 2", systemImage: "info.circle")
                    }
            }
            .navigationTitle("AWARE App")
        }
        .onAppear {
            watchConnectivityManager.setupWatchConnectivity()
        }
    }
}

struct Page1View: View {
    var body: some View {
        VStack {
            Text("AWARE")
                .font(.largeTitle)
                .padding()
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.gray)
                .padding()
        }
    }
}

struct Page2View: View {
    @Binding var enableDataCollection: Bool
    @Binding var shouldHide: Bool
    @ObservedObject var motion: MotionManager
    @ObservedObject var watchConnectivityManager: WatchConnectivityManager

    var body: some View {
        VStack {
            if enableDataCollection {
                if !shouldHide {
                    Text("Disable Data Collection on your Apple Watch")
                    Button {
                        enableDataCollection.toggle()
                        sendDataToPhone()
                        print(enableDataCollection)
                    } label: {
                        Image(systemName: "touchid")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .background(Color.green)
                            .controlSize(.extraLarge)
                    }
                }
            } else {
                Text("Enable Data Collection on your Apple Watch")
                Button {
                    enableDataCollection.toggle()
                    sendDataToPhone()
                    print(enableDataCollection)
                } label: {
                    Image(systemName: "touchid")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .background(Color.red)
                        .controlSize(.extraLarge)
                }
            }
        }
        .onChange(of: enableDataCollection)
        {
            sendDataToPhone()

            if enableDataCollection {
                startDeviceMotion()
            } else {
                motion.motion.stopDeviceMotionUpdates()
            }
        }
    }

    func sendDataToPhone() {
        guard watchConnectivityManager.wcSession?.isReachable == true else {
            print("Phone is not reachable")
            return
        }

        let dataToSend: [String: Any] = [
            "enableDataCollection": enableDataCollection
            // Add other data you want to send...
        ]

        watchConnectivityManager.wcSession?.transferUserInfo(dataToSend)
    }

    func startDeviceMotion() {
        if motion.motion.isDeviceMotionAvailable {
            motion.motion.deviceMotionUpdateInterval = 1.0 / 50.0
            motion.motion.showsDeviceMovementDisplay = true
            motion.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)

            let timer = Timer(fire: Date(), interval: (1.0 / 50.0), repeats: true) { timer in
                if let data = motion.motion.deviceMotion {
                    let attitudeX = data.attitude.pitch
                    let attitudeY = data.attitude.roll
                    let attitudeZ = data.attitude.yaw
                    let accelerometerX = data.userAcceleration.x
                    let accelerometerY = data.userAcceleration.y
                    let accelerometerZ = data.userAcceleration.z
                    let gyroX = data.rotationRate.x
                    let gyroY = data.rotationRate.y
                    let gyroZ = data.rotationRate.z

                    print("Attitude x: ", attitudeX)
                    print("Attitude y: ", attitudeY)
                    print("Attitude z: ", attitudeZ)
                    print("Accelerometer x: ", accelerometerX)
                    print("Accelerometer y: ", accelerometerY)
                    print("Accelerometer z: ", accelerometerZ)
                    print("Rotation x: ", gyroX)
                    print("Rotation y: ", gyroY)
                    print("Rotation z: ", gyroZ)
                }
            }

            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        }
    }
}
