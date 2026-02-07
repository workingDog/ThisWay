//
//  DirectionView.swift
//  ThisWayApp
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import SwiftUI
import MapKit
import CoreLocation


struct DirectionView: View {
    @Environment(RouteManager.self) var router
    
    let place: Place
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $cameraPosition) {
            MapPolyline(router.route.polyline).stroke(.blue, lineWidth: 4)
            if let location = router.locator.location {
                Annotation("", coordinate: location.coordinate) {
                    Image("arrow")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .rotationEffect(
                            .degrees(router.routeBearing - router.locator.headingDegrees - 90)
                        )
                }
            }
        }
        .task {
            router.tgtLocation = place.item.location
            
            guard let start = router.location()?.coordinate else {return}
            guard let tgt = router.tgtLocation?.coordinate else {return}
            
            print("---> start: \(start)")
            print("---> tgt: \(tgt)\n")
            
            router.getRoute()
        }
    }
}



//struct DirectionView2: View {
//    @Environment(LocationManager.self) var locationManager
//    
//    let place: Place
//
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(place.item.name ?? "Unknown place").font(.headline)
//            Text(place.item.address?.shortAddress ?? "unknown").padding(.bottom, 12)
//            Text(locationManager.locator.location?.distanceStringTo(place.item.location) ?? "")
//            Spacer()
//            Image("arrow")
//                .resizable()
//                .frame(width: 333, height: 333)
//                .rotationEffect(.degrees(locationManager.locator.headingToTgt))
//            Spacer()
//        }
//        .padding()
//        .task {
//            locationManager.tgtLocation = place.item.location
//        }
//    }
//}


/*
 
.animate(withDuration: 0.5) {
   self.imageView.transform = CGAffineTransform(rotationAngle: latestBearing - latestHeading)
 }
 
 
 What I want is to remove all these arrows, and have just one that is
 equivalent to Apple Map app, that shows the direction to take at my current position.
 My current code is:
 
 "ZStack {

     Map(position: $cameraPosition) {
         MapPolyline(router.route.polyline)
             .stroke(.blue, lineWidth: 4)
     }
            Image("arrow")
                .resizable()
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(routeBearing - router.locator.headingDegrees))
}
 }". How can I achieve this, and what to I use for the routeBearing?
 
 
 */
