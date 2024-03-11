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
    @State private var shouldHide = false
    @Binding var name: String
    
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
            .background(enableDataCollectionObj.enableDataCollection == 0 ? Style.primaryColor : (biometricsManager.intoxLevel == 0 ? Style.soberBoxColor : (biometricsManager.intoxLevel == 1 ? Style.tipsyBoxColor : (biometricsManager.intoxLevel == 2 ? Style.drunkBoxColor : (biometricsManager.intoxLevel == 3 ? Style.dangerBoxColor : Style.primaryColor )))))
            
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
            
            if (enableDataCollectionObj.enableDataCollection == 0) {
                VStack {
                    Text("Press the button below to start tracking your drinking!")
                        .font(.system(size: 30))
                        .font(.headline)
                        .foregroundColor(Style.highlightColor)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(width: 350, height: 230)
                .background(Style.primaryColor)
                .cornerRadius(20)
                .padding()
           
                if !self.$shouldHide.wrappedValue {
                    Button(action: {
                        enableDataCollectionObj.toggleOn()
                    }) {
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 200, height: 200)
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
                VStack {
                    Text("You are")
                        .font(.system(size: 30))
                        .font(.headline)
                        .foregroundColor(biometricsManager.intoxLevel == 0 ? Style.soberTextColor : (biometricsManager.intoxLevel == 1 ? Style.tipsyTextColor : (biometricsManager.intoxLevel == 2 ? Style.drunkTextColor : (biometricsManager.intoxLevel == 3 ? Style.dangerTextColor : Style.primaryColor ))))
                    Text(biometricsManager.intoxLevel == 0 ? "SOBER" : (biometricsManager.intoxLevel == 1 ? "TIPSY" : (biometricsManager.intoxLevel == 2 ? "DRUNK" : "IN DANGER")))
                        .font(.system(size: 50))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(biometricsManager.intoxLevel == 0 ? Style.soberTextColor : (biometricsManager.intoxLevel == 1 ? Style.tipsyTextColor : (biometricsManager.intoxLevel == 2 ? Style.drunkTextColor : (biometricsManager.intoxLevel == 3 ? Style.dangerTextColor : Style.primaryColor ))))
                    }
                        .frame(width: 350, height: 230)
                        .background(biometricsManager.intoxLevel == 0 ? Style.soberBoxColor : (biometricsManager.intoxLevel == 1 ? Style.tipsyBoxColor : (biometricsManager.intoxLevel == 2 ? Style.drunkBoxColor : (biometricsManager.intoxLevel == 3 ? Style.dangerBoxColor : Style.primaryColor ))))
                        .cornerRadius(20)
                        .padding()

                Button(action: {
                    enableDataCollectionObj.toggleOff()
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(biometricsManager.intoxLevel == 0 ? Style.soberButtonFillColor : (biometricsManager.intoxLevel == 1 ? Style.tipsyButtonFillColor : (biometricsManager.intoxLevel == 2 ? Style.drunkButtonFillColor : (biometricsManager.intoxLevel == 3 ? Style.dangerButtonFillColor : Style.primaryColor ))))
                                               .frame(width: 200, height: 200)

                        Image("cocktail.fill")
                            .font(.system(size: 80))
                            .controlSize(.extraLarge)
                            .overlay(Color.white.opacity(1))
                            .mask(Image("cocktail.fill").resizable())

                        Image(systemName: "bubbles.and.sparkles")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .offset(x: 10, y: -50)
                        }
                }.padding()
                Spacer()
            }
        }
        .onChange(of: enableDataCollectionObj.enableDataCollection) {
            if (enableDataCollectionObj.enableDataCollection == 1) {
                alertManager.intoxLevel = 0;
                biometricsManager.startDeviceMotion()
                biometricsManager.startHeartRate()
            } else {
                alertManager.intoxLevel = -1;
                biometricsManager.stopDeviceMotion()
                biometricsManager.stopHeartRate()
            }
        }
    }
}
