//
//  ScreenSizeExt.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 25.10.2024.
//

import SwiftUI

extension View {
    func width() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    func height() -> CGFloat {
        return UIScreen.main.bounds.height
    }
}
