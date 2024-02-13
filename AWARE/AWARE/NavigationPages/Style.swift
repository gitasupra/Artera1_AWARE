//
//  Style.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/12/24.
//

import SwiftUI

class Style {
    static let accentColor:Color = .purple
    static let backgroundColor:Color = .black
    struct CustomButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
                .padding([.top, .bottom], 2)
        }
    }
}
