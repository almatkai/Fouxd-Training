//
//  CircularProgressView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 25.10.2024.
//

import SwiftUI

// MARK: - Circular Timer View
struct CircularTimerView: View {
    let progress: Double
    let remainingSeconds: Int
    let totalSeconds: Int
    
    @State private var lastPlayedSecond: Int?
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
            
            Text("\(remainingSeconds)")
                .font(.system(size: 50, weight: .bold, design: .rounded))
        }
        .frame(width: 200, height: 200)
        .onChange(of: remainingSeconds) { newValue in
            // Play sound when countdown reaches 4 or less, but only once per second
            if newValue == 3 || newValue == 2 || newValue == 1 {
                TimerSoundManager.shared.playCountdownSound(forSecond: newValue, whichSound: "countdown_beep_secondary")
                print("Played sound for \(newValue)")
            } else if newValue == 0 {
                TimerSoundManager.shared.playCountdownSound(forSecond: newValue, whichSound: "countdown_beep_primary")
                print("Played sound for \(newValue)")
            }
            print(newValue)
        }
        // Reset lastPlayedSecond when the view appears
        .onAppear {
            lastPlayedSecond = nil
        }
    }
}
