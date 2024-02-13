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
    @Binding var enableDataCollection: Bool
    @Binding var shouldHide: Bool
    @EnvironmentObject var motion: CMMotionManager
    @EnvironmentObject var healthStore: HKHealthStore
    @State private var timer: Timer?
    
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
        .onChange(of: enableDataCollection)
        {
            if (enableDataCollection) {
                startHeartRate()
            } else {
                stopHeartRate()
            }
        }
    }
    
    func startHeartRate() {
        
        let heartRateQuantity = HKUnit(from: "count/min")
        var heartRateIdx = 0
        
        
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            // Configure a timer to fetch the device motion data
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true,
                                         block: { (timer) in
                let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
                
                let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
                    query, samples, deletedObjects, queryAnchor, error in
                    
                    
                    guard let samples = samples as? [HKQuantitySample] else {
                        return
                    }
                    
                    var lastHeartRate = 0.0
                    
                    for sample in samples {
                        
                        lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
                    }
                    
                    heartRateIdx += 1
                    WCSession.default.transferUserInfo(["lastHeartRate": lastHeartRate, "heartRateIdx": heartRateIdx])
                }
                
                
                
                let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: .heartRate)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
                
                
                healthStore.execute(query)
            })
        }
        
    }
    
    func stopHeartRate() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview{
    ContentView()
}
