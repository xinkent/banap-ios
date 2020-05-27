//
//  optionView.swift
//  Banap
//
//  Created by Yushi Yamada on 2020/04/12.
//  Copyright © 2020 Eggy. All rights reserved.
//

import SwiftUI

struct OptionView: View {
    
@State var showModal = false
    
    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("ご依頼・ご要望")) {
                   Button(action:{
                    self.showModal.toggle()
                    }){
                    HStack{
                    Spacer().frame(width: 5)
                    Image(systemName:"paperplane")
                    .foregroundColor(.black)
                    Spacer()
                    Text("掲載店舗に関するご依頼")
                    .foregroundColor(.black)
                    Spacer().frame(width: 20)
                        }
                    .sheet(isPresented: $showModal){
                    SafariView(url: URL(string: "https://forms.gle/6LTFotZQRDXib5Y8A")!)
                        }
                    }
                    
                    Button(action:{
                    self.showModal.toggle()
                    }){
                    HStack{
                    Spacer().frame(width: 5)
                    Image(systemName:"paperplane")
                    .foregroundColor(.black)
                    Spacer()
                    Text("アプリ改善のご要望")
                    .foregroundColor(.black)
                    Spacer().frame(width: 20)
                        }
                    .sheet(isPresented: $showModal){
                    SafariView(url: URL(string: "https://forms.gle/riTdKYyLdtpz11jP8")!)
                        }
                    }
                    
                }
 
                Section(header: Text("アプリ情報")) {
                    Button(action:{
                    self.openWebBrowser()
                    }){
                    HStack{
                    Spacer().frame(width: 5)
                    Image(systemName:"link")
                    .foregroundColor(.black)
                    Spacer()
                    Text("バナップ公式アカウント")
                    .foregroundColor(.black)
                    Spacer().frame(width: 20)
                        }
                    }
                    Button(action:{
                    self.openAppStore()
                    }){
                    HStack{
                    Spacer().frame(width: 5)
                    Image(systemName:"star")
                    .foregroundColor(.black)
                    Spacer()
                    Text("このアプリをレビューする")
                    .foregroundColor(.black)
                    Spacer().frame(width: 20)
                        }
                    }
                }
                    
                Section() {
                    HStack{
                    Spacer().frame(width: 5)
                    Image(systemName:"gear")
                    .foregroundColor(.black)
                    Spacer()
                    Text("ver 1.7.0")
                    Spacer().frame(width: 20)
                        }
                }
        }
        .navigationBarTitle("オプション")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // instagram遷移用
    func openWebBrowser() {
        let url = URL(string: "https://www.instagram.com/banap877/")!
        // 一度本当にURLが開けるか確認する
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    // Appストア遷移用
    func openAppStore() {
        let url = URL(string: "https://apps.apple.com/jp/app/%E3%83%90%E3%83%8A%E3%83%83%E3%83%97/id1506461890?l=ja")!
        // 一度本当にURLが開けるか確認する
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
