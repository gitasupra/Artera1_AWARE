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
    @State private var selection: Int // Declare selection here
    
    @State private var testIntoxLevel = -1; // Use for testing on simulator (Values: 0, 1, 2), uncomment alertManager if statement code for iPhone testing


    init() {
        UITabBar.appearance().backgroundColor = UIColor(Style.primaryColor)

        name = Auth.auth().currentUser?.displayName ?? ""
        _selection = State(initialValue: 3) // Set initial value here
    }
    
    var body: some View {
        if viewModel.userSession != nil {
//            @State var selection = 3
            TabView(selection:$selection) {
                // Page 1 Analytics
                AnalyticsView()
                    .environmentObject(enableDataCollectionObj)
                    .environmentObject(biometricsManager)
                    .tabItem {
                        Label("Analytics", systemImage: "heart.text.square")
                    } .tag(1)
                
                // Page 2 Contacts
                ContactListView()
                    .tabItem {
                        Label("Contacts", systemImage: "person.crop.circle")
                    } .tag(2)
                
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
