//
//  HapticFeedBackExt.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 20.10.2024.
//

import SwiftUI

extension View {
    func vibrate() {
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
            impactHeavy.impactOccurred()
    }
}
