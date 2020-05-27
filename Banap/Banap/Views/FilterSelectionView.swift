//
//  FilterSelectionView.swift
//  Banap
//
//  Created by Yushi Yamada on 2020/03/15.
//  Copyright © 2020 Eggy. All rights reserved.
//

import SwiftUI

struct FilterSelectionView: View {
    var filterSelection = ["すべて", "今日開いている"]
    private var selected: Binding<Int> {
        Binding (
            get: {return self.isFilter ? 1:0},
            set: {self.isFilter = $0 == 1}
        )
    }
    
    @Binding var isTapped: Bool
    @Binding var isFilter: Bool
    var body: some View {
        VStack{
            Picker("", selection: selected) {
                ForEach(0 ..< filterSelection.count) {
                    Text(self.filterSelection[$0])
                        .foregroundColor(.white)
                }
            }.pickerStyle(SegmentedPickerStyle())
            .frame(width:350)
            Button(action: {
                self.isTapped = false
             }){
                 Text("決定")
                .frame(width:350, height:30)
                .foregroundColor(Color.black)
                    .background(Color(.white))
                .cornerRadius(10)
            }
        }
    }
}
