//
//  ThemeService.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 01.11.2024.
//

import SwiftUI

enum Theme: String, CaseIterable {
    case system
    case light
    case dark
    
    var themeIcon: String {
        switch self {
        case .system:
            return "⚙️"
        case .light:
            return "☀️"
        case .dark:
            return "🌙"
        }
    }
    
    var representableForm: LocalizedStringResource {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

class ThemeService: ObservableObject {
    static let shared = ThemeService()
    
    @AppStorage("theme") private var savedTheme: Theme = .system
    
    var theme: Theme {
        get { savedTheme }
        set { savedTheme = newValue }
    }
    
    private init() {}
}
