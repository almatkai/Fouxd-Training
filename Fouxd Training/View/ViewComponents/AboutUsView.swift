//
//  AboutUsView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 01.11.2024.
//

import SwiftUI

struct AboutUsView: View {
    @State private var showInfo = false

    var body: some View {
        Button(action: {
            showInfo.toggle()
        }){
            HStack {
                Text("ℹ️")
                    .font(.system(size: 24))
                Text("About Us")
                    .font(.system(size: 18))
                    .foregroundColor(Color("cblack"))
                Spacer()
            }
        }
        .sheet(isPresented: $showInfo) {
            VStack(spacing: 20) {
                Text("Fouxd Training")
                    .font(.title)
                    .bold()
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("This app is designed to provide users with focused and planned fitness at home or gym. It includes a variety of workouts, nutrition plans, and health tracking features.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("Authors")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Naukanova Nuraiym")
                            .font(.headline)
                    }
                    Spacer()
                }
                Button("Close") {
                    showInfo = false
                }
                .padding()
            }
            .padding()
        }
    }
}
