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
    @State private var switchLevels = false
    
    @State private var testIntoxLevel = 2; // Use for testing on simulator (Values: 0, 1, 2), uncomment alertManager if statement code for iPhone testing
    
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
            .background(enableDataCollectionObj.enableDataCollection == 0 ? Style.primaryColor : (testIntoxLevel == 0 ? Style.soberBoxColor : (testIntoxLevel == 1 ? Style.tipsyBoxColor : (testIntoxLevel == 2 ? Style.drunkBoxColor : (testIntoxLevel == 3 ? Style.dangerBoxColor : Style.primaryColor )))))
        
            
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
                .onChange(of: enableDataCollectionObj.enableDataCollection) {
                    if (enableDataCollectionObj.enableDataCollection == 1) {
                        biometricsManager.startDeviceMotion()
                        biometricsManager.startHeartRate()
                    } else {
                        biometricsManager.stopDeviceMotion()
                        biometricsManager.stopHeartRate()
                    }
                }
            
            if (enableDataCollectionObj.enableDataCollection == 0) {
                VStack {
                    Text("Press the button below to start tracking your drinking!")
                        .font(.system(size: 25))
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(width: 300, height: 200)
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
                VStack {
                    Text("You are")
                        .font(.system(size: 25))
                        .font(.headline)
                        .foregroundColor(Style.soberTextColor)
                    Text(testIntoxLevel == 0 ? "SOBER" : (testIntoxLevel == 1 ? "TIPSY" : (testIntoxLevel == 2 ? "DRUNK" : "IN DANGER")))
                        .font(.system(size: 50))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(Style.soberTextColor)
                }
                .frame(width: 300, height: 200)
                .background(testIntoxLevel == 0 ? Style.soberBoxColor : (testIntoxLevel == 1 ? Style.tipsyBoxColor : (testIntoxLevel == 2 ? Style.drunkBoxColor : (testIntoxLevel == 3 ? Style.dangerBoxColor : Style.primaryColor ))))
                .cornerRadius(20)
                .padding()
                
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
                switchLevels = true
                alertManager.intoxLevel = 0;
            }
            
            //            } else {
            //                biometricsManager.stopDeviceMotion()
            //                biometricsManager.stopHeartRate()
            //            }
        }
    }
}
