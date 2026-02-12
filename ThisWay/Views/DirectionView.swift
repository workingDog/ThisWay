//
//  DirectionView.swift
//  ThisWay
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import SwiftUI
import MapKit
import CoreLocation


struct DirectionView: View {
    @Environment(RouteManager.self) var router
    
    let place: Place
    
    @State private var voiceNavi = VoiceNavigator()
    @State private var speechOn: Bool = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    @State private var lastNavHeading: Double?
    @State private var lastCameraLocation: CLLocation?
    @State private var lastVoiceTriggerLocation: CLLocation?
    

    var body: some View {
        VStack {
            Text(RouteManager.asString(router.remainingDistance))
            Map(position: $cameraPosition) {
                MapPolyline(router.route.polyline).stroke(.blue, lineWidth: 4)
                if let location = router.locator.location {
                    Annotation("", coordinate: location.coordinate) {
                        Image(systemName: "location.north.circle")
                            .resizable()
                            .rotationEffect(
                                .degrees(router.routeBearing - router.locator.headingDegrees)
                            )
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.red, .red)
                            .font(.system(size: 60))
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    speechOn.toggle()
                } label: {
                    Image(systemName: "speaker.wave.3.fill")
                }
                .tint(speechOn ? .accentColor : .primary)
            }
            
            ToolbarItem(placement: .automatic) {
                HStack {
                    // just for fun
                    LookAroundButton(coordinate: router.location()?.coordinate).padding(10)
                    Button {
                        if let home = HomeLocation.current {
                            let location = CLLocation(latitude: home.latitude, longitude: home.longitude)
                            router.tgtLocation = location
                            router.getRoute()
                        }
                    } label: {
                        Image(systemName: "house.fill")
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
                updateVoiceNavi()
                return
            }
            if angleDelta(router.locator.headingDegrees, last) >= 20 {
                lastNavHeading = router.locator.headingDegrees
                updateVoiceNavi()
            }
        }
        .onChange(of: router.locator.location) {
            router.updateRoute()
            guard let userPos = router.location() else { return }
            handleLocationUpdate(userPos)
            handleVoiceNavigation(userPos)
        }
        .task {
            router.tgtLocation = place.item.location
            router.getRoute()
            updateCameraHeading() 
        }
    }

    private func handleVoiceNavigation(_ location: CLLocation) {
        if let last = lastVoiceTriggerLocation {
            let distance = location.distance(from: last)
            guard distance >= 20 else { return }
            updateVoiceNavi()
            lastVoiceTriggerLocation = location
        } else {
            lastVoiceTriggerLocation = location
        }
    }
    
    private func handleLocationUpdate(_ location: CLLocation) {
        if let last = lastCameraLocation {
            let distance = location.distance(from: last)
            guard distance >= 5 else { return }
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
    
    private func updateVoiceNavi() {
        if speechOn {
            voiceNavi.updateNavigation(angle: (router.routeBearing - router.locator.headingDegrees), distance: crowDistance())
        }
    }

    private func angleDelta(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 360)
        return min(diff, 360 - diff)
    }
    
    private func updateCameraHeading() {
        guard let userLocation = router.location() else { return }
        let camera = MapCamera(
            centerCoordinate: userLocation.coordinate,
            distance: 1000,              // walking zoom
            heading: router.routeBearing,
            pitch: 0
        )
        cameraPosition = .camera(camera)
    }
    
}
