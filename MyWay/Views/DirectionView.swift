//
//  DirectionView.swift
//  MyWay
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import SwiftUI
import MapKit
import CoreLocation


struct DirectionView: View {
    @Environment(LocationManager.self) var locationManager
    
    let place: Place

    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(place.item.name ?? "Unknown place").font(.headline)
            Text(place.item.address?.shortAddress ?? "unknown")
            Text(locationManager.location?.distanceStringTo(place.item.location) ?? "")
        }
        .padding()
    }
}


/*
 
.animate(withDuration: 0.5) {
   self.imageView.transform = CGAffineTransform(rotationAngle: latestBearing - latestHeading)
 }
 
 
 */
