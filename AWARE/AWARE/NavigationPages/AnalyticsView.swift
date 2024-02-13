//
//  AnalyticsView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/13/24.
//

import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("Analytics")
                    .font(.system(size: 36))
                
                Spacer()
                
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
                                Text(datesForCurrentWeek[index].components(separatedBy: " ")[1])
                                    .padding(10)
                                    .background(currentDay == dayOnly ? Style.accentColor : Style.backgroundColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .font(.system(size: 15))
                            }
                        }
                    }
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.accentColor, lineWidth: 1)
                    )
                }
                
                LocationView()
                
                
                NavigationLink(destination: Text("View Past Data")) {
                    Button("View Past Data") {}
                        .buttonStyle(Style.CustomButtonStyle())
                }
                
                Spacer()
            }
        }
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
}
