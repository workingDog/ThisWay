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




/*
 
 
 func bearingFromUser(to end: CLLocationCoordinate2D) -> CLLocationDegrees {
     if let userCoord = locator.location?.coordinate {
         let lat1 = degreesToRadians(degrees: userCoord.latitude)
         let lon1 = degreesToRadians(degrees: userCoord.longitude)
         
         let lat2 = degreesToRadians(degrees: end.latitude)
         let lon2 = degreesToRadians(degrees: end.longitude)
         
         let dLon = lon2 - lon1
         
         let y = sin(dLon) * cos(lat2)
         let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
         
         var bearing = atan2(y, x) * 180 / .pi
         bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)
         
         return bearing
     }
     
     return .zero
 }
 
 func bearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDegrees {
     
     let lat1 = degreesToRadians(degrees: start.latitude)
     let lon1 = degreesToRadians(degrees: start.longitude)
     
     let lat2 = degreesToRadians(degrees: end.latitude)
     let lon2 = degreesToRadians(degrees: end.longitude)
     
     let dLon = lon2 - lon1
     
     let y = sin(dLon) * cos(lat2)
     let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
     
     var bearing = atan2(y, x) * 180 / .pi
     bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)

     return bearing
 }
 
 func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / Double(180) }
 
 func radiansToDegrees(radians: Double) -> Double { return radians * Double(180) / .pi }
 
 func bearing(from polyline: MKPolyline) -> CLLocationDegrees? {
     guard polyline.pointCount >= 2 else { return nil }
     
     let points = polyline.points()
     let start = points[0].coordinate
     let next = points[1].coordinate
     
     return bearing(from: start, to: next)
 }
 
 func closestSegmentIndex(to location: CLLocationCoordinate2D, in polyline: MKPolyline) -> Int? {

     let userPoint = MKMapPoint(location)
     let points = polyline.points()

     var closestIndex: Int?
     var minDistance = CLLocationDistance.greatestFiniteMagnitude

     for i in 0..<(polyline.pointCount - 1) {
         let p1 = points[i]
         let p2 = points[i + 1]

         let distance = distanceFromPoint(userPoint, toSegmentBetween: p1,and: p2)

         if distance < minDistance {
             minDistance = distance
             closestIndex = i
         }
     }

     return closestIndex
 }
 
 func distanceFromPoint(_ p: MKMapPoint, toSegmentBetween v: MKMapPoint, and w: MKMapPoint) -> CLLocationDistance {

     let l2 = v.distance(to: w)
     if l2 == 0 { return p.distance(to: v) }

     let t = max(0, min(1,
         ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) /
         ((w.x - v.x) * (w.x - v.x) + (w.y - v.y) * (w.y - v.y))
     ))

     let projection = MKMapPoint(
         x: v.x + t * (w.x - v.x),
         y: v.y + t * (w.y - v.y)
     )

     return p.distance(to: projection)
 }

 func updateRouteBearing2() {
     if let userLoc = locator.location {
         guard let index = closestSegmentIndex(
             to: userLoc.coordinate,
             in: route.polyline
         ) else { return }

         let points = route.polyline.points()
         let start = points[index].coordinate
         let aheadIndex = min(index + 5, route.polyline.pointCount - 1)
         let end = points[aheadIndex].coordinate

         routeBearing = bearing(from: start, to: end)
     }
 }
 
 
 
 */
