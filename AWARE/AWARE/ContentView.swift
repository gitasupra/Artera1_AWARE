import SwiftUI
import HealthKit
import CoreMotion
import WatchConnectivity  // Import WatchConnectivity



struct ContentView: View {
    @AppStorage("enableDataCollection", store: UserDefaults(suiteName: "artera.aware.shared")) var enableDataCollection: Bool = false

    @State private var shouldHide = false

    // setting toggles
    @State private var name = ""
    @State private var isNotificationEnabled = true
    @State private var isContactListEnabled = true
    @State private var isUberEnabled = false
    @State private var isEmergencyContacts = false
    @State private var isHelpTipsEnabled = true
    
    // Declare WatchConnectivity properties
       @StateObject private var watchConnectivityManager = WatchConnectivityManager()
    
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
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            // Page 2 Graphs
            NavigationView {
                VStack(alignment: .center) {
                    Text("Graphs")
                        .font(.system(size: 36))
                    
                    NavigationLink(destination: Text("Heart Rate Data")) {
                        Button("View Heart Rate Data") {
                            sendDataToWatch()  // Send data to Watch
                        }
                    }
                    
                    NavigationLink(destination: Text("Breathing Rate Data")) {
                        Button("View Breathing Rate Data") {
                            sendDataToWatch()  // Send data to Watch
                        }
                        
            
                    }
                    
                    NavigationLink(destination: Text("Walking Steadiness Data")) {
                        Button("View Walking Steadiness Data") {
                            sendDataToWatch()  // Send data to Watch

                        }
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
        .onAppear {
                   watchConnectivityManager.setupWatchConnectivity()
        }
    }
    
    // Function to send data to Watch
    func sendDataToWatch() {
            guard let wcSession = watchConnectivityManager.wcSession, wcSession.isReachable else {
                print("Watch is not reachable")
                return
            }

            let dataToSend: [String: Any] = [
                "enableDataCollection": enableDataCollection,
                // Add other data you want to send...
            ]

            wcSession.sendMessage(dataToSend, replyHandler: nil, errorHandler: { error in
                print("Error sending message to Watch: \(error.localizedDescription)")
            })
        }
    
  
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
// WatchConnectivityManager class
class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var wcSession: WCSession?

    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
          // Handle session did become inactive
      }

      func sessionDidDeactivate(_ session: WCSession) {
          // Handle session did deactivate
          wcSession?.activate()
      }

      func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
          // Handle session activation completion
      }

      func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
          // Handle received message from Watch
      }

    // Implement WCSessionDelegate methods if needed
    // ...
}


