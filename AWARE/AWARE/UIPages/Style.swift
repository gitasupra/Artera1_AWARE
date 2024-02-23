//
//  Style.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/20/24.
//

import SwiftUI

class Style {
    static let accentColor:Color = Color(red: 148/255, green: 40/255, blue: 186/255)
    static let primaryColor:Color = Color(red: 45/255, green: 24/255, blue: 92/255)
    static let secondaryColor:Color = Color(red: 250/255, green: 51/255, blue: 92/255)
    static let backgroundColor:Color = .black
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
