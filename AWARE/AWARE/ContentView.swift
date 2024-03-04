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

    init() {
        UITabBar.appearance().backgroundColor = UIColor(Style.primaryColor)
        name = Auth.auth().currentUser?.displayName ?? ""
    }
    
    var body: some View {
        if viewModel.userSession != nil {
            TabView {
                // Page 1 Analytics
                AnalyticsView()
                    .environmentObject(enableDataCollectionObj)
                    .environmentObject(biometricsManager)
                    .tabItem {
                        Label("Analytics", systemImage: "heart.text.square")
                    }
                
                // Page 2 Contacts
                ContactListView()
                    .tabItem {
                        Label("Contacts", systemImage: "person.crop.circle")
                    }
                
                // Page 3 - Home / Toggle
                HomeView(name: $name)
                    .environmentObject(enableDataCollectionObj)
                    .environmentObject(biometricsManager)
                    .environmentObject(alertManager)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                // Page 4 Navigation
                NavigationServicesView()
                    .tabItem {
                        Label("Navigation", systemImage: "map")
                    }
                
                // Page 5 Settings
                SettingsView(name: $name)
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
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
            .fullScreenCover(isPresented: $showEmergencySOS) {
                EmergencySOSView(showCalling911: $showCalling911)
            }
            .fullScreenCover(isPresented: $showCalling911) {
                Calling911View()
                    .environmentObject(alertManager)
            }
            .onAppear(){
                    requestNotificationPermissions()
            }

            .onChange(of: biometricsManager.intoxLevel) { oldValue, newValue in
                guard oldValue != newValue else {
                    print("value not different")
                    return // Return early if the value hasn't changed
                }
                print("sending notif")
                
                sendPhoneNotification(level: biometricsManager.intoxLevel)
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
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
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
        let content = UNMutableNotificationContent()
        content.title="Intoxication Level Alert"
        content.sound=UNNotificationSound.default
        switch level {
        case 0:
            content.subtitle = "Current level: sober"
        case 1:
            content.subtitle = "Current level: tipsy"
        case 2:
            content.subtitle = "Current level: moderately impaired"
        case 3:
            content.subtitle = "Current level: emergency"
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
