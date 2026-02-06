//
//  DirectionView.swift
//  MyWay
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import SwiftUI
import MapKit
import CoreLocation


struct DirectionView: View {
    let place: Place
    
    var body: some View {
        Text(place.item.name ?? "unknown")
        Text(place.item.address?.shortAddress ?? "unknown")
    }
}
