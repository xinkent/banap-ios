//
//  StoreRequestView.swift
//  Banap
//
//  Created by Yushi Yamada on 2020/04/12.
//  Copyright © 2020 Eggy. All rights reserved.
//

import SwiftUI
import WebKit

struct SafariView: UIViewRepresentable {
    var url: URL
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView(frame: .zero)
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let req = URLRequest(url: url)
        uiView.load(req)
    }
}
