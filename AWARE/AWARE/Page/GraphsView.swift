//
//  GraphsView.swift
//  AWARE
//
//  Created by Jessica Lieu on 1/23/24.
//

import SwiftUI
import Charts


struct GraphsView: View {
    var body: some View {
        //used to test db write
        //self.ref.child("users").child("1").setValue(["username": "test3"])
        VStack(alignment: .center) {
            Text("Graphs")
                .font(.system(size: 36))
            NavigationStack {
                VStack {
                    Button {
                        //showHeartChart = true
                    } label: {
                        Text("View Heart Rate Data")
                    }
                    .navigationDestination(
                        isPresented: $showAccChart) {
                            accelerometerGraph(acc: acc)
                        }
                        .buttonStyle(CustomButtonStyle())
                    
                    Button {
                        showAccChart = true
                    } label: {
                        Text("View Breathing Rate Data")
                    }
                    .navigationDestination(
                        isPresented: $showAccChart) {
                            accelerometerGraph(acc: acc)
                        }
                        .buttonStyle(CustomButtonStyle())
                    
                    Button {
                        showAccChart = true
                    } label: {
                        Text("View Walking Steadiness Data")
                    }
                    .navigationDestination(
                        isPresented: $showAccChart) {
                            accelerometerGraph(acc: acc)
                        }
                        .buttonStyle(CustomButtonStyle())
                }
            }
        }
    }.onLoad{
    }
}

struct GraphsView_Previews: PreviewProvider {
    static var previews: some View {
        GraphsView()
    }
}

