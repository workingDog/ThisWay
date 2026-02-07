//
//  Extension.swift
//  ThisWayApp
//
//  Created by Ringo Wathelet on 2026/02/06.
//

import Foundation


extension Double {
    
    func asStringDistance() -> String {
        if self < 1_000 {
            return "\(Int(self)) m "
        } else {
            return String(format: "%.1f km ", self / 1_000)
        }
    }
    
}
