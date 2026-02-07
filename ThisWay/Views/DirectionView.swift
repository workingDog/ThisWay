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
        
        Text("\(router.remainingDistance.asStringDistance())")
        
        Map(position: $cameraPosition) {
            MapPolyline(router.route.polyline).stroke(.blue, lineWidth: 4)
            if let location = router.locator.location {
                Annotation("", coordinate: location.coordinate) {
                    Image("arrow")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .rotationEffect(
                            .degrees(router.routeBearing - router.locator.headingDegrees)
                        )
                     //   .rotationEffect(.degrees(0))
                }
            }
        }
        // if rotating the map arrowRotation = bearingAfter - phoneHeading + mapHeading
        
        .onChange(of: router.locator.location) {
            router.updateRoute()
        }
        .task {
            cameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
            
            router.tgtLocation = place.item.location
            router.getRoute()
        }
    }
}


//            Text(place.item.name ?? "Unknown place").font(.headline)
//            Text(place.item.address?.shortAddress ?? "unknown").padding(.bottom, 12)
//            Text(locationManager.locator.location?.distanceStringTo(place.item.location) ?? "")

//}
