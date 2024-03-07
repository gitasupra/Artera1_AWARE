import SwiftUI
import HealthKit
import CoreMotion
import WatchConnectivity

struct ContentView: View {
    @State private var shouldHide = false
    @State private var selection: Int // Declare selection here

        init() {
            _selection = State(initialValue: 0) // Set initial value here
            

        }

    var body: some View {
        NavigationView {
            TabView(selection:$selection) {
                // Page 1
                Page1View()
                    .tabItem {
                        Label("AWARE", systemImage: "person.circle.fill")
                    }.tag(1)

                // Page 2
                Page2View(shouldHide: $shouldHide)
                    .tabItem {
                        Label("Page 2", systemImage: "info.circle")
                    }.tag(2)
            }
            .onAppear {
                // Set the initial tab selection to HomeView (tag 3) only on the first appearance
                if selection != 2 {
                    selection = 2
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
    @State private var testIntoxLevel = 0;// Use for testing on simulator (Values: 0, 1, 2), uncomment alertManager if statement code for iPhone testing

    
    var body: some View {
    

        VStack {
            if (enableDataCollectionObj.enableDataCollection == 0) {
                if !self.$shouldHide.wrappedValue {
                    Text("Enable Drinking Mode")
                        .multilineTextAlignment(.center)
                    Button(action: {
                        enableDataCollectionObj.toggleOn()
                    }) {
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
                Button(action: {
                    enableDataCollectionObj.toggleOff()
                }) {
                    ZStack {
                        Circle()
                        .foregroundColor(enableDataCollectionObj.intoxLevel == 0 ? Style.soberButtonFillColor : (enableDataCollectionObj.intoxLevel == 1 ? Style.tipsyButtonFillColor : (enableDataCollectionObj.intoxLevel == 2 ? Style.drunkButtonFillColor : (enableDataCollectionObj.intoxLevel == 3 ? Style.dangerButtonFillColor : Style.primaryColor ))))
//                                               .frame(width: 110, height: 100)
                        .frame(width: 110, height: 100)

                        Image("cocktail.fill")
                            .frame(width: 50, height: 50)
                            .controlSize(.extraLarge)
                                .overlay(Color.white.opacity(1))
                                .mask(Image("cocktail.fill").resizable())

                        Image(systemName: "bubbles.and.sparkles")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                                               .offset(x: 5, y: -25)
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

