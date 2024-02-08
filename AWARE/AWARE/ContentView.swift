import SwiftUI
import HealthKit
import CoreMotion
import Charts
import Firebase
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseDatabase
import CoreML

struct viewDidLoadModifier: ViewModifier{
    @State private var didLoad = false
    private let action: (() -> Void)?
    
    init(perform action: (() -> Void)? = nil){
        self.action = action
    }
    
    func body(content: Content) -> some View{
        content.onAppear{
            if didLoad == false{
                didLoad=true
                action?()
            }
        }
    }
}

extension View{
    func onLoad(perform action: (() -> Void)? = nil) -> some View{
        modifier(viewDidLoadModifier(perform: action))
    }
}


struct ContentView: View {
    
    @EnvironmentObject var motion: CMMotionManager
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var enableDataCollectionObj = EnableDataCollection()
    @State private var enableDataCollection = false
    @State private var shouldHide = false
    
    // setting toggles
    @State private var name = ""
    @State private var isNotificationEnabled = true
    @State private var isContactListEnabled = true
    @State private var isUberEnabled = false
    @State private var isEmergencyContacts = false
    @State private var isHelpTipsEnabled = true
    @State var showAccChart: Bool = true
    
    // accelerometer data variables
    @State private var acc: [AccelerometerDataPoint] = []
    @State private var accIdx: Int = 0
    
    @State private var windowData: [AccelerometerDataPoint] = []
    
    //FIXME not sure about type here, just want helper methods
    private var predictLevel = PredictLevel.init()
    let windowFile : String = "window_data.csv"
    

    
    // accelerometer data struct
    struct AccelerometerDataPoint: Identifiable {
        let timestamp: Int64
        let x: Double
        let y: Double
        let z: Double
        var myIndex: Int = 0
        var id: UUID
    }
    
