//
//  TimerSoundManager.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 26.10.2024.
//

import Foundation
import AVFoundation

class TimerSoundManager {
    static let shared = TimerSoundManager()
    private var player: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playCountdownSound(forSecond second: Int) {
        guard let soundURL = Bundle.main.url(forResource: "countdown_beep", withExtension: "wav") else {
            print("Sound file not found")
            return
        }
        
        do {
            // Create a new player instance each time to allow overlapping sounds
            let newPlayer = try AVAudioPlayer(contentsOf: soundURL)
            newPlayer.prepareToPlay()
            newPlayer.play()
            // Keep a reference to prevent deallocation before sound completes
            player = newPlayer
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
}