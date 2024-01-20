import SwiftUI
import HealthKit
import CoreMotion
import Charts


struct ContentView: View {
    
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
    
    
    var body: some View {
        Group{
            if viewModel.userSession != nil{
                TabView {
                    // Page 1 Graphs
                    GraphsView().tabItem {Label("Graphs", systemImage: "chart.pie.fill")}
                    
                    // Page 2 Contacts
                    ContactsView().tabItem {Label("Contacts", systemImage: "person.crop.circle")}
                    
                    // Page 3 - Home / Toggle
                    ToggleView().tabItem {Label("Home", systemImage: "house.fill")}
                    
                    // Page 4 Analytics
                    AnalyticsView().tabItem {Label("Analytics", systemImage: "heart.text.square")}
                    
                    // Page 5 Settings
                    SettingsView().tabItem {Label("Settings", systemImage: "gearshape.fill")}
                    
                }.accentColor(accentColor)
            }
            
            struct ContentView_Previews: PreviewProvider {
                static var previews: some View {
                    ContentView()
                }
            }
        }
    }
}
