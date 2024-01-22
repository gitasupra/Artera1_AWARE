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
    @EnvironmentObject var healthStore: HKHealthStore
    @State public var heartRate: [HeartRateDataPoint] = []
    @State private var heartRateIdx: Int = 0
    @StateObject var enableDataCollectionObj = EnableDataCollection()
    @Binding var enableDataCollection: Bool
    @Binding var shouldHide: Bool
    @EnvironmentObject var motion: CMMotionManager
    
    // heart rate data struct
   struct HeartRateDataPoint: Identifiable {
       let heartRate: Double
       var myIndex: Int = 0
       var id: UUID
   }

    var body: some View {
        VStack {
            if (enableDataCollectionObj.enableDataCollection == 0) {
                if !self.$shouldHide.wrappedValue {
                    Text("Disable Data Collection")
                        .multilineTextAlignment(.center)
                    Button(action: {
                        enableDataCollection.toggle()
                        enableDataCollectionObj.toggleOn()
                    }) {
                        Image(systemName: "touchid")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                        .controlSize(.extraLarge)
                    }
                }
            } else {
                Text("Enable Data Collection")
                    .multilineTextAlignment(.center)
                Button {
                    enableDataCollection.toggle()
                    enableDataCollectionObj.toggleOff()
                } label: {
                    Image(systemName: "touchid")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .controlSize(.extraLarge)
                }
            }
        }
        .onChange(of: enableDataCollectionObj.enableDataCollection)
        {
            if (enableDataCollectionObj.enableDataCollection != 0) {
                startDeviceMotion()
            } else {
                self.motion.stopDeviceMotionUpdates()
            }
        }
    }
    
    func startDeviceMotion() {
        
        let heartRateQuantity = HKUnit(from: "count/min")
        let accIdx = 0
            
            
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0 / 50.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            // Configure a timer to fetch the device motion data
            let timer = Timer(fire: Date(), interval: (1.0 / 50.0), repeats: true,
                               block: { (timer) in
                if let data = self.motion.deviceMotion {
                    // Get attitude data
                    let attitudeX = data.attitude.pitch
                    let attitudeY = data.attitude.roll
                    let attitudeZ = data.attitude.yaw
                    // Get accelerometer data
                    let accelerometerX = data.userAcceleration.x
                    let accelerometerY = data.userAcceleration.y
                    let accelerometerZ = data.userAcceleration.z
                    // Get the gyroscope data
                    let gyroX = data.rotationRate.x
                    let gyroY = data.rotationRate.y
                    let gyroZ = data.rotationRate.z
                    
                }
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

                        
                        let newHeart:HeartRateDataPoint = HeartRateDataPoint(heartRate: lastHeartRate, myIndex: heartRateIdx, id: UUID())
                        heartRateIdx += 1
                        heartRate.append(newHeart)
                        WCSession.default.transferUserInfo(["lastHeartRate": lastHeartRate])
                        print(newHeart)
                    }

                

                let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: .heartRate)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
                
                query.updateHandler = updateHandler
                
                
                healthStore.execute(query)
            })
            
            // Add the timer to the current run loop
            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        }
        
    }
}

#Preview{
    ContentView()
}
