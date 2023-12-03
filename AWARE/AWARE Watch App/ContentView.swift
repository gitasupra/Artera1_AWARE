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

struct ContentView: View {
    @State private var enableDataCollection: Bool = false
    @State private var shouldHide: Bool = false
    @ObservedObject private var motion = MotionManager()

    var body: some View {
        NavigationView {
            TabView {
                // Page 1
                Page1View()
                    .tabItem {
                        Label("AWARE", systemImage: "person.circle.fill")
                    }

                // Page 2
                Page2View(enableDataCollection: $enableDataCollection, shouldHide: $shouldHide, motion: motion)
                    .tabItem {
                        Label("Page 2", systemImage: "info.circle")
                    }
            }
            .navigationTitle("AWARE App")
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
        guard WCSession.default.isReachable else {
            print("Phone is not reachable")
            return
        }

        let dataToSend: [String: Any] = [
            "enableDataCollection": enableDataCollection
            // Add other data you want to send...
        ]

        WCSession.default.transferUserInfo(dataToSend)
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
