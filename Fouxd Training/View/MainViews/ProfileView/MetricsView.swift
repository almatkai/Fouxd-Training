//
//  MetricsView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 26.10.2024.
//

import SwiftUI

enum PickerType: String, CaseIterable {
    case weight = "Weight"
    case height = "Height"
    case age = "Age"
    case gender = "Gender"
    case activityLevel = "Activity Level"
}

struct MetricsView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MetricsView()
}
