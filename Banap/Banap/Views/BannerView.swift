//
//  BannerView.swift
//  Banap
//
//  Created by Yushi Yamada on 2020/04/18.
//  Copyright © 2020 Eggy. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

struct BannerView : UIViewRepresentable{
    
    func makeUIView(context: UIViewRepresentableContext<BannerView>) -> GADBannerView {
        let banner = GADBannerView(adSize: kGADAdSizeBanner)
        // リリース申請時に本番用広告と入れ替える
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(GADRequest())
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: UIViewRepresentableContext<BannerView>) {
    }
    
}
