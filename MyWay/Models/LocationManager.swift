//
//  LocationManager.swift
//  MyWay
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import Foundation
import SwiftUI
import CoreLocation


@Observable
@MainActor
final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    var location: CLLocation?
    var tgtLocation: CLLocation?
    
    var degrees: CGFloat = .zero
    var headingDegrees: CGFloat = .zero
    var bearingToTarget: CGFloat = .zero
    var headingToTgt: CGFloat = .zero
    
    let errorMargin: CLLocationDegrees = 5.0
    
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var error: Error?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.headingFilter = 1
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
            //   error = LocationError.permissionDenied
            print(".denied, .restricted")
            
        @unknown default:  break
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
        guard let current = location, let target = tgtLocation else { return }
        bearingToTarget = current.bearingToLocationDegrees(destinationLocation: target)
        updateHeadingToTgt()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        headingDegrees = newHeading.trueHeading
        updateHeadingToTgt()
    }
    
    private func updateHeadingToTgt() {
        headingToTgt = normalizedAngle(bearingToTarget - headingDegrees)
    }
    
    func normalizedAngle(_ angle: CGFloat) -> CGFloat {
        var a = angle.truncatingRemainder(dividingBy: 360)
        if a > 180 { a -= 360 }
        if a < -180 { a += 360 }
        return a
    }
    
}
