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
    let language = Locale.preferredLanguages.first ?? "en"
    
    @State private var router = RouteManager()
    @State private var searcher = SearchManager()
    
    @State private var query = ""
    @State private var selectedPlace: Place? = nil

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
            .navigationTitle("SEARCHED_PLACES") 
            .searchable(text: $query, prompt: "Search for a place")
        }
        .environment(router)
        .task {
            router.locator.requestPermissionAndLocation()
          //  query = "Bunkamura Orchard Hall Shinjuku"
            query = "Tokyo station"
          //  query = "Nihonbashi"
        }
        .task(id: query) {
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard
                trimmed.count > 3,
                let location = router.location()
            else {
                searcher.places = []
                return
            }
            try? await Task.sleep(for: .milliseconds(300))
            searcher.update(query: trimmed, near: location)
        }
    }
}

struct PlaceRow: View {
    @Environment(RouteManager.self) var router
    
    let item: MKMapItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.name ?? "Unknown place").font(.headline)
            Text(item.address?.shortAddress ?? "")
            Text(crowDistance())
        }
        .padding(5)
    }

    func crowDistance() -> String {
        if let userPos = router.location() {
            let dist = userPos.distance(from: item.location)
            return RouteManager.asString(dist)
        }
        return ""
    }
}
