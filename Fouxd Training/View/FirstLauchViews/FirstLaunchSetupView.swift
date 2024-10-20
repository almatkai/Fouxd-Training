//
//  FirstLaunchSetupView.swift
//  Fouxd Training
//
//  Created by Nuraiym Naukanova on 15.10.2024.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct FirstLaunchSetupView: View {
    
    @EnvironmentObject private var globalVM: GlobalVM
    @State var pageCounter = 0
    
    var body: some View {
        switch pageCounter {
        case 0:
            WelcomeView(pageCounter: $pageCounter)
        case 1:
            SecondLaunchView(pageCounter: $pageCounter)
        case 2:
            ThirdView(pageCounter: $pageCounter)
        default:
            EmptyView()
        }
    }
}
