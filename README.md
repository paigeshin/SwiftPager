# SwiftPager


### Offset TabView

```swift
import SwiftUI

// Custom View that will return offset for Paging Control...
struct OffsetPageTabView<Content: View>: UIViewRepresentable {
    
    typealias UIViewType = UIScrollView
    var content: Content
    @Binding var offset: CGFloat
    @Binding var selection: Int
    
    func makeCoordinator() -> Coordinator {
        return OffsetPageTabView.Coordinator(parent: self)
    }
    
    init(selection: Binding<Int>, offset: Binding<CGFloat>, @ViewBuilder content: @escaping () -> Content) {
        self._selection = selection
        self.content = content()
        self._offset = offset
    }
 
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView: UIScrollView = UIScrollView()
        
        // Extracting SwiftuI View and embedding into UIKit ScrollView...
        let hostView: UIHostingController = UIHostingController(rootView: content)
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            hostView.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostView.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ]
        
        // if you are using vertical paging...
        // then don't declare height constraint...
        scrollView.addSubview(hostView.view)
        scrollView.addConstraints(constraints)
        
        // Enabling Paging...
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // setting Delegate...
        scrollView.delegate = context.coordinator
        
        return scrollView
        
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let currentOffset: CGFloat = uiView.contentOffset.x
        
        if currentOffset != offset {
            uiView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        
        var parent: OffsetPageTabView
        
        init(parent: OffsetPageTabView) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset: CGFloat = scrollView.contentOffset.x
            
            // Safer Side Updating Selection On Scroll...
            let maxSize: CGFloat = scrollView.contentSize.width
            let currentSelection = (offset / maxSize).rounded()
            parent.selection = Int(currentSelection)
            
            parent.offset = offset
        }
        
    }
    
}

```

### PagerTabView

```swift
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
```

### Usage

```swift
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
```

# Module & Upgraded Version
```swift
//
//  SwiftPager.swift
//  SeasonalFood
//
//  Created by paige shin on 2022/04/20.
//

import SwiftUI

// Custom View that will return offset for Paging Control...
fileprivate struct OffsetPageTabView<Content: View>: UIViewRepresentable {
    
    typealias UIViewType = UIScrollView
    var content: Content
    @Binding var offset: CGFloat
    @Binding var selection: Int
    
    func makeCoordinator() -> Coordinator {
        return OffsetPageTabView.Coordinator(parent: self)
    }
    
    init(selection: Binding<Int>, offset: Binding<CGFloat>, @ViewBuilder content: @escaping () -> Content) {
        self._selection = selection
        self.content = content()
        self._offset = offset
    }
 
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView: UIScrollView = UIScrollView()
        
        // Extracting SwiftuI View and embedding into UIKit ScrollView...
        let hostView: UIHostingController = UIHostingController(rootView: content)
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            hostView.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostView.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ]
        
        // if you are using vertical paging...
        // then don't declare height constraint...
        scrollView.addSubview(hostView.view)
        scrollView.addConstraints(constraints)
        
        // Enabling Paging...
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // setting Delegate...
        scrollView.delegate = context.coordinator
        
        return scrollView
        
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let currentOffset: CGFloat = uiView.contentOffset.x
        
        if currentOffset != offset {
            uiView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        
        var parent: OffsetPageTabView
        
        init(parent: OffsetPageTabView) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset: CGFloat = scrollView.contentOffset.x
            
            // Safer Side Updating Selection On Scroll...
            let maxSize: CGFloat = scrollView.contentSize.width
            let currentSelection = (offset / maxSize).rounded()
            parent.selection = Int(currentSelection)
            
            parent.offset = offset
        }
        
    }
    
}

// Custom View Builder...
struct SwiftPager<Content: View, Label: View>: View {
    
    var showIndicators: Bool
    var tint: Color
    @Binding var selection: Int
    
    var content: Content
    var label: Label
      
    init(
        showIndicators: Bool = false,
        tint: Color,
        selection: Binding<Int>,
        @ViewBuilder labels: @escaping() -> Label,
        @ViewBuilder content: @escaping() -> Content
    ) {
        self.showIndicators = showIndicators
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

fileprivate struct TabPreferenceKey: PreferenceKey {
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
```
