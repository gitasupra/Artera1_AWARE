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
                    
                    if (accIdx == 800){
                        //At multiple of (data points per second) * 10 seconds
                        windowFileURL = writeAccDataToCSV(data: windowAccData)!
                        print("Window data saved to: \(windowFileURL)")
//                        
//                        inputFunctions.processData(windowFile: windowFileURL)
//                        
                        let file = inputFunctions.processData(datafile: windowFileURL)
                        predictLevel(file: file)
                        
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

    func predictLevel(file: String) {
            do{
                let config = MLModelConfiguration()
                let model = try! alcohol(configuration: config)
                
                // Read the processed CSV file using SwiftCSV
                
                let csvFile = try! CSV<Named>(url: URL(fileURLWithPath: file))
                
                var featureDictionary = [String: Double]()
                
                for row in csvFile.rows {
                    if let xMeValue0 = row["0xMe"].flatMap(Double.init) { featureDictionary["0xMe"] = xMeValue0 }
                    if let xVrValue0 = row["0xVr"].flatMap(Double.init) { featureDictionary["0xVr"] = xVrValue0 }
                    if let xMxValue0 = row["0xMx"].flatMap(Double.init) { featureDictionary["0xMx"] = xMxValue0 }
                    if let xMiValue0 = row["0xMi"].flatMap(Double.init) { featureDictionary["0xMi"] = xMiValue0 }
                    if let xUMValue0 = row["0xUM"].flatMap(Double.init) { featureDictionary["0xUM"] = xUMValue0 }
                    if let xLMValue0 = row["0xLM"].flatMap(Double.init) { featureDictionary["0xLM"] = xLMValue0 }
                    if let yMeValue0 = row["0yMe"].flatMap(Double.init) { featureDictionary["0yMe"] = yMeValue0 }
                    if let yVrValue0 = row["0yVr"].flatMap(Double.init) { featureDictionary["0yVr"] = yVrValue0 }
                    if let yMxValue0 = row["0yMx"].flatMap(Double.init) { featureDictionary["0yMx"] = yMxValue0 }
                    if let yMnValue0 = row["0yMn"].flatMap(Double.init) { featureDictionary["0yMn"] = yMnValue0 }
                    if let yUMValue0 = row["0yUM"].flatMap(Double.init) { featureDictionary["0yUM"] = yUMValue0 }
                    if let yLMValue0 = row["0yLM"].flatMap(Double.init) { featureDictionary["0yLM"] = yLMValue0 }
                    if let zMeValue0 = row["0zMe"].flatMap(Double.init) { featureDictionary["0zMe"] = zMeValue0 }
                    if let zVrValue0 = row["0zVr"].flatMap(Double.init) { featureDictionary["0zVr"] = zVrValue0 }
                    if let zMxValue0 = row["0zMx"].flatMap(Double.init) { featureDictionary["0zMx"] = zMxValue0 }
                    if let zMiValue0 = row["0zMi"].flatMap(Double.init) { featureDictionary["0zMi"] = zMiValue0 }
                    if let zUMValue0 = row["0zUM"].flatMap(Double.init) { featureDictionary["0zUM"] = zUMValue0 }
                    if let zLMValue0 = row["0zLM"].flatMap(Double.init) { featureDictionary["0zLM"] = zLMValue0 }
                    
                    if let dxMeValue0 = row["d0xMe"].flatMap(Double.init) { featureDictionary["d0xMe"] = dxMeValue0 }
                    if let dxVrValue0 = row["d0xVr"].flatMap(Double.init) { featureDictionary["d0xVr"] = dxVrValue0 }
                    if let dxMxValue0 = row["d0xMx"].flatMap(Double.init) { featureDictionary["d0xMx"] = dxMxValue0 }
                    if let dxMiValue0 = row["d0xMi"].flatMap(Double.init) { featureDictionary["d0xMi"] = dxMiValue0 }
                    if let dxUMValue0 = row["d0xUM"].flatMap(Double.init) { featureDictionary["d0xUM"] = dxUMValue0 }
                    if let dxLMValue0 = row["d0xLM"].flatMap(Double.init) { featureDictionary["d0xLM"] = dxLMValue0 }
                    if let dyMeValue0 = row["d0yMe"].flatMap(Double.init) { featureDictionary["d0yMe"] = dyMeValue0 }
                    if let dyVrValue0 = row["d0yVr"].flatMap(Double.init) { featureDictionary["d0yVr"] = dyVrValue0 }
                    if let dyMxValue0 = row["d0yMx"].flatMap(Double.init) { featureDictionary["d0yMx"] = dyMxValue0 }
                    if let dyMnValue0 = row["d0yMn"].flatMap(Double.init) { featureDictionary["d0yMn"] = dyMnValue0 }
                    if let dyUMValue0 = row["d0yUM"].flatMap(Double.init) { featureDictionary["d0yUM"] = dyUMValue0 }
                    if let dyLMValue0 = row["d0yLM"].flatMap(Double.init) { featureDictionary["d0yLM"] = dyLMValue0 }
                    if let dzMeValue0 = row["d0zMe"].flatMap(Double.init) { featureDictionary["d0zMe"] = dzMeValue0 }
                    if let dzVrValue0 = row["d0zVr"].flatMap(Double.init) { featureDictionary["d0zVr"] = dzVrValue0 }
                    if let dzMxValue0 = row["d0zMx"].flatMap(Double.init) { featureDictionary["d0zMx"] = dzMxValue0 }
                    if let dzMiValue0 = row["d0zMi"].flatMap(Double.init) { featureDictionary["d0zMi"] = dzMiValue0 }
                    if let dzUMValue0 = row["d0zUM"].flatMap(Double.init) { featureDictionary["d0zUM"] = dzUMValue0 }
                    if let dzLMValue0 = row["d0zLM"].flatMap(Double.init) { featureDictionary["d0zLM"] = dzLMValue0 }
                    
                    if let xMeValue1 = row["1xMe"].flatMap(Double.init) { featureDictionary["1xMe"] = xMeValue1 }
                    if let xVrValue1 = row["1xVr"].flatMap(Double.init) { featureDictionary["1xVr"] = xVrValue1 }
                    if let xMxValue1 = row["1xMx"].flatMap(Double.init) { featureDictionary["1xMx"] = xMxValue1 }
                    if let xMiValue1 = row["1xMi"].flatMap(Double.init) { featureDictionary["1xMi"] = xMiValue1 }
                    if let xUMValue1 = row["1xUM"].flatMap(Double.init) { featureDictionary["1xUM"] = xUMValue1 }
                    if let xLMValue1 = row["1xLM"].flatMap(Double.init) { featureDictionary["1xLM"] = xLMValue1 }
                    if let yMeValue1 = row["1yMe"].flatMap(Double.init) { featureDictionary["1yMe"] = yMeValue1 }
                    if let yVrValue1 = row["1yVr"].flatMap(Double.init) { featureDictionary["1yVr"] = yVrValue1 }
                    if let yMxValue1 = row["1yMx"].flatMap(Double.init) { featureDictionary["1yMx"] = yMxValue1 }
                    if let yMnValue1 = row["1yMn"].flatMap(Double.init) { featureDictionary["1yMn"] = yMnValue1 }
                    if let yUMValue1 = row["1yUM"].flatMap(Double.init) { featureDictionary["1yUM"] = yUMValue1 }
                    if let yLMValue1 = row["1yLM"].flatMap(Double.init) { featureDictionary["1yLM"] = yLMValue1 }
                    if let zMeValue1 = row["1zMe"].flatMap(Double.init) { featureDictionary["1zMe"] = zMeValue1 }
                    if let zVrValue1 = row["1zVr"].flatMap(Double.init) { featureDictionary["1zVr"] = zVrValue1 }
                    if let zMxValue1 = row["1zMx"].flatMap(Double.init) { featureDictionary["1zMx"] = zMxValue1 }
                    if let zMiValue1 = row["1zMi"].flatMap(Double.init) { featureDictionary["1zMi"] = zMiValue1 }
                    if let zUMValue1 = row["1zUM"].flatMap(Double.init) { featureDictionary["1zUM"] = zUMValue1 }
                    if let zLMValue1 = row["1zLM"].flatMap(Double.init) { featureDictionary["1zLM"] = zLMValue1 }
                    
                    if let dxMeValue1 = row["d1xMe"].flatMap(Double.init) { featureDictionary["d1xMe"] = dxMeValue1 }
                    if let dxVrValue1 = row["d1xVr"].flatMap(Double.init) { featureDictionary["d1xVr"] = dxVrValue1 }
                    if let dxMxValue1 = row["d1xMx"].flatMap(Double.init) { featureDictionary["d1xMx"] = dxMxValue1 }
                    if let dxMiValue1 = row["d1xMi"].flatMap(Double.init) { featureDictionary["d1xMi"] = dxMiValue1 }
                    if let dxUMValue1 = row["d1xUM"].flatMap(Double.init) { featureDictionary["d1xUM"] = dxUMValue1 }
                    if let dxLMValue1 = row["d1xLM"].flatMap(Double.init) { featureDictionary["d1xLM"] = dxLMValue1 }
                    if let dyMeValue1 = row["d1yMe"].flatMap(Double.init) { featureDictionary["d1yMe"] = dyMeValue1 }
                    if let dyVrValue1 = row["d1yVr"].flatMap(Double.init) { featureDictionary["d1yVr"] = dyVrValue1 }
                    if let dyMxValue1 = row["d1yMx"].flatMap(Double.init) { featureDictionary["d1yMx"] = dyMxValue1 }
                    if let dyMnValue1 = row["d1yMn"].flatMap(Double.init) { featureDictionary["d1yMn"] = dyMnValue1 }
                    if let dyUMValue1 = row["d1yUM"].flatMap(Double.init) { featureDictionary["d1yUM"] = dyUMValue1 }
                    if let dyLMValue1 = row["d1yLM"].flatMap(Double.init) { featureDictionary["d1yLM"] = dyLMValue1 }
                    if let dzMeValue1 = row["d1zMe"].flatMap(Double.init) { featureDictionary["d1zMe"] = dzMeValue1 }
                    if let dzVrValue1 = row["d1zVr"].flatMap(Double.init) { featureDictionary["d1zVr"] = dzVrValue1 }
                    if let dzMxValue1 = row["d1zMx"].flatMap(Double.init) { featureDictionary["d1zMx"] = dzMxValue1 }
                    if let dzMiValue1 = row["d1zMi"].flatMap(Double.init) { featureDictionary["d1zMi"] = dzMiValue1 }
                    if let dzUMValue1 = row["d1zUM"].flatMap(Double.init) { featureDictionary["d1zUM"] = dzUMValue1 }
                    if let dzLMValue1 = row["d1zLM"].flatMap(Double.init) { featureDictionary["d1zLM"] = dzLMValue1 }
                    
                    if let xMeValue2 = row["2xMe"].flatMap(Double.init) { featureDictionary["2xMe"] = xMeValue2 }
                    if let xVrValue2 = row["2xVr"].flatMap(Double.init) { featureDictionary["2xVr"] = xVrValue2 }
                    if let xMxValue2 = row["2xMx"].flatMap(Double.init) { featureDictionary["2xMx"] = xMxValue2 }
                    if let xMiValue2 = row["2xMi"].flatMap(Double.init) { featureDictionary["2xMi"] = xMiValue2 }
                    if let xUMValue2 = row["2xUM"].flatMap(Double.init) { featureDictionary["2xUM"] = xUMValue2 }
                    if let xLMValue2 = row["2xLM"].flatMap(Double.init) { featureDictionary["2xLM"] = xLMValue2 }
                    if let yMeValue2 = row["2yMe"].flatMap(Double.init) { featureDictionary["2yMe"] = yMeValue2 }
                    if let yVrValue2 = row["2yVr"].flatMap(Double.init) { featureDictionary["2yVr"] = yVrValue2 }
                    if let yMxValue2 = row["2yMx"].flatMap(Double.init) { featureDictionary["2yMx"] = yMxValue2 }
                    if let yMnValue2 = row["2yMn"].flatMap(Double.init) { featureDictionary["2yMn"] = yMnValue2 }
                    if let yUMValue2 = row["2yUM"].flatMap(Double.init) { featureDictionary["2yUM"] = yUMValue2 }
                    if let yLMValue2 = row["2yLM"].flatMap(Double.init) { featureDictionary["2yLM"] = yLMValue2 }
                    if let zMeValue2 = row["2zMe"].flatMap(Double.init) { featureDictionary["2zMe"] = zMeValue2 }
                    if let zVrValue2 = row["2zVr"].flatMap(Double.init) { featureDictionary["2zVr"] = zVrValue2 }
                    if let zMxValue2 = row["2zMx"].flatMap(Double.init) { featureDictionary["2zMx"] = zMxValue2 }
                    if let zMiValue2 = row["2zMi"].flatMap(Double.init) { featureDictionary["2zMi"] = zMiValue2 }
                    if let zUMValue2 = row["2zUM"].flatMap(Double.init) { featureDictionary["2zUM"] = zUMValue2 }
                    if let zLMValue2 = row["2zLM"].flatMap(Double.init) { featureDictionary["2zLM"] = zLMValue2 }
                    
                    if let dxMeValue2 = row["d2xMe"].flatMap(Double.init) { featureDictionary["d2xMe"] = dxMeValue2 }
                    if let dxVrValue2 = row["d2xVr"].flatMap(Double.init) { featureDictionary["d2xVr"] = dxVrValue2 }
                    if let dxMxValue2 = row["d2xMx"].flatMap(Double.init) { featureDictionary["d2xMx"] = dxMxValue2 }
                    if let dxMiValue2 = row["d2xMi"].flatMap(Double.init) { featureDictionary["d2xMi"] = dxMiValue2 }
                    if let dxUMValue2 = row["d2xUM"].flatMap(Double.init) { featureDictionary["d2xUM"] = dxUMValue2 }
                    if let dxLMValue2 = row["d2xLM"].flatMap(Double.init) { featureDictionary["d2xLM"] = dxLMValue2 }
                    if let dyMeValue2 = row["d2yMe"].flatMap(Double.init) { featureDictionary["d2yMe"] = dyMeValue2 }
                    if let dyVrValue2 = row["d2yVr"].flatMap(Double.init) { featureDictionary["d2yVr"] = dyVrValue2 }
                    if let dyMxValue2 = row["d2yMx"].flatMap(Double.init) { featureDictionary["d2yMx"] = dyMxValue2 }
                    if let dyMnValue2 = row["d2yMn"].flatMap(Double.init) { featureDictionary["d2yMn"] = dyMnValue2 }
                    if let dyUMValue2 = row["d2yUM"].flatMap(Double.init) { featureDictionary["d2yUM"] = dyUMValue2 }
                    if let dyLMValue2 = row["d2yLM"].flatMap(Double.init) { featureDictionary["d2yLM"] = dyLMValue2 }
                    if let dzMeValue2 = row["d2zMe"].flatMap(Double.init) { featureDictionary["d2zMe"] = dzMeValue2 }
                    if let dzVrValue2 = row["d2zVr"].flatMap(Double.init) { featureDictionary["d2zVr"] = dzVrValue2 }
                    if let dzMxValue2 = row["d2zMx"].flatMap(Double.init) { featureDictionary["d2zMx"] = dzMxValue2 }
                    if let dzMiValue2 = row["d2zMi"].flatMap(Double.init) { featureDictionary["d2zMi"] = dzMiValue2 }
                    if let dzUMValue2 = row["d2zUM"].flatMap(Double.init) { featureDictionary["d2zUM"] = dzUMValue2 }
                    if let dzLMValue2 = row["d2zLM"].flatMap(Double.init) { featureDictionary["d2zLM"] = dzLMValue2 }
                    
                    if let xMeValue4 = row["4xMe"].flatMap(Double.init) { featureDictionary["4xMe"] = xMeValue4 }
                    if let xVrValue4 = row["4xVr"].flatMap(Double.init) { featureDictionary["4xVr"] = xVrValue4 }
                    if let xMxValue4 = row["4xMx"].flatMap(Double.init) { featureDictionary["4xMx"] = xMxValue4 }
                    if let xMiValue4 = row["4xMi"].flatMap(Double.init) { featureDictionary["4xMi"] = xMiValue4 }
                    if let xUMValue4 = row["4xUM"].flatMap(Double.init) { featureDictionary["4xUM"] = xUMValue4 }
                    if let xLMValue4 = row["4xLM"].flatMap(Double.init) { featureDictionary["4xLM"] = xLMValue4 }
                    if let yMeValue4 = row["4yMe"].flatMap(Double.init) { featureDictionary["4yMe"] = yMeValue4 }
                    if let yVrValue4 = row["4yVr"].flatMap(Double.init) { featureDictionary["4yVr"] = yVrValue4 }
                    if let yMxValue4 = row["4yMx"].flatMap(Double.init) { featureDictionary["4yMx"] = yMxValue4 }
                    if let yMnValue4 = row["4yMn"].flatMap(Double.init) { featureDictionary["4yMn"] = yMnValue4 }
                    if let yUMValue4 = row["4yUM"].flatMap(Double.init) { featureDictionary["4yUM"] = yUMValue4 }
                    if let yLMValue4 = row["4yLM"].flatMap(Double.init) { featureDictionary["4yLM"] = yLMValue4 }
                    if let zMeValue4 = row["4zMe"].flatMap(Double.init) { featureDictionary["4zMe"] = zMeValue4 }
                    if let zVrValue4 = row["4zVr"].flatMap(Double.init) { featureDictionary["4zVr"] = zVrValue4 }
                    if let zMxValue4 = row["4zMx"].flatMap(Double.init) { featureDictionary["4zMx"] = zMxValue4 }
                    if let zMiValue4 = row["4zMi"].flatMap(Double.init) { featureDictionary["4zMi"] = zMiValue4 }
                    if let zUMValue4 = row["4zUM"].flatMap(Double.init) { featureDictionary["4zUM"] = zUMValue4 }
                    if let zLMValue4 = row["4zLM"].flatMap(Double.init) { featureDictionary["4zLM"] = zLMValue4 }
                    
                    if let dxMeValue4 = row["d4xMe"].flatMap(Double.init) { featureDictionary["d4xMe"] = dxMeValue4 }
                    if let dxVrValue4 = row["d4xVr"].flatMap(Double.init) { featureDictionary["d4xVr"] = dxVrValue4 }
                    if let dxMxValue4 = row["d4xMx"].flatMap(Double.init) { featureDictionary["d4xMx"] = dxMxValue4 }
                    if let dxMiValue4 = row["d4xMi"].flatMap(Double.init) { featureDictionary["d4xMi"] = dxMiValue4 }
                    if let dxUMValue4 = row["d4xUM"].flatMap(Double.init) { featureDictionary["d4xUM"] = dxUMValue4 }
                    if let dxLMValue4 = row["d4xLM"].flatMap(Double.init) { featureDictionary["d4xLM"] = dxLMValue4 }
                    if let dyMeValue4 = row["d4yMe"].flatMap(Double.init) { featureDictionary["d4yMe"] = dyMeValue4 }
                    if let dyVrValue4 = row["d4yVr"].flatMap(Double.init) { featureDictionary["d4yVr"] = dyVrValue4 }
                    if let dyMxValue4 = row["d4yMx"].flatMap(Double.init) { featureDictionary["d4yMx"] = dyMxValue4 }
                    if let dyMnValue4 = row["d4yMn"].flatMap(Double.init) { featureDictionary["d4yMn"] = dyMnValue4 }
                    if let dyUMValue4 = row["d4yUM"].flatMap(Double.init) { featureDictionary["d4yUM"] = dyUMValue4 }
                    if let dyLMValue4 = row["d4yLM"].flatMap(Double.init) { featureDictionary["d4yLM"] = dyLMValue4 }
                    if let dzMeValue4 = row["d4zMe"].flatMap(Double.init) { featureDictionary["d4zMe"] = dzMeValue4 }
                    if let dzVrValue4 = row["d4zVr"].flatMap(Double.init) { featureDictionary["d4zVr"] = dzVrValue4 }
                    if let dzMxValue4 = row["d4zMx"].flatMap(Double.init) { featureDictionary["d4zMx"] = dzMxValue4 }
                    if let dzMiValue4 = row["d4zMi"].flatMap(Double.init) { featureDictionary["d4zMi"] = dzMiValue4 }
                    if let dzUMValue4 = row["d4zUM"].flatMap(Double.init) { featureDictionary["d4zUM"] = dzUMValue4 }
                    if let dzLMValue4 = row["d4zLM"].flatMap(Double.init) { featureDictionary["d4zLM"] = dzLMValue4 }
                    
                    if let xMeValue5 = row["5xMe"].flatMap(Double.init) { featureDictionary["5xMe"] = xMeValue5 }
                    if let xVrValue5 = row["5xVr"].flatMap(Double.init) { featureDictionary["5xVr"] = xVrValue5 }
                    if let xMxValue5 = row["5xMx"].flatMap(Double.init) { featureDictionary["5xMx"] = xMxValue5 }
                    if let xMiValue5 = row["5xMi"].flatMap(Double.init) { featureDictionary["5xMi"] = xMiValue5 }
                    if let xUMValue5 = row["5xUM"].flatMap(Double.init) { featureDictionary["5xUM"] = xUMValue5 }
                    if let xLMValue5 = row["5xLM"].flatMap(Double.init) { featureDictionary["5xLM"] = xLMValue5 }
                    if let yMeValue5 = row["5yMe"].flatMap(Double.init) { featureDictionary["5yMe"] = yMeValue5 }
                    if let yVrValue5 = row["5yVr"].flatMap(Double.init) { featureDictionary["5yVr"] = yVrValue5 }
                    if let yMxValue5 = row["5yMx"].flatMap(Double.init) { featureDictionary["5yMx"] = yMxValue5 }
                    if let yMnValue5 = row["5yMn"].flatMap(Double.init) { featureDictionary["5yMn"] = yMnValue5 }
                    if let yUMValue5 = row["5yUM"].flatMap(Double.init) { featureDictionary["5yUM"] = yUMValue5 }
                    if let yLMValue5 = row["5yLM"].flatMap(Double.init) { featureDictionary["5yLM"] = yLMValue5 }
                    if let zMeValue5 = row["5zMe"].flatMap(Double.init) { featureDictionary["5zMe"] = zMeValue5 }
                    if let zVrValue5 = row["5zVr"].flatMap(Double.init) { featureDictionary["5zVr"] = zVrValue5 }
                    if let zMxValue5 = row["5zMx"].flatMap(Double.init) { featureDictionary["5zMx"] = zMxValue5 }
                    if let zMiValue5 = row["5zMi"].flatMap(Double.init) { featureDictionary["5zMi"] = zMiValue5 }
                    if let zUMValue5 = row["5zUM"].flatMap(Double.init) { featureDictionary["5zUM"] = zUMValue5 }
                    if let zLMValue5 = row["5zLM"].flatMap(Double.init) { featureDictionary["5zLM"] = zLMValue5 }
                    
                    if let dxMeValue5 = row["d5xMe"].flatMap(Double.init) { featureDictionary["d5xMe"] = dxMeValue5 }
                    if let dxVrValue5 = row["d5xVr"].flatMap(Double.init) { featureDictionary["d5xVr"] = dxVrValue5 }
                    if let dxMxValue5 = row["d5xMx"].flatMap(Double.init) { featureDictionary["d5xMx"] = dxMxValue5 }
                    if let dxMiValue5 = row["d5xMi"].flatMap(Double.init) { featureDictionary["d5xMi"] = dxMiValue5 }
                    if let dxUMValue5 = row["d5xUM"].flatMap(Double.init) { featureDictionary["d5xUM"] = dxUMValue5 }
                    if let dxLMValue5 = row["d5xLM"].flatMap(Double.init) { featureDictionary["d5xLM"] = dxLMValue5 }
                    if let dyMeValue5 = row["d5yMe"].flatMap(Double.init) { featureDictionary["d5yMe"] = dyMeValue5 }
                    if let dyVrValue5 = row["d5yVr"].flatMap(Double.init) { featureDictionary["d5yVr"] = dyVrValue5 }
                    if let dyMxValue5 = row["d5yMx"].flatMap(Double.init) { featureDictionary["d5yMx"] = dyMxValue5 }
                    if let dyMnValue5 = row["d5yMn"].flatMap(Double.init) { featureDictionary["d5yMn"] = dyMnValue5 }
                    if let dyUMValue5 = row["d5yUM"].flatMap(Double.init) { featureDictionary["d5yUM"] = dyUMValue5 }
                    if let dyLMValue5 = row["d5yLM"].flatMap(Double.init) { featureDictionary["d5yLM"] = dyLMValue5 }
                    if let dzMeValue5 = row["d5zMe"].flatMap(Double.init) { featureDictionary["d5zMe"] = dzMeValue5 }
                    if let dzVrValue5 = row["d5zVr"].flatMap(Double.init) { featureDictionary["d5zVr"] = dzVrValue5 }
                    if let dzMxValue5 = row["d5zMx"].flatMap(Double.init) { featureDictionary["d5zMx"] = dzMxValue5 }
                    if let dzMiValue5 = row["d5zMi"].flatMap(Double.init) { featureDictionary["d5zMi"] = dzMiValue5 }
                    if let dzUMValue5 = row["d5zUM"].flatMap(Double.init) { featureDictionary["d5zUM"] = dzUMValue5 }
                    if let dzLMValue5 = row["d5zLM"].flatMap(Double.init) { featureDictionary["d5zLM"] = dzLMValue5 }
                    
                    if let xMeValue6 = row["6xMe"].flatMap(Double.init) { featureDictionary["6xMe"] = xMeValue6 }
                    if let xVrValue6 = row["6xVr"].flatMap(Double.init) { featureDictionary["6xVr"] = xVrValue6 }
                    if let xMxValue6 = row["6xMx"].flatMap(Double.init) { featureDictionary["6xMx"] = xMxValue6 }
                    if let xMiValue6 = row["6xMi"].flatMap(Double.init) { featureDictionary["6xMi"] = xMiValue6 }
                    if let xUMValue6 = row["6xUM"].flatMap(Double.init) { featureDictionary["6xUM"] = xUMValue6 }
                    if let xLMValue6 = row["6xLM"].flatMap(Double.init) { featureDictionary["6xLM"] = xLMValue6 }
                    if let yMeValue6 = row["6yMe"].flatMap(Double.init) { featureDictionary["6yMe"] = yMeValue6 }
                    if let yVrValue6 = row["6yVr"].flatMap(Double.init) { featureDictionary["6yVr"] = yVrValue6 }
                    if let yMxValue6 = row["6yMx"].flatMap(Double.init) { featureDictionary["6yMx"] = yMxValue6 }
                    if let yMnValue6 = row["6yMn"].flatMap(Double.init) { featureDictionary["6yMn"] = yMnValue6 }
                    if let yUMValue6 = row["6yUM"].flatMap(Double.init) { featureDictionary["6yUM"] = yUMValue6 }
                    if let yLMValue6 = row["6yLM"].flatMap(Double.init) { featureDictionary["6yLM"] = yLMValue6 }
                    if let zMeValue6 = row["6zMe"].flatMap(Double.init) { featureDictionary["6zMe"] = zMeValue6 }
                    if let zVrValue6 = row["6zVr"].flatMap(Double.init) { featureDictionary["6zVr"] = zVrValue6 }
                    if let zMxValue6 = row["6zMx"].flatMap(Double.init) { featureDictionary["6zMx"] = zMxValue6 }
                    if let zMiValue6 = row["6zMi"].flatMap(Double.init) { featureDictionary["6zMi"] = zMiValue6 }
                    if let zUMValue6 = row["6zUM"].flatMap(Double.init) { featureDictionary["6zUM"] = zUMValue6 }
                    if let zLMValue6 = row["6zLM"].flatMap(Double.init) { featureDictionary["6zLM"] = zLMValue6 }
                    
                    if let dxMeValue6 = row["d6xMe"].flatMap(Double.init) { featureDictionary["d6xMe"] = dxMeValue6 }
                    if let dxVrValue6 = row["d6xVr"].flatMap(Double.init) { featureDictionary["d6xVr"] = dxVrValue6 }
                    if let dxMxValue6 = row["d6xMx"].flatMap(Double.init) { featureDictionary["d6xMx"] = dxMxValue6 }
                    if let dxMiValue6 = row["d6xMi"].flatMap(Double.init) { featureDictionary["d6xMi"] = dxMiValue6 }
                    if let dxUMValue6 = row["d6xUM"].flatMap(Double.init) { featureDictionary["d6xUM"] = dxUMValue6 }
                    if let dxLMValue6 = row["d6xLM"].flatMap(Double.init) { featureDictionary["d6xLM"] = dxLMValue6 }
                    if let dyMeValue6 = row["d6yMe"].flatMap(Double.init) { featureDictionary["d6yMe"] = dyMeValue6 }
                    if let dyVrValue6 = row["d6yVr"].flatMap(Double.init) { featureDictionary["d6yVr"] = dyVrValue6 }
                    if let dyMxValue6 = row["d6yMx"].flatMap(Double.init) { featureDictionary["d6yMx"] = dyMxValue6 }
                    if let dyMnValue6 = row["d6yMn"].flatMap(Double.init) { featureDictionary["d6yMn"] = dyMnValue6 }
                    if let dyUMValue6 = row["d6yUM"].flatMap(Double.init) { featureDictionary["d6yUM"] = dyUMValue6 }
                    if let dyLMValue6 = row["d6yLM"].flatMap(Double.init) { featureDictionary["d6yLM"] = dyLMValue6 }
                    if let dzMeValue6 = row["d6zMe"].flatMap(Double.init) { featureDictionary["d6zMe"] = dzMeValue6 }
                    if let dzVrValue6 = row["d6zVr"].flatMap(Double.init) { featureDictionary["d6zVr"] = dzVrValue6 }
                    if let dzMxValue6 = row["d6zMx"].flatMap(Double.init) { featureDictionary["d6zMx"] = dzMxValue6 }
                    if let dzMiValue6 = row["d6zMi"].flatMap(Double.init) { featureDictionary["d6zMi"] = dzMiValue6 }
                    if let dzUMValue6 = row["d6zUM"].flatMap(Double.init) { featureDictionary["d6zUM"] = dzUMValue6 }
                    if let dzLMValue6 = row["d6zLM"].flatMap(Double.init) { featureDictionary["d6zLM"] = dzLMValue6 }
                    
                    if let xMeValue7 = row["7xMe"].flatMap(Double.init) { featureDictionary["7xMe"] = xMeValue7 }
                    if let xVrValue7 = row["7xVr"].flatMap(Double.init) { featureDictionary["7xVr"] = xVrValue7 }
                    if let xMxValue7 = row["7xMx"].flatMap(Double.init) { featureDictionary["7xMx"] = xMxValue7 }
                    if let xMiValue7 = row["7xMi"].flatMap(Double.init) { featureDictionary["7xMi"] = xMiValue7 }
                    if let xUMValue7 = row["7xUM"].flatMap(Double.init) { featureDictionary["7xUM"] = xUMValue7 }
                    if let xLMValue7 = row["7xLM"].flatMap(Double.init) { featureDictionary["7xLM"] = xLMValue7 }
                    if let yMeValue7 = row["7yMe"].flatMap(Double.init) { featureDictionary["7yMe"] = yMeValue7 }
                    if let yVrValue7 = row["7yVr"].flatMap(Double.init) { featureDictionary["7yVr"] = yVrValue7 }
                    if let yMxValue7 = row["7yMx"].flatMap(Double.init) { featureDictionary["7yMx"] = yMxValue7 }
                    if let yMnValue7 = row["7yMn"].flatMap(Double.init) { featureDictionary["7yMn"] = yMnValue7 }
                    if let yUMValue7 = row["7yUM"].flatMap(Double.init) { featureDictionary["7yUM"] = yUMValue7 }
                    if let yLMValue7 = row["7yLM"].flatMap(Double.init) { featureDictionary["7yLM"] = yLMValue7 }
                    if let zMeValue7 = row["7zMe"].flatMap(Double.init) { featureDictionary["7zMe"] = zMeValue7 }
                    if let zVrValue7 = row["7zVr"].flatMap(Double.init) { featureDictionary["7zVr"] = zVrValue7 }
                    if let zMxValue7 = row["7zMx"].flatMap(Double.init) { featureDictionary["7zMx"] = zMxValue7 }
                    if let zMiValue7 = row["7zMi"].flatMap(Double.init) { featureDictionary["7zMi"] = zMiValue7 }
                    if let zUMValue7 = row["7zUM"].flatMap(Double.init) { featureDictionary["7zUM"] = zUMValue7 }
                    if let zLMValue7 = row["7zLM"].flatMap(Double.init) { featureDictionary["7zLM"] = zLMValue7 }
                    
                    if let dxMeValue7 = row["d7xMe"].flatMap(Double.init) { featureDictionary["d7xMe"] = dxMeValue7 }
                    if let dxVrValue7 = row["d7xVr"].flatMap(Double.init) { featureDictionary["d7xVr"] = dxVrValue7 }
                    if let dxMxValue7 = row["d7xMx"].flatMap(Double.init) { featureDictionary["d7xMx"] = dxMxValue7 }
                    if let dxMiValue7 = row["d7xMi"].flatMap(Double.init) { featureDictionary["d7xMi"] = dxMiValue7 }
                    if let dxUMValue7 = row["d7xUM"].flatMap(Double.init) { featureDictionary["d7xUM"] = dxUMValue7 }
                    if let dxLMValue7 = row["d7xLM"].flatMap(Double.init) { featureDictionary["d7xLM"] = dxLMValue7 }
                    if let dyMeValue7 = row["d7yMe"].flatMap(Double.init) { featureDictionary["d7yMe"] = dyMeValue7 }
                    if let dyVrValue7 = row["d7yVr"].flatMap(Double.init) { featureDictionary["d7yVr"] = dyVrValue7 }
                    if let dyMxValue7 = row["d7yMx"].flatMap(Double.init) { featureDictionary["d7yMx"] = dyMxValue7 }
                    if let dyMnValue7 = row["d7yMn"].flatMap(Double.init) { featureDictionary["d7yMn"] = dyMnValue7 }
                    if let dyUMValue7 = row["d7yUM"].flatMap(Double.init) { featureDictionary["d7yUM"] = dyUMValue7 }
                    if let dyLMValue7 = row["d7yLM"].flatMap(Double.init) { featureDictionary["d7yLM"] = dyLMValue7 }
                    if let dzMeValue7 = row["d7zMe"].flatMap(Double.init) { featureDictionary["d7zMe"] = dzMeValue7 }
                    if let dzVrValue7 = row["d7zVr"].flatMap(Double.init) { featureDictionary["d7zVr"] = dzVrValue7 }
                    if let dzMxValue7 = row["d7zMx"].flatMap(Double.init) { featureDictionary["d7zMx"] = dzMxValue7 }
                    if let dzMiValue7 = row["d7zMi"].flatMap(Double.init) { featureDictionary["d7zMi"] = dzMiValue7 }
                    if let dzUMValue7 = row["d7zUM"].flatMap(Double.init) { featureDictionary["d7zUM"] = dzUMValue7 }
                    if let dzLMValue7 = row["d7zLM"].flatMap(Double.init) { featureDictionary["d7zLM"] = dzLMValue7 }

                                    let modelInput = alcoholInput(
                    _0xMe: featureDictionary["0xMe"] ?? 0.0,
                    _0xVr: featureDictionary["0xVr"] ?? 0.0,
                    _0xMx: featureDictionary["0xMx"] ?? 0.0,
                    _0xMi: featureDictionary["0xMi"] ?? 0.0,
                    _0xUM: featureDictionary["0xUM"] ?? 0.0,
                    _0xLM: featureDictionary["0xLM"] ?? 0.0,
                    _0yMe: featureDictionary["0yMe"] ?? 0.0,
                    _0yVr: featureDictionary["0yVr"] ?? 0.0,
                    _0yMx: featureDictionary["0yMx"] ?? 0.0,
                    _0yMn: featureDictionary["0yMn"] ?? 0.0,
                    _0yUM: featureDictionary["0yUM"] ?? 0.0,
                    _0yLM: featureDictionary["0yLM"] ?? 0.0,
                    _0zMe: featureDictionary["0zMe"] ?? 0.0,
                    _0zVr: featureDictionary["0zVr"] ?? 0.0,
                    _0zMx: featureDictionary["0zMx"] ?? 0.0,
                    _0zMi: featureDictionary["0zMi"] ?? 0.0,
                    _0zUM: featureDictionary["0zUM"] ?? 0.0,
                    _0zLM: featureDictionary["0zLM"] ?? 0.0,
                    d0xMe: featureDictionary["d0xMe"] ?? 0.0,
                    d0xVr: featureDictionary["d0xVr"] ?? 0.0,
                    d0xMx: featureDictionary["d0xMx"] ?? 0.0,
                    d0xMi: featureDictionary["d0xMi"] ?? 0.0,
                    d0xUM: featureDictionary["d0xUM"] ?? 0.0,
                    d0xLM: featureDictionary["d0xLM"] ?? 0.0,
                    d0yMe: featureDictionary["d0yMe"] ?? 0.0,
                    d0yVr: featureDictionary["d0yVr"] ?? 0.0,
                    d0yMx: featureDictionary["d0yMx"] ?? 0.0,
                    d0yMn: featureDictionary["d0yMn"] ?? 0.0,
                    d0yUM: featureDictionary["d0yUM"] ?? 0.0,
                    d0yLM: featureDictionary["d0yLM"] ?? 0.0,
                    d0zMe: featureDictionary["d0zMe"] ?? 0.0,
                    d0zVr: featureDictionary["d0zVr"] ?? 0.0,
                    d0zMx: featureDictionary["d0zMx"] ?? 0.0,
                    d0zMi: featureDictionary["d0zMi"] ?? 0.0,
                    d0zUM: featureDictionary["d0zUM"] ?? 0.0,
                    d0zLM: featureDictionary["d0zLM"] ?? 0.0,
                    _1xMe: featureDictionary["1xMe"] ?? 0.0,
                    _1xVr: featureDictionary["1xVr"] ?? 0.0,
                    _1xMx: featureDictionary["1xMx"] ?? 0.0,
                    _1xMi: featureDictionary["1xMi"] ?? 0.0,
                    _1xUM: featureDictionary["1xUM"] ?? 0.0,
                    _1xLM: featureDictionary["1xLM"] ?? 0.0,
                    _1yMe: featureDictionary["1yMe"] ?? 0.0,
                    _1yVr: featureDictionary["1yVr"] ?? 0.0,
                    _1yMx: featureDictionary["1yMx"] ?? 0.0,
                    _1yMn: featureDictionary["1yMn"] ?? 0.0,
                    _1yUM: featureDictionary["1yUM"] ?? 0.0,
                    _1yLM: featureDictionary["1yLM"] ?? 0.0,
                    _1zMe: featureDictionary["1zMe"] ?? 0.0,
                    _1zVr: featureDictionary["1zVr"] ?? 0.0,
                    _1zMx: featureDictionary["1zMx"] ?? 0.0,
                    _1zMi: featureDictionary["1zMi"] ?? 0.0,
                    _1zUM: featureDictionary["1zUM"] ?? 0.0,
                    _1zLM: featureDictionary["1zLM"] ?? 0.0,
                    d1xMe: featureDictionary["d1xMe"] ?? 0.0,
                    d1xVr: featureDictionary["d1xVr"] ?? 0.0,
                    d1xMx: featureDictionary["d1xMx"] ?? 0.0,
                    d1xMi: featureDictionary["d1xMi"] ?? 0.0,
                    d1xUM: featureDictionary["d1xUM"] ?? 0.0,
                    d1xLM: featureDictionary["d1xLM"] ?? 0.0,
                    d1yMe: featureDictionary["d1yMe"] ?? 0.0,
                    d1yVr: featureDictionary["d1yVr"] ?? 0.0,
                    d1yMx: featureDictionary["d1yMx"] ?? 0.0,
                    d1yMn: featureDictionary["d1yMn"] ?? 0.0,
                    d1yUM: featureDictionary["d1yUM"] ?? 0.0,
                    d1yLM: featureDictionary["d1yLM"] ?? 0.0,
                    d1zMe: featureDictionary["d1zMe"] ?? 0.0,
                    d1zVr: featureDictionary["d1zVr"] ?? 0.0,
                    d1zMx: featureDictionary["d1zMx"] ?? 0.0,
                    d1zMi: featureDictionary["d1zMi"] ?? 0.0,
                    d1zUM: featureDictionary["d1zUM"] ?? 0.0,
                    d1zLM: featureDictionary["d1zLM"] ?? 0.0,
                    _2xMe: featureDictionary["2xMe"] ?? 0.0,
                    _2xVr: featureDictionary["2xVr"] ?? 0.0,
                    _2xMx: featureDictionary["2xMx"] ?? 0.0,
                    _2xMi: featureDictionary["2xMi"] ?? 0.0,
                    _2xUM: featureDictionary["2xUM"] ?? 0.0,
                    _2xLM: featureDictionary["2xLM"] ?? 0.0,
                    _2yMe: featureDictionary["2yMe"] ?? 0.0,
                    _2yVr: featureDictionary["2yVr"] ?? 0.0,
                    _2yMx: featureDictionary["2yMx"] ?? 0.0,
                    _2yMn: featureDictionary["2yMn"] ?? 0.0,
                    _2yUM: featureDictionary["2yUM"] ?? 0.0,
                    _2yLM: featureDictionary["2yLM"] ?? 0.0,
                    _2zMe: featureDictionary["2zMe"] ?? 0.0,
                    _2zVr: featureDictionary["2zVr"] ?? 0.0,
                    _2zMx: featureDictionary["2zMx"] ?? 0.0,
                    _2zMi: featureDictionary["2zMi"] ?? 0.0,
                    _2zUM: featureDictionary["2zUM"] ?? 0.0,
                    _2zLM: featureDictionary["2zLM"] ?? 0.0,
                    d2xMe: featureDictionary["d2xMe"] ?? 0.0,
                    d2xVr: featureDictionary["d2xVr"] ?? 0.0,
                    d2xMx: featureDictionary["d2xMx"] ?? 0.0,
                    d2xMi: featureDictionary["d2xMi"] ?? 0.0,
                    d2xUM: featureDictionary["d2xUM"] ?? 0.0,
                    d2xLM: featureDictionary["d2xLM"] ?? 0.0,
                    d2yMe: featureDictionary["d2yMe"] ?? 0.0,
                    d2yVr: featureDictionary["d2yVr"] ?? 0.0,
                    d2yMx: featureDictionary["d2yMx"] ?? 0.0,
                    d2yMn: featureDictionary["d2yMn"] ?? 0.0,
                    d2yUM: featureDictionary["d2yUM"] ?? 0.0,
                    d2yLM: featureDictionary["d2yLM"] ?? 0.0,
                    d2zMe: featureDictionary["d2zMe"] ?? 0.0,
                    d2zVr: featureDictionary["d2zVr"] ?? 0.0,
                    d2zMx: featureDictionary["d2zMx"] ?? 0.0,
                    d2zMi: featureDictionary["d2zMi"] ?? 0.0,
                    d2zUM: featureDictionary["d2zUM"] ?? 0.0,
                    d2zLM: featureDictionary["d2zLM"] ?? 0.0,
                    _4xMe: featureDictionary["4xMe"] ?? 0.0,
                    _4xVr: featureDictionary["4xVr"] ?? 0.0,
                    _4xMx: featureDictionary["4xMx"] ?? 0.0,
                    _4xMi: featureDictionary["4xMi"] ?? 0.0,
                    _4xUM: featureDictionary["4xUM"] ?? 0.0,
                    _4xLM: featureDictionary["4xLM"] ?? 0.0,
                    _4yMe: featureDictionary["4yMe"] ?? 0.0,
                    _4yVr: featureDictionary["4yVr"] ?? 0.0,
                    _4yMx: featureDictionary["4yMx"] ?? 0.0,
                    _4yMn: featureDictionary["4yMn"] ?? 0.0,
                    _4yUM: featureDictionary["4yUM"] ?? 0.0,
                    _4yLM: featureDictionary["4yLM"] ?? 0.0,
                    _4zMe: featureDictionary["4zMe"] ?? 0.0,
                    _4zVr: featureDictionary["4zVr"] ?? 0.0,
                    _4zMx: featureDictionary["4zMx"] ?? 0.0,
                    _4zMi: featureDictionary["4zMi"] ?? 0.0,
                    _4zUM: featureDictionary["4zUM"] ?? 0.0,
                    _4zLM: featureDictionary["4zLM"] ?? 0.0,
                    d4xMe: featureDictionary["d4xMe"] ?? 0.0,
                    d4xVr: featureDictionary["d4xVr"] ?? 0.0,
                    d4xMx: featureDictionary["d4xMx"] ?? 0.0,
                    d4xMi: featureDictionary["d4xMi"] ?? 0.0,
                    d4xUM: featureDictionary["d4xUM"] ?? 0.0,
                    d4xLM: featureDictionary["d4xLM"] ?? 0.0,
                    d4yMe: featureDictionary["d4yMe"] ?? 0.0,
                    d4yVr: featureDictionary["d4yVr"] ?? 0.0,
                    d4yMx: featureDictionary["d4yMx"] ?? 0.0,
                    d4yMn: featureDictionary["d4yMn"] ?? 0.0,
                    d4yUM: featureDictionary["d4yUM"] ?? 0.0,
                    d4yLM: featureDictionary["d4yLM"] ?? 0.0,
                    d4zMe: featureDictionary["d4zMe"] ?? 0.0,
                    d4zVr: featureDictionary["d4zVr"] ?? 0.0,
                    d4zMx: featureDictionary["d4zMx"] ?? 0.0,
                    d4zMi: featureDictionary["d4zMi"] ?? 0.0,
                    d4zUM: featureDictionary["d4zUM"] ?? 0.0,
                    d4zLM: featureDictionary["d4zLM"] ?? 0.0,
                    _5xMe: featureDictionary["5xMe"] ?? 0.0,
                    _5xVr: featureDictionary["5xVr"] ?? 0.0,
                    _5xMx: featureDictionary["5xMx"] ?? 0.0,
                    _5xMi: featureDictionary["5xMi"] ?? 0.0,
                    _5xUM: featureDictionary["5xUM"] ?? 0.0,
                    _5xLM: featureDictionary["5xLM"] ?? 0.0,
                    _5yMe: featureDictionary["5yMe"] ?? 0.0,
                    _5yVr: featureDictionary["5yVr"] ?? 0.0,
                    _5yMx: featureDictionary["5yMx"] ?? 0.0,
                    _5yMn: featureDictionary["5yMn"] ?? 0.0,
                    _5yUM: featureDictionary["5yUM"] ?? 0.0,
                    _5yLM: featureDictionary["5yLM"] ?? 0.0,
                    _5zMe: featureDictionary["5zMe"] ?? 0.0,
                    _5zVr: featureDictionary["5zVr"] ?? 0.0,
                    _5zMx: featureDictionary["5zMx"] ?? 0.0,
                    _5zMi: featureDictionary["5zMi"] ?? 0.0,
                    _5zUM: featureDictionary["5zUM"] ?? 0.0,
                    _5zLM: featureDictionary["5zLM"] ?? 0.0,
                    d5xMe: featureDictionary["d5xMe"] ?? 0.0,
                    d5xVr: featureDictionary["d5xVr"] ?? 0.0,
                    d5xMx: featureDictionary["d5xMx"] ?? 0.0,
                    d5xMi: featureDictionary["d5xMi"] ?? 0.0,
                    d5xUM: featureDictionary["d5xUM"] ?? 0.0,
                    d5xLM: featureDictionary["d5xLM"] ?? 0.0,
                    d5yMe: featureDictionary["d5yMe"] ?? 0.0,
                    d5yVr: featureDictionary["d5yVr"] ?? 0.0,
                    d5yMx: featureDictionary["d5yMx"] ?? 0.0,
                    d5yMn: featureDictionary["d5yMn"] ?? 0.0,
                    d5yUM: featureDictionary["d5yUM"] ?? 0.0,
                    d5yLM: featureDictionary["d5yLM"] ?? 0.0,
                    d5zMe: featureDictionary["d5zMe"] ?? 0.0,
                    d5zVr: featureDictionary["d5zVr"] ?? 0.0,
                    d5zMx: featureDictionary["d5zMx"] ?? 0.0,
                    d5zMi: featureDictionary["d5zMi"] ?? 0.0,
                    d5zUM: featureDictionary["d5zUM"] ?? 0.0,
                    d5zLM: featureDictionary["d5zLM"] ?? 0.0,
                    _6xMe: featureDictionary["6xMe"] ?? 0.0,
                    _6xVr: featureDictionary["6xVr"] ?? 0.0,
                    _6xMx: featureDictionary["6xMx"] ?? 0.0,
                    _6xMi: featureDictionary["6xMi"] ?? 0.0,
                    _6xUM: featureDictionary["6xUM"] ?? 0.0,
                    _6xLM: featureDictionary["6xLM"] ?? 0.0,
                    _6yMe: featureDictionary["6yMe"] ?? 0.0,
                    _6yVr: featureDictionary["6yVr"] ?? 0.0,
                    _6yMx: featureDictionary["6yMx"] ?? 0.0,
                    _6yMn: featureDictionary["6yMn"] ?? 0.0,
                    _6yUM: featureDictionary["6yUM"] ?? 0.0,
                    _6yLM: featureDictionary["6yLM"] ?? 0.0,
                    _6zMe: featureDictionary["6zMe"] ?? 0.0,
                    _6zVr: featureDictionary["6zVr"] ?? 0.0,
                    _6zMx: featureDictionary["6zMx"] ?? 0.0,
                    _6zMi: featureDictionary["6zMi"] ?? 0.0,
                    _6zUM: featureDictionary["6zUM"] ?? 0.0,
                    _6zLM: featureDictionary["6zLM"] ?? 0.0,
                    d6xMe: featureDictionary["d6xMe"] ?? 0.0,
                    d6xVr: featureDictionary["d6xVr"] ?? 0.0,
                    d6xMx: featureDictionary["d6xMx"] ?? 0.0,
                    d6xMi: featureDictionary["d6xMi"] ?? 0.0,
                    d6xUM: featureDictionary["d6xUM"] ?? 0.0,
                    d6xLM: featureDictionary["d6xLM"] ?? 0.0,
                    d6yMe: featureDictionary["d6yMe"] ?? 0.0,
                    d6yVr: featureDictionary["d6yVr"] ?? 0.0,
                    d6yMx: featureDictionary["d6yMx"] ?? 0.0,
                    d6yMn: featureDictionary["d6yMn"] ?? 0.0,
                    d6yUM: featureDictionary["d6yUM"] ?? 0.0,
                    d6yLM: featureDictionary["d6yLM"] ?? 0.0,
                    d6zMe: featureDictionary["d6zMe"] ?? 0.0,
                    d6zVr: featureDictionary["d6zVr"] ?? 0.0,
                    d6zMx: featureDictionary["d6zMx"] ?? 0.0,
                    d6zMi: featureDictionary["d6zMi"] ?? 0.0,
                    d6zUM: featureDictionary["d6zUM"] ?? 0.0,
                    d6zLM: featureDictionary["d6zLM"] ?? 0.0,
                    _7xMe: featureDictionary["7xMe"] ?? 0.0,
                    _7xVr: featureDictionary["7xVr"] ?? 0.0,
                    _7xMx: featureDictionary["7xMx"] ?? 0.0,
                    _7xMi: featureDictionary["7xMi"] ?? 0.0,
                    _7xUM: featureDictionary["7xUM"] ?? 0.0,
                    _7xLM: featureDictionary["7xLM"] ?? 0.0,
                    _7yMe: featureDictionary["7yMe"] ?? 0.0,
                    _7yVr: featureDictionary["7yVr"] ?? 0.0,
                    _7yMx: featureDictionary["7yMx"] ?? 0.0,
                    _7yMn: featureDictionary["7yMn"] ?? 0.0,
                    _7yUM: featureDictionary["7yUM"] ?? 0.0,
                    _7yLM: featureDictionary["7yLM"] ?? 0.0,
                    _7zMe: featureDictionary["7zMe"] ?? 0.0,
                    _7zVr: featureDictionary["7zVr"] ?? 0.0,
                    _7zMx: featureDictionary["7zMx"] ?? 0.0,
                    _7zMi: featureDictionary["7zMi"] ?? 0.0,
                    _7zUM: featureDictionary["7zUM"] ?? 0.0,
                    _7zLM: featureDictionary["7zLM"] ?? 0.0,
                    d7xMe: featureDictionary["d7xMe"] ?? 0.0,
                    d7xVr: featureDictionary["d7xVr"] ?? 0.0,
                    d7xMx: featureDictionary["d7xMx"] ?? 0.0,
                    d7xMi: featureDictionary["d7xMi"] ?? 0.0,
                    d7xUM: featureDictionary["d7xUM"] ?? 0.0,
                    d7xLM: featureDictionary["d7xLM"] ?? 0.0,
                    d7yMe: featureDictionary["d7yMe"] ?? 0.0,
                    d7yVr: featureDictionary["d7yVr"] ?? 0.0,
                    d7yMx: featureDictionary["d7yMx"] ?? 0.0,
                    d7yMn: featureDictionary["d7yMn"] ?? 0.0,
                    d7yUM: featureDictionary["d7yUM"] ?? 0.0,
                    d7yLM: featureDictionary["d7yLM"] ?? 0.0,
                    d7zMe: featureDictionary["d7zMe"] ?? 0.0,
                    d7zVr: featureDictionary["d7zVr"] ?? 0.0,
                    d7zMx: featureDictionary["d7zMx"] ?? 0.0,
                    d7zMi: featureDictionary["d7zMi"] ?? 0.0,
                    d7zUM: featureDictionary["d7zUM"] ?? 0.0,
                    d7zLM: featureDictionary["d7zLM"] ?? 0.0)
        
                    let prediction = try! model.prediction(input: modelInput)
                print("Current Level: ", prediction.TAC_Reading)
                }
                

                }
            }
    
}
