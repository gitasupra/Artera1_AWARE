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
                self.ref.child("users").child("1").setValue(["username": "test"])
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
                                    .foregroundColor(.green)
                                    .controlSize(.extraLarge)
                            }.padding()
                            Text("Disable Data Collection")
                            Spacer()
                        }
                    } else {
                        Button(action: {
                                enableDataCollectionObj.toggleOff()
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
