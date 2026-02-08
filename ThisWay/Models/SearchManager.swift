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
    private var resolveTask: Task<Void, Never>?
    
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
    
    private func resolveCompletions(_ completions: [MKLocalSearchCompletion]) {
        resolveTask?.cancel()
        
        resolveTask = Task {
            var resolved: [Place] = []
            
            for completion in completions.prefix(10) {
                if Task.isCancelled { return }
                
                do {
                    let request = MKLocalSearch.Request(completion: completion)
                    let response = try await MKLocalSearch(request: request).start()
                    resolved.append(contentsOf: response.mapItems.map { Place(item: $0) })
                } catch {
                    continue
                }
            }
            
            places = resolved
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        resolveCompletions(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        places = []
    }
    
}
