//
//  BiometricsManager.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/17/24.
//

import Charts
import SwiftUI
import HealthKit
import CoreMotion
import WatchConnectivity

class BiometricsManager: ObservableObject {
    let motion = CMMotionManager()
    let healthStore = HKHealthStore()
    var timer: Timer?
    
    // accelerometer data variables
    var acc: [AccelerometerDataPoint] = []
    var accIdx: Int = 0
    
    // accelerometer data struct
    struct AccelerometerDataPoint: Identifiable {
        let x: Double
        let y: Double
        let z: Double
        var myIndex: Int = 0
        var id: UUID
    }

    func startDeviceMotion() {
        print("start device motion called")
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0/50.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            // Configure a timer to fetch the device motion data
            let timer = Timer(fire: Date(), interval: (1.0/50.0), repeats: true) { (timer) in
                if let data = self.motion.deviceMotion {
                    // Get accelerometer data
                    let accelerometer = data.userAcceleration
                    self.accIdx += 1
                    
                    let new: AccelerometerDataPoint = AccelerometerDataPoint(x: Double(accelerometer.x), y: Double(accelerometer.y), z: Double(accelerometer.z), myIndex: self.accIdx, id: UUID())
                    
                    self.acc.append(new)
                }
            }
            // Add the timer to the current run loop
            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        }
    }
    
    func stopDeviceMotion() {
        print("stop device motion called")
        motion.stopDeviceMotionUpdates()
    }
    
    func startHeartRate() {
        print("start heart rate called")
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
                     
                self.healthStore.execute(query)
            })
        }
        
    }
    
    func stopHeartRate() {
        print("stop heart rate called")
        timer?.invalidate()
        timer = nil
    }
}

struct accelerometerGraph: View {
    var acc: [BiometricsManager.AccelerometerDataPoint]
    var body: some View {
        ScrollView {
            VStack {
                Chart {
                    ForEach(acc) { element in
                        LineMark(x: .value("Date", element.myIndex), y: .value("x", element.x))
                            .foregroundStyle(by: .value("x", "x"))
                        LineMark(x: .value("Date", element.myIndex), y: .value("y", element.y))
                            .foregroundStyle(by: .value("y", "y"))
                        LineMark(x: .value("Date", element.myIndex), y: .value("z", element.z))
                            .foregroundStyle(by: .value("z", "z"))
                    }
                }
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 50)
                .padding()
            }
        }
    }
}

struct heartRateGraph: View {
    var heartRate: [(Double, Int)]
    var body: some View {
        ScrollView {
            VStack {
                Chart {
                    ForEach(heartRate.indices, id: \.self) { index in
                        let element = heartRate[index]
                        LineMark(x: .value("idx", element.1), y: .value("Heart Rate", element.0))
                    }
                }
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 50)
                .padding()
            }
        }
    }
}
