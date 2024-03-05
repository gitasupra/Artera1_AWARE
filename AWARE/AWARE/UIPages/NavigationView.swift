//
//  NavigationServicesView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/20/24.
//

import SwiftUI

struct NavigationServicesView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Spacer().frame(height: 10)
                LocationView()
            }
            .navigationBarTitle("Navigation", displayMode: .large)
        }
    }
}

