//
//  Extension.swift
//  MyWay
//
//  Created by Ringo Wathelet on 2026/02/06.
//

import Foundation
import CoreLocation


public extension CLLocation {
  func bearingToLocationRadian(_ destinationLocation: CLLocation) -> CGFloat {
    
    let lat1 = self.coordinate.latitude.degreesToRadians
    let lon1 = self.coordinate.longitude.degreesToRadians
    
    let lat2 = destinationLocation.coordinate.latitude.degreesToRadians
    let lon2 = destinationLocation.coordinate.longitude.degreesToRadians
    
    let dLon = lon2 - lon1
    
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radiansBearing = atan2(y, x)
    
    return CGFloat(radiansBearing)
  }
  
  func bearingToLocationDegrees(destinationLocation: CLLocation) -> CGFloat {
    return bearingToLocationRadian(destinationLocation).radiansToDegrees
  }
}

extension CGFloat {
  var degreesToRadians: CGFloat { return self * .pi / 180 }
  var radiansToDegrees: CGFloat { return self * 180 / .pi }
}

private extension Double {
  var degreesToRadians: Double { return Double(CGFloat(self).degreesToRadians) }
  var radiansToDegrees: Double { return Double(CGFloat(self).radiansToDegrees) }
}

/*
 
 
 let location1 = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
 let location2 = CLLocation(latitude: 34.0522, longitude: -118.2437) // Los Angeles

 // Calculate distance
 let distance = location1.distance(from: location2)
 print("Distance: \(distance / 1000) km")

 // Or use Measurement API for type-safe conversions
 let measurement = Measurement(value: distance, unit: UnitLength.meters)
 let km = measurement.converted(to: .kilometers).value
 print("Distance: \(km) km")

 // Calculate bearing
 let bearing = location1.bearing(toLocation: location2)
 print("Bearing: \(bearing)°")

 // Calculate coordinate at bearing and distance
 let coordinate = location1.locationCoordinate(withBearing: 45, distanceMeters: 1000)
 print("New coordinate: \(coordinate)")

 // Pretty distance description (localized)
 let description = location1.prettyDistanceDescription(fromLocation: location2)
 print("Distance: \(description)")
 
 */
