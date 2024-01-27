//
//  GraphsView.swift
//  AWARE
//
//  Created by Jessica Lieu on 1/23/24.
//

import SwiftUI
import HealthKit
import Charts
import CoreMotion

struct GraphsView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var motion: CMMotionManager
    @State var showAccChart: Bool = true

    // accelerometer data variables
    @State private var acc: [AccelerometerDataPoint] = []
    @State private var accIdx: Int = 0
    
    // accelerometer data struct
    struct AccelerometerDataPoint: Identifiable {
        let x: Double
        let y: Double
        let z: Double
        var myIndex: Int = 0
        var id: UUID
    }
    
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
        //used to test db write
        //self.ref.child("users").child("1").setValue(["username": "test3"])
        VStack(alignment: .center) {
            Text("Graphs")
                .font(.system(size: 36))
            NavigationStack {
                VStack {
                    Button {
                        //showHeartChart = true
                    } label: {
                        Text("View Heart Rate Data")
                    }
                    .navigationDestination(
                        isPresented: $showAccChart) {
                            accelerometerGraph(acc: acc)
                        }
                        .buttonStyle(Theme.CustomButtonStyle())
                    
                    Button {
                        showAccChart = true
                    } label: {
                        Text("View Breathing Rate Data")
                    }
                    .navigationDestination(
                        isPresented: $showAccChart) {
                            accelerometerGraph(acc: acc)
                        }
                        .buttonStyle(Theme.CustomButtonStyle())
                    
                    Button {
                        showAccChart = true
                    } label: {
                        Text("View Walking Steadiness Data")
                    }
                    .navigationDestination(
                        isPresented: $showAccChart) {
                            accelerometerGraph(acc: acc)
                        }
                        .buttonStyle(Theme.CustomButtonStyle())
                }
            }
        }
    }
    
    struct accelerometerGraph: View {
            var acc: [AccelerometerDataPoint]
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
    
    func startDeviceMotion() {
        //var idx = 0
        
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0/50.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            // Configure a timer to fetch the device motion data
            let timer = Timer(fire: Date(), interval: (1.0/50.0), repeats: true,
                                block: { (timer) in
                if let data = self.motion.deviceMotion {
                    // Get attitude data
                    let attitude = data.attitude
                    // Get accelerometer data
                    let accelerometer = data.userAcceleration
                    // Get the gyroscope data
                    let gyro = data.rotationRate
                    accIdx += 1
                    
                    let new:AccelerometerDataPoint = AccelerometerDataPoint(x: Double(accelerometer.x), y: Double(accelerometer.y), z: Double(accelerometer.z), myIndex: accIdx, id: UUID())
                    
                    acc.append(new)
                    
                }
                
                
            })
            
            // Add the timer to the current run loop
            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        }
        
    }
    
}

struct GraphsView_Previews: PreviewProvider {
    static var previews: some View {
        GraphsView()
    }
}

