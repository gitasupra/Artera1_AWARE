import SwiftUI

struct ContentView: View {
    @State private var enableDataCollection = false
    @State private var shouldHide = false
    
    var body: some View {
        TabView {
            // Page 1 - Home / Toggle
            VStack(alignment: .center) {
                Text("AWARE")
                    .font(.system(size: 36)) // Adjust the font size for the title
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100)) // Adjust the font size to make the image bigger
                    .foregroundColor(.gray)
                    .padding()
                
                if enableDataCollection {
                    if !self.$shouldHide.wrappedValue {
                        Text("Disable Data Collection")
                            .padding()
                        Button {
                            enableDataCollection.toggle()
                            print(enableDataCollection)
                        } label: {
                            Image(systemName: "touchid")
                                .font(.system(size: 50)) // Adjust the font size for the button image
                                .foregroundColor(.white)
                                .background(Color.red)
                                .controlSize(.extraLarge)
                        }
                    }
                } else {
                    Text("Enable Data Collection")
                        .padding()
                    Button {
                        enableDataCollection.toggle()
                        print(enableDataCollection)
                    } label: {
                        Image(systemName: "touchid")
                            .font(.system(size: 50)) // Adjust the font size for the button image
                            .foregroundColor(.white)
                            .background(Color.green)
                            .controlSize(.extraLarge)
                    }
                }
            }
            .tabItem {
                Label("Home", systemImage: "1.circle")
            }
            
            // Page 2 Graphs
            NavigationView {
                VStack(alignment: .center) {
                    Text("Graphs")
                        .font(.system(size: 36))
                    
                    NavigationLink(destination: Text("Heart Rate Data")) {
                        Button("View Heart Rate Data") {}
                    }
                    
                    NavigationLink(destination: Text("Breathing Rate Data")) {
                        Button("View Breathing Rate Data") {}
                    }
                    
                    NavigationLink(destination: Text("Walking Steadiness Data")) {
                        Button("View Walking Steadiness Data") {}
                    }
                }
            }
            .tabItem {
                Label("Graphs", systemImage: "2.circle")
            }
            
            // Page 3 User
            VStack(alignment: .center) {
                Text("User")
                    .font(.system(size: 36))
            }
            .tabItem {
                Label("User", systemImage: "3.circle")
            }
            
            // Page 4 Today
            NavigationView {
                VStack(alignment: .center) {
                    Text("Today")
                        .font(.system(size: 36))
                    
                    NavigationLink(destination: Text("Past Holistic Drunkenness Data Collection")) {
                        Button("View Past Holistic Drunkenness Data Collection") {}
                    }
                }
            }
            .tabItem {
                Label("Today", systemImage: "4.circle")
            }
            
            // Page 5 Settings
            VStack(alignment: .center) {
                Text("Settings")
                    .font(.system(size: 36))
            }
            .tabItem {
                Label("Settings", systemImage: "5.circle")
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
