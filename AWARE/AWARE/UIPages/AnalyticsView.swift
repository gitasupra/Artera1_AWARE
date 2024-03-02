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
                    }
                }
            }.navigationBarTitle("Analytics", displayMode: .large)
        }
    }
}

struct CalendarView: View {
    // Define a struct to represent a day's drinking level
    struct Day: Hashable {
        var date: Date
        var level: Int // Drinking level for the day (-1 to 3)

        // Implementing hash(into:) method required by Hashable protocol
        func hash(into hasher: inout Hasher) {
            hasher.combine(date)
        }
    }

    // Define your calendar data
    var calendarData: [[Day]] {
        let currentDate = Date()
        let startDate = currentDate.startOfMonth()
        let endDate = currentDate.endOfMonth()

        var calendarData = [[Day]]()
        var currentWeek = [Day]()

        var dayIterator = startDate
        while dayIterator <= endDate {
            let level: Int
            if dayIterator <= currentDate {
                level = Int.random(in: 0...3)
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
    let colors: [Color] = [.gray, .green, .yellow, .orange, .red]

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
        VStack(alignment: .leading, spacing: 10) {
            Text("Today")
                .font(.title)
                .padding(.top, 5)
                HStack {
                    let daysOfTheWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                    let datesForCurrentWeek = getDatesForCurrentWeek()
                    let currentDay = Calendar.current.component(.day, from: Date())

                    ForEach(Array(daysOfTheWeek.enumerated()), id: \.element) { index, element in
                        VStack {
                            Text(element)
                                .padding(10)
                                .foregroundColor(.gray)
                                .cornerRadius(8)
                                .font(.system(size: 12))

                            let dayOnly = Int(datesForCurrentWeek[index].components(separatedBy: " ")[1])
                            Text(datesForCurrentWeek[index].components(separatedBy: " ")[1])
                                .padding(10)
                                .background(currentDay == dayOnly ? Style.accentColor : .black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .font(.system(size: 15))
                        }
                    }
                }
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Style.accentColor, lineWidth: 1)
                )

            Text("Intoxication History")
                .font(.title)

            ForEach(calendarData, id: \.self) { week in
                HStack(spacing: 10) {
                    ForEach(week, id: \.self) { day in
                        ZStack {
                            if day.level != -2 {
                                Circle()
                                    .foregroundColor(colors[day.level + 1])
                                    .frame(width: 40, height: 40)

                                Text("\(day.date.day)")
                                    .font(.subheadline)
                                    .foregroundColor(day.level != -1 ? .white : .black)
                            } else {
                                Circle()
                                    .foregroundColor(Color.clear)
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
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
        let range = calendar.range(of: .day, in: .month, for: self)!
        let lastDayOfMonth = range.upperBound - 1
        return calendar.date(byAdding: .day, value: lastDayOfMonth, to: startOfMonth())!
    }

    var day: Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: self)
    }

    var weekday: Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }
}
