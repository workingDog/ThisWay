//
//  ContentView.swift
//  ThisWay
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import SwiftUI
import CoreLocation
import MapKit



struct ContentView: View {
    let language = Locale.preferredLanguages.first ?? "en"
    
    @State private var router = RouteManager()
    @State private var searcher: SearchManager
    
    @State private var query = ""
    @State private var selectedPlace: Place?
    @State private var showSettings = false
    
    @State private var searchTask: Task<Void, Never>?
    
    init() {
        let router = RouteManager()
        _router = State(initialValue: router)
        _searcher = State(initialValue: SearchManager(router: router))
    }

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                    .tint(.accentColor)
                }
            }
            .navigationTitle("SEARCHED_PLACES")
            .searchable(text: $query, prompt: "Search for a place")
            .onSubmit(of: .search) {
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard
                    trimmed.count >= 3,
                    let location = router.location()
                else {
                    searcher.places = []
                    return
                }
                Task {
                    await searcher.update(query: trimmed, near: location)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environment(router)
                .presentationDetents([.medium])
        }
        .environment(router)
        .task {
            router.locator.requestPermissionAndLocation()
        }
        .onChange(of: query) {
            // cancel previous request immediately
            searchTask?.cancel()
            
            searchTask = Task {
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard trimmed.count >= 3,
                      let location = router.location()
                else {
                    await MainActor.run {
                        searcher.places = []
                    }
                    return
                }
                
                // ⏱ debounce (wait for user to pause typing)
                try? await Task.sleep(for: .milliseconds(500))
                
                // if user typed again → this task is obsolete
                guard !Task.isCancelled else { return }
                
                await searcher.update(query: trimmed, near: location)
            }
        }
        
        // too many requests to the API
//        .task(id: query) {
//            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
//            guard
//                trimmed.count >= 3,
//                let location = router.location()
//            else {
//                searcher.places = []
//                return
//            }
//            print("---> query: \(trimmed)")
//            try? await Task.sleep(for: .milliseconds(300))
//            searcher.update(query: trimmed, near: location)
//        }
        
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
