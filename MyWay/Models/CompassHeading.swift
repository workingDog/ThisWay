//
//  CompassHeading.swift
//  MyWay
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import SwiftUI
import Foundation
import CoreLocation

/*
@Observable class CompassHeading: NSObject, CLLocationManagerDelegate {

    var degrees: Double = .zero
    var headingDegrees: Double = .zero
    var destAngle: CLLocationDegrees = .zero
    
    let errorMargin: CLLocationDegrees = 5.0
    let locationManager: LocationManager
    
    var isHeadingToTarget: Bool {
        let lowerBound = destAngle - errorMargin
        let upperBound = destAngle + errorMargin
        return headingDegrees >= lowerBound && headingDegrees <= upperBound
    }
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        self.locationManager.delegate = self
        self.setup()
    }
    
    private func setup() {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.headingAvailable() {
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.degrees = -1 * newHeading.magneticHeading
    }
    
    
    
}

*/
