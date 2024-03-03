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
            if dayIterator < currentDate.yesterday {
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
    let colors: [Color] = [.black, .green, .yellow, .orange, .red] // .gray to .black

    func getDatesForCurrentWeek() -> [String] {
        let currentDate = Date()
        let calendar = Calendar.current

        // Find the start of the current week (Sunday)
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
        VStack(alignment: .leading, spacing: 10) {
//            Text("Today")
//                .font(.title)
//                .padding(.top, 5)
            HStack {
//                let daysOfTheWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
//                let datesForCurrentWeek = getDatesForCurrentWeek()
//                let currentDay = Calendar.current.component(.day, from: Date())
                
//                ForEach(Array(daysOfTheWeek.enumerated()), id: \.element) { index, element in
//                    VStack {
//                        Text(element)
//                            .padding(10)
//                            .foregroundColor(.gray)
//                            .cornerRadius(8)
//                            .font(.system(size: 12))
//                        
//                        let dayOnly = Int(datesForCurrentWeek[index].components(separatedBy: " ")[1])
//                        Text(datesForCurrentWeek[index].components(separatedBy: " ")[1])
//                            .padding(10)
//                            .background(currentDay == dayOnly ? Style.accentColor : .black)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                            .font(.system(size: 15))
//                    }
//                }
            }
//            .cornerRadius(6)
//            .overlay(
//                RoundedRectangle(cornerRadius: 6)
//                    .stroke(Style.accentColor, lineWidth: 1)
//            )
            
            Text("Intoxication History")
                .font(.title)
        VStack {
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
//                        Text(datesForCurrentWeek[index].components(separatedBy: " ")[1])
//                            .padding(10)
//                            .background(currentDay == dayOnly ? Style.accentColor : .black)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                            .font(.system(size: 15))
                    }
                }
            }
            ForEach(calendarData, id: \.self) { week in
                HStack(spacing: 10) {
                    ForEach(week, id: \.self) { day in
                        let isToday = day.date.isToday // Move the 'day' variable outside the loop

                        ZStack {
                            Circle()
                                .foregroundColor(.black)
                                .frame(width: 40, height: 40)
                            
                            if day.level != -2 {
                                Circle()
                                    .foregroundColor(colors[day.level + 1])
                                    .frame(width: 10, height: 10)
                                    .offset(y: 15) // Adjust the offset to position the tiny colored circle below the gray circle
                                Text("\(day.date.day)")
                                    .font(.subheadline)
                                //                                            .foregroundColor(day.level != -1 ? .white : .black)
                                    .foregroundColor(.white)
                                    .padding(10)

                                
                                //                                if day.level != -1 {
                                //                                    Text("\(day.date.day)")
                                //                                        .font(.subheadline)
                                //                                        .foregroundColor(day.level != -1 ? .white : .black)
                                //                                }
                                
                                if day.date.isToday {
                                    Circle()
                                        .foregroundColor(Style.accentColor)
                                        .overlay(
                                            Text("\(day.date.day)")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                        )
                                        .frame(width: 30, height: 30) // Adjust the width and height as needed

                                }
                                //                                .foregroundColor(day.date.isToday ? .white : .black)
                                //                                .background(day.date.isToday ? Style.accentColor : .clear)
                                //                                .cornerRadius(10)
                                //                                .frame(width: 20, height: 20) // Adjust width and height for spacing
                            } else {
                                Circle()
                                    .foregroundColor(.clear)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        
                    }
                }
            }

//            .padding(isToday ? [.top, .bottom] : .none, 10)
            .padding(.bottom, 10)


            
        } // VStack
        .cornerRadius(6)
            .overlay(
                
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Style.accentColor, lineWidth: 1)
//                        .padding([.top, .bottom], 100) // Add equal padding to top and bottom


                )
            

        
            
            
        } // include Today
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
}
