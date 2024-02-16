//
//  EmergencySOSView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/15/24.
//

import SwiftUI

struct EmergencySOSView: View {
    @State private var countdown = 1
    @Binding var showCalling911: Bool
    @Environment(\.presentationMode) var presentationMode
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Spacer()
            Text("EMERGENCY SOS")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("It looks like you are highly intoxicated and your heart rate has reached a critical level.")
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("AWARE will automatically contact emergency services if you do not respond. Tap the X to cancel.")
                .font(.system(size: 20, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
            
            Text("\(countdown)")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.red)
                .padding()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                ZStack {
                    Circle()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.red)
                        .opacity(0.2)
                        .overlay(Circle().stroke(Color.red, lineWidth: 2))
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 75)
                        .foregroundColor(.red)
                }  
            }
            .padding()
            Spacer()
        }
        .onReceive(timer) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                showCalling911 = true
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarHidden(true)
    }
}
