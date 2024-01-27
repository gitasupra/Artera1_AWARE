import SwiftUI
import HealthKit
import CoreMotion
import Charts
import Firebase
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseDatabase

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
    
    @EnvironmentObject var theme: Theme
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
    
    // accelerometer data struct
    struct AccelerometerDataPoint: Identifiable {
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
                    GraphsView().tabItem {
                        Label("Graphs", systemImage: "chart.pie.fill")
                    }
                    
                    // Page 2 Contacts
                    ContactsView().tabItem {
                        Label("Contacts", systemImage: "person.crop.circle")
                    }
                    
                    // Page 3 Toggle
                    ToggleView().tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    
                    // Page 4 Analytics
                    AnalyticsView().tabItem {
                        Label("Analytics", systemImage: "heart.text.square")
                    }
                    
                    // Page 5 Settings
                    SettingsView().tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
                .accentColor(theme.accentColor)
            }
            else{
                LoginView()
            }
        }
        
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
                    accIdx += 1
                    
                    let new:AccelerometerDataPoint = AccelerometerDataPoint(x: Double(accelerometer.x), y: Double(accelerometer.y), z: Double(accelerometer.z), myIndex: accIdx, id: UUID())
                    
                    acc.append(new)
                    
                }
                
                
            })
            
            // Add the timer to the current run loop
            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
