//
//  ContentView.swift
//  ThisWayApp
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import SwiftUI
import MapKit
import CoreLocation


struct ContentView: View {
    
    @State private var locationManager = LocationManager()
    @State private var searcher = SearchManager()
    
    @State private var query = ""
    @State private var selectedPlace: Place? = nil
    
    @State private var searchTask: Task<Void, Never>? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if let userLocation = locationManager.location {
                    List(searcher.places) { place in
                        PlaceRow(item: place.item, userLocation: userLocation)
                            .contentShape(Rectangle()) // makes whole row tappable
                            .onTapGesture {
                                selectedPlace = place
                            }
                    }
                }
            }
            .navigationDestination(item: $selectedPlace) { place in
                DirectionView(place: place)
            }
            .navigationTitle("Search places")
            .searchable(text: $query, prompt: "Search Apple Maps")
            .onChange(of: query) {
                searchTask?.cancel()
                
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(350))
                    
                    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    guard
                        trimmed.count >= 3,
                        let userLocation = locationManager.location
                    else {
                        searcher.places = []
                        return
                    }
                    
                    do {
                        try await searcher.searchPlaces(query: trimmed, near: userLocation)
                    } catch {
                        print("Search error:", error)
                    }
                }
            }
        }
        .environment(locationManager)
        .task {
            locationManager.requestPermissionAndLocation()
          //  query = "Bunkamura Orchard Hall Shinjuku"
            query = "Tokyo station"
        }
    }
}

struct PlaceRow: View {
    let item: MKMapItem
    let userLocation: CLLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name ?? "Unknown place").font(.headline)
            Text(userLocation.distanceStringTo(item.location) ?? "")
        }
        .padding(.vertical, 4)
    }
    
}
