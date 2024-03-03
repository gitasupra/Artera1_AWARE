//
//  HomeView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/20/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var enableDataCollectionObj: EnableDataCollection
    @EnvironmentObject var biometricsManager: BiometricsManager
    @EnvironmentObject var alertManager: AlertManager
    @Binding var name: String
    
    @State private var shouldHide = false
    
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
                    Text("\(alertManager.intoxLevel)")
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
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 170, height: 170)
                            Image("cocktail")
                                .font(.system(size: 80))
                                .controlSize(.extraLarge)
                                .overlay(Color.gray.opacity(1))
                                .mask(Image("cocktail").resizable())
                        }
                    }.padding()
                    Spacer()
                }
            } else {
                Button(action: {
                    enableDataCollectionObj.toggleOff()
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.green)
                            .frame(width: 170, height: 170)
                    
                        Image("cocktail.fill")
                            .font(.system(size: 80))
                            .controlSize(.extraLarge)
                            .overlay(Color.white.opacity(1))
                            .mask(Image("cocktail.fill").resizable())
                    }
                }.padding()
                Spacer()
            }
        }
        .onChange(of: enableDataCollectionObj.enableDataCollection) {
            if (enableDataCollectionObj.enableDataCollection == 1) {
                biometricsManager.startDeviceMotion()
                biometricsManager.startHeartRate()
            } else {
                biometricsManager.stopDeviceMotion()
                biometricsManager.stopHeartRate()
            }
        }
    }
}
