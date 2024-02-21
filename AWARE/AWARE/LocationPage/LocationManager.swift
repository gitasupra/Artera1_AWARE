//
//  LocationManager.swift
//  AWARE
//
//  Created by Cheryl Stanley on 1/15/24.
//

import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var region = MKCoordinateRegion(
         center: CLLocationCoordinate2D(latitude: 38.898150, longitude: -77.034340),
         span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
     )
    private var hasSetRegion = false
    static let shared = LocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("DEBUG: Not determined")
            
        case .restricted:
            print("DEBUG: Restricted")
            
        case .denied:
            print("DEBUG: Denied")
            
        case .authorizedAlways:
            print("DEBUG: Auth always")
            
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            
        @unknown default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        self.userLocation = location
    }
}

