//
//  Utilities.swift
//  Directus
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import Foundation
import CoreLocation


struct LocationUtils {
    
    static func getRadiansBearingBetweenTwoPoints(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
        let lat1 = degreesToRadians(degrees: point1.latitude)
        let lon1 = degreesToRadians(degrees: point1.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.latitude)
        let lon2 = degreesToRadians(degrees: point2.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansBearing
    }
    
    static func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / Double(180) }
    static func radiansToDegrees(radians: Double) -> Double { return radians * Double(180) / .pi }
}


