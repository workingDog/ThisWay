//
//  RouteManager.swift
//  ThisWayApp
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import Foundation
import SwiftUI
import CoreLocation
import MapKit


@Observable
//@MainActor
final class RouteManager {
    
    let locator = LocationService()
    
    var tgtLocation: CLLocation?
    var route = MKRoute()
    var arrows: [RouteArrow] = []
    
    init() { }
    
    func location() -> CLLocation? {
        locator.location
    }
    
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
    
    @MainActor
    func buildArrows() {
        arrows = route.steps.compactMap { step in
            let polyline = step.polyline
            guard polyline.pointCount >= 2 else { return nil }
            
            let points = polyline.points()
            let startCoord = points[0].coordinate
            
            let bearing = bearing(from: startCoord, to: points[1].coordinate)
            
            return RouteArrow(coordinate: startCoord, bearing: bearing)
        }
    }
    
    func getRoute() {
        if let userLoc = locator.location, let tgtLoc = tgtLocation {
            
            let source = MKMapItem(location: userLoc, address: nil)
            let destination = MKMapItem(location: tgtLoc, address: nil)
            
            let request = MKDirections.Request()
            request.source = source
            request.destination = destination
            request.transportType = .walking
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            
            directions.calculate { response, error in
                guard let route = response?.routes.first else { return }
                self.route = route
            }
            
            buildArrows()
        }
    }
    
}
