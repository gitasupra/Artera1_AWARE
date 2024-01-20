//
//  ToggleView.swift
//  AWARE
//

import SwiftUI
import CoreMotion
import HealthKit

struct ToggleView: View {
    @EnvironmentObject var motion: CMMotionManager
    @StateObject var enableDataCollectionObj = EnableDataCollection()
    @State private var enableDataCollection = false
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
    
    func startDeviceMotion() {
            //var idx = 0
            if motion.isDeviceMotionAvailable {
                self.motion.deviceMotionUpdateInterval = 1.0/50.0
                self.motion.showsDeviceMovementDisplay = true
                self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
                
                // Configure a timer to fetch the device motion data
                let timer = Timer(fire: Date(), interval: (1.0/50.0), repeats: true,
                                  block: { (timer) in
                    if let data = self.motion.deviceMotion {
                        // Get attitude data
                        let attitude = data.attitude
                        // Get accelerometer data
                        let accelerometer = data.userAcceleration
                        // Get the gyroscope data
                        let gyro = data.rotationRate
                        accIdx += 1
                        
                        let new:AccelerometerDataPoint = AccelerometerDataPoint(x: Double(accelerometer.x), y: Double(accelerometer.y), z: Double(accelerometer.z), myIndex: accIdx, id: UUID())
                        
                        acc.append(new)
                        
                    }
                    
                    
                })
                
                // Add the timer to the current run loop
                RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
            }
            
        }
}
