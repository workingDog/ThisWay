//
//  SpeechManager.swift
//  ThisWay
//
//  Created by Ringo Wathelet on 2026/02/08.
//
import Foundation
import AVFoundation
import SwiftUI


struct SpeechManager {
    let lang = Locale.preferredLanguages.first ?? "en"
    let session = AVAudioSession.sharedInstance()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    init() {
        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print(error)
        }
    }

    func speak_Old(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        let language = Locale.preferredLanguages.first ?? "en-US"
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0

        synthesizer.speak(utterance)
    }
   
}
