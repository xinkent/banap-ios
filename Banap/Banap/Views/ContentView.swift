//
//  ContentView.swift
//  Banap
//
//  Created by Yushi Yamada on 2020/02/16.
//  Copyright © 2020 Eggy. All rights reserved.
//

import SwiftUI
import Firebase
import MapKit

struct ContentView: View {
    @EnvironmentObject var storeObserver: StoreObserver
    var body: some View {
        TabView{
            // 地図画面
            UIMapView()
                .tabItem{
                    Image(systemName:"mappin.and.ellipse")
                    Text("Map")
                }
            // 新着店舗画面
            NewStoresView()
                .tabItem{
                    Image(systemName:"list.bullet")
                    Text("新着店")
                }
            
            OptionView()
            .tabItem{
                Image(systemName:"ellipsis")
                Text("オプション")
            
                }
            
        }.onAppear(perform: self.storeObserver.listenStoreData)
        .edgesIgnoringSafeArea(.top)
    }

}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
