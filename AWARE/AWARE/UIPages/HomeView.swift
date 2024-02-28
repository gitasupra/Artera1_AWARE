//
//  HomeView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 2/20/24.
//

import SwiftUI
import Alamofire

struct HomeView: View {
    struct APIResponse: Codable {
        let predict: Int
    }
    
    
    @EnvironmentObject var enableDataCollectionObj: EnableDataCollection
    @EnvironmentObject var biometricsManager: BiometricsManager
    @EnvironmentObject var alertManager: AlertManager
    @Binding var name: String
    @State private var timer: Timer?
    
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
                        Image(systemName: "touchid")
                            .font(.system(size: 100))
                            .foregroundColor(.red)
                            .controlSize(.extraLarge)
                    }.padding()
                    Text("Enable Drinking Mode")
                    Spacer()
                }
            } else {
                Button(action: {
                    enableDataCollectionObj.toggleOff()
                }) {
                    Image(systemName: "touchid")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                        .controlSize(.extraLarge)
                }.padding()
                Text("Disable Drinking Mode")
                Spacer()
            }
        }
        .onChange(of: enableDataCollectionObj.enableDataCollection) {
            if (enableDataCollectionObj.enableDataCollection == 1) {
                biometricsManager.startDeviceMotion()
                biometricsManager.startHeartRate()
                let timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { timer in
                   // code to be executed every 1 second
                    sendCSVToServer(accData: biometricsManager.windowFile) { predictionResult in
                        alertManager.intoxLevel = predictionResult
                    }
                }
            } else {
                biometricsManager.stopDeviceMotion()
                biometricsManager.stopHeartRate()
                self.timer?.invalidate()
            }
        }
    }
    


    func sendCSVToServer(accData: String, completion: @escaping (Int) -> Void) {
        guard let url = URL(string: "https://jessicalieu.pythonanywhere.com/uploadCSV") else {
            print("Invalid URL")
            completion(-1)
            return
        }

        guard let fileURL = Bundle.main.url(forResource: accData, withExtension: "csv") else {
            print("CSV file not found.")
            completion(-2)
            return
        }
        
        
        // Create URLRequest
        // Create URLRequest with error handling
        do {
            var urlRequest = try URLRequest(url: url, method: .post)
            
            // Set custom timeout interval (e.g., 60 seconds)
            urlRequest.timeoutInterval = 300
            
            // Upload request with custom timeout
            AF.upload(
                multipartFormData: { multipartFormData in
                    // Append the CSV file to the multipart form data
                    multipartFormData.append(fileURL, withName: "file", fileName: "uploaded_file.csv", mimeType: "text/csv")
                },
                with: urlRequest // Use the custom URLRequest
            )
            .uploadProgress { progress in
                // Handle upload progress if needed
                print("Upload Progress: \(progress.fractionCompleted)")
            }
            .responseDecodable(of: APIResponse.self) { response in
                switch response.result {
                case .success(let value):
                    // Handle successful response
                    print("Parsed Response: \(value)")
                    // You can access response properties directly using value.key1, value.key2, etc.
                    completion(0) // or pass appropriate success code
                case .failure(let error):
                    // Handle error
                    print("Upload failed: \(error)")
                    completion(-3) // or pass appropriate error code
                }
            }
        } catch {
            // Handle URLRequest creation error
            print("Error creating URLRequest: \(error)")
            completion(-4) // or pass appropriate error code
        }
}
}
