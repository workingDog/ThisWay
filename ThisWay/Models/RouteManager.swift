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
    var routeBearing: CLLocationDegrees = .zero
    
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
 
    func updateRouteBearing() {
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
                self.updateRouteBearing()
            }
        }
    }
    
}
