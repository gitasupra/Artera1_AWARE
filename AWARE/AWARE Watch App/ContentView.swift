import SwiftUI
import HealthKit
import CoreMotion

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
        }
    }
    
}

struct Page1View: View {
    let accentColor:Color = .purple

    var body: some View {
        VStack {
            Image("AWARE_Logo_2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
        }
    }
}

struct Page2View: View {
    @StateObject var enableDataCollectionObj = EnableDataCollection()
    @Binding var enableDataCollection: Bool
    @Binding var shouldHide: Bool
    @EnvironmentObject var motion: CMMotionManager

    var body: some View {
        VStack {
            if (enableDataCollectionObj.enableDataCollection == 0) {
                if !self.$shouldHide.wrappedValue {
                    Text("Disable Data Collection")
                        .multilineTextAlignment(.center)
                    Button(action: {
                        enableDataCollectionObj.toggleOn()
                        enableDataCollection.toggle()
                    }) {
                        Image(systemName: "touchid")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                        .controlSize(.extraLarge)
                    }
                }
            } else {
                Text("Enable Data Collection")
                    .multilineTextAlignment(.center)
                Button {
                    enableDataCollectionObj.toggleOff()
                    enableDataCollection.toggle()
                } label: {
                    Image(systemName: "touchid")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .controlSize(.extraLarge)
                }
            }
        }
        .onChange(of: enableDataCollection)
        {
            if (enableDataCollection) {
                startDeviceMotion()
            } else {
                self.motion.stopDeviceMotionUpdates()
            }
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
                        // Get attitude data
                        let attitudeX = data.attitude.pitch
                        let attitudeY = data.attitude.roll
                        let attitudeZ = data.attitude.yaw
                        // Get accelerometer data
                        let accelerometerX = data.userAcceleration.x
                        let accelerometerY = data.userAcceleration.y
                        let accelerometerZ = data.userAcceleration.z
                        // Get the gyroscope data
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
}

#Preview{
    ContentView()
}
