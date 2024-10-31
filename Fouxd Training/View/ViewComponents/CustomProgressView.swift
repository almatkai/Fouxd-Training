//
//  CustomProgressView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 27.10.2024.
//

import SwiftUI

struct CustomProgressView: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.3))
                    .frame(width: geometry.size.width, height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .foregroundColor(Color(hex: "FF69B4"))
                    .frame(width: geometry.size.width * progress, height: 8)
                    .cornerRadius(4)
                    .animation(.linear, value: progress)
            }
        }
    }
}
