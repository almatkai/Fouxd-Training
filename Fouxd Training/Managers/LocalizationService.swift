//
//  LocalizationService.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 31.10.2024.
//

import Foundation

enum Language: String, CaseIterable, Equatable {
    case en = "en"
    case kaz = "kk"
    
    var localeIdentifier: String {
        return self.rawValue
    }
    
    var representableForm: LocalizedStringResource {
        switch self {
        case .en: return "language.english"
        case .kaz: return "language.kazakh"
        }
    }
    
    var languageFlag: String {
        switch self {
        case .en: return "🇬🇧"
        case .kaz: return "🇰🇿"
        }
    }
}

class LocalizationService: ObservableObject {
    static let shared = LocalizationService()
    static let changedLanguage = Notification.Name("changedLanguage")
    
    @Published var language: Language {
        didSet {
            if oldValue != language {
                UserDefaults.standard.setValue(language.rawValue, forKey: "language")
                NotificationCenter.default.post(name: LocalizationService.changedLanguage, object: nil)
            }
        }
    }
    
    private init() {
        if let languageString = UserDefaults.standard.string(forKey: "language"),
           let savedLanguage = Language(rawValue: languageString) {
            self.language = savedLanguage
        } else {
            self.language = .en
        }
    }
}
