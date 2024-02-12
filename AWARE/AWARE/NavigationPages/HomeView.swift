//
//  HomeView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/12/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var enableDataCollectionObj: EnableDataCollection
    @State static var enableDataCollection = false
    @State private var shouldHide = false
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Image("testlogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 100)
            Image("testicon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
            
            Spacer()
            
            if (enableDataCollectionObj.enableDataCollection == 0) {
                if !self.$shouldHide.wrappedValue {
                    Button(action: {
                        enableDataCollectionObj.toggleOn()
                        HomeView.enableDataCollection.toggle()
                    }) {
                        Image(systemName: "touchid")
                            .font(.system(size: 100))
                            .foregroundColor(.red)
                            .controlSize(.extraLarge)
                    }.padding()
                    Text("Enable Data Collection")
                    Spacer()
                }
            } else {
                Button(action: {
                    enableDataCollectionObj.toggleOff()
                    HomeView.enableDataCollection.toggle()
                }) {
                    Image(systemName: "touchid")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                        .controlSize(.extraLarge)
                }.padding()
                Text("Disable Data Collection")
                Spacer()
            }
        }
    }
}
