//
//  NutriPanel.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 27.10.2024.
//

import SwiftUI
import WebKit

struct NutriPanel: View {
    @State private var isSheetPresented = false
    
    var body: some View {
        ZStack {
            // Background grdient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FF69B4"),  // Pink
                    Color(hex: "FF1493")   // Deeper pink
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Check your nutrition")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        isSheetPresented = true
                    }) {
                        Text("See")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 26)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.3))
                            )
                    }
                }
                .padding(.leading, 30)
                .padding(.vertical)
                
                Spacer()
                
                Image("breadAndButter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .background(Color.white)
                    .clipShape(Circle())
                    .padding(.trailing, 30)
            }
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(30)
        .sheet(isPresented: $isSheetPresented) {
            WebViewWithProgress(urlString: "https://sincere-kiss-2c8.notion.site/1-75371fafc4e34cb78a2fc66c7f59d35e")
        }
    }
}

struct WebViewWithProgress: View {
    let urlString: String
    @State private var progress: Double = 0
    
    var body: some View {
        VStack(spacing: 0) {
            CustomProgressView(progress: progress)
                .frame(height: 8)
                .opacity(progress == 1.0 ? 0 : 1)
                .animation(.easeInOut, value: progress)
            
            WebView(urlString: urlString, progress: $progress)
        }
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var progress: Double
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {

    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.progress = 0.1
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.progress = 0.5
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.progress = 1.0
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.progress = 1.0
        }
    }
}
