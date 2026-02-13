//
//  RouteManager.swift
//  ThisWay
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import Foundation
import SwiftUI
import CoreLocation
import MapKit


@Observable
final class RouteManager {
    
    // service for user location 
    let locator = LocationService()
    // target location
    var tgtLocation: CLLocation?
    
    var route = MKRoute()
    var routeBearing: CLLocationDegrees = .zero
    var remainingDistance: Double = 0

    
    init() { }
    
    // convenience
    func location() -> CLLocation? {
        locator.location
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
                self.updateRoute()
            }
        }
    }

    private func closestPolylineIndex(to location: CLLocationCoordinate2D, in polyline: MKPolyline) -> Int {
        
        let userPoint = MKMapPoint(location)
        let points = polyline.points()

        var bestIndex = 0
        var bestDistance = CLLocationDistance.greatestFiniteMagnitude

        for i in 0..<polyline.pointCount {
            let d = userPoint.distance(to: points[i])
            if d < bestDistance {
                bestDistance = d
                bestIndex = i
            }
        }

        return bestIndex
    }
    
    func updateRoute() {
        updateRouteBearing()
        updateRemainingDistance()
    }
    
    private func updateRouteBearing() {
        guard let location = locator.location else { return }

        let polyline = route.polyline
        let pointCount = polyline.pointCount
        
        // Ensure we have enough points
        guard pointCount > 1 else { return }

        let points = polyline.points()

        var index = closestPolylineIndex(to: location.coordinate, in: polyline)

        // Clamp index safely into valid range
        index = max(0, min(index, pointCount - 1))

        let aheadIndex = min(index + 3, pointCount - 1)

        let start = location.coordinate
        let end = points[aheadIndex].coordinate

        routeBearing = bearing(from: start, to: end)
    }

    private func updateRemainingDistance() {
        guard let location = locator.location else { return }

        let polyline = route.polyline
        let points = polyline.points()

        let index = closestPolylineIndex(to: location.coordinate, in: polyline)

        var remaining = 0.0

        // Distance from user to next route point
        remaining += location.distance(
            from: CLLocation(
                latitude: points[index].coordinate.latitude,
                longitude: points[index].coordinate.longitude
            )
        )

        // Remaining polyline length
        for i in index..<(polyline.pointCount - 1) {
            remaining += points[i].distance(to: points[i + 1])
        }
        
        remainingDistance = remaining
    }
    
    static func asString(_ dist: Double) -> String {
        if dist < 1_000 {
            return "\(Int(dist)) m "
        } else {
            return String(format: "%.1f km ", dist / 1_000)
        }
    }
}
