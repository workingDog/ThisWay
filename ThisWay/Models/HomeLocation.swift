//
//  HomeLocation.swift
//  ThisWay
//
//  Created by Ringo Wathelet on 2026/02/09.
//
import Foundation
import CoreLocation
import SwiftUI


struct HomeLocation: Codable, Hashable {

    private static let storageKey = "homeLocation"

    let latitude: Double
    let longitude: Double

    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    @AppStorage(storageKey)
    private static var storedData: Data?

    static var current: CLLocationCoordinate2D? {
        get {
            guard
                let data = storedData,
                let value = try? JSONDecoder().decode(HomeLocation.self, from: data)
            else { return nil }

            return value.coordinate
        }
        set {
            if let coordinate = newValue {
                let value = HomeLocation(coordinate)
                storedData = try? JSONEncoder().encode(value)
            } else {
                storedData = nil
            }
        }
    }
}
