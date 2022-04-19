//
//  Home.swift
//  ScrollableTabBar
//
//  Created by paige shin on 2022/04/20.
//

import SwiftUI

struct Home: View {
    
    // Current Tab...
    @State var currentSelection: Int = 0
    
    var body: some View {
        PagerTabView(tint: .black, selection: $currentSelection) {
            
            Image(systemName: "house.fill")
                .pageLabel()
            
            Image(systemName: "house.fill")
                .pageLabel()
            
            Image(systemName: "house.fill")
                .pageLabel()
        } content: {
            Color.red
                .pageView(ignoresSafeArea: true, edges: .bottom)
            Color.blue
                .pageView(ignoresSafeArea: true, edges: .bottom)
            Color.green
                .pageView()
            
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


