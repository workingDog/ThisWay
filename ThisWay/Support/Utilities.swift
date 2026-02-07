//
//  Utilities.swift
//  ThisWayApp
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import Foundation
import CoreLocation


//    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 35.68365805925461, longitude: 139.78335278819443),
//        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//    ))
    

//            .onMapCameraChange { context in
//                let camera = context.camera
//                print("--> map heading:", camera.heading)
//                heading = (bearingAfter - camera.heading)
//                print("---> heading: \(heading)")
//            }
            

/*
 // if rotating the map
 arrowRotation = bearingAfter - phoneHeading + mapHeading
 */


/*
 
 //            Map(position: $cameraPosition) {
 //                if let response = osrm.routeResponse {
 //                    ForEach(response.routes) { route in
 //                        MapPolyline(coordinates: route.geometry.coordinates2D)
 //                            .stroke(.blue, lineWidth: 8)
 //                        if let end = route.geometry.coordinates2D.last{
 //                            Marker("End", coordinate: end)
 //                        }
 //                    }
 //                }
 //            }
             
 

//            Image("arrow")
//                .resizable()
//                .frame(width: 100, height: 100)
//                .rotationEffect(.degrees(routeBearing - locationManager.headingDegrees))
 
 
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
             
             // after first step use bearingAfter
//                    if distanceToStep < 10 {
//                        use step.maneuver.bearingAfter
//                    } else {
//                        use bearing(from: user → step)
//                    }
             
//                    if let step = steps.first {
//                        bearingAfter = step.maneuver.bearingAfter
//                    }
             
             // first step
             if let stepLoc = steps.first?.maneuver.location {
                 let stepCoord = CLLocationCoordinate2D(
                     latitude: stepLoc[1],
                     longitude: stepLoc[0]
                 )
                 routeBearing = locationManager.bearingFromUser(to: stepCoord)
             }
         }
 }
 
 */
