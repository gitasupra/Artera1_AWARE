import SwiftUI
import CoreMotion
import Charts
import WatchConnectivity


class WatchSessionDelegate: NSObject, WCSessionDelegate {
    var contentView: ContentView?
    var enableDataCollectionBinding: Binding<Bool>?
    var receiveDataClosure: (() -> Void)?

    init(enableDataCollection: Binding<Bool>) {
        self.enableDataCollectionBinding = enableDataCollection
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
                self.enableDataCollectionBinding?.wrappedValue = receivedEnableDataCollection
                print("Received enableDataCollection from watch: \(receivedEnableDataCollection)")
            }
        }
    }
    
    func sendDataToWatch() {
        // Implement your logic to send data to the watch
        // Example: use WCSession.default.sendMessage
    }
    
    func receiveDataFromWatch() {
        // Implement your logic to send data to the watch
        // Example: use WCSession.default.sendMessage
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation
    }
}

class EnableDataCollectionObservable: ObservableObject {
    @Published var enableDataCollection: Bool = false
}

struct ContentView: View {
    @EnvironmentObject var motion: CMMotionManager
    @StateObject private var enableDataCollectionObservable = EnableDataCollectionObservable()
    @State private var shouldHide = false
    
    // setting toggles
    @State private var name = ""
    @State private var isNotificationEnabled = true
    @State private var isContactListEnabled = true
    @State private var isUberEnabled = false
    @State private var isEmergencyContacts = false
    @State private var isHelpTipsEnabled = true
    
    var watchSessionDelegate: WatchSessionDelegate?
    
    func setupWatchDelegate() {
        watchSessionDelegate?.receiveDataClosure = {
            // Call any function in ContentView when data is received from the watch
            print("Data received from watch!")
        }
    }
    
    func sendDataToWatch() {
        if WCSession.default.isReachable {
            print("WC Session Reachable")
            let message = ["enableDataCollection": enableDataCollectionObservable.enableDataCollection]
            WCSession.default.sendMessage(message, replyHandler: { response in
                print("Successfully sent message to watch. Response: \(response)")
            }, errorHandler: { error in
                print("Error sending message to watch: \(error)")
            })
        } else {
            print("Watch is not reachable.")
        }
    }

    mutating func receiveDataFromWatch() {
        print("Receiving data from watch...")
        if WCSession.isSupported() {
            // Check if the delegate is already set
            if watchSessionDelegate == nil {
                watchSessionDelegate = WatchSessionDelegate(enableDataCollection: $enableDataCollectionObservable.enableDataCollection)
                WCSession.default.delegate = watchSessionDelegate
                WCSession.default.activate()
                while WCSession.default.activationState != .activated {
                    WCSession.default.activate()
                    print("activate again")
                }
                
                print("Watch session activated.")
            }
        } else {
            print("Watch session is not supported.")
        }
    }
    
