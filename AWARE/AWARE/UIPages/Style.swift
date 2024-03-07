//
//  Style.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/20/24.
//

import SwiftUI

class Style {
    static var accentColor:Color = Color(red: 148/255, green: 40/255, blue: 186/255)
    static var highlightColor:Color = Color(red: 240/255, green: 220/255, blue: 255/255)
    static var primaryColor:Color = Color(red: 45/255, green: 24/255, blue: 92/255)
    static var secondaryColor:Color = Color(red: 250/255, green: 51/255, blue: 92/255)
    static var defaultGray:Color = Color(red: 148/255, green: 40/255, blue: 186/255)
    static var backgroundColor:Color = .black
    
    struct CustomButtonStyle: ButtonStyle {
        var isActive: Bool
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(isActive ? Style.highlightColor : Color.accentColor)
                )
                .foregroundColor(isActive ? Style.accentColor : .white)
                .cornerRadius(30)
                .padding([.top, .bottom], 2)
        }
    }
    
    // Intoxication Levels for home page
    // ======================================================
    
    // Sober
    static var soberButtonFillColor:Color = Color(red: 60/255, green: 203/255, blue: 90/255)
    static var soberBoxColor:Color = Color(red: 0/255, green: 70/255, blue: 42/255)
    static var soberTextColor:Color = Color(red: 172/255, green: 229/255, blue: 200/255)
    
    // Tipsy
    static var tipsyButtonFillColor:Color = Color(red: 212/255, green: 176/255, blue: 87/255)
    static var tipsyBoxColor:Color = Color(red: 235/255, green: 169/255, blue: 7/255)
    static var tipsyTextColor:Color = Color(red: 15/255, green: 14/255, blue: 11/255)
    
    // Drunk
    static var drunkButtonFillColor:Color = Color(red: 248/255, green: 163/255, blue: 42/255)
    static var drunkBoxColor:Color = Color(red: 1.0, green: 120/255, blue: 0.0)
    static var drunkTextColor:Color = Color(red: 245/255, green: 240/255, blue: 204/255)
    
    // Danger
    static var dangerButtonFillColor:Color = Color(red: 211/255, green: 28/255, blue: 28/255)
    static var dangerBoxColor:Color = Color(red: 132/255, green: 0/255, blue: 51/255)
    static var dangerTextColor:Color = Color(red: 255/255, green: 255/255, blue: 255/255)
}
