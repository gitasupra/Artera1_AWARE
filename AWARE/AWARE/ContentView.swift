import SwiftUI
import CoreMotion
import CoreLocation
import Charts
import Combine
import MapKit


struct ContentView: View {
    
//    @StateObject private var viewModel = ContentViewModel()
    
    @EnvironmentObject var motion: CMMotionManager
    @StateObject var enableDataCollectionObj = EnableDataCollection()
    
    // User Location
    @ObservedObject var locationManager = LocationManager.shared
    
    // Map 2
    
    @StateObject private var viewModel = ContentViewModel()
    
   
    
    //map 1
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
    
    // San Jose
//    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054), 
//                                                   span:
//                                                    MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)) //0.1 0.1
//    
    
    @State private var enableDataCollection = false
    @State private var shouldHide = false
    
    // setting toggles
    @State private var name = ""
    @State private var isNotificationEnabled = true
    @State private var isContactListEnabled = true
    @State private var isUberEnabled = false
    @State private var isEmergencyContacts = false
    @State private var isHelpTipsEnabled = true
    
    
    // style variables
    let accentColor:Color = .purple
    let backgroundColor:Color = .black
    struct CustomButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
                .padding([.top, .bottom], 2)
        }
    }
    
    func getDatesForCurrentWeek() -> [String] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let lastSunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM'\u{2028}' d"
        
        return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: lastSunday)! }
            .map {formatter.string(from: $0)}
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
    
    //======================

    
    func startDeviceMotion() {
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0 / 50.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            // Configure a timer to fetch the device motion data
            let timer = Timer(fire: Date(), interval: (1.0 / 50.0), repeats: true) { _ in
                guard let data = self.motion.deviceMotion else { return }
                
                // Get attitude data
                let attitudeX = data.attitude.pitch
                let attitudeY = data.attitude.roll
                let attitudeZ = data.attitude.yaw
                // Get accelerometer data
                let accelerometerX = data.userAcceleration.x
                let accelerometerY = data.userAcceleration.y
                let accelerometerZ = data.userAcceleration.z
                // Get the gyroscope data
                let gyroX = data.rotationRate.x
                let gyroY = data.rotationRate.y
                let gyroZ = data.rotationRate.z
                
                print("Attitude x: ", attitudeX)
                print("Attitude y: ", attitudeY)
                print("Attitude z: ", attitudeZ)
                print("Accelerometer x: ", accelerometerX)
                print("Accelerometer y: ", accelerometerY)
                print("Accelerometer z: ", accelerometerZ)
                print("Rotation x: ", gyroX)
                print("Rotation y: ", gyroY)
                print("Rotation z: ", gyroZ)
            }
            
            // Add the timer to the current run loop
            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        }
    }
    
    var body: some View {
        TabView {
            // Page 1 Graphs
            NavigationView {
                VStack(alignment: .center) {
                    Text("Graphs")
                        .font(.system(size: 36))
                    NavigationLink(destination: Text("Heart Rate Data")) {
                        Button("View Heart Rate Data") {}
                            .buttonStyle(CustomButtonStyle())
                    }
                    
                    NavigationLink(destination: Text("Breathing Rate Data")) {
                        Button("View Breathing Rate Data") {}
                            .buttonStyle(CustomButtonStyle())
                    }
                    
                    NavigationLink(destination: Text("Walking Steadiness Data")) {
                        Button("View Walking Steadiness Data") {}
                            .buttonStyle(CustomButtonStyle())
                    }
                }
            }
            .tabItem {
                Label("Graphs", systemImage: "chart.pie.fill")
            }
            
            // Page 3 Contacts
            VStack(alignment: .center) {
                Text("Contacts")
                    .font(.system(size: 36))
                    .multilineTextAlignment(.leading)
                    .padding()
                
                Spacer()
                
                NavigationLink(destination: Text("Contact List")) {
                    Button("Edit Contact List") {}
                        .buttonStyle(CustomButtonStyle())
                }
                
                NavigationLink(destination: Text("Call Uber")) {
                    Button("Call Uber") {}
                        .buttonStyle(CustomButtonStyle())
                }
                
                NavigationLink(destination: Text("Call 911")) {
                    Button("Call Emergency Services") {}
                        .buttonStyle(CustomButtonStyle())
                }
                
                Spacer()
            }
            .tabItem {
                Label("Contacts", systemImage: "person.crop.circle")
            }
            
            // Page 3 - Home / Toggle
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
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                
                // Page 4 Analytics
                NavigationView {
                    VStack(alignment: .center) {
                        Text("Analytics")
                            .font(.system(size: 36))
                        
                        Spacer()
                        
                        VStack {
                            
                            //UNCOMMENT THIS LATER
                            //                            HStack {
                            //                                let daysOfTheWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                            //                                let datesForCurrentWeek = getDatesForCurrentWeek()
                            //                                let currentDay = Calendar.current.component(.day, from: Date())
                            //
                            //                                ForEach(Array(daysOfTheWeek.enumerated()), id: \.element) { index, element in
                            //                                    VStack {
                            //                                        Text(element)
                            //                                            .padding(10)
                            //                                            .foregroundColor(.gray)
                            //                                            .cornerRadius(8)
                            //                                            .font(.system(size: 12))
                            //
                            //                                        let dayOnly = Int(datesForCurrentWeek[index].components(separatedBy: " ")[1])
                            //                                        Text(datesForCurrentWeek[index].components(separatedBy: " ")[1])
                            //                                            .padding(10)
                            //                                            .background(currentDay == dayOnly ? Color.accentColor : backgroundColor)
                            //                                            .foregroundColor(.white)
                            //                                            .cornerRadius(8)
                            //                                            .font(.system(size: 15))
                            //                                    }
                            //                                }
                            //
                            //                            }
                            //                            .cornerRadius(6)
                            //                            .overlay(
                            //                                RoundedRectangle(cornerRadius: 6)
                            //                                    .stroke(Color.accentColor, lineWidth: 1)
                            //                            )
                            //
                            //UNCOMMENT ABOVE LATER
                            
                            
                            
                                                        VStack {
                                                            Text("Latitude: \(coordinates.lat)")
                                                                .font(.subheadline) //.largeTitle
                                                            Text("Longitude: \(coordinates.lon)")
                                                                .font(.subheadline)
                                                        }
                                                        .onAppear {
                                                            observeCoordinateUpdates()
                                                            observeLocationAccessDenied()
                                                            deviceLocationService.requestLocationUpdates()
                                                        }
                                                        .cornerRadius(6)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 6)
                                                                .stroke(Color.accentColor, lineWidth: 1)
                                                        )
                            
                            
                            
                            
                        }
//                        
//                        NavigationLink(destination: Text("View Past Data")) {
//                            Button("View Past Data") {}
//                                .buttonStyle(CustomButtonStyle())
//                        }
                        
                        Spacer()
                        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                            
                            .ignoresSafeArea()
//                            .accentColor(Color(.systemPink))
                        
                            .onAppear {
                                viewModel.checkIfLocationServicesIsEnabled()
                            }
                            .mapControls {
                                MapCompass()
                                MapUserLocationButton()
                            }
                        //                                    ForEach(results, id: \.self) { item in
                        //                                        if routeDisplaying {
                        //                                            if item == routeDestination  {
                        //                                                let placemark = item.placemark
                        //                                                Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                        //                                            }
                        //                                        } else {
                        //                                            let placemark = item.placemark
                        //                                            Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                        //                                        }
                        //                                    }
                        //                                    if let route {
                        //                                        MapPolyline(route.polyline)
                        //                                            .stroke(.blue, lineWidth: 6)
                        //                                    }
                        //                                }
                            .overlay(alignment: .bottomTrailing) {
                                    TextField("Search for Location...", text: $searchText)
                                            .font(.subheadline)
                                            .padding(12)
                                            .background(.black)
                                            .padding()
                                            .shadow(radius: 10)
                            }
                            .onSubmit(of: .text) {
                                Task { await searchPlaces() }
                            }
                            .onChange(of: getDirections, { oldValue, newValue in
                                if newValue {
                                    fetchRoute()
                                }
                            })
                            .onChange(of: mapSelection, { oldValue, newValue in
                                showDetails = newValue != nil
                            })
                            .sheet(isPresented: $showDetails, content: { LocationDetailsView(mapSelection: $mapSelection, show: $showDetails, getDirections: $getDirections)
                                    .presentationDetents([.height(340)])
                                    .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                                    .presentationCornerRadius(12)
                            })
                                                
                        
                                                     
                        
//                        Group {
//                            if locationManager.userLocation == nil {
//                                LocationRequestView()
//                            } else {
//                                Map(position: $cameraPosition,
//                                    selection: $mapSelection) {
//                                    Annotation("My location", coordinate: .userLocation) {
//                                        ZStack {
//                                            Circle()
//                                                .frame(width: 32, height: 32)
//                                                .foregroundColor(.blue.opacity(0.25))
//                                            Circle()
//                                                .frame(width: 20, height: 20)
//                                                .foregroundColor(.white)
//                                            Circle()
//                                                .frame(width: 12, height: 12)
//                                                .foregroundColor(.blue)
//                                        }
//                                    }
//                                    ForEach(results, id: \.self) { item in
//                                        if routeDisplaying {
//                                            if item == routeDestination  {
//                                                let placemark = item.placemark
//                                                Marker(placemark.name ?? "", coordinate: placemark.coordinate)
//                                            }
//                                        } else {
//                                            let placemark = item.placemark
//                                            Marker(placemark.name ?? "", coordinate: placemark.coordinate)
//                                        }
//                                    }
//                                    if let route {
//                                        MapPolyline(route.polyline)
//                                            .stroke(.blue, lineWidth: 6)
//                                    }
//                                }
//                                .overlay(alignment: .bottomTrailing) {
//                                    TextField("Search for Location...", text: $searchText)
//                                        .font(.subheadline)
//                                        .padding(12)
//                                        .background(.black)
//                                        .padding()
//                                        .shadow(radius: 10)
//                                }
//                                .onSubmit(of: .text) {
//                                    Task { await searchPlaces() }
//                                }
//                                .onChange(of: getDirections, { oldValue, newValue in
//                                    if newValue {
//                                        fetchRoute()
//                                    }
//                                })
//                                .onChange(of: mapSelection, { oldValue, newValue in
//                                    showDetails = newValue != nil
//                                })
//                                .sheet(isPresented: $showDetails, content: { LocationDetailsView(mapSelection: $mapSelection, show: $showDetails, getDirections: $getDirections)
//                                        .presentationDetents([.height(340)])
//                                        .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
//                                        .presentationCornerRadius(12)
//                                })
//                                .mapControls {
//                                    MapCompass()
//                                    MapUserLocationButton()
//                                }
//                            }
//                        }
                    }
//                        Map(position: $cameraPosition, selection: $mapSelection) {
//                            //                            Marker("My location", systemImage: "paperplane", coordinate: .userLocation)
//                            //                                .tint(.blue)
//                            Annotation("My location", coordinate: .userLocation) {
//                                ZStack {
//                                    Circle()
//                                        .frame(width: 32, height: 32)
//                                        .foregroundColor(.blue.opacity(0.25))
//                                    Circle()
//                                        .frame(width: 20, height: 20)
//                                        .foregroundColor(.white)
//                                    Circle()
//                                        .frame(width: 12, height: 12)
//                                        .foregroundColor(.blue)
//                                }
//                                
//                            }
//                            ForEach(results, id: \.self) { item in
//                                if routeDisplaying {
//                                    if item == routeDestination  {
//                                        let placemark = item.placemark
//                                        Marker(placemark.name ?? "", coordinate: placemark.coordinate)
//                                    }
//                                } else {
//                                    let placemark = item.placemark
//                                    Marker(placemark.name ?? "", coordinate: placemark.coordinate)
//                                }
//                            }
//                            if let route {
//                                //                                MapPolyline(route.polyline)
//                                //                                    .stroke(.blue, lineWidth: 6)
//                                MapPolyline(route.polyline)
//                                    .stroke(.blue, lineWidth: 6)
//                            }
//                        }
//                       
//                    
//                        .overlay(alignment: .bottomTrailing) {
//                            TextField("Search for Location...", text: $searchText)
//                                .font(.subheadline)
//                                .padding(12)
//                                .background(.black)
//                                .padding()
//                                .shadow(radius: 10)
//                        }
//                        .onSubmit(of: .text) {
//                            Task { await searchPlaces() }
//                        }
//                        .onChange(of: getDirections, { oldValue, newValue in
//                            if newValue {
//                                fetchRoute()
//                            }
//                        })
//                        
//                        .onChange(of: mapSelection, { oldValue, newValue in
//                            showDetails = newValue != nil
//                        })
//                        .sheet(isPresented: $showDetails, content: { LocationDetailsView(mapSelection: $mapSelection, show: $showDetails, getDirections: $getDirections)
//                                .presentationDetents([.height(340)])
//                                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
//                                .presentationCornerRadius(12)
//                        })
//                        .mapControls {
//                            MapCompass()
//                            MapUserLocationButton()
//                        }// hold option + shift + move mouse = zoom in/out + show compass
////                        Map(coordinateRegion: $region, showsUserLocation: true)
////                            .ignoresSafeArea()
////                            .onAppear {
////                                viewModel.checkIfLocationServicesIsEnabled()
////                            }
                    
                }
                .tabItem {
                    Label("Analytics", systemImage: "heart.text.square")
                }
                
                // Page 5 Settings
                NavigationView {
                    Form {
                        Section(header: Text("User Profile")) {
                            TextField("Name", text: $name).disableAutocorrection(true)
                        }.tint(accentColor)
                        
                        Section(header: Text("Contacts")) {
                            Toggle(isOn: $isContactListEnabled) {
                                Text("Enable contact list")
                                Text("Contact others when intoxicated")
                            }
                            Toggle(isOn: $isUberEnabled) {
                                Text("Enable Uber")
                                Text("Open the Uber app when driving impaired")
                            }
                            Toggle(isOn: $isEmergencyContacts) {
                                Text("Enable emergency services")
                                Text("Call 911 in case of extreme emergencies")
                            }
                        }.tint(accentColor)
                        
                        Section(header: Text("Notifications")) {
                            Toggle(isOn: $isNotificationEnabled) {
                                Text("Allow notifications")
                                Text("Receive updates on your intoxication level")
                            }
                        }.tint(accentColor)
                        
                        Section(header: Text("Miscellaneous")) {
                            Toggle(isOn: $isHelpTipsEnabled) {
                                Text("Enable help tips")
                                Text("Receive tips on drinking safely")
                            }
                        }.tint(accentColor)
                        
                        Section {
                            Button("Reset to default") {
                                isNotificationEnabled = true
                                isContactListEnabled = true
                                isUberEnabled = false
                                isEmergencyContacts = false
                                isHelpTipsEnabled = true
                            }
                        }.tint(accentColor)
                    }
                    .navigationBarTitle(Text("Settings"))
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }.accentColor(accentColor)
        }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
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
        //        return .init(latitude: 34.4358294, longitude: -119.8276389)
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
//            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
//            checkLocationAuthorization()
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

    
//    func checkIfLocationServicesIsEnabled() {
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager = CLLocationManager()
//            //customize kCLLocationAccuracy
//            locationManager!.delegate = self
////            locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation // this was removed
//        } else {
//            print("Show and alert letting them to know location is off and to turn it on")
//        }
//    }
    
//    private func checkLocationAuthorization() {
//        guard let locationManager = locationManager else { return }
//        
//        switch locationManager.authorizationStatus {
//        case .notDetermined: //.requestWhenInUseAuthorization
////            if(enableDataCollectionObj.enableDataCollection == 1) {
//                locationManager.requestAlwaysAuthorization()
////            }
//        case .restricted:
//            print("Your location is restricted likely due to parental controls")
//        case .denied:
//            print("You have denied location permissions for this app. Please go into settings and enable location permissions for this app.")
//        case .authorizedAlways, .authorizedWhenInUse:
//            break;
//        @unknown default:
//            break;
//        }
//    }
    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        checkLocationAuthorization()
//    }
    