    // style variables
    let accentColor:Color = .purple
    let backgroundColor:Color = .black
    struct CustomButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
                .padding([.top, .bottom], 2)
        }
    }
    
    func getDatesForCurrentWeek() -> [String] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let lastSunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM'\u{2028}' d"
        
        return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: lastSunday)! }
            .map {formatter.string(from: $0)}
    }
    
    var body: some View {
        TabView {
            // Page 1: Graphs
            NavigationView {
                VStack(alignment: .center) {
                    Text("Graphs")
                        .font(.system(size: 36))
                    
                    // Display days of the week and dates for the current week
                    HStack {
                        let daysOfTheWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                        let datesForCurrentWeek = getDatesForCurrentWeek()
                        let currentDay = Calendar.current.component(.day, from: Date())
                        
                        // Iterate through days of the week
                        ForEach(Array(daysOfTheWeek.enumerated()), id: \.element) { index, element in
                            VStack {
                                Text(element)
                                    .padding(10)
                                    .foregroundColor(.gray)
                                    .cornerRadius(8)
                                
                                // Extract day only from the date
                                let dayOnly = Int(datesForCurrentWeek[index].components(separatedBy: " ")[1])
                                
                                // Display date with background color indicating the current day
                                Text(datesForCurrentWeek[index])
                                    .padding(10)
                                    .background(currentDay == dayOnly ? Color.accentColor : Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.accentColor, lineWidth: 1)
                    )
                    .padding([.top, .bottom], 2)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.accentColor, lineWidth: 1)
                    )
                    .padding([.top, .bottom], 2)
                    
                    Spacer()
                    
                    // Navigation links to different data views
                    NavigationLink(destination: Text("Heart Rate Data")) {
                        Button("View Heart Rate Data") {}
                            .buttonStyle(CustomButtonStyle())
                    }
                    
                    NavigationLink(destination: Text("Breathing Rate Data")) {
                        Button("View Breathing Rate Data") {}
                            .buttonStyle(CustomButtonStyle())
                    }
                    
                    NavigationLink(destination: Text("Walking Steadiness Data")) {
                        Button("View Walking Steadiness Data") {}
                            .buttonStyle(CustomButtonStyle())
                    }
                }
            }
            .tabItem {
                Label("Graphs", systemImage: "chart.pie.fill")
            }

            // Page 2: Contacts
            VStack(alignment: .center) {
                Text("Contacts")
                    .font(.system(size: 36))
                    .multilineTextAlignment(.leading)
                    .padding()
                
                Spacer()
                
                // Navigation links to different contact actions
                NavigationLink(destination: Text("Contact List")) {
                    Button("Edit Contact List") {}
                        .buttonStyle(CustomButtonStyle())
                }
                
                NavigationLink(destination: Text("Call Uber")) {
                    Button("Call Uber") {}
                        .buttonStyle(CustomButtonStyle())
                }
                
                NavigationLink(destination: Text("Call 911")) {
                    Button("Call Emergency Services") {}
                        .buttonStyle(CustomButtonStyle())
                }
                
                Spacer()
            }
            .tabItem {
                Label("Contacts", systemImage: "person.crop.circle")
            }

            // Page 3: Home / Toggle
            VStack(alignment: .center) {
                Text("AWARE")
                    .font(.system(size: 36))
                
                Image(systemName: "heart.circle")
                    .font(.system(size: 200))
                    .foregroundColor(enableDataCollectionObservable.enableDataCollection ? .green : .red)
                    .padding()
                
                if enableDataCollectionObservable.enableDataCollection {
                    if !shouldHide {
                        Text("Disable Data Collection")
                            .padding()
                        Button {
                            enableDataCollectionObservable.enableDataCollection.toggle()
                            sendDataToWatch()
                            print(enableDataCollectionObservable.enableDataCollection)
                        } label: {
                            Image(systemName: "touchid")
                                .font(.system(size: 100))
                                .foregroundColor(.green)
                                .background(Color.white)
                                .controlSize(.extraLarge)
                        }
                    }
                } else {
                    Text("Enable Data Collection")
                        .padding()
                    Button {
                        enableDataCollectionObservable.enableDataCollection.toggle()
                        sendDataToWatch()
                        print(enableDataCollectionObservable.enableDataCollection)
                    } label: {
                        Image(systemName: "touchid")
                            .font(.system(size: 100))
                            .foregroundColor(.red)
                            .background(Color.white)
                            .controlSize(.extraLarge)
                    }
                }
            }
            .onChange(of: enableDataCollectionObservable.enableDataCollection) { newValue in
                if enableDataCollectionObservable.enableDataCollection {
                    startDeviceMotion()
                } else {
                    motion.stopDeviceMotionUpdates()
                }
            }
            .onAppear {
                if let watchSessionDelegate = watchSessionDelegate {
                    print("watchSessionDelegate created")
                    watchSessionDelegate.enableDataCollectionBinding = Binding {
                        enableDataCollectionObservable.enableDataCollection
                    } set: { newValue in
                        enableDataCollectionObservable.enableDataCollection = newValue
                        sendDataToWatch()
                    }

                    // Setup closure to be called when data is received from the watch
                    setupWatchDelegate()

                    // Receive data from the watch
                    watchSessionDelegate.receiveDataFromWatch()
                }
                else if !WCSession.isSupported() {
                    print("Watch Connectivity is not supported.")
                }
                else if WCSession.default.activationState != .activated {
                    print("WCSession is not yet activated. Current activation state: \(WCSession.default.activationState.rawValue)")
                }
                else if watchSessionDelegate == nil {
                    print("Watch session delegate does not exist.")
                }
                else {
                    print("Issue creating watchSessionDelegate")
                }
            }
            .environmentObject(enableDataCollectionObservable)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
                    
            // Page 4 Analytics
            NavigationView {
                VStack(alignment: .center) {
                    Text("Analytics")
                        .font(.system(size: 36))
                    
                    NavigationLink(destination: Text("Past Holistic Drunkenness Data Collection")) {
                        Button("View Past Holistic Drunkenness Data Collection") {}
                            .buttonStyle(CustomButtonStyle())
                    }
                }
            }
            .tabItem {
                Label("Analytics", systemImage: "heart.text.square")
            }
            
            // Page 5 Settings
            NavigationView {
                Form {
                    Section(header: Text("User Profile")) {
                        TextField("Name", text: $name).disableAutocorrection(true)
                    }.tint(accentColor)
                    
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
                    }.tint(accentColor)

                    Section(header: Text("Notifications")) {
                        Toggle(isOn: $isNotificationEnabled) {
                            Text("Allow notifications")
                            Text("Receive updates on your intoxication level")
                        }
                    }.tint(accentColor)
                    
                    Section(header: Text("Miscellaneous")) {
                        Toggle(isOn: $isHelpTipsEnabled) {
                            Text("Enable help tips")
                            Text("Receive tips on drinking safely")
                        }
                    }.tint(accentColor)

                    Section {
                        Button("Reset to default") {
                            isNotificationEnabled = true
                            isContactListEnabled = true
                            isUberEnabled = false
                            isEmergencyContacts = false
                            isHelpTipsEnabled = true
                        }
                    }.tint(accentColor)
                }
                .navigationBarTitle(Text("Settings"))
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }.background(backgroundColor)
        }.accentColor(accentColor)
            
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
        else{
            print("Device motion not available")
        }
        }
}
