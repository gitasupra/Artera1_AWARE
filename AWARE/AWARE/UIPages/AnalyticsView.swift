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
                CalendarView()
                    .padding([.top, .bottom], 10)
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
                    
                    NavigationLink(destination: heartRateGraph(heartRate: enableDataCollectionObj.heartRateList), isActive: $showHeartChart) {
                        Button {
                            showHeartChart = true
                        } label: {
                            Text(showHeartChart ? "Showing Heart Rate Data" : "View Heart Rate Data")
                        }
                        .buttonStyle(Style.CustomButtonStyle(isActive: showHeartChart))
                    }
                    
                    NavigationLink(destination: accelerometerGraph(acc: biometricsManager.acc), isActive: $showAccChart) {
                        Button {
                            showAccChart = true
                        } label: {
                            Text(showAccChart ? "Showing Walking Steadiness Data" : "View Walking Steadiness Data")
                        }
                        .buttonStyle(Style.CustomButtonStyle(isActive: showAccChart))
                        .padding(.bottom, 10)
                    }
                }.padding(.bottom, 30)
            }
            .navigationBarTitle("Analytics", displayMode: .large)
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
        var calendarData = [[Day]]()
        
        if Calendar.current.component(.month, from: Date()) != Calendar.current.component(.month, from: self.currentDate) {
            // Regenerate all the dates in the month to match self.currentDate
            let startDate = self.currentDate.startOfMonth()
            let endDate = self.currentDate.endOfMonth()
            
            var currentWeek = [Day]()
            var dayIterator = startDate
            
            while dayIterator <= endDate {
                var level = 0
                if self.currentDate.monthName != dayIterator.monthName || dayIterator < Date().yesterday {
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
                    level = -1
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
        } else {
            calendarData = self.generateCalendarData(for: self.currentDate)
        }
        
        return calendarData
    }
    
    // Define colors for different drinking levels
    let colors: [Color] = [Style.primaryColor, .green, .yellow, .orange, .red]
    
    func generateCalendarData(for date: Date) -> [[Day]] {
        let startDate = date.startOfMonth()
        let endDate = date.endOfMonth()
        
        var calendarData = [[Day]]()
        var currentWeek = [Day]()
        
        var dayIterator = startDate
        
        while dayIterator <= endDate {
            var level = 0
            if date.monthName != currentDate.monthName || dayIterator < Date().yesterday {
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
        GeometryReader { geometry in
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    
                    Button {
                        if Calendar.current.component(.month, from: self.currentDate) != 1 {
                            self.currentDate = Calendar.current.date(byAdding: .month, value: -1, to: self.currentDate)!
                            canNavigateForward = true
                            if Calendar.current.component(.month, from: self.currentDate) == 1 {
                                canNavigateBack = false
                            }
                        } else {
                            canNavigateBack = false
                        }
                    } label: {
                        Image(systemName: "heart.fill")
                            .rotationEffect(.degrees(90))
                            .font(.title)
                    }
                    .disabled(!canNavigateBack)
                    .padding(.trailing, 10)
                    
                    Text("\(currentDate.monthName) \(currentDate.yearName)")
                        .font(.headline)

                    Button {
                        if Calendar.current.component(.month, from: self.currentDate) != self.currentMonth {
                            self.currentDate = Calendar.current.date(byAdding: .month, value: 1, to: self.currentDate)!
                            canNavigateBack = true
                            if Calendar.current.component(.month, from: self.currentDate) == self.currentMonth {
                                canNavigateForward = false
                            }
                        } else {
                            canNavigateForward = false
                        }
                    } label: {
                        Image(systemName: "heart.fill")
                            .rotationEffect(.degrees(-90))
                            .font(.title)
                    }
                    .disabled(!canNavigateForward)
                    .padding(.leading, 10)
                    Spacer()
                }
                .padding([.top, .bottom], -5)
                
                VStack(alignment: .center) {
                    HStack {
                            let daysOfTheWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                            ForEach(Array(daysOfTheWeek.enumerated()), id: \.element) { index, element in
                                ZStack {
                                Circle()
                                    .foregroundColor(Style.primaryColor)
                                    .frame(width: 40, height: 40)
                                VStack(alignment: .center) {
                                    Text(element)
                                        .foregroundColor(.gray)
                                        .cornerRadius(8)
                                        .font(.system(size: 12))
                                }
                            }
                        }
                    }.padding(.top, 10)
                    
                    ForEach(calendarData, id: \.self) { week in
                        HStack(spacing: 10) {
                            ForEach(week.indices, id: \.self) { index in
                                let day = week[index]
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
                    Spacer()
                }
                .cornerRadius(20)
                .frame(width: geometry.size.width, height: geometry.size.height * 0.85)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Style.primaryColor)
                )
            }
            .onAppear {
                // Check if the current month is not the actual current month
                if Calendar.current.component(.month, from: self.currentDate) != Calendar.current.component(.month, from: Date()) {
                    self.currentDate = Date().endOfMonth()
                }
            }
        }
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
