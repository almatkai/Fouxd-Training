//
//  PrivacyPolicyView.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 01.11.2024.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @State private var showPrivacyPolicy = false

    var body: some View {
        Button(action: {
            showPrivacyPolicy.toggle()
        }) {
            HStack {
                Text("🔒")
                    .font(.system(size: 24))
                Text("Privacy Policy")
                    .font(.system(size: 18))
                    .foregroundColor(Color("cblack"))
                Spacer()
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            VStack(spacing: 20) {
                Text("Privacy Policy")
                    .font(.title)
                    .bold()
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Your privacy is important to us. This policy outlines the types of information collected by the app, how it is used, and the measures we take to ensure your data is secure.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("Data Collection")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                Text("The app collects data related to your workouts, nutrition, and health metrics to provide personalized recommendations and track progress. We do not share your data with third parties.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("Close") {
                    showPrivacyPolicy = false
                }
                .padding()
            }
            .padding()
        }
    }
}

