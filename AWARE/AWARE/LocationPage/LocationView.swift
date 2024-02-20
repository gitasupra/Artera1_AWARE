//
//  LocationView.swift
//  AWARE
//
//  Created by Jessica Nguyen on 1/20/24.
//

import SwiftUI
import CoreLocation
import Combine
import MapKit
import UIKit
import UberRides

struct UberRideRequestButton: UIViewRepresentable {
    func makeUIView(context: Context) -> RideRequestButton {
        return RideRequestButton()
    }

    func updateUIView(_ uiView: RideRequestButton, context: Context) {
        // Update any properties or handle events if needed
    }
}

struct LocationView: View {
    // User Location
    @ObservedObject var locationManager = LocationManager.shared
        
    // Map 2
    @StateObject private var viewModel = ContentViewModel()
    
    // Map 1
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    
    // Coordinates
    @StateObject var deviceLocationService = DeviceLocationService.shared
    @State var tokens: Set<AnyCancellable> = []
    @State var coordinates: (lat: Double, lon: Double) = (0,0)
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Location")
                    .font(.title)
                
                HStack {
                    Text("Latitude: \(coordinates.lat)")
                    Text("Longitude: \(coordinates.lon)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
        }
        Spacer()
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
            .ignoresSafeArea()
            .onAppear {
                viewModel.checkIfLocationServicesIsEnabled()
            }
            .mapControls {
                MapCompass()
                MapUserLocationButton()
            }
            .frame(height: 400)
            .cornerRadius(10)
        Spacer()

        HStack {
            Text("Feelin Tipsy?")
                .italic()
                .font(.subheadline)
            
            Image(systemName: "wineglass")
                .foregroundColor(.purple)
        }
        HStack {
            // Ride request button
            UberRideRequestButton()
                .frame(width: 240, height: 40)
        }
        .onAppear {
            observeCoordinateUpdates()
            observeLocationAccessDenied()
            deviceLocationService.requestLocationUpdates()
        }
        .cornerRadius(6)
        .background(Color.accentColor)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.accentColor, lineWidth: 1)
        )
        Spacer()
    }
    
    // Coordinates ================
    func observeCoordinateUpdates() {
        deviceLocationService.coordinatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            } receiveValue: { coordinates in
                self.coordinates = (coordinates.latitude, coordinates.longitude)
            }
            .store(in: &tokens)
    }

    func observeLocationAccessDenied() {
        deviceLocationService.deniedLocationAccessPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                print("Show some kind of alert to the user")
            }
            .store(in: &tokens)
    }
}

extension LocationView {
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery  = searchText
        request.region = .userRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.snappy) {
                    routeDisplaying = true
                    showDetails = false
                    
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
    }
}



extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 25.7602, longitude: -80.1959)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}
final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)) //latitude: 37.221516, longitude: -121.891854
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
        } else {
            print("Show an alert letting them know this is off and to go turn it on")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            print("Your location is restricted likely due to parental controls")
            
        case .denied:
            print("You have denied this app location permission. Please go into settings to change it.")
            
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
