//
//  Calling911View.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/15/24.
//

import SwiftUI

struct Calling911View: View {
    @State private var isShaking = false
    @EnvironmentObject var alertManager: AlertManager
    @Environment(\.presentationMode) var presentationMode
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    var body: some View {

        VStack {
            Spacer()
            
            Text("Calling 911...")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 50)
            ZStack {
                Image(systemName: "iphone") // Using the phone receiver symbol
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.red)
                    .fontWeight(.ultraLight)
                    .padding(.top, 50)
                    .rotationEffect(.degrees(isShaking ? -5 : 5))
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                            self.isShaking.toggle()
                        }
                    }
                
                Image(systemName: "wave.3.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red)
                    .offset(x: -60, y: 0)
                    .padding(.top, 50)
                    .rotationEffect(.degrees(isShaking ? -5 : 5))
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                            self.isShaking.toggle()
                        }
                    }
                
                Image(systemName: "wave.3.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red)
                    .offset(x: 60, y: 0)
                    .padding(.top, 50)
                    .rotationEffect(.degrees(isShaking ? -5 : 5))
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                            self.isShaking.toggle()
                        }
                    }
            }
            Spacer()
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
            .padding(.bottom, 50)
        }
        .onReceive(timer) { _ in
            presentationMode.wrappedValue.dismiss()
        }
        .onAppear {
            alertManager.sendUpdate(level: 3)
            // alertManager.contactEmergencyServices()
        }
    }
}
