//
//  PageHelper.swift
//  ScrollableTabBar
//
//  Created by paige shin on 2022/04/20.
//

import SwiftUI

// Custom View Builder...
struct PagerTabView<Content: View, Label: View>: View {
    
    var tint: Color
    @Binding var selection: Int
    
    var content: Content
    var label: Label
      
    init(
        tint: Color,
        selection: Binding<Int>,
        @ViewBuilder labels: @escaping() -> Label,
        @ViewBuilder content: @escaping() -> Content
    ) {
        self.tint = tint
        self._selection = selection
        self.label = labels()
        self.content = content()
    }
    
    // Offset for Page Scroll...
    @State private var offset: CGFloat = 0
    @State private var maxTabs: CGFloat = 0
    @State private var tabOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                label
            }
            // For Tab to change tab...
            .overlay(
                HStack(spacing: 0) {
                    ForEach(0..<Int(maxTabs), id: \.self) { index in
                        Rectangle()
                            .fill(Color.black.opacity(0.01))
                            .onTapGesture {
                                // Changing Offset....
                                // Based on index...
                                let newOffset: CGFloat = CGFloat(index) * getScreenBounds().width
                                self.offset = newOffset
                            }
                    }
                }
            )
            .foregroundColor(tint)
            
            // Indicators...
            Capsule()
                .fill(tint)
                .frame(width: maxTabs == 0 ? 0 : (getScreenBounds().width / maxTabs), height: 5)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: -tabOffset)
            
            OffsetPageTabView(selection: $selection, offset: $offset) {
                HStack(spacing: 0) {
                    content
                }
                // Getting How Many Tabs are there by getting the total Content Size...
                .overlay(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: TabPreferenceKey.self, value: proxy.frame(in: .global))
                    }
                )
                // When Value Changes...
                .onPreferenceChange(TabPreferenceKey.self) { proxy in
                    let minX: CGFloat = proxy.minX
                    let maxWidth: CGFloat = proxy.width
                    let screenWidth: CGFloat = getScreenBounds().width
                    let maxTabs: CGFloat = (maxWidth / screenWidth).rounded()
                    
                    // Getting Tab Offset...
                    let progress: CGFloat = minX / screenWidth
                    let tabOffset: CGFloat = progress * (screenWidth / maxTabs)
                    self.tabOffset = tabOffset
                    
                    self.maxTabs = maxTabs
                }
            }
            
        }
    }
}

struct PageHelper_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TabPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .init()
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    
    func pageLabel() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func pageView(ignoresSafeArea: Bool = false, edges: Edge.Set = []) -> some View {
        self
            .frame(width: getScreenBounds().width, alignment: .center)
            .ignoresSafeArea(ignoresSafeArea ? .container : .init(), edges: edges)
    }
    
    func getScreenBounds() -> CGRect {
        return UIScreen.main.bounds
    }
    
}
