//
//  Style.swift
//  AWARE Watch App
//
//  Created by Cheryl Stanley on 3/5/24.
//

import Foundation
import SwiftUI

class Style {
   
    
     static var accentColor:Color = Color(red: 148/255, green: 40/255, blue: 186/255)
     static var primaryColor:Color = Color(red: 45/255, green: 24/255, blue: 92/255)
     static var secondaryColor:Color = Color(red: 250/255, green: 51/255, blue: 92/255)
     static var backgroundColor:Color = .black
     static var defaultGray:Color = Color(red: 148/255, green: 40/255, blue: 186/255)

     // Intoxication Levels for home page
     // ======================================================

     // Sober
     static var soberHeaderColor:Color = Color(red: 65/255, green: 187/255, blue: 160/255)
     static var soberBackgroundColor:Color = Color(red: 232/255, green: 246/255, blue: 235/255)
     static var soberButtonFillColor:Color = Color(red: 60/255, green: 203/255, blue: 90/255)
     static var soberButtonOutlineColor:Color = Color(red: 22/255, green: 92/255, blue: 52/255)
     static var soberBoxColor:Color = Color(red: 0/255, green: 70/255, blue: 42/255)
     static var soberTextColor:Color = Color(red: 172/255, green: 229/255, blue: 200/255)

     // Tipsy
     // 235, 169, 7
     static var tipsyHeaderColor:Color = Color(red: 235/255, green: 169/255, blue: 7/255)
     static var tipsyBackgroundColor:Color = Color(red: 232/255, green: 246/255, blue: 235/255)
     static var tipsyButtonFillColor:Color = Color(red: 212/255, green: 176/255, blue: 87/255)
     static var tipsyButtonOutlineColor:Color = Color(red: 22/255, green: 92/255, blue: 52/255)
     static var tipsyBoxColor:Color = Color(red: 235/255, green: 169/255, blue: 7/255)
     // 15, 14, 11
     static var tipsyTextColor:Color = Color(red: 15/255, green: 14/255, blue: 11/255)


     // Drunk
     //230, 118, 62
     static var drunkHeaderColor:Color = Color(red: 139/255, green: 89/255, blue: 76/255)
     static var drunkBackgroundColor:Color = Color(red: 253/255, green: 243/255, blue: 227/255)
     static var drunkButtonFillColor:Color = Color(red: 248/255, green: 163/255, blue: 42/255)
     static var drunkButtonOutlineColor:Color = Color(red: 161/255, green: 93/255, blue: 30/255)
     static var drunkBoxColor:Color = Color(red: 1.0, green: 120/255, blue: 0.0)
     static var drunkTextColor:Color = Color(red: 245/255, green: 240/255, blue: 204/255)
 // 245, 240, 237

     // Danger
     static var dangerHeaderColor:Color = Color(red: 211/255, green: 28/255, blue: 28/255)
     static var dangerBackgroundColor:Color = Color(red: 234/255, green: 218/255, blue: 218/255)
     static var dangerButtonFillColor:Color = Color(red: 211/255, green: 28/255, blue: 28/255)
     static var dangerButtonOutlineColor:Color = Color(red: 77/255, green: 12/255, blue: 12/255)
     static var dangerBoxColor:Color = Color(red: 132/255, green: 0/255, blue: 51/255)
     static var dangerTextColor:Color = Color(red: 255/255, green: 255/255, blue: 255/255)
    struct CustomButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .cornerRadius(6)
                .background(Color.accentColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
                .padding([.top, .bottom], 2)
        }
    }
}