    // database
    //FIXME may be loading DB every time, ideally in .onload
    let ref=Database.database().reference()

    
    
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
        Group{
            if viewModel.userSession != nil{
            TabView {
            // Page 1 Graphs
            NavigationView {
                VStack(alignment: .center) {
                    Text("Graphs")
                        .font(.system(size: 36))
                    NavigationStack {
                        VStack {
                            Button {
                                //showHeartChart = true
                            } label: {
                                Text("View Heart Rate Data")
                            }
                            .navigationDestination(
                                isPresented: $showAccChart) {
                                    accelerometerGraph(acc: acc)
                                }
                                .buttonStyle(CustomButtonStyle())
                            
                            Button {
                                showAccChart = true
                            } label: {
                                Text("View Breathing Rate Data")
                            }
                            .navigationDestination(
                                isPresented: $showAccChart) {
                                    accelerometerGraph(acc: acc)
                                }
                                .buttonStyle(CustomButtonStyle())
                            
                            Button {
                                showAccChart = true
                            } label: {
                                Text("View Walking Steadiness Data")
                            }
                            .navigationDestination(
                                isPresented: $showAccChart) {
                                    accelerometerGraph(acc: acc)
                                }
                                .buttonStyle(CustomButtonStyle())
                        }
                    }
                }
            }.onLoad{
                //used to test db write
                //self.ref.child("users").child("1").setValue(["username": "test3"])
            }
            .tabItem {
                Label("Graphs", systemImage: "chart.pie.fill")
            }
            
            // Page 3 Contacts
                VStack(alignment: .center) {
                    NavigationStack {
                        Text("Contacts")
                            .font(.system(size: 36))
                            .multilineTextAlignment(.leading)
                            .padding()
                        
                        Spacer()
                        
                        Button(action: {}) {
                            NavigationLink(destination: ContactListView()) {
                                Text("Contact List")
                            }
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
                    }
                    
                    Spacer()
                }
                .tabItem {
                    Label("Contacts", systemImage: "person.crop.circle")
                }
            
            // Page 3 - Home / Toggle
            VStack(alignment: .center) {
                Spacer()
                Image("testlogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 100)
                Image("testicon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                
                Spacer()
                
                if (enableDataCollectionObj.enableDataCollection == 0) {
                    if !self.$shouldHide.wrappedValue {
                        Button(action: {
                                enableDataCollectionObj.toggleOn()
                                enableDataCollection.toggle()
                            }) {
                                Image(systemName: "touchid")
                                    .font(.system(size: 100))
                                    .foregroundColor(.red)
                                    .controlSize(.extraLarge)
                            }.padding()
                            Text("Enable Data Collection")
                            Spacer()
                        }
                    } else {
                        Button(action: {
                                enableDataCollectionObj.toggleOff()
                                enableDataCollection.toggle()
                            }) {
                                Image(systemName: "touchid")
                                    .font(.system(size: 100))
                                    .foregroundColor(.green)
                                    .controlSize(.extraLarge)
                            }.padding()
                        Text("Disable Data Collection")
                        Spacer()
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
                        
                        Spacer()
                        
                        VStack {
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
                                            .font(.system(size: 12))
                                        
                                        let dayOnly = Int(datesForCurrentWeek[index].components(separatedBy: " ")[1])
                                        Text(datesForCurrentWeek[index].components(separatedBy: " ")[1])
                                            .padding(10)
                                            .background(currentDay == dayOnly ? Color.accentColor : backgroundColor)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                            .font(.system(size: 15))
                                    }
                                }
                            }
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                        }
                        
                        LocationView()
                        
                        
                        NavigationLink(destination: Text("View Past Data")) {
                            Button("View Past Data") {}
                                .buttonStyle(CustomButtonStyle())
                        }
                        
                        Spacer()
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
                        
                        Section {
                            Button("Log out") {
                                viewModel.signOut()
                            }
                        }.tint(.red)
                    }
                    .navigationBarTitle(Text("Settings"))
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }.accentColor(accentColor)
        }
            
            else{
                LoginView()
            }
        }.preferredColorScheme(.dark)
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
        //var idx = 0
        var windowFileURL : String = ""
        var processedURL : String = ""
        
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
                    
                    let timestampInMilliseconds = Int64(Date().timeIntervalSince1970 * 1000)

                    
                    let new: AccelerometerDataPoint = AccelerometerDataPoint(timestamp: timestampInMilliseconds, x: Double(accelerometer.x), y: Double(accelerometer.y), z: Double(accelerometer.z), myIndex: accIdx, id: UUID())

                    
                    acc.append(new)
                    windowData.append(new)
                    
                    //FIXME this might get messed up by start/stop data collection, timer might be better
                    //FIXME corner cases where stop in middle of window, don't want prediction made on walking windows that are not continuous
                    if (accIdx > 0 ) && (accIdx % 500 == 0){
                        //At multiple of (data points per second) * 10 seconds
                        windowFileURL = writeAccDataToCSV(data: windowData)!
                        print(windowFileURL)
                        processedURL = predictLevel.processData(pidFilename: windowFileURL)
                        //FIXME call prediction func here
                    }
                        
                        
                    accIdx += 1

                    
                }
                
                
            })
            
            // Add the timer to the current run loop
            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        }
        
    }
    
    func writeAccDataToCSV(data: [AccelerometerDataPoint]) -> String? {
        // Create a CSV string header
        var csvString = "time,x,y,z\n"
        
        // Append each data point to the CSV string
        for dataPoint in data {
            let timestamp = dataPoint.timestamp
            let x = dataPoint.x
            let y = dataPoint.y
            let z = dataPoint.z
            csvString.append("\(timestamp),\(x),\(y),\(z)\n")
        }
        
        // Create a file URL for saving the CSV file
        let fileName = windowFile
        guard let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName) else {
            print("Failed to create file URL")
            return nil
        }
        
        // Write the CSV string to the file
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV file saved successfully")
            return fileURL.path
        } catch {
            print("Error writing CSV file: \(error)")
            return nil
        }
    }
    func predictFromFile(inputFilename: String){
        do{
            let config=MLModelConfiguration()
            let model = try alcohol_time_3(configuration:config)
            
            
            // Load data from the file
            guard let fileURL = URL(string: inputFilename) else {
                print("Invalid file URL.")
                return
            }
            let inputData = try Data(contentsOf: fileURL)
            
            // Perform prediction using the model
            let input = try alcohol_time_3Input(data: inputData)
            let prediction = try model.prediction(input: input)
        }
        catch{
            
        }
    }

}
