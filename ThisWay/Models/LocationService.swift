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
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.headingFilter = kCLHeadingFilterNone
        manager.headingOrientation = .portrait
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
        
        if authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways {
            
            manager.requestLocation()
            
            if CLLocationManager.headingAvailable() {
                manager.startUpdatingHeading()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // direction the iPhone is pointing, in degrees, relative to true north.
        headingDegrees = newHeading.trueHeading
    }
    
}

