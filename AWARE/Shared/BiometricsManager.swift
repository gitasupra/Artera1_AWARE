//
//  BiometricsManager.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/17/24.
//

import CoreML
import Charts
import SwiftUI
import SwiftCSV
import HealthKit
import CoreMotion
import WatchConnectivity

class BiometricsManager: ObservableObject {
    let motion = CMMotionManager()
    let healthStore = HKHealthStore()
    var timer: Timer?
    var intoxLevel: Int = 0
    
    // accelerometer data variables
    var acc: [AccelerometerDataPoint] = []
    var accIdx: Int = 0
    
    // accelerometer data struct
    struct AccelerometerDataPoint: Identifiable {
        let timestamp: Int64
        let x: Double
        let y: Double
        let z: Double
        var myIndex: Int = 0
        var id: UUID
    }
    
    #if os(iOS)
    // machine learning variables
    @State private var windowAccData: [AccelerometerDataPoint] = []
    @State private var windowFile: String = "window_data.csv"
    @State private var windowFileURL: String = ""
    @StateObject var inputFunctions = InputFunctions()
    #endif
    
    func startDeviceMotion() {
        if motion.isDeviceMotionAvailable {
            //Bar Crawl dataset sampled at 40Hz
            self.motion.deviceMotionUpdateInterval = 1.0/40.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            // Configure a timer to fetch the device motion data
            let timer = Timer(fire: Date(), interval: (1.0/40.0), repeats: true,
                              block: { (timer) in
                if let data = self.motion.deviceMotion {
                    // Get attitude, accelerometer, and gyroscope data
                    let attitude = data.attitude
                    let accelerometer = data.userAcceleration
                    let gyro = data.rotationRate
                    
                    let timestampInMilliseconds = Int64(Date().timeIntervalSince1970 * 1000)
                    
                    let new:AccelerometerDataPoint = AccelerometerDataPoint(timestamp: timestampInMilliseconds, x: Double(accelerometer.x), y: Double(accelerometer.y), z: Double(accelerometer.z), myIndex: self.accIdx, id: UUID())
                    
                    self.acc.append(new)
                    
                    //FIXME this might get messed up by start/stop data collection, timer might be better to trigger saving to CSV function
                    //ex: corner cases where stop in middle of window, don't want prediction made on walking windows that are not continuous
                    #if os(iOS)
                    self.windowAccData.append(new)
                    
                    if self.accIdx > 0 && self.accIdx % 840 == 0 {
                        //At multiple of (data points per second) * 10 seconds
                        self.windowFileURL = self.writeAccDataToCSV(data: self.windowAccData)!
                        print("Window data saved to: \(self.windowFileURL)")
                        let file = self.inputFunctions.processData(datafile: self.windowFileURL)
                        
                        Predictor.predictLevel(file: "file.csv")
                        
                        //reset window data array
                        self.windowAccData=[]
                    }
                    #endif
                    
                    self.accIdx += 1
                }
            })
            
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
        var consecutiveDangerousHeartRateCount = 0
        var timeInDangerousRange: TimeInterval = 0
        let durationThreshold: TimeInterval = 15 * 60 // 15 minutes
        let lowThreshold = 50 // low heart rate threshold for bradycardia
        let highThreshold = 150 // high heart rate threshold for tachycardia
        
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            // Configure a timer to fetch the device motion data
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
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
                    
                    // check if heart rate is within dangerous range
                    if self.intoxLevel == 2 {
                        if lastHeartRate < Double(lowThreshold) || lastHeartRate > Double(highThreshold) {
                            consecutiveDangerousHeartRateCount += 1
                            timeInDangerousRange += 1
                            
                            // if consecutive dangerous heart rate readings exceed threshold and time in dangerous range reaches threshold, trigger alert
                            if consecutiveDangerousHeartRateCount >= 1 && timeInDangerousRange >= durationThreshold {
                                self.intoxLevel = 3
                            }
                        } else {
                            consecutiveDangerousHeartRateCount = 0
                            timeInDangerousRange = 0
                        }
                    }
                    
                    heartRateIdx += 1
                    WCSession.default.transferUserInfo(["lastHeartRate": lastHeartRate, "heartRateIdx": heartRateIdx])
                }
                
                let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: .heartRate)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
                
                self.healthStore.execute(query)
            }
        }
    }
    
    func stopHeartRate() {
        print("stop heart rate called")
        timer?.invalidate()
        timer = nil
    }
    
    func writeAccDataToCSV(data: [AccelerometerDataPoint]) -> String? {
        // Create a CSV string header
        var csvString = "time,x,y,z\n"
        
        // Append each data point to the CSV string
        for dataPoint in data {
            let timestamp = dataPoint.timestamp
            let x = dataPoint.x
            let y = dataPoint.y
            let z = dataPoint.z
            csvString.append("\(timestamp),\(x),\(y),\(z)\n")
        }

        // Create a file URL for saving the CSV file
        let fileName = windowFile
        guard let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName) else {
            print("Failed to create file URL")
            return nil
        }
        
        // Write the CSV string to the file
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            // print("CSV file saved successfully")
            return fileURL.path
        } catch {
            print("Error writing CSV file: \(error)")
            return nil
        }
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
