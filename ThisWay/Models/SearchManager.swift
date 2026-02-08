//
//  SearchManager.swift
//  ThisWayApp
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import MapKit
import SwiftUI
import Foundation


@MainActor
@Observable
final class SearchManager: NSObject, MKLocalSearchCompleterDelegate {
    
    var places: [Place] = []
    
    private let completer = MKLocalSearchCompleter()
    private var queryID: Int = 0
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }
    
    func update(query: String, near location: CLLocation) {
        completer.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 40_000,
            longitudinalMeters: 40_000
        )
        completer.queryFragment = query
    }
    
    private func resolveCompletions(_ completions: [MKLocalSearchCompletion], for queryID: Int) {
        Task {
            var resolved: [Place] = []
            for completion in completions.prefix(10) {
                // If a newer query started, silently stop
                guard queryID == self.queryID else { return }
                do {
                    let request = MKLocalSearch.Request(completion: completion)
                    let response = try await MKLocalSearch(request: request).start()
                    resolved.append(
                        contentsOf: response.mapItems.map { Place(item: $0) }
                    )
                } catch {
                    continue
                }
            }
            // Final guard before publishing
            guard queryID == self.queryID else { return }
            places = resolved
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let currentQueryID = queryID
        resolveCompletions(completer.results, for: currentQueryID)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        places = []
    }
    
}
