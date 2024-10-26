//
//  BMIModel.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 15.10.2024.
//

import Foundation

enum BMICategory {
    case underweight, normal, overweight, obese

    static func categorize(weight: Double, height: Int) -> BMICategory {
        let heightM = Double(height / 100)
        let bmi = Double(weight) / (heightM * heightM)
        switch bmi {
        case ..<18.5: return .underweight
        case 18.5..<24.9: return .normal
        case 25..<29.9: return .overweight
        default: return .obese
        }
    }
    
}
