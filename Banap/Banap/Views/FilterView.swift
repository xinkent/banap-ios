//
//  FilterView.swift
//  Banap
//
//  Created by Yushi Yamada on 2020/03/15.
//  Copyright © 2020 Eggy. All rights reserved.
//

import SwiftUI

struct FilterView: View {
    var body: some View {
        Image(systemName:"slider.horizontal.3")
        .frame(width: 45, height: 45)
        .foregroundColor(.black)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 3))
        
    }
}
