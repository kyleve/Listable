//
//  ListEdgeInsets.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 2/11/21.
//

import Foundation


public struct ListEdgeInsets : Equatable, Hashable {
    
    public static var empty : Self {
        .init()
    }
    
    public var top : CGFloat?

    public var left : CGFloat?

    public var bottom : CGFloat?

    public var right : CGFloat?

    public init(
        top: CGFloat? = nil,
        left: CGFloat? = nil,
        bottom: CGFloat? = nil,
        right: CGFloat? = nil
    ) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
    
    public func insets(appliedTo insets : UIEdgeInsets) -> UIEdgeInsets {
        UIEdgeInsets(
            top: self.top ?? insets.top,
            left: self.left ?? insets.left,
            bottom: self.bottom ?? insets.bottom,
            right: self.right ?? insets.right
        )
    }
    
    public func toUIEdgeInsets() -> UIEdgeInsets {
        UIEdgeInsets(
            top: self.top ?? 0,
            left: self.left ?? 0,
            bottom: self.bottom ?? 0,
            right: self.right ?? 0
        )
    }
}
