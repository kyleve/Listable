//
//  SwiftUIListViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 5/29/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import SwiftUILists


@available(iOS 13.0, *)
final class SwiftUIListViewController : UIViewController
{
    let hosting : UIHostingController<AnyView>
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        self.hosting = UIHostingController(rootView: AnyView(EmptyView()))
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.addChild(self.hosting)
        self.hosting.didMove(toParent: self)
        
        self.hosting.rootView = AnyView(self.body)
        
        self.title = "SwiftUI Integration"
    }
    
    override func loadView()
    {
        super.loadView()
        
        self.view.addSubview(self.hosting.view)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        self.hosting.view.frame = self.view.bounds
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    var body : some View {
        ListableView { list in
            
            list.layout = .demoLayout
            list.appearance = .demoAppearance
            
            list("section") { section in
                
                section += (1...1000).map {
                    SwiftUIDemoItem(text: "\($0)")
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

@available(iOS 13.0, *)
fileprivate struct SwiftUIDemoItem : SwiftUIItemContent, Equatable
{
    var text : String
    
    var identifier: Identifier<SwiftUIDemoItem> {
        .init()
    }
    
    func content(with info: ApplyItemContentInfo) -> some View {
        Text(self.text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 16.0, weight: .medium, design: .default))
            .foregroundColor(info.state.isActive ? .white : .black)
            .padding(EdgeInsets(top: 10.0, leading: 15.0, bottom: 10.0, trailing: 15.0))
    }
    
    func background(with info: ApplyItemContentInfo) -> some View {
        Rectangle()
            .foregroundColor(.white)
            .cornerRadius(8.0)
            .shadow(color: Color.black.opacity(0.15), radius: 2.0, x: 0.0, y: 1.0)
    }
    
    func selectedBackground(with info: ApplyItemContentInfo) -> some View {
        Rectangle()
            .foregroundColor(.gray)
            .cornerRadius(8.0)
            .shadow(color: Color.black.opacity(0.15), radius: 2.0, x: 0.0, y: 1.0)
    }
}

