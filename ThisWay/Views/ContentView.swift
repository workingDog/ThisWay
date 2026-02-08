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
    
    @State private var router = RouteManager()
    @State private var searcher = SearchManager()
    
    @State private var query = ""
    @State private var selectedPlace: Place? = nil
    
    @State private var searchTask: Task<Void, Never>? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if router.location() != nil {
                    List(searcher.places) { place in
                        PlaceRow(item: place.item)
                            .contentShape(Rectangle()) 
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
            .searchable(text: $query, prompt: "Search for a place")
            .onChange(of: query) {
                searchTask?.cancel()
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(350))
                    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard
                        trimmed.count >= 3,
                        let userLocation = router.location()
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
        .environment(router)
        .task {
            router.locator.requestPermissionAndLocation()
          //  query = "Bunkamura Orchard Hall Shinjuku"
          //  query = "Tokyo station"
          //  query = "Nihonbashi"
        }
    }
}

struct PlaceRow: View {
    @Environment(RouteManager.self) var router
    
    let item: MKMapItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name ?? "Unknown place").font(.headline)
            Text(item.address?.shortAddress ?? "")
            Text(crowDistance())
        }
        .padding(.vertical, 4)
    }

    func crowDistance() -> String {
        if let userPos = router.location() {
            let dist = userPos.distance(from: item.location)
            return RouteManager.asString(dist)
        }
        return ""
    }
}
