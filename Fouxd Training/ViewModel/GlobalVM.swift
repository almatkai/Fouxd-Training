//
//  GlobalVM.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import SwiftUI

class GlobalVM: ObservableObject {
    @Published var screenWidth: CGFloat
    @Published var screenHeight: CGFloat
    @Published var isUserLoggedIn: Bool = false

    init() {
        self.screenWidth = UIScreen.main.bounds.width
        self.screenHeight = UIScreen.main.bounds.height
    }
}
