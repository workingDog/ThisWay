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
        VStack(alignment: .leading) {
            Text(place.item.name ?? "Unknown place").font(.headline)
            Text(place.item.address?.shortAddress ?? "unknown").padding(.bottom, 12)
            Text(locationManager.location?.distanceStringTo(place.item.location) ?? "")
            Spacer()
            Image("arrow")
                .resizable()
                .frame(width: 333, height: 333)
                .rotationEffect(.degrees(locationManager.headingToTgt))
            Spacer()
        }
        .padding()
        .task {
            locationManager.tgtLocation = place.item.location
        }
    }
}


/*
 
.animate(withDuration: 0.5) {
   self.imageView.transform = CGAffineTransform(rotationAngle: latestBearing - latestHeading)
 }
 
 
 */
