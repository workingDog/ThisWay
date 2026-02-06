//
//  Temp1.swift
//  ThisWayApp
//
//  Created by Ringo Wathelet on 2026/02/06.
//

/*
 
 @Observable
 class NewLocationManager {
     var location: CLLocation? = nil
     private let locationManager = CLLocationManager()
     
     func requestUserAuthorization() async throws {
         locationManager.requestWhenInUseAuthorization()
     }
     
     func startCurrentLocationUpdates() async throws {
         for try await locationUpdate in CLLocationUpdate.liveUpdates() {
             guard let newLocation = locationUpdate.location else { return }
             // adjust the logic/parameters as you require
             if let oldLocation = location {
                 if !oldLocation.isClose(to: newLocation, withinDistance: 50.0) {
                     location = newLocation
                 }
             } else {
                 location = newLocation
             }
         }
     }

 }

 struct ContentViewtytyjuy: View {
     @State var newlocationManager = NewLocationManager()
     @State private var selectedResult: MKMapItem?
     @State private var route: MKRoute?
     
     // for my tests, Tokyo garden
     private let startingPoint = CLLocationCoordinate2D(latitude: 35.661991, longitude: 139.762735)
     
     @State private var destinationCoordinates = CLLocationCoordinate2D(latitude: 35.67, longitude: 139.763)  // <--- here @State
     
     var body: some View {
         Map(selection: $selectedResult) {
             UserAnnotation()
             // Adding the marker for the starting point
             Marker("Start", coordinate: startingPoint)
             // Show the route if it is available
             if let route {
                 MapPolyline(route)
                     .stroke(.blue, lineWidth: 5)
             }
         }
         .onChange(of: newlocationManager.location) {  // <--- here
             if let coord = newlocationManager.location?.coordinate {
                 destinationCoordinates = coord
                 getDirections2()
             }
         }
         .onChange(of: selectedResult) {
          //   getDirections()
             print("----> selectedResult: \(selectedResult)")
         }
         .task {
             try? await newlocationManager.requestUserAuthorization()
             try? await newlocationManager.startCurrentLocationUpdates()
             // remember that nothing will run here until the for try await loop finishes
         }
         .onAppear {
             CLLocationManager().requestWhenInUseAuthorization()
             selectedResult = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinates))
         }
     }
     
     func getDirections() {
         route = nil
         // Check if there is a selected result
         guard let selectedResult else { return }
         // Create and configure the request
         let request = MKDirections.Request()
         request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.startingPoint))
         request.destination = selectedResult
         // Get the directions based on the request
         Task {
             let directions = MKDirections(request: request)
             let response = try? await directions.calculate()
             route = response?.routes.first
             print("----> route selectedResult: \(selectedResult)")
         }
     }
     
     // --- here
     func getDirections2() {
         route = nil
         // Create and configure the request
         let request = MKDirections.Request()
         request.source = MKMapItem(placemark: MKPlacemark(coordinate: startingPoint))
         request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinates))
         // Get the directions based on the request
         Task {
             let directions = MKDirections(request: request)
             let response = try? await directions.calculate()
             route = response?.routes.first
         }
     }
     
 }

 extension CLLocation {
     func isClose(to otherLocation: CLLocation, withinDistance distance: CLLocationDistance) -> Bool {
         return self.distance(from: otherLocation) <= distance
     }
 }

 
 struct MyMapItem: Identifiable {
     let id = UUID()
     let mapItem: MKMapItem
 }

 struct MyReverseGeocoderView: View {
     
     let fountainCoordinates = [
         CLLocation(latitude: 39.042617, longitude: -94.587526),
         CLLocation(latitude: 40.774313, longitude: -73.970835),
         CLLocation(latitude: -33.870986, longitude: 151.211786),
         CLLocation(latitude: 41.875790, longitude: -87.618953),
     ]
     
     @State private var fountains: [MyMapItem] = []

     var body: some View {
         VStack {
             ForEach(fountains) { item in
                 Text(item.mapItem.address?.fullAddress ?? "no data").foregroundStyle(.blue)
                 Text(item.mapItem.address?.shortAddress ?? "no data").foregroundStyle(.red)
             }
         }
         .task {
             for coordinate in fountainCoordinates {
                 if let request = MKReverseGeocodingRequest(location: coordinate) {
                     do {
                         let mapitems = try await request.mapItems
                         if let mapitem = mapitems.first {
                             fountains.append(MyMapItem(mapItem: mapitem))
                         }
                     } catch {
                         print(error)
                     }
                 }
             }
         }
     }
 }

 
 */
