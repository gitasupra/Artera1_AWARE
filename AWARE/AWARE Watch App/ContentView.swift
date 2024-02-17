import SwiftUI
import HealthKit
import CoreMotion
import WatchConnectivity

struct ContentView: View {
    @State private var enableDataCollection = false
    @State private var shouldHide = false

    var body: some View {
        NavigationView {
            TabView {
                // Page 1
                Page1View()
                    .tabItem {
                        Label("AWARE", systemImage: "person.circle.fill")
                    }

                // Page 2
                Page2View(enableDataCollection: $enableDataCollection, shouldHide: $shouldHide)
                    .tabItem {
                        Label("Page 2", systemImage: "info.circle")
                    }
            }
        }
    }
    
}

struct Page1View: View {
    let accentColor:Color = .purple

    var body: some View {
        VStack {
            Image("AWARE_Logo_2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
        }
    }
}

struct Page2View: View {
    @StateObject var enableDataCollectionObj = EnableDataCollection()
    @StateObject var biometricsManager = BiometricsManager()
    @Binding var enableDataCollection: Bool
    @Binding var shouldHide: Bool
    
    var body: some View {
        VStack {
            if (enableDataCollectionObj.enableDataCollection == 0) {
                if !self.$shouldHide.wrappedValue {
                    Text("Enable Data Collection")
                        .multilineTextAlignment(.center)
                    Button(action: {
                        enableDataCollectionObj.toggleOn()
                        enableDataCollection.toggle()
                    }) {
                        Image(systemName: "touchid")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                            .controlSize(.extraLarge)
                    }
                }
            } else {
                Text("Disable Data Collection")
                    .multilineTextAlignment(.center)
                Button {
                    enableDataCollectionObj.toggleOff()
                    enableDataCollection.toggle()
                } label: {
                    Image(systemName: "touchid")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                        .controlSize(.extraLarge)
                }
            }
        }
        .onChange(of: enableDataCollection) {
            if (enableDataCollection) {
                biometricsManager.startDeviceMotion()
                biometricsManager.startHeartRate()
            } else {
                biometricsManager.stopDeviceMotion()
                biometricsManager.stopHeartRate()
            }
        }
    }
}

#Preview{
    ContentView()
}
