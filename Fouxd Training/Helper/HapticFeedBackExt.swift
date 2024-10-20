//
//  HapticFeedBackExt.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 20.10.2024.
//

import SwiftUI

extension View {
    func vibrate() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
    }
}
