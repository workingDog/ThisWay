//
//  LocationService.swift
//  ThisWay
//
//  Created by Ringo Wathelet on 2026/02/07.
//
import Foundation
import SwiftUI
import CoreLocation
import MapKit



@Observable
@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    // user location
    var location: CLLocation?
    var headingDegrees: CGFloat = .zero

    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var error: Error?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.headingOrientation = .portrait
        manager.headingFilter = 5  // kCLHeadingFilterNone
        manager.distanceFilter = 3  // kCLDistanceFilterNone
        manager.activityType = .fitness
        manager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestPermissionAndLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            print(".notDetermined")
            manager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse, .authorizedAlways:
            print(".authorizedWhenInUse, .authorizedAlways")
            manager.requestLocation()
            
        case .denied, .restricted:
            print(".denied, .restricted  permissionDenied")
            
        @unknown default: break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            return
        }

        manager.startUpdatingLocation()
        
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy > 0 else { return }
        // direction the iPhone is pointing, in degrees, relative to true north.
        headingDegrees = newHeading.trueHeading
    }
    
}




/*
 
 // with simulation
 
@Observable
@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    // user location
    var location: CLLocation?
    var headingDegrees: CGFloat = .zero

    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var error: Error?
    
    var isSimulating = false
    private var simulationTask: Task<Void, Never>?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.headingFilter = kCLHeadingFilterNone
        manager.headingOrientation = .portrait
        manager.distanceFilter = 5
    }
    
    func requestPermissionAndLocation() {
        guard !isSimulating else { return }
        
        switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
                
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
                
            case .denied, .restricted:
                break
            
            @unknown default: break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            return
        }

        manager.startUpdatingLocation()
        
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !isSimulating else { return }
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // direction the iPhone is pointing, in degrees, relative to true north.
        headingDegrees = newHeading.trueHeading
    }
    
    func startSimulation(
        from startCoordinate: CLLocationCoordinate2D,
        speedMetersPerSecond: Double = 1.4 // normal walking speed
    ) {
        isSimulating = true
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
        
        var current = startCoordinate
        let interval: TimeInterval = 1.0
        
        simulationTask = Task {
            while !Task.isCancelled {
                
                // Move forward along heading
                let headingRad = Double(headingDegrees) * .pi / 180
                
                let deltaLat = (speedMetersPerSecond * cos(headingRad)) / 111_111
                let deltaLon = (speedMetersPerSecond * sin(headingRad)) /
                    (111_111 * cos(current.latitude * .pi / 180))
                
                current.latitude += deltaLat
                current.longitude += deltaLon
                
                location = CLLocation(
                    coordinate: current,
                    altitude: 0,
                    horizontalAccuracy: 5,
                    verticalAccuracy: 5,
                    timestamp: Date()
                )
                
                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }
    
    func stopSimulation() {
        simulationTask?.cancel()
        simulationTask = nil
        isSimulating = false
    }
    
    private func coordinates(from polyline: MKPolyline) -> [CLLocationCoordinate2D] {
        var coords = Array(
            repeating: kCLLocationCoordinate2DInvalid,
            count: polyline.pointCount
        )
        polyline.getCoordinates(&coords, range: NSRange(location: 0, length: polyline.pointCount))
        return coords
    }
    
    func startRouteSimulation(route: MKRoute, speed metersPerSecond: Double = 1.4) {
        
        isSimulating = true
        
        // Stop real location updates
        manager.stopUpdatingLocation()
        
        // ❗️Keep heading updates running
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
        
        let coords = coordinates(from: route.polyline)
        guard coords.count > 1 else { return }
        
        simulationTask?.cancel()
        
        simulationTask = Task {
            
            var currentIndex = 0
            
            while currentIndex < coords.count - 1 && !Task.isCancelled {
                
                let startCoord = coords[currentIndex]
                let endCoord   = coords[currentIndex + 1]
                
                let startLocation = CLLocation(latitude: startCoord.latitude,
                                               longitude: startCoord.longitude)
                
                let endLocation = CLLocation(latitude: endCoord.latitude,
                                             longitude: endCoord.longitude)
                
                let distance = startLocation.distance(from: endLocation)
                let segmentDuration = distance / metersPerSecond
                let steps = max(Int(segmentDuration / 0.5), 1)
                
                for step in 1...steps {
                    
                    let fraction = Double(step) / Double(steps)
                    
                    let lat = startCoord.latitude +
                        (endCoord.latitude - startCoord.latitude) * fraction
                    
                    let lon = startCoord.longitude +
                        (endCoord.longitude - startCoord.longitude) * fraction
                    
                    let simulatedCoord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    
                    location = CLLocation(
                        coordinate: simulatedCoord,
                        altitude: 0,
                        horizontalAccuracy: 5,
                        verticalAccuracy: 5,
                        timestamp: Date()
                    )
                    
                    try? await Task.sleep(for: .milliseconds(500))
                }
                
                currentIndex += 1
            }
            
            isSimulating = false
        }
    }
    
    
    func degToRad(degrees: Double) -> Double { return degrees * .pi / Double(180) }
    
    func radToDeg(radians: Double) -> Double { return radians * Double(180) / .pi }
    
    func bearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDegrees {
        
        let lat1 = degToRad(degrees: start.latitude)
        let lon1 = degToRad(degrees: start.longitude)
        
        let lat2 = degToRad(degrees: end.latitude)
        let lon2 = degToRad(degrees: end.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var bearing = atan2(y, x) * 180 / .pi
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)

        return bearing
    }
}
*/

