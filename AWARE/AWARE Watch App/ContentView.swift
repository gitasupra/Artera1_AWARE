import SwiftUI
import HealthKit
import CoreMotion
import WatchConnectivity

struct ContentView: View {
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
                Page2View(shouldHide: $shouldHide)
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
    @Binding var shouldHide: Bool
    
    var body: some View {
        VStack {
            if (enableDataCollectionObj.enableDataCollection == 0) {
                if !self.$shouldHide.wrappedValue {
                    Text("Enable Drinking Mode")
                    Button {
                        enableDataCollectionObj.toggleOn()
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 110, height: 100)
                            
                            Image("cocktail")
                                .frame(width: 50, height: 50)
                                .controlSize(.extraLarge)
                                .overlay(Color.gray.opacity(1))
                                .mask(Image("cocktail").resizable())
                        }
                    }
                }
            } else {
                Text("Disable Drinking Mode")
                Button {
                    enableDataCollectionObj.toggleOff()
                } label: {
                    ZStack {
                        Circle()
                            .foregroundColor(.green)
                            .frame(width: 100, height: 100)
                        
                        Image("cocktail.fill")
                            .frame(width: 50, height: 50)
                            .controlSize(.extraLarge)
                            .overlay(Color.white.opacity(1))
                            .mask(Image("cocktail.fill").resizable())
                    }
                }
            }
        }
        .onChange(of: enableDataCollectionObj.enableDataCollection) {
            if (enableDataCollectionObj.enableDataCollection == 1) {
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

