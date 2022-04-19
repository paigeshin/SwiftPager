//
//  OffsetTabView.swift
//  ScrollableTabBar
//
//  Created by paige shin on 2022/04/20.
//

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
