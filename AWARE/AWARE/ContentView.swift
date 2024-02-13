import SwiftUI
import HealthKit
import CoreMotion
import Charts
import Firebase
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseDatabase

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var enableDataCollectionObj = EnableDataCollection()
    
    // database
    //FIXME may be loading DB every time, ideally in .onload
    let ref = Database.database().reference()

    var body: some View {
        Group{
            if viewModel.userSession != nil{
                TabView {
                    // Page 1 Graphs
                    GraphView()
                        .environmentObject(enableDataCollectionObj)
                        .tabItem {
                            Label("Graphs", systemImage: "chart.pie.fill")
                        }
                    
                    // Page 2 Contacts
                    ContactsView()
                        .tabItem {
                            Label("Contacts", systemImage: "person.crop.circle")
                        }
                    
                    // Page 3 - Home / Toggle
                    HomeView()
                        .environmentObject(enableDataCollectionObj)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    // Page 4 Analytics
                    AnalyticsView()
                        .tabItem {
                            Label("Analytics", systemImage: "heart.text.square")
                        }
                    
                    // Page 5 Settings
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                }.accentColor(Style.accentColor)
            }
            else {
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
