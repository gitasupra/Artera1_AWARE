//
//  LocationRequestView.swift
//  AWARE
//
//  Created by Cheryl Stanley on 1/15/24.
//

import Foundation
import SwiftUI

struct LocationRequestView: View {
    var body: some View {
//        Text("Request location from user!")
        ZStack {
            Color(.systemBlue).ignoresSafeArea() //.systemBlue
            VStack {
                Spacer()
                
                Image(systemName: "paperplane.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 32)
                Text("Find safe places near your current location on the map / share location with family?")
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding()
                Text("Start sharing your location with us")
                    .multilineTextAlignment(.center)
                    .frame(width: 140)
                    .padding()
                Spacer()
                VStack {
                    Button {
//                        print("Request location from user")
                        LocationManager.shared.requestLocation()
                    } label: {
                        Text("Allow location")
                            .padding()
                            .font(.headline)
                            .foregroundColor(Color(.systemBlue)) //.systemBlue
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .padding(.horizontal, -32)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .padding()
                    
                    Button {
                        print("Dismiss")
                    } label: {
                        Text("Maybe later")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 32)
            }
            .foregroundColor(.white)
        }
    }
}

struct LocationRequestView_Previews: PreviewProvider {
    static var previews: some View {
        LocationRequestView()
    }
}
