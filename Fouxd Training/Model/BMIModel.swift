//
//  BMIModel.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import Foundation

struct BMI {
    let value: Double
    let category: BMICategory
}

enum BMICategory {
    case underweight, normal, overweight, obese

    static func categorize(bmi: Double) -> BMICategory {
        switch bmi {
        case ..<18.5: return .underweight
        case 18.5..<24.9: return .normal
        case 25..<29.9: return .overweight
        default: return .obese
        }
    }
}
