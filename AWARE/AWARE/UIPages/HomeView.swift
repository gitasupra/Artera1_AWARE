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
            
            
                .onChange(of: enableDataCollectionObj.enableDataCollection) {
                    if (enableDataCollectionObj.enableDataCollection == 1) {
                        biometricsManager.startDeviceMotion()
                        biometricsManager.startHeartRate()
                    } else {
                        biometricsManager.stopDeviceMotion()
                        biometricsManager.stopHeartRate()
                    }
                }
            
            
            
            if(enableDataCollectionObj.enableDataCollection == 0 ) {
//                Button(action: {}) { // Commented out all button codes to reduce  potential user confusion about **which** button enables drinking mode
                    VStack {
                        Text("Press the button to start tracking your drinking!")
                            .font(.headline)
                            .foregroundColor(.white)
                     
                    }
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(20)
//                }
                .padding()
    


                
            }
            else if(enableDataCollectionObj.enableDataCollection == 1){
//                if(alertManager.intoxLevel == 0) { // for iPhone testing
                if(testIntoxLevel == 0) { // for simulator testing
                
//                                Button(action: {}) {
                                    VStack {
                                        Text("You are")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("SOBER")
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Style.soberButtonFillColor)
                                    .cornerRadius(20)
//                                }
                                .padding()
                    
                }
//                if(alertManager.intoxLevel == 1) { // for iPhone testing
                if(testIntoxLevel == 1) { // for simulator testing

//                                Button(action: {}) {
                                    VStack {
                                        Text("You are")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("DRUNK")
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Style.drunkButtonFillColor)
                                    .cornerRadius(20)
//                                }
                                .padding()
                    
                }
//                if(alertManager.intoxLevel == 2) { // for iPhone testing
                if(testIntoxLevel == 2) { // for simulator testing

//                                Button(action: {}) {
                                    VStack {
                                        Text("You are")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("IN DANGER")
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Style.dangerButtonFillColor)
                                    .cornerRadius(20)
//                                }
                                .padding()
                    
                }
            }
            
          
//            Spacer()
//            
//            Button(action: {}) {
//                VStack {
//                    Text("Estimated Intoxication Level:")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                    Text("\(alertManager.intoxLevel)")
//                        .font(.largeTitle)
//                        .foregroundColor(.white)
//                }
//                .padding()
//                .background(Color.purple)
//                .cornerRadius(20)
//            }
//            .padding()
//            
//            Spacer()
            
            
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
            }
                
//            } else {
//                biometricsManager.stopDeviceMotion()
//                biometricsManager.stopHeartRate()
//            }
        }
    }
}
