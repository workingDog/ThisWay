//
//  VoiceNavigator.swift
//  ThisWay
//
//  Created by Ringo Wathelet on 2026/02/08.
//
import Foundation
import AVFoundation
import SwiftUI


@Observable
@MainActor
final class VoiceNavigator {

    let speechManager = SpeechManager()
    
    let straightThreshold: Double = 10        // degrees
    let slightTurnThreshold: Double = 30      // degrees
    
    let approachingDistance: Double = 25      // meters
    let arrivalDistance: Double = 8           // meters
    
    var lastInstruction: Instruction?
    var lastAngle: Double?                    // degrees
    
    init() { }
    
    func updateNavigation(angle: Double, distance: Double) {
        let angleNorm = normalizeAngle( angle )
        if let lastAngle, abs(angleNorm - lastAngle) < 10 {
            return
        }
        lastAngle = angleNorm
        if let instruction = nextInstruction(angle: angleNorm, distance: distance) {
            speechManager.speak(instruction.speechText)
        }
    }

    private func nextInstruction(angle: Double, distance: Double) -> Instruction? {
        // Distance always wins near the destination
        if let distanceInstruction = distanceInstruction(for: distance) {
            return commit(distanceInstruction)
        }
        // Direction guidance
        if let directionInstruction = directionInstruction(for: angle) {
            return commit(directionInstruction)
        }
        return nil
    }

    private func distanceInstruction(for distance: Double) -> Instruction? {
        switch distance {
            case ...arrivalDistance: .arrived
            case ...approachingDistance: .near
            default: nil
        }
    }

    private func directionInstruction(for angleError: Double) -> Instruction? {
        let absAngle = abs(angleError)
        return switch absAngle {
            case ...straightThreshold: .keepStraight
            case ...slightTurnThreshold: angleError > 0 ? .slightRight : .slightLeft
            default: angleError > 0 ? .right : .left
        }
    }

    private func commit(_ instruction: Instruction) -> Instruction? {
        guard instruction != lastInstruction else { return nil }
        lastInstruction = instruction
        return instruction
    }

    private func normalizeAngle(_ angle: Double) -> Double {
        var a = angle.truncatingRemainder(dividingBy: 360)
        if a > 180 { a -= 360 }
        if a < -180 { a += 360 }
        return a
    }
}

enum Instruction: Equatable {
    case keepStraight
    case slightLeft
    case left
    case slightRight
    case right
    case near
    case arrived
    
    var localizationKey: String.LocalizationValue {
        switch self {
            case .keepStraight: return "GO_STRAIGHT"
            case .slightLeft:   return "TURN_SLIGHT_LEFT"
            case .left:         return "TURN_LEFT"
            case .slightRight:  return "TURN_SLIGHT_RIGHT"
            case .right:        return "TURN_RIGHT"
            case .near:         return "NEAR"
            case .arrived:      return "ARRIVED"
        }
    }
    
    var speechText: String {
        String(localized: localizationKey)
    }
}

