import SwiftUI
import CoreMotion

struct ContentView: View {
    @EnvironmentObject var motion: CMMotionManager
    @State private var enableDataCollection = false
    @State private var shouldHide = false
    
    // setting toggles
    @State private var name = ""
    @State private var isNotificationEnabled = true
    @State private var isContactListEnabled = true
    @State private var isUberEnabled = false
    @State private var isEmergencyContacts = false
    @State private var isHelpTipsEnabled = true
    
    var body: some View {
        TabView {
            // Page 1 - Home / Toggle
            VStack(alignment: .center) {
                Text("AWARE")
                    .font(.system(size: 36)) // Adjust the font size for the title
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100)) // Adjust the font size to make the image bigger
                    .foregroundColor(.gray)
                    .padding()
                
                if enableDataCollection {
                    if !self.$shouldHide.wrappedValue {
                        Text("Disable Data Collection")
                            .padding()
                        Button {
                            enableDataCollection.toggle()
                            print(enableDataCollection)
                        } label: {
                            Image(systemName: "touchid")
                                .font(.system(size: 50)) // Adjust the font size for the button image
                                .foregroundColor(.white)
                                .background(Color.green)
                                .controlSize(.extraLarge)
                        }
                    }
                } else {
                    Text("Enable Data Collection")
                        .padding()
                    Button {
                        enableDataCollection.toggle()
                        print(enableDataCollection)
                    } label: {
                        Image(systemName: "touchid")
                            .font(.system(size: 50)) // Adjust the font size for the button image
                            .foregroundColor(.white)
                            .background(Color.red)
                            .controlSize(.extraLarge)
                    }
                }
            }
            .onChange(of: enableDataCollection) {
                if (enableDataCollection) {
                    startDeviceMotion()
                } else {
                    self.motion.stopDeviceMotionUpdates()
                }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            // Page 2 Graphs
            NavigationView {
                VStack(alignment: .center) {
                    Text("Graphs")
                        .font(.system(size: 36))
                    
                    NavigationLink(destination: Text("Heart Rate Data")) {
                        Button("View Heart Rate Data") {}
                    }
                    
                    NavigationLink(destination: Text("Breathing Rate Data")) {
                        Button("View Breathing Rate Data") {}
                    }
                    
                    NavigationLink(destination: Text("Walking Steadiness Data")) {
                        Button("View Walking Steadiness Data") {}
                    }
                }
            }
            .tabItem {
                Label("Graphs", systemImage: "chart.pie.fill")
            }
            
            // Page 3 User
            VStack(alignment: .center) {
                Text("User")
                    .font(.system(size: 36))
            }
            .tabItem {
                Label("User", systemImage: "person.crop.circle")
            }
            
            // Page 4 Today
            NavigationView {
                VStack(alignment: .center) {
                    Text("Today")
                        .font(.system(size: 36))
                    
                    NavigationLink(destination: Text("Past Holistic Drunkenness Data Collection")) {
                        Button("View Past Holistic Drunkenness Data Collection") {}
                    }
                }
            }
            .tabItem {
                Label("Today", systemImage: "calendar")
            }
            
            // Page 5 Settings
            NavigationView {
                Form {
                    Section(header: Text("User Profile")) {
                        TextField("Name", text: $name).disableAutocorrection(true)
                    }
                    
                    Section(header: Text("Contacts")) {
                        Toggle(isOn: $isContactListEnabled) {
                            Text("Enable contact list")
                            Text("Contact others when intoxicated")
                        }
                        Toggle(isOn: $isUberEnabled) {
                            Text("Enable Uber")
                            Text("Open the Uber app when driving impaired")
                        }
                        Toggle(isOn: $isEmergencyContacts) {
                            Text("Enable emergency services")
                            Text("Call 911 in case of extreme emergencies")
                        }
                    }

                    Section(header: Text("Notifications")) {
                        Toggle(isOn: $isNotificationEnabled) {
                            Text("Allow notifications")
                            Text("Receive updates on your intoxication level")
                        }
                    }
                    
                    Section(header: Text("Miscellaneous")) {
                        Toggle(isOn: $isHelpTipsEnabled) {
                            Text("Enable help tips")
                            Text("Receive tips on drinking safely")
                        }
                    }

                    Section {
                        Button("Reset to default") {
                            isNotificationEnabled = true
                            isContactListEnabled = true
                            isUberEnabled = false
                            isEmergencyContacts = false
                            isHelpTipsEnabled = true
                        }
                    }
                }
                .navigationBarTitle(Text("Settings"))
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
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
