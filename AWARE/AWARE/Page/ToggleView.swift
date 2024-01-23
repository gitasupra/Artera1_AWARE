//
//  ToggleView.swift
//  AWARE
//
//  Created by Jessica Lieu on 1/23/24.
//

import SwiftUI

struct ToggleView: View {
    
    @StateObject var enableDataCollectionObj = EnableDataCollection()
    @State private var enableDataCollection = false
    
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
                            enableDataCollection.toggle()
                        }) {
                            Image(systemName: "touchid")
                                .font(.system(size: 100))
                                .foregroundColor(.green)
                                .controlSize(.extraLarge)
                        }.padding()
                        Text("Disable Data Collection")
                        Spacer()
                    }
                } else {
                    Button(action: {
                            enableDataCollectionObj.toggleOff()
                            enableDataCollection.toggle()
                        }) {
                            Image(systemName: "touchid")
                                .font(.system(size: 100))
                                .foregroundColor(.red)
                                .controlSize(.extraLarge)
                        }.padding()
                    Text("Enable Data Collection")
                    Spacer()
                }
            }
            .onChange(of: enableDataCollection) {
                if (enableDataCollection) {
                    startDeviceMotion()
                } else {
                    self.motion.stopDeviceMotionUpdates()
                }
            }
    }
}


struct ToggleView_Previews: PreviewProvider {
    static var previews: some View {
        ToggleView()
    }
}
