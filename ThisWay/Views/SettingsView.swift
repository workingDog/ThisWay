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
            
            Menu {
                ForEach([5, 10, 20, 30, 40, 50, 60, 70 ,80, 90, 100].reversed(), id: \.self) { km in
                    Button {
                        router.searchRange = Double(km)
                    } label: {
                        if router.searchRange == Double(km) {
                            Label("\(km) km", systemImage: "checkmark")
                        } else {
                            Text("\(km) km")
                        }
                    }
                }
            } label: {
                Label(
                    "Search distance \(Int(router.searchRange)) km",
                    systemImage: "location.circle"
                )
                .font(.title2)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 40)
            .padding(.bottom, 40)

            Button {
                if let currentPos = router.location() {
                    HomeLocation.current = currentPos.coordinate
                    dismiss()
                }
            } label: {
                Label("SET_HOME", systemImage: "house.fill")
                    .font(.title2)
                    .padding(.vertical, 20)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }
}
