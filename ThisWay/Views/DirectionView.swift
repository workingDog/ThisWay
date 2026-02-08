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
    
    @State private var speechOn: Bool = false
    @State private var navProcessor = NavigationProcessor()
    @State private var lastNavHeading: Double?
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var lastCameraLocation: CLLocation?
    
    var body: some View {
        VStack {
            Toggle("Voice directions", isOn: $speechOn).padding(5)
            
            Text(RouteManager.asString(router.remainingDistance))
            
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
                    }
                }
            }
        }
        .onChange(of: router.routeBearing) {
            updateCameraHeading()
        }
        .onChange(of: router.locator.headingDegrees) {
            guard let last = lastNavHeading else {
                lastNavHeading = router.locator.headingDegrees
                updateNavigation()
                return
            }
            if angleDelta(router.locator.headingDegrees, last) >= 15 {
                lastNavHeading = router.locator.headingDegrees
                updateNavigation()
            }
        }
        .onChange(of: router.locator.location) {
            router.updateRoute()
            if let userPos = router.location() {
                handleLocationUpdate(userPos)
                // speech instructions
                if let last = lastCameraLocation {
                    let distance = userPos.distance(from: last)
                    if distance >= 8 {
                        updateNavigation()
                    }
                }
            }
        }
        .task {
            router.tgtLocation = place.item.location
            router.getRoute()
            updateCameraHeading()
        }
    }
    
    func angleDelta(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 360)
        return min(diff, 360 - diff)
    }
    
    func updateCameraHeading() {
        guard let userLocation = router.location() else { return }
        
        let camera = MapCamera(
            centerCoordinate: userLocation.coordinate,
            distance: 1000,              // walking zoom
            heading: router.routeBearing,
            pitch: 0
        )
        
        cameraPosition = .camera(camera)
    }
    
    func handleLocationUpdate(_ location: CLLocation) {
        if let last = lastCameraLocation {
            let distance = location.distance(from: last)
            guard distance >= 8 else {
                return
            }
        }
        lastCameraLocation = location
        updateCameraHeading()
    }
    
    private func crowDistance() -> Double {
        if let userPos = router.location(), let tgtLocation = router.tgtLocation {
            return userPos.distance(from: tgtLocation)
        }
        return Double.greatestFiniteMagnitude
    }
    
    func updateNavigation() {
        if speechOn {
            navProcessor.updateNavigation(angle: (router.routeBearing - router.locator.headingDegrees), distance: crowDistance())
        }
    }
    
}
