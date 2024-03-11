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
    @State private var selection = 3
    @State private var name: String
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Style.primaryColor)
        self.name = Auth.auth().currentUser?.displayName ?? ""
    }
    
    var body: some View {
        if viewModel.userSession != nil {
            TabView(selection:$selection) {
                // Page 1 Analytics
                AnalyticsView()
                    .environmentObject(enableDataCollectionObj)
                    .environmentObject(biometricsManager)
                    .accentColor(Style.accentColor)
                    .tabItem {
                        Label("Analytics", systemImage: "heart.text.square")
                    }.tag(1)
                
                // Page 2 Contacts
                ContactListView()
                    .accentColor(Style.accentColor)
                    .tabItem {
                        Label("Contacts", systemImage: "person.crop.circle")
                    }.tag(2)
                
                // Page 3 - Home / Toggle
                HomeView(name: $name)
                    .environmentObject(enableDataCollectionObj)
                    .environmentObject(biometricsManager)
                    .environmentObject(alertManager)
                    .accentColor(Style.accentColor)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }.tag(3)
                
                // Page 4 Navigation
                NavigationServicesView()
                    .accentColor(Style.accentColor)
                    .tabItem {
                        Label("Navigation", systemImage: "map")
                    }.tag(4)
                
                // Page 5 Settings
                SettingsView(name: $name)
                    .environmentObject(viewModel)
                    .accentColor(Style.accentColor)
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
            .accentColor(Style.highlightColor)
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
                if biometricsManager.intoxLevel > alertManager.intoxLevel {
                    alertManager.intoxLevel = biometricsManager.intoxLevel
                }
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
    
    private func requestNotificationPermissions() {
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
            } else {
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
            content.subtitle = "Current level: TIPSY - Drink some water!"
        case 2:
            content.subtitle = "Current level: DRUNK - Slow down, and call an Uber or a friend!"
        case 3:
            content.subtitle = "Current level: EMERGENCY"
        default:
            content.subtitle = "Current level: \(level)"
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("scheduled successfully")
            }
        }
    }
}
