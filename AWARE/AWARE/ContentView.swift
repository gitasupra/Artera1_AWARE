import SwiftUI
import HealthKit
import CoreMotion
import CoreML
import Charts
import Firebase
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseDatabase
import SwiftCSV
//import UberRides

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
    
    //accelerometer 10-second window data variables
    @State private var windowAccData: [AccelerometerDataPoint] = []
    @State private var windowFile: String = "window_data.csv"
    @State private var windowFileURL: String = ""
    
    @State private var inputFunctions = InputFunctions()
    
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
                            inputFunctions.processData(windowFile: "BK7610.csv")
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
        
        if motion.isDeviceMotionAvailable {
            //Bar Crawl dataset sampled at 40Hz
            self.motion.deviceMotionUpdateInterval = 1.0/40.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            // Configure a timer to fetch the device motion data
            let timer = Timer(fire: Date(), interval: (1.0/40.0), repeats: true,
                                block: { (timer) in
                if let data = self.motion.deviceMotion {
                    // Get attitude data
                    let attitude = data.attitude
                    // Get accelerometer data
                    let accelerometer = data.userAcceleration
                    // Get the gyroscope data
                    let gyro = data.rotationRate
                    
                    let timestampInMilliseconds = Int64(Date().timeIntervalSince1970 * 1000)
                    
                    
                    
                    let new:AccelerometerDataPoint = AccelerometerDataPoint(timestamp: timestampInMilliseconds, x: Double(accelerometer.x), y: Double(accelerometer.y), z: Double(accelerometer.z), myIndex: accIdx, id: UUID())
                    
                    acc.append(new)
                    windowAccData.append(new)
                    
                    //FIXME this might get messed up by start/stop data collection, timer might be better to trigger saving to CSV function
                    //ex: corner cases where stop in middle of window, don't want prediction made on walking windows that are not continuous
                    
                    if (accIdx > 0 ) && (accIdx % 400 == 0){
                        //At multiple of (data points per second) * 10 seconds
                        windowFileURL = writeAccDataToCSV(data: windowAccData)!
                        print("Window data saved to: \(windowFileURL)")
                        
                        inputFunctions.processData(windowFile: windowFileURL)
                        
                        //reset window data array
                        windowAccData=[]
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
        
//        if let firstTimestamp = data.first?.timestamp,
//            let lastTimestamp = data.last?.timestamp {
//             print("First timestamp: \(firstTimestamp), Last timestamp: \(lastTimestamp)")
//         }

        // Create a file URL for saving the CSV file
        let fileName = windowFile
        guard let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName) else {
            print("Failed to create file URL")
            return nil
        }

        // Write the CSV string to the file
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
//            print("CSV file saved successfully")
            return fileURL.path
        } catch {
            print("Error writing CSV file: \(error)")
            return nil
        }
    }

//    func predictLevel() {
//        do{
//            let config = MLModelConfiguration()
//            let model = try alcohol(configuration: config)
//            
//            // Read the processed CSV file using SwiftCSV
//            
//            let csvFile = try CSV<Named>(url: URL(fileURLWithPath: file))
//                
//            for row in csvFile:
//            let csvFeatureProvider = try MLDictionaryFeatureProvider(dictionary:
//                ["0xMe": Double(row["0xMe"]!)!, "0xVr": Double(row["0xVr"]!)!, "0xMx": Double(row["0xMx"]!)!, "0xMi": Double(row["0xMi"]!)!, "0xUM": Double(row["0xUM"]!)!, "0xLM": Double(row["0xLM"]!)!, "0yMe": Double(row["0yMe"]!)!, "0yVr": Double(row["0yVr"]!)!, "0yMx": Double(row["0yMx"]!)!, "0yMn": Double(row["0yMn"]!)!, "0yUM": Double(row["0yUM"]!)!, "0yLM": Double(row["0yLM"]!)!, "0zMe": Double(row["0zMe"]!)!, "0zVr": Double(row["0zVr"]!)!, "0zMx": Double(row["0zMx"]!)!, "0zMi": Double(row["0zMi"]!)!, "0zUM": Double(row["0zUM"]!)!, "0zLM": Double(row["0zLM"]!)!, 
//                "d0xMe": Double(row["d0xMe"]!)!, "d0xVr": Double(row["d0xVr"]!)!, "d0xMx": Double(row["d0xMx"]!)!, "d0xMi": Double(row["d0xMi"]!)!, "d0xUM": Double(row["d0xUM"]!)!, "d0xLM": Double(row["d0xLM"]!)!, "d0yMe": Double(row["d0yMe"]!)!, "d0yVr": Double(row["d0yVr"]!)!, "d0yMx": Double(row["d0yMx"]!)!, "d0yMn": Double(row["d0yMn"]!)!, "d0yUM": Double(row["d0yUM"]!)!, "d0yLM": Double(row["d0yLM"]!)!, "d0zMe": Double(row["d0zMe"]!)!, "d0zVr": Double(row["d0zVr"]!)!, "d0zMx": Double(row["d0zMx"]!)!, "d0zMi": Double(row["d0zMi"]!)!, "d0zUM": Double(row["d0zUM"]!)!, "d0zLM": Double(row["d0zLM"]!)!, 
//                "1xMe": Double(row["1xMe"]!)!, "1xVr": Double(row["1xVr"]!)!, "1xMx": Double(row["1xMx"]!)!, "1xMi": Double(row["1xMi"]!)!, "1xUM": Double(row["1xUM"]!)!, "1xLM": Double(row["1xLM"]!)!, "1yMe": Double(row["1yMe"]!)!, "1yVr": Double(row["1yVr"]!)!, "1yMx": Double(row["1yMx"]!)!, "1yMn": Double(row["1yMn"]!)!, "1yUM": Double(row["1yUM"]!)!, "1yLM": Double(row["1yLM"]!)!, "1zMe": Double(row["1zMe"]!)!, "1zVr": Double(row["1zVr"]!)!, "1zMx": Double(row["1zMx"]!)!, "1zMi": Double(row["1zMi"]!)!, "1zUM": Double(row["1zUM"]!)!, "1zLM": Double(row["1zLM"]!)!,
//                "d1xMe": Double(row["d1xMe"]!)!, "d1xVr": Double(row["d1xVr"]!)!, "d1xMx": Double(row["d1xMx"]!)!, "d1xMi": Double(row["d1xMi"]!)!, "d1xUM": Double(row["d1xUM"]!)!, "d1xLM": Double(row["d1xLM"]!)!, "d1yMe": Double(row["d1yMe"]!)!, "d1yVr": Double(row["d1yVr"]!)!, "d1yMx": Double(row["d1yMx"]!)!, "d1yMn": Double(row["d1yMn"]!)!, "d1yUM": Double(row["d1yUM"]!)!, "d1yLM": Double(row["d1yLM"]!)!, "d1zMe": Double(row["d1zMe"]!)!, "d1zVr": Double(row["d1zVr"]!)!, "d1zMx": Double(row["d1zMx"]!)!, "d1zMi": Double(row["d1zMi"]!)!, "d1zUM": Double(row["d1zUM"]!)!, "d1zLM": Double(row["d1zLM"]!)!,
//                "2xMe": Double(row["2xMe"]!)!, "2xVr": Double(row["2xVr"]!)!, "2xMx": Double(row["2xMx"]!)!, "2xMi": Double(row["2xMi"]!)!, "2xUM": Double(row["2xUM"]!)!, "2xLM": Double(row["2xLM"]!)!, "2yMe": Double(row["2yMe"]!)!, "2yVr": Double(row["2yVr"]!)!, "2yMx": Double(row["2yMx"]!)!, "2yMn": Double(row["2yMn"]!)!, "2yUM": Double(row["2yUM"]!)!, "2yLM": Double(row["2yLM"]!)!, "2zMe": Double(row["2zMe"]!)!, "2zVr": Double(row["2zVr"]!)!, "2zMx": Double(row["2zMx"]!)!, "2zMi": Double(row["2zMi"]!)!, "2zUM": Double(row["2zUM"]!)!, "2zLM": Double(row["2zLM"]!)!,
//                "d2xMe": Double(row["d2xMe"]!)!, "d2xVr": Double(row["d2xVr"]!)!, "d2xMx": Double(row["d2xMx"]!)!, "d2xMi": Double(row["d2xMi"]!)!, "d2xUM": Double(row["d2xUM"]!)!, "d2xLM": Double(row["d2xLM"]!)!, "d2yMe": Double(row["d2yMe"]!)!, "d2yVr": Double(row["d2yVr"]!)!, "d2yMx": Double(row["d2yMx"]!)!, "d2yMn": Double(row["d2yMn"]!)!, "d2yUM": Double(row["d2yUM"]!)!, "d2yLM": Double(row["d2yLM"]!)!, "d2zMe": Double(row["d2zMe"]!)!, "d2zVr": Double(row["d2zVr"]!)!, "d2zMx": Double(row["d2zMx"]!)!, "d2zMi": Double(row["d2zMi"]!)!, "d2zUM": Double(row["d2zUM"]!)!, "d2zLM": Double(row["d2zLM"]!)!,
//                "3xMe": Double(row["3xMe"]!)!, "3xVr": Double(row["3xVr"]!)!, "3xMx": Double(row["3xMx"]!)!, "3xMi": Double(row["3xMi"]!)!, "3xUM": Double(row["3xUM"]!)!, "3xLM": Double(row["3xLM"]!)!, "3yMe": Double(row["3yMe"]!)!, "3yVr": Double(row["3yVr"]!)!, "3yMx": Double(row["3yMx"]!)!, "3yMn": Double(row["3yMn"]!)!, "3yUM": Double(row["3yUM"]!)!, "3yLM": Double(row["3yLM"]!)!, "3zMe": Double(row["3zMe"]!)!, "3zVr": Double(row["3zVr"]!)!, "3zMx": Double(row["3zMx"]!)!, "3zMi": Double(row["3zMi"]!)!, "3zUM": Double(row["3zUM"]!)!, "3zLM": Double(row["3zLM"]!)!,
//                "d3xMe": Double(row["d3xMe"]!)!, "d3xVr": Double(row["d3xVr"]!)!, "d3xMx": Double(row["d3xMx"]!)!, "d3xMi": Double(row["d3xMi"]!)!, "d3xUM": Double(row["d3xUM"]!)!, "d3xLM": Double(row["d3xLM"]!)!, "d3yMe": Double(row["d3yMe"]!)!, "d3yVr": Double(row["d3yVr"]!)!, "d3yMx": Double(row["d3yMx"]!)!, "d3yMn": Double(row["d3yMn"]!)!, "d3yUM": Double(row["d3yUM"]!)!, "d3yLM": Double(row["d3yLM"]!)!, "d3zMe": Double(row["d3zMe"]!)!, "d3zVr": Double(row["d3zVr"]!)!, "d3zMx": Double(row["d3zMx"]!)!, "d3zMi": Double(row["d3zMi"]!)!, "d3zUM": Double(row["d3zUM"]!)!, "d3zLM": Double(row["d3zLM"]!)!,
//                "4xMe": Double(row["4xMe"]!)!, "4xVr": Double(row["4xVr"]!)!, "4xMx": Double(row["4xMx"]!)!, "4xMi": Double(row["4xMi"]!)!, "4xUM": Double(row["4xUM"]!)!, "4xLM": Double(row["4xLM"]!)!, "4yMe": Double(row["4yMe"]!)!, "4yVr": Double(row["4yVr"]!)!, "4yMx": Double(row["4yMx"]!)!, "4yMn": Double(row["4yMn"]!)!, "4yUM": Double(row["4yUM"]!)!, "4yLM": Double(row["4yLM"]!)!, "4zMe": Double(row["4zMe"]!)!, "4zVr": Double(row["4zVr"]!)!, "4zMx": Double(row["4zMx"]!)!, "4zMi": Double(row["4zMi"]!)!, "4zUM": Double(row["4zUM"]!)!, "4zLM": Double(row["4zLM"]!)!,
//                "d4xMe": Double(row["d4xMe"]!)!, "d4xVr": Double(row["d4xVr"]!)!, "d4xMx": Double(row["d4xMx"]!)!, "d4xMi": Double(row["d4xMi"]!)!, "d4xUM": Double(row["d4xUM"]!)!, "d4xLM": Double(row["d4xLM"]!)!, "d4yMe": Double(row["d4yMe"]!)!, "d4yVr": Double(row["d4yVr"]!)!, "d4yMx": Double(row["d4yMx"]!)!, "d4yMn": Double(row["d4yMn"]!)!, "d4yUM": Double(row["d4yUM"]!)!, "d4yLM": Double(row["d4yLM"]!)!, "d4zMe": Double(row["d4zMe"]!)!, "d4zVr": Double(row["d4zVr"]!)!, "d4zMx": Double(row["d4zMx"]!)!, "d4zMi": Double(row["d4zMi"]!)!, "d4zUM": Double(row["d4zUM"]!)!, "d4zLM": Double(row["d4zLM"]!)!,
//                "5xMe": Double(row["5xMe"]!)!, "5xVr": Double(row["5xVr"]!)!, "5xMx": Double(row["5xMx"]!)!, "5xMi": Double(row["5xMi"]!)!, "5xUM": Double(row["5xUM"]!)!, "5xLM": Double(row["5xLM"]!)!, "5yMe": Double(row["5yMe"]!)!, "5yVr": Double(row["5yVr"]!)!, "5yMx": Double(row["5yMx"]!)!, "5yMn": Double(row["5yMn"]!)!, "5yUM": Double(row["5yUM"]!)!, "5yLM": Double(row["5yLM"]!)!, "5zMe": Double(row["5zMe"]!)!, "5zVr": Double(row["5zVr"]!)!, "5zMx": Double(row["5zMx"]!)!, "5zMi": Double(row["5zMi"]!)!, "5zUM": Double(row["5zUM"]!)!, "5zLM": Double(row["5zLM"]!)!,
//                "d5xMe": Double(row["d5xMe"]!)!, "d5xVr": Double(row["d5xVr"]!)!, "d5xMx": Double(row["d5xMx"]!)!, "d5xMi": Double(row["d5xMi"]!)!, "d5xUM": Double(row["d5xUM"]!)!, "d5xLM": Double(row["d5xLM"]!)!, "d5yMe": Double(row["d5yMe"]!)!, "d5yVr": Double(row["d5yVr"]!)!, "d5yMx": Double(row["d5yMx"]!)!, "d5yMn": Double(row["d5yMn"]!)!, "d5yUM": Double(row["d5yUM"]!)!, "d5yLM": Double(row["d5yLM"]!)!, "d5zMe": Double(row["d5zMe"]!)!, "d5zVr": Double(row["d5zVr"]!)!, "d5zMx": Double(row["d5zMx"]!)!, "d5zMi": Double(row["d5zMi"]!)!, "d5zUM": Double(row["d5zUM"]!)!, "d5zLM": Double(row["d5zLM"]!)!,
//                "6xMe": Double(row["6xMe"]!)!, "6xVr": Double(row["6xVr"]!)!, "6xMx": Double(row["6xMx"]!)!, "6xMi": Double(row["6xMi"]!)!, "6xUM": Double(row["6xUM"]!)!, "6xLM": Double(row["6xLM"]!)!, "6yMe": Double(row["6yMe"]!)!, "6yVr": Double(row["6yVr"]!)!, "6yMx": Double(row["6yMx"]!)!, "6yMn": Double(row["6yMn"]!)!, "6yUM": Double(row["6yUM"]!)!, "6yLM": Double(row["6yLM"]!)!, "6zMe": Double(row["6zMe"]!)!, "6zVr": Double(row["6zVr"]!)!, "6zMx": Double(row["6zMx"]!)!, "6zMi": Double(row["6zMi"]!)!, "6zUM": Double(row["6zUM"]!)!, "6zLM": Double(row["6zLM"]!)!,
//                "d6xMe": Double(row["d6xMe"]!)!, "d6xVr": Double(row["d6xVr"]!)!, "d6xMx": Double(row["d6xMx"]!)!, "d6xMi": Double(row["d6xMi"]!)!, "d6xUM": Double(row["d6xUM"]!)!, "d6xLM": Double(row["d6xLM"]!)!, "d6yMe": Double(row["d6yMe"]!)!, "d6yVr": Double(row["d6yVr"]!)!, "d6yMx": Double(row["d6yMx"]!)!, "d6yMn": Double(row["d6yMn"]!)!, "d6yUM": Double(row["d6yUM"]!)!, "d6yLM": Double(row["d6yLM"]!)!, "d6zMe": Double(row["d6zMe"]!)!, "d6zVr": Double(row["d6zVr"]!)!, "d6zMx": Double(row["d6zMx"]!)!, "d6zMi": Double(row["d6zMi"]!)!, "d6zUM": Double(row["d6zUM"]!)!, "d6zLM": Double(row["d6zLM"]!)!,
//                "7xMe": Double(row["7xMe"]!)!, "7xVr": Double(row["7xVr"]!)!, "7xMx": Double(row["7xMx"]!)!, "7xMi": Double(row["7xMi"]!)!, "7xUM": Double(row["7xUM"]!)!, "7xLM": Double(row["7xLM"]!)!, "7yMe": Double(row["7yMe"]!)!, "7yVr": Double(row["7yVr"]!)!, "7yMx": Double(row["7yMx"]!)!, "7yMn": Double(row["7yMn"]!)!, "7yUM": Double(row["7yUM"]!)!, "7yLM": Double(row["7yLM"]!)!, "7zMe": Double(row["7zMe"]!)!, "7zVr": Double(row["7zVr"]!)!, "7zMx": Double(row["7zMx"]!)!, "7zMi": Double(row["7zMi"]!)!, "7zUM": Double(row["7zUM"]!)!, "7zLM": Double(row["7zLM"]!)!,
//                "d7xMe": Double(row["d7xMe"]!)!, "d7xVr": Double(row["d7xVr"]!)!, "d7xMx": Double(row["d7xMx"]!)!, "d7xMi": Double(row["d7xMi"]!)!, "d7xUM": Double(row["d7xUM"]!)!, "d7xLM": Double(row["d7xLM"]!)!, "d7yMe": Double(row["d7yMe"]!)!, "d7yVr": Double(row["d7yVr"]!)!, "d7yMx": Double(row["d7yMx"]!)!, "d7yMn": Double(row["d7yMn"]!)!, "d7yUM": Double(row["d7yUM"]!)!, "d7yLM": Double(row["d7yLM"]!)!, "d7zMe": Double(row["d7zMe"]!)!, "d7zVr": Double(row["d7zVr"]!)!, "d7zMx": Double(row["d7zMx"]!)!, "d7zMi": Double(row["d7zMi"]!)!, "d7zUM": Double(row["d7zUM"]!)!, "d7zLM": Double(row["d7zLM"]!)!])
//
//            for row in csvFile.rows {
//                    guard let p = try? model.prediction(from: csvFeatureProvider)
//                    print("Current Level: ", p)
//                    else {
//                        fatalError("Unexpected runtime error.")
//                    }
//                }
//        }
//        catch{
//            
//        }
//    }
    
}
