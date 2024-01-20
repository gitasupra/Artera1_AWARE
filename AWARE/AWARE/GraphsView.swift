//
//  GraphsView.swift
//  AWARE
//

import SwiftUI
import Charts
import HealthKit
import CoreMotion

struct GraphsView: View {
    
    @EnvironmentObject var motion: CMMotionManager
    
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
                        .buttonStyle(CustomButtonStyle())
                    
                    Button {
                        showAccChart = true
                    } label: {
                        Text("View Breathing Rate Data")
                    }
                    .navigationDestination(
                        isPresented: $showAccChart) {
                            accelerometerGraph(acc: acc)
                        }
                        .buttonStyle(CustomButtonStyle())
                    
                    Button {
                        showAccChart = true
                    } label: {
                        Text("View Walking Steadiness Data")
                    }
                    .navigationDestination(
                        isPresented: $showAccChart) {
                            accelerometerGraph(acc: acc)
                        }
                        .buttonStyle(CustomButtonStyle())
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
}
