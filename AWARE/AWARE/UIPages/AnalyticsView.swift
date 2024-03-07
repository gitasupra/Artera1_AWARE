//
//  AnalyticsView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/20/24.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var enableDataCollectionObj: EnableDataCollection
    @EnvironmentObject var biometricsManager: BiometricsManager
    @State var showHeartChart: Bool = false
    @State var showAccChart: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                NavigationStack {
                    CalendarView()
                        .padding(.bottom, 10)
                    VStack {
                        Text("Showing Intoxication History")
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Style.highlightColor)
                            )
                            .foregroundColor(Style.accentColor)
                            .cornerRadius(30)
                            .padding([.top, .bottom], 2)
                        
                        Button {
                            showHeartChart = true
                        } label: {
                            Text("View Heart Rate Data")
                        }
                        .navigationDestination(
                            isPresented: $showHeartChart) {
                                heartRateGraph(heartRate: enableDataCollectionObj.heartRateList)
                            }
                            .buttonStyle(Style.CustomButtonStyle())
                        
                        Button {
                            showAccChart = true
                        } label: {
                            Text("View Walking Steadiness Data")
                        }
                        .navigationDestination(
                            isPresented: $showAccChart) {
                                accelerometerGraph(acc: biometricsManager.acc)
                            }
                            .buttonStyle(Style.CustomButtonStyle())
                            .padding(.bottom, 20)
                    }
                }
            }.navigationBarTitle("Analytics", displayMode: .large)
        }
    }
}

struct CalendarView: View {
    @State private var currentDate = Date()
    @State private var currentMonth = Calendar.current.component(.month, from: Date())
    @State private var canNavigateBack = true
    @State private var canNavigateForward = false
    
    struct Day: Hashable {
        var date: Date
        var level: Int // Drinking level for the day (-1 to 3)
        
        // Implementing hash(into:) method required by Hashable protocol
        func hash(into hasher: inout Hasher) {
            hasher.combine(date)
        }
    }
    
    var calendarData: [[Day]] {
        let currentDate = Date()
        let startDate = currentDate.startOfMonth()
        let endDate = currentDate.endOfMonth()
        
        var calendarData = [[Day]]()
        var currentWeek = [Day]()
        
        var dayIterator = startDate
        while dayIterator <= endDate {
            var level = 0
            if dayIterator < currentDate.yesterday {
                let weights = [0.5, 0.3, 0.15, 0.05]
                let totalWeight = weights.reduce(0, +)
                
                let randomValue = Double.random(in: 0..<totalWeight)
                
                var cumulativeWeight = 0.0
                for i in 0..<weights.count {
                    cumulativeWeight += weights[i]
                    if randomValue <= cumulativeWeight {
                        level = i
                        break
                    }
                }
            } else {
                level = -1 // No info for future days
            }
            currentWeek.append(Day(date: dayIterator, level: level))
            
            if dayIterator.weekday == 7 {
                if calendarData.isEmpty && currentWeek.count < 7 {
                    // If it's the first week and doesn't have 7 days, fill remaining days at the beginning
                    let invisibleDays = Array(repeating: Day(date: Date(), level: -2), count: 7 - currentWeek.count)
                    currentWeek.insert(contentsOf: invisibleDays, at: 0)
                }
                calendarData.append(currentWeek)
                currentWeek = []
            }
            
            dayIterator = Calendar.current.date(byAdding: .day, value: 1, to: dayIterator)!
        }
        
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                // Fill remaining days of the week with invisible days
                currentWeek.append(Day(date: Date(), level: -2))
            }
            calendarData.append(currentWeek)
        }
        return calendarData
    }
    
    // Define colors for different drinking levels
    let colors: [Color] = [Style.primaryColor, .green, .yellow, .orange, .red]
    
    func getDatesForCurrentWeek() -> [String] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) else {
            return []
        }
        
        var datesForCurrentWeek: [String] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: sunday) {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                datesForCurrentWeek.append(formatter.string(from: date))
            }
        }
        return datesForCurrentWeek
    }
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Button("<") {
                    if Calendar.current.component(.month, from: self.currentDate) != 1 {
                        self.currentDate = Calendar.current.date(byAdding: .month, value: -1, to: self.currentDate)!
                        canNavigateForward = true
                        if Calendar.current.component(.month, from: self.currentDate) == 1 {
                            canNavigateBack = false
                        }
                    } else {
                        canNavigateBack = false
                    }
                }
                .font(.title)
                .fontWeight(.bold)
                .disabled(!canNavigateBack)
                
                Text("\(currentDate.monthName) \(currentDate.yearName)")
                    .font(.headline)
                    .padding([.leading, .trailing], 15)
                
                Button(">") {
                    if Calendar.current.component(.month, from: self.currentDate) != self.currentMonth {
                        self.currentDate = Calendar.current.date(byAdding: .month, value: 1, to: self.currentDate)!
                        canNavigateBack = true
                        if Calendar.current.component(.month, from: self.currentDate) == self.currentMonth {
                            canNavigateForward = false
                        }
                    } else {
                        canNavigateForward = false
                    }
                }
                .font(.title)
                .fontWeight(.bold)
                .disabled(!canNavigateForward)
            }
            .padding(.bottom, -5)
            
            VStack(alignment: .center) {
                HStack {
                    let daysOfTheWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                    
                    ForEach(Array(daysOfTheWeek.enumerated()), id: \.element) { index, element in
                        Spacer()
                        VStack {
                            Text(element)
                                .foregroundColor(.gray)
                                .cornerRadius(8)
                                .font(.system(size: 12))
                        }
                        Spacer()
                    }
                }.padding(.top, 10)
                
                ForEach(calendarData, id: \.self) { week in
                    HStack(spacing: 10) {
                        ForEach(week, id: \.date) { day in
                            ZStack {
                                Circle()
                                    .foregroundColor(Style.primaryColor)
                                    .frame(width: 40, height: 40)
                                
                                if day.level != -2 {
                                    Circle()
                                        .foregroundColor(colors[day.level + 1])
                                        .frame(width: 10, height: 10)
                                        .offset(y: 15) // Adjust the offset to position the tiny colored circle below the gray circle
                                    Text("\(day.date.day)")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    if day.date.isToday {
                                        Circle()
                                            .foregroundColor(Style.accentColor)
                                            .overlay(
                                                Text("\(day.date.day)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white))
                                            .frame(width: 40, height: 40)
                                    }
                                } else {
                                    Circle()
                                        .foregroundColor(.clear)
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                    }
                }
            }
            .cornerRadius(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Style.primaryColor)
            )
        }
        .padding(.bottom, 10)
    }
}

extension Date {
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }

    func endOfMonth() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: self)
        components.month! += 1
        components.day = 0
        return calendar.date(from: components)!
    }

    var day: Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }

    var weekday: Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }
    
    var isToday: Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }

    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
    }

    var monthName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    var yearName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: self)
    }
}
