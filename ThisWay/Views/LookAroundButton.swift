//
//  LookAroundButton.swift
//  ThisWay
//
//  Created by Ringo Wathelet on 2026/02/09.
//
import SwiftUI
import MapKit


struct LookAroundButton: View {
    let coordinate: CLLocationCoordinate2D?
    
    @State private var scene: MKLookAroundScene?
    @State private var showingLookAround = false
    @State private var isLoading = false

    var body: some View {
        Button {
            Task {
                await loadLookAroundScene()
            }
        } label: {
            if isLoading {
                ProgressView()
            } else {
                Label("", systemImage: "binoculars.fill")
            }
        }
        .disabled(isLoading)
        .lookAroundViewer(isPresented: $showingLookAround, initialScene: scene)
    }
    
    private func loadLookAroundScene() async {
        isLoading = true
        defer { isLoading = false }

        if let coord = coordinate, let foundScene = await fetchNearestLookAroundScene(to: coord) {
            scene = foundScene
            showingLookAround = true
        } else {
            scene = nil
            showingLookAround = true
        }
    }

    private func fetchNearestLookAroundScene(to coordinate: CLLocationCoordinate2D) async -> MKLookAroundScene? {
        // Try exact coordinate
        if let scene = try? await MKLookAroundSceneRequest(coordinate: coordinate).scene {
            return scene
        }

        // Fallback: nearby POIs
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        let poiRequest = MKLocalPointsOfInterestRequest(coordinateRegion: region)
        let search = MKLocalSearch(request: poiRequest)

        if let response = try? await search.start(),
           let firstItem = response.mapItems.first {
            return try? await MKLookAroundSceneRequest(coordinate: firstItem.location.coordinate).scene
        }

        return nil
    }
}
