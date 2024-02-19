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
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var enableDataCollectionObj = EnableDataCollection()
    @State private var shouldHide = false
    
    @StateObject var alertManager = AlertManager()
    @State private var showEmergencySOS = false
    @State private var showCalling911 = false
    
    // setting toggles
    @State private var name = ""
    @State private var isNotificationEnabled = true
    @State private var isContactListEnabled = true
    @State private var isUberEnabled = false
    @State private var isEmergencyContacts = false
    @State private var isHelpTipsEnabled = true
    
    // biometric data collection and graphs
    @StateObject var biometricsManager = BiometricsManager()
    @State var showHeartChart: Bool = true
    @State var showAccChart: Bool = true
    @State private var selectedTab = 1
    
    // database
    //FIXME may be loading DB every time, ideally in .onload
    let ref=Database.database().reference()
    
    // style variables
    let accentColor:Color = Color(red: 148/255, green: 40/255, blue: 186/255)
    let primaryColor:Color = Color(red: 45/255, green: 24/255, blue: 92/255)
    let secondaryColor:Color = Color(red: 250/255, green: 51/255, blue: 92/255)
    let backgroundColor:Color = .black
    struct CustomButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .cornerRadius(6)
                .background(Color.accentColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
                .padding([.top, .bottom], 2)
        }
    }
    
    init() {
        // UINavigationBar.appearance().backgroundColor = UIColor(primaryColor)
        UITabBar.appearance().backgroundColor = UIColor(primaryColor)
    }
    
    var body: some View {
        Group{
            if viewModel.userSession != nil{
                TabView(selection: $selectedTab) {
                    // Page 1 Analytics
                    NavigationView {
                        VStack(spacing: 10) {
                            NavigationStack {
                                CalendarView()
                                    .padding(.bottom, 10)
                                VStack {
                                    Button {
                                        showHeartChart = true
                                    } label: {
                                        Text("View Heart Rate Data")
                                    }
                                    .navigationDestination(
                                        isPresented: $showHeartChart) {
                                            heartRateGraph(heartRate: enableDataCollectionObj.heartRateList)
                                        }
                                        .buttonStyle(CustomButtonStyle())
                                    
                                    Button {
                                        showAccChart = true
                                    } label: {
                                        Text("View Walking Steadiness Data")
                                    }
                                    .navigationDestination(
                                        isPresented: $showAccChart) {
                                            accelerometerGraph(acc: biometricsManager.acc)
                                        }
                                        .buttonStyle(CustomButtonStyle())
                                }
                            }
                        }.navigationBarTitle("Analytics", displayMode: .large)
                    }.onLoad{
                        //used to test db write
                        //self.ref.child("users").child("1").setValue(["username": "test3"])
                    }
                    .tabItem {
                        Label("Analytics", systemImage: "heart.text.square")
                    }
                    
                    // Page 2 Contacts
                    ContactListView()
                        .tabItem {
                            Label("Contacts", systemImage: "person.crop.circle")
                        }
                    
                    // Page 3 - Home / Toggle
                    VStack(alignment: .center) {
                        HStack (alignment: .center){
                            Spacer()
                            Image("testlogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 50)
                            Image("testicon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                            Spacer()
                        }
                        .background(primaryColor)
                        
                        Text("Hello, Name!")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            .padding()
                        Text("Welcome to AWARE")
                            .font(.title)
                            .padding()
                        
                        Text("Explore app features or enable drinking mode to get started.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            VStack {
                                Text("Estimated Intoxication Level:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("0")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(20)
                        }
                        .padding()
                        
                        Spacer()
                        
                        
                        if (enableDataCollectionObj.enableDataCollection == 0) {
                            if !self.$shouldHide.wrappedValue {
                                Button(action: {
                                    enableDataCollectionObj.toggleOn()
                                }) {
                                    Image(systemName: "touchid")
                                        .font(.system(size: 100))
                                        .foregroundColor(.red)
                                        .controlSize(.extraLarge)
                                }.padding()
                                Text("Enable Drinking Mode")
                                Spacer()
                            }
                        } else {
                            Button(action: {
                                enableDataCollectionObj.toggleOff()
                            }) {
                                Image(systemName: "touchid")
                                    .font(.system(size: 100))
                                    .foregroundColor(.green)
                                    .controlSize(.extraLarge)
                            }.padding()
                            Text("Disable Drinking Mode")
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .onChange(of: enableDataCollectionObj.enableDataCollection) {
                    if (enableDataCollectionObj.enableDataCollection == 1) {
                        biometricsManager.startDeviceMotion()
                        biometricsManager.startHeartRate()
                    } else {
                        biometricsManager.stopDeviceMotion()
                        biometricsManager.stopHeartRate()
                    }
                    }.tag(1)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    // Page 4 Navigation
                    NavigationView {
                        VStack(alignment: .center) {
                            Spacer().frame(height: 20)
                            LocationView()
                        }.navigationBarTitle("Navigation Services", displayMode: .large)
                    }
                    .tabItem {
                        Label("Navigation", systemImage: "map")
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
}

struct CalendarView: View {
    // Define a struct to represent a day's drinking level
    struct Day: Hashable {
        var date: Date
        var level: Int // Drinking level for the day (-1 to 3)
        
        // Implementing hash(into:) method required by Hashable protocol
        func hash(into hasher: inout Hasher) {
            hasher.combine(date)
        }
    }
    
    // Define your calendar data
    var calendarData: [[Day]] {
        let currentDate = Date()
        let startDate = currentDate.startOfMonth()
        let endDate = currentDate.endOfMonth()
        
        var calendarData = [[Day]]()
        var currentWeek = [Day]()
        
        var dayIterator = startDate
        while dayIterator <= endDate {
            let level: Int
            if dayIterator <= currentDate {
                level = Int.random(in: 0...3)
            } else {
                level = -1 // No info for future days
            }
            currentWeek.append(Day(date: dayIterator, level: level))
            
            if dayIterator.weekday == 7 {
                if calendarData.isEmpty && currentWeek.count < 7 {
                    // If it's the first week and doesn't have 7 days, fill remaining days at the beginning
                    let invisibleDays = Array(repeating: Day(date: Date(), level: -2), count: 7 - currentWeek.count)
                    currentWeek.insert(contentsOf: invisibleDays, at: 0)
                }
                calendarData.append(currentWeek)
                currentWeek = []
            }
            
            dayIterator = Calendar.current.date(byAdding: .day, value: 1, to: dayIterator)!
        }
        
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                // Fill remaining days of the week with invisible days
                currentWeek.append(Day(date: Date(), level: -2))
            }
            calendarData.append(currentWeek)
        }
        
        return calendarData
    }
    
    // Define colors for different drinking levels
    let colors: [Color] = [.gray, .green, .yellow, .orange, .red]
    
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
        VStack(alignment: .leading, spacing: 10) {
            Text("Today")
                .font(.title)
                .padding(.bottom, 10)
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
                                .background(currentDay == dayOnly ? Color.accentColor : .black)
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
                .padding(.bottom, 20)
            
            Text("Intoxication History")
                .font(.title)
                .padding(.bottom, 10)
            
            ForEach(calendarData, id: \.self) { week in
                HStack(spacing: 10) {
                    ForEach(week, id: \.self) { day in
                        ZStack {
                            if day.level != -2 {
                                Circle()
                                    .foregroundColor(colors[day.level + 1])
                                    .frame(width: 40, height: 40)
                                
                                if day.level != -1 {
                                    Text("\(day.date.day)")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                            } else {
                                Circle()
                                    .foregroundColor(Color.clear)
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension Date {
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        let lastDayOfMonth = range.upperBound - 1
        return calendar.date(byAdding: .day, value: lastDayOfMonth, to: startOfMonth())!
    }
    
    var day: Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }
    
    var weekday: Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }
}
