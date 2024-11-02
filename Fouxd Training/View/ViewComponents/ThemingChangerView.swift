//
//  ThemingChangerView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 01.11.2024.
//

import SwiftUI

struct ThemingChangerView: View {
    @AppStorage("theme")
    private var theme = ThemeService.shared.theme
    @State private var showThemePicker = false
    
    var body: some View {
        Menu(content: {
            ForEach(Theme.allCases, id: \.self) { theme in
                Button(action: {
                    ThemeService.shared.theme = theme
                }) {
                    HStack {
                        Text("\(theme.themeIcon) \(theme.representableForm)")
                    }
                }
            }
        }, label: {
            HStack {
                Text("\(theme.themeIcon) ")
                    .font(.system(size: 24))
                Text("\(theme.representableForm) theme")
                    .font(.system(size: 18))
                    .foregroundColor(Color("cblack"))
                Spacer()
            }
        })
    }
}

