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
    
    
    // setting toggles
    @State private var name = ""
    @State private var isNotificationEnabled = true
    @State private var isContactListEnabled = true
    @State private var isUberEnabled = false
    @State private var isEmergencyContacts = false
    @State private var isHelpTipsEnabled = true
    
    
    
    
    
    
    
    
    // database
    //FIXME may be loading DB every time, ideally in .onload
    let ref=Database.database().reference()

    
    
    
    
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
                    GraphView()
                        .tabItem {
                            Label("Graphs", systemImage: "chart.pie.fill")
                        }
            
            // Page 3 Contacts
                ContactsView()
                .tabItem {
                    Label("Contacts", systemImage: "person.crop.circle")
                }
            
            // Page 3 - Home / Toggle
            HomeView()
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
                                            .background(currentDay == dayOnly ? Color.Style.accentColor : Style.backgroundColor)
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
                                .buttonStyle(Style.CustomButtonStyle())
                        }
                        
                        Spacer()
                    }
                }
                .tabItem {
                    Label("Analytics", systemImage: "heart.text.square")
                }
                
                // Page 5 Settings
                SettingsView()
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
