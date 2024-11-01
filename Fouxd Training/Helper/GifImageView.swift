//
//  GifImageView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 25.10.2024.
//

import SwiftUI
import WebKit

struct GifImageView: UIViewRepresentable {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        print(name)

        if let url = Bundle.main.url(forResource: name, withExtension: "gif"),
           let data = try? Data(contentsOf: url) {
            webview.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
        } else {
            print("Failed to load GIF: \(name)")
        }

        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }
}
