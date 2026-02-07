//
//  DirectionView.swift
//  ThisWayApp
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import SwiftUI
import MapKit
import CoreLocation
import OSRMSwift


struct DirectionView: View {
    @Environment(LocationManager.self) var locationManager
    
    let place: Place
    
    @State private var steps: [OSRMStep] = []
    @State private var routeBearing = 0.0
    @State private var osrm = OSRMDataModel()
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                if let response = osrm.routeResponse {
                    ForEach(response.routes) { route in
                        MapPolyline(coordinates: route.geometry.coordinates2D)
                            .stroke(.blue, lineWidth: 8)
                        if let end = route.geometry.coordinates2D.last{
                            Marker("End", coordinate: end)
                        }
                    }
                }
            }

            Image("arrow")
                .resizable()
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(routeBearing - locationManager.headingDegrees))
        }
        .task {
            locationManager.tgtLocation = place.item.location
            
            guard let start = locationManager.location?.coordinate else {return}
            guard let tgt = locationManager.tgtLocation?.coordinate else {return}
            
            print("---> start: \(start)")
            print("---> tgt: \(tgt)")

            let request = OSRMRequest(
                profile: .driving,
                coordinates: [
                    OSRMCoordinate(lat: start.latitude, lon: start.longitude,
                                   bearing: OSRMBearing(value: 90, range: 20),
                                   radius: 20000),
                    OSRMCoordinate(lat: tgt.latitude, lon: tgt.longitude)
                ],
                service: .route,
                steps: true,
                geometries: "geojson",
                overview: "full",
                annotations: "false",
                alternatives: true,
                continueStraight: true
            )
            
            await osrm.getOSRMResponse(for: request)
            
            if let response = osrm.routeResponse, let route = response.routes.first {
             //   print("---> route: \(route)")
             //   print("---> legs: \(route.legs)")
                if let leg = route.legs.first {
             //       print("---> steps: \(leg.steps)")
                    steps = leg.steps
                    
                    if let stepLoc = steps.first?.maneuver.location {
                        let stepCoord = CLLocationCoordinate2D(
                            latitude: stepLoc[1],
                            longitude: stepLoc[0]
                        )
                        routeBearing = locationManager.bearingFromUser(to: stepCoord)
                    }
                }

            }
        }
    }
}



struct DirectionView2: View {
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
