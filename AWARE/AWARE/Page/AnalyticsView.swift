//
//  AnalyticsView.swift
//  AWARE
//
//  Created by Jessica Lieu on 1/23/24.
//

import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Analytics")
                .font(.system(size: 36))
            
            /*Spacer()
            
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
                                .background(currentDay == dayOnly ? Color.accentColor : backgroundColor)
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
            }*/
            
            LocationView()
            
            
            /*NavigationLink(destination: Text("View Past Data")) {
                Button("View Past Data") {}
                    .buttonStyle(CustomButtonStyle())
            }*/
            
            Spacer()
        }
    }
}


struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}