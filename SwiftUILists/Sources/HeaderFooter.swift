//
//  HeaderFooter.swift
//  SwiftUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import Listable
import SwiftUI


@available(iOS 13.0, *)
public protocol SwiftUIHeaderFooterContent : HeaderFooterContent where ContentView == SwiftUIContentView
{
    //
    // MARK: Creating SwiftUI View Representations
    //
    
    associatedtype ContentType : SwiftUI.View
    
    var body : ContentType { get }
}


@available(iOS 13.0, *)
public extension SwiftUIHeaderFooterContent
{
    //
    // MARK: HeaderFooterContent
    //
    
    func apply(to view: ContentView, reason: ApplyReason)
    {
        view.rootView = AnyView(self.body)
    }
    
    static func createReusableHeaderFooterView(frame: CGRect) -> ContentView
    {
        SwiftUIContentView(frame: frame)
    }
}

