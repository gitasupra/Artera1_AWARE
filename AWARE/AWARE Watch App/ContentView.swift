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
                .font(.system(size: 100)) // Adjust the font size to make the image bigger
                .foregroundColor(.gray)
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
//            Text("Page 2 Content")
//                .font(.largeTitle)
//                .padding()
            
            if (enableDataCollection) {
                if !shouldHide {
                    Text("Disable Data Collection on your Apple Watch")
                    Button {
                        enableDataCollection.toggle()
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
            if (enableDataCollection) {
                startAccelerometer()
                startGyroscope()
            } else {
                self.motion.stopAccelerometerUpdates()
                self.motion.stopGyroUpdates()
            }
        }
    }
    
    func startAccelerometer() {
            
            
            if motion.isAccelerometerAvailable {
                self.motion.accelerometerUpdateInterval = 1.0 / 50.0
                self.motion.startAccelerometerUpdates()
                
                // Configure a timer to fetch the accelerometer data
                let timer = Timer(fire: Date(), interval: (1.0 / 50.0), repeats: true,
                                   block: { (timer) in
                    if let data = self.motion.accelerometerData {
                        // Get the acceleration data
                        let accelerationX = data.acceleration.x
                        let accelerationY = data.acceleration.y
                        let accelerationZ = data.acceleration.z
                        
                        print("Acceleration x: ", accelerationX)
                        print("Acceleration y: ", accelerationY)
                        print("Acceleration z: ", accelerationZ)
                    }
                })
                
                // Add the timer to the current run loop
                RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
            }
            
        }
    
    func startGyroscope() {
            
            
            if motion.isGyroAvailable {
                self.motion.gyroUpdateInterval = 1.0 / 50.0
                self.motion.startGyroUpdates()
                
                // Configure a timer to fetch the gyroscope data
                let timer = Timer(fire: Date(), interval: (1.0 / 50.0), repeats: true,
                                   block: { (timer) in
                    if let data = self.motion.gyroData {
                        // Get the gyroscope data
                        let gyroX = data.rotationRate.x
                        let gyroY = data.rotationRate.y
                        let gyroZ = data.rotationRate.z
                        
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
