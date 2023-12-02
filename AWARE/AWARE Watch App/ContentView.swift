import SwiftUI
import CoreMotion
import WatchConnectivity

struct ContentView: View {
    @State private var enableDataCollection = false
    @State private var shouldHide = false

    var body: some View {
        NavigationView {
            TabView {
                // Page 1
                Page1View()
                    .tabItem {
                        Label("AWARE", systemImage: "person.circle.fill")
                    }

                // Page 2
                Page2View(enableDataCollection: $enableDataCollection, shouldHide: $shouldHide)
                    .tabItem {
                        Label("Page 2", systemImage: "info.circle")
                    }
            }
            .navigationTitle("AWARE App")
        }
    }
}

struct Page1View: View {
    let accentColor: Color = .purple

    var body: some View {
        VStack {
            Text("AWARE")
                .font(.largeTitle)
                .padding()
                .offset(y: 15)
            Image(systemName: "heart.circle")
                .font(.system(size: 100))
                .foregroundColor(accentColor)
                .padding()
        }
    }
}

struct Page2View: View {
    @Binding var enableDataCollection: Bool
    @Binding var shouldHide: Bool
    @EnvironmentObject var motion: CMMotionManager

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
                            .foregroundColor(.red)
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
                        .foregroundColor(.green)
                        .controlSize(.extraLarge)
                }
            }
        }
        // Use onChange with two parameters
        .onChange(of: enableDataCollection) { newValue, _ in
            if enableDataCollection {
                startDeviceMotion()
            } else {
                motion.stopDeviceMotionUpdates()
            }
        }
        .onAppear {
            receiveDataFromPhone()
        }
    }

    func startDeviceMotion() {
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0 / 50.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)

            // Configure a timer to fetch the device motion data
            let timer = Timer(fire: Date(), interval: (1.0 / 50.0), repeats: true,
                              block: { (timer) in
                                  if let data = self.motion.deviceMotion {
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
                              })

            // Add the timer to the current run loop
            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        }
    }

    func sendDataToPhone() {
        if WCSession.default.isReachable {
            let message = ["enableDataCollection": enableDataCollection]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending message to phone: \(error)")
            })
        } else {
            print("Phone is not reachable.")
        }
    }

    func receiveDataFromPhone() {
        if WCSession.isSupported() {
            let sessionDelegate = WCSessionDelegateHandler(enableDataCollection: $enableDataCollection)
            WCSession.default.delegate = sessionDelegate
            WCSession.default.activate()
        }
    }
}

// Use NSObject as a superclass
class WCSessionDelegateHandler: NSObject, WCSessionDelegate {
    @Binding var enableDataCollection: Bool

    init(enableDataCollection: Binding<Bool>) {
        _enableDataCollection = enableDataCollection
        super.init()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .notActivated:
            print("WCSession not yet activated.")
        case .inactive:
            print("WCSession is inactive.")
        case .activated:
            print("WCSession activated and ready to send/receive data.")
        @unknown default:
            fatalError("Unexpected WCSession activation state.")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let receivedEnableDataCollection = message["enableDataCollection"] as? Bool {
            DispatchQueue.main.async {
                self.enableDataCollection = receivedEnableDataCollection
                print("Received enableDataCollection from phone: \(self.enableDataCollection)")
            }
        }
    }
}

// ... (unchanged code)

