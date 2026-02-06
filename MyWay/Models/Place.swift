//
//  Place.swift
//  MyWay
//
//  Created by Ringo Wathelet on 2026/02/06.
//
import Foundation
import SwiftUI
import MapKit


struct Place: Identifiable, Hashable {
    let id = UUID()
    
    var item: MKMapItem
    
    init() {
        self.item = MKMapItem()
    }
    
    init(item: MKMapItem) {
        self.item = item
    }
}
