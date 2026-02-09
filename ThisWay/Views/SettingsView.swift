//
//  SettingsView.swift
//  ThisWay
//
//  Created by Ringo Wathelet on 2026/02/09.
//
import SwiftUI
import CoreLocation

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(RouteManager.self) var router

    var body: some View {
        VStack {
            Button {
                if let currentPos = router.location() {
                    HomeLocation.current = currentPos.coordinate
                    dismiss()
                }
            } label: {
                Label("SET_HOME", systemImage: "house.fill").padding(.vertical, 20)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
