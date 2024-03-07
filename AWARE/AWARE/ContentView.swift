import SwiftUI
import HealthKit
import Firebase
import FirebaseCore
import FirebaseDatabase
import FirebaseAnalytics
import FirebaseAnalyticsSwift

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var enableDataCollectionObj = EnableDataCollection()
    @StateObject var biometricsManager = BiometricsManager()
    @StateObject var alertManager = AlertManager()

    @State private var showEmergencySOS = false
    @State private var showCalling911 = false
    @State private var name: String
    @State private var selection: Int
    @State private var testIntoxLevel: Int
    @State private var tabBarColor: Color
    @State private var isCustomColorEnabled: Bool

    init() {
        _selection = State(initialValue: 3)
        _name = State(initialValue: Auth.auth().currentUser?.displayName ?? "")
        _testIntoxLevel = State(initialValue: -1)
        _tabBarColor = State(initialValue: Color(Style.primaryColor)) // Set the default color
        _isCustomColorEnabled = State(initialValue: true)

        _showEmergencySOS = State(initialValue: false)
        _showCalling911 = State(initialValue: false)

        UITabBar.appearance().backgroundColor = UIColor(tabBarColor)
    }
    
    var body: some View {
        if viewModel.userSession != nil {
            // @State var selection = 3
            TabView(selection:$selection) {
                // Page 1 Analytics
                AnalyticsView()
                    .environmentObject(enableDataCollectionObj)
                    .environmentObject(biometricsManager)
                    .tabItem {
                        Label("Analytics", systemImage: "heart.text.square")
                    }.tag(1)
                
                // Page 2 Contacts
                ContactListView()
                    .tabItem {
                        Label("Contacts", systemImage: "person.crop.circle")
                    }.tag(2)
                
                // Page 3 - Home / Toggle
                HomeView(name: $name)
                    .environmentObject(enableDataCollectionObj)
                    .environmentObject(biometricsManager)
                    .environmentObject(alertManager)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }.tag(3)
                
                // Page 4 Navigation
                NavigationServicesView()
                    .tabItem {
                        Label("Navigation", systemImage: "map")
                    }.tag(4)
                
                // Page 5 Settings
                SettingsView(name: $name)
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }.tag(5)
                }
                .onAppear {
                    if selection != 3 {
                        selection = 3 // Set the initial tab selection to HomeView (tag 3) only on the first appearance
                    }
                    requestNotificationPermissions()
            }
            .onReceive(viewModel.$userSession) { userSession in
                if userSession != nil {
                    name = Auth.auth().currentUser?.displayName ?? "user"
                }
            }
            .onReceive(alertManager.$intoxLevel) { newIntoxLevel in
                if newIntoxLevel == 3 {
                    showEmergencySOS = true
                }
            }
            .onChange(of: biometricsManager.intoxLevel) { oldValue, newValue in
                
                guard oldValue != newValue else{
                    //return if new level same as old
                    print("new intoxLevel not different")
                    return
                }
                print("sending notification")
                enableDataCollectionObj.sendLevelToWatch(level: biometricsManager.intoxLevel)
                sendPhoneNotification(level: biometricsManager.intoxLevel)
                //TODO: update alerManager.intoxLevel here too
            }
            .fullScreenCover(isPresented: $showEmergencySOS) {
                EmergencySOSView(showCalling911: $showCalling911)
            }
            .fullScreenCover(isPresented: $showCalling911) {
                Calling911View()
                    .environmentObject(alertManager)
            }

        } else {
            LoginView()
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
    private func requestNotificationPermissions(){
        UNUserNotificationCenter.current().getNotificationSettings {
            settings in
            if settings.authorizationStatus != .authorized{
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {success, error in
                    if success {
                        print("Notification request success")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
            else{
                print("Already authorized for notifications")
            }
        }
    }
    
    private func sendPhoneNotification(level: Int){
        //notification on phone also appears on watch
        
        let content = UNMutableNotificationContent()
        content.title = "Intoxication Level Alert"
        content.sound=UNNotificationSound.default
        switch level {
        case 0:
            content.subtitle = "Current level: SOBER"
        case 1:
            content.subtitle = "Current level: TIPSY"
        case 2:
            content.subtitle = "Current level: DRUNK"
        case 3:
            content.subtitle = "Current level: EMERGENCY"
        default:
            content.subtitle = "Current level: \(level)"
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        
        UNUserNotificationCenter.current().add(request){ (error) in
            if let error = error{
                print(error.localizedDescription)
            }else{
                print("scheduled successfully")
            }
        }
    }
}
