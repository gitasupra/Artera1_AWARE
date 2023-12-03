import SwiftUI
import CoreMotion
import Charts


struct ContentView: View {
    @EnvironmentObject var motion: CMMotionManager
    @State private var enableDataCollection = false
    @State private var shouldHide = false
    
    // accelerometer data variables
    @State private var acc: [AccelerometerDataPoint] = []
    @State private var time: UInt64 = UInt64(Date().timeIntervalSince1970)
    // setting toggles
    @State private var name = ""
    @State private var isNotificationEnabled = true
    @State private var isContactListEnabled = true
    @State private var isUberEnabled = false
    @State private var isEmergencyContacts = false
    @State private var isHelpTipsEnabled = true
    @State var showChart: Bool = true
    
    // accelerometer data struct
    struct AccelerometerDataPoint: Identifiable {
          let x: Double
          let y: Double
          let z: Double
          var myIndex: Int = 0
          var id: UUID
       }
    // style variables
    let accentColor:Color = .purple
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
            // Page 1 Graphs
            NavigationView {
                VStack(alignment: .center) {
                    Text("Graphs")
                        .font(.system(size: 36))
                    
                    HStack {
                        let daysOfTheWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                        let datesForCurrentWeek = getDatesForCurrentWeek()
                        let currentDay = Calendar.current.component(.day, from: Date())
                        
                        ForEach(Array(daysOfTheWeek.enumerated()), id: \.element) { index, element in
                            VStack {
                                Text(element)
                                    .padding(10)
                                    .foregroundColor(.gray)
                                    .cornerRadius(8)
                                
                                let dayOnly = Int(datesForCurrentWeek[index].components(separatedBy: " ")[1])
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
                        Spacer()
                    
                    NavigationStack {
                        VStack {
                            Button {
                                showChart = true
                            } label: {
                                Text("View Heart Rate Data")
                            }
                            .navigationDestination(
                                isPresented: $showChart) {
                                    accelerometerGraph(acc: acc)
                            }
                            .buttonStyle(CustomButtonStyle())
                            
                            Button {
                                showChart = true
                            } label: {
                                Text("View Breathing Rate Data")
                            }
                            .navigationDestination(
                                isPresented: $showChart) {
                                    accelerometerGraph(acc: acc)
                            }
                            .buttonStyle(CustomButtonStyle())
                            
                            Button {
                                showChart = true
                            } label: {
                                Text("View Walking Steadiness Data")
                            }
                            .navigationDestination(
                                isPresented: $showChart) {
                                    accelerometerGraph(acc: acc)
                            }
                            .buttonStyle(CustomButtonStyle())
                        }
                    }
                }
            }
            .tabItem {
                Label("Graphs", systemImage: "chart.pie.fill")
            }
            
            // Page 3 Contacts
            VStack(alignment: .center) {
                Text("Contacts")
                    .font(.system(size: 36))
                    .multilineTextAlignment(.leading)
                    .padding()
                
                Spacer()
                
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
            
            // Page 3 - Home / Toggle
            VStack(alignment: .center) {
                Text("AWARE")
                    .font(.system(size: 36)) // Adjust the font size for the title
                Image(systemName: "heart.circle")
                    .font(.system(size: 200)) // Adjust the font size to make the image bigger
                    .foregroundColor(accentColor)
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
                                .font(.system(size: 100)) // Adjust the font size for the button image
                                .foregroundColor(.green)
                                .background(Color.white)
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
                            .font(.system(size: 100)) // Adjust the font size for the button image
                            .foregroundColor(.red)
                            .background(Color.white)
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
            }
        }.accentColor(accentColor)
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
    struct accelerometerGraph: View {
        var acc: [AccelerometerDataPoint]
        var body: some View {
            ScrollView {
                VStack {
                    Chart {
                        ForEach(acc) { element in
                            LineMark(x: .value("Date", element.myIndex), y: .value("x", element.x))
                                .foregroundStyle(by: .value("x", "x"))
                            LineMark(x: .value("Date", element.myIndex), y: .value("y", element.y))
                                .foregroundStyle(by: .value("y", "y"))
                            LineMark(x: .value("Date", element.myIndex), y: .value("z", element.z))
                                .foregroundStyle(by: .value("z", "z"))
                        }
                    }
                    .chartScrollableAxes(.horizontal)
                    .chartXVisibleDomain(length: 50)
                    .padding()
                }
            }
        }
    }
    func startDeviceMotion() {
            var idx = 0
            
            if motion.isDeviceMotionAvailable {
                self.motion.deviceMotionUpdateInterval = 1.0/50.0
                self.motion.showsDeviceMovementDisplay = true
                self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
                
                // Configure a timer to fetch the device motion data
                let timer = Timer(fire: Date(), interval: (1.0/50.0), repeats: true,
                                   block: { (timer) in
                    if let data = self.motion.deviceMotion {
                        // Get attitude data
                        let attitude = data.attitude
                        // Get accelerometer data
                        let accelerometer = data.userAcceleration
                        // Get the gyroscope data
                        let gyro = data.rotationRate
                        idx += 1
                        
                        let new:AccelerometerDataPoint = AccelerometerDataPoint(x: Double(accelerometer.x), y: Double(accelerometer.y), z: Double(accelerometer.z), myIndex: idx, id: UUID())
                                    
                        acc.append(new)
                        print("Attitude x: ", attitude.pitch)
                        print("Attitude y: ", attitude.roll)
                        print("Attitude z: ", attitude.yaw)
                        print("Accelerometer x: ", accelerometer.x)
                        print("Accelerometer y: ", accelerometer.y)
                        print("Accelerometer z: ", accelerometer.z)
                        print("Rotation x: ", gyro.x)
                        print("Rotation y: ", gyro.y)
                        print("Rotation z: ", gyro.z)
                        print(acc)
                    }
                })
                
                // Add the timer to the current run loop
                RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
            }
            
        }
}
