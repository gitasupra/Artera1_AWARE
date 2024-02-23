import SwiftUI
import HealthKit
import Firebase
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseDatabase

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
        } else {
            LoginView()
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
