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
@Observable class SearchManager {
    
    var places: [Place] = []
    
    func searchPlaces(query: String, near location: CLLocation) async throws {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 20_000,
            longitudinalMeters: 20_000
        )

        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        places = response.mapItems.map { Place(item: $0) }
    }
    
}
