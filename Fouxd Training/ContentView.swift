//
//  ContentView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 15.10.2024.
//

import SwiftUI

struct ContentView: View {

    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @EnvironmentObject private var globalVM: GlobalVM
    
    var body: some View {
        VStack {
            if isFirstLaunch {
                FirstLaunchSetupView()
                    .ignoresSafeArea()
                    .transition(.move(edge: .leading))
            } else {
                MainView()
                    .onAppear {
                        if let user = globalVM.userSession {
                            FBMUserData.shared.fetchUserData(uid: user.uid, completion: { res in
                                if case .success(let userData) = res {
                                    globalVM.userData = userData
                                }
                            })
                        } else {
                            guard let userData = UDUserData.shared.fetchUserDataLocally() else { return }
                            globalVM.userData = userData
                        }
                        HealthKitService.shared.setup()
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
