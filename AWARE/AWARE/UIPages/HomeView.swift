//
//  HomeView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/20/24.
//

import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var enableDataCollectionObj: EnableDataCollection
    @EnvironmentObject var biometricsManager: BiometricsManager
    @EnvironmentObject var alertManager: AlertManager
    @Binding var name: String
    
    @State private var shouldHide = false
    @State private var intoxLevelSub: AnyCancellable?
    
    var body: some View {
        VStack(alignment: .center) {
            HStack (alignment: .center){
                Spacer()
                Image("testlogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 50)
                Image("testicon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Spacer()
            }
            .background(Style.primaryColor)
            
            if name == "" {
                Text("Hello, user!")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            } else {
                Text("Hello, \(name)!")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
  
            Text("Welcome to AWARE")
                .font(.title)
                .padding()
            
            Text("Explore app features or enable drinking mode to get started.")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {}) {
                VStack {
                    Text("Estimated Intoxication Level:")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(biometricsManager.intoxLevel)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.purple)
                .cornerRadius(20)
            }
            .padding()
            
            Spacer()
            
            if (enableDataCollectionObj.enableDataCollection == 0) {
                if !self.$shouldHide.wrappedValue {
                    Button(action: {
                        enableDataCollectionObj.toggleOn()
                    }) {
                        Image(systemName: "touchid")
                            .font(.system(size: 100))
                            .foregroundColor(.red)
                            .controlSize(.extraLarge)
                    }.padding()
                    Text("Enable Drinking Mode")
                    Spacer()
                }
            } else {
                Button(action: {
                    enableDataCollectionObj.toggleOff()
                }) {
                    Image(systemName: "touchid")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                        .controlSize(.extraLarge)
                }.padding()
                Text("Disable Drinking Mode")
                Spacer()
            }
        }
        .onChange(of: enableDataCollectionObj.enableDataCollection) {
            if (enableDataCollectionObj.enableDataCollection == 1) {
                biometricsManager.startDeviceMotion()
                biometricsManager.startHeartRate()
                intoxLevelSub = alertManager.$intoxLevel
                    .sink { level in
                        if level == 3 {
                            alertManager.intoxLevel = 3
                        }
                    }
            } else {
                biometricsManager.stopDeviceMotion()
                biometricsManager.stopHeartRate()
                intoxLevelSub?.cancel()
            }
        }
    }
}
