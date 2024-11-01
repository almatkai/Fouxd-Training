//
//  LangaugeChangerView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 31.10.2024.
//

import SwiftUI

struct LanguageChangerView: View {
    @AppStorage("language")
    private var language = LocalizationService.shared.language
    @State private var showLanguagePicker = false
    var body: some View {
        Menu(content: {
            ForEach(Language.allCases, id: \.self) { language in
                Button(action: {
                    LocalizationService.shared.language = language
                }) {
                    HStack {
                        Text("\(language.languageFlag)\(language.representableForm)")
                    }
                }
            }
        }, label: {
            HStack {
                Text("\(language.languageFlag) ")
                    .font(.system(size: 24))
                Text("\(language.representableForm)")
                    .font(.system(size: 18))
                    .foregroundColor(Color("cblack"))
                Spacer()
            }
        })
    }
}

