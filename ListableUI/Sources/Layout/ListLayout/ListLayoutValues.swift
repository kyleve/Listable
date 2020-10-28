//
//  ListLayoutValues.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/6/20.
//

import Foundation
import UIKit

public struct ListLayoutPoint : Hashable {

    public var x : CGFloat
    public var y : CGFloat
    
    public var rotates : Bool
    
    public init(x: CGFloat, y: CGFloat, rotates: Bool)
    {
        self.x = x
        self.y = y
        self.rotates = rotates
    }
    
    public func CGPointValue(for direction : LayoutDirection) -> CGPoint {
        if direction == .horizontal && self.rotates {
            return CGPoint(x: self.y, y: self.x)
        } else {
            return CGPoint(x: self.x, y: self.y)
        }
    }
}


public struct ListLayoutSize : Hashable {

    public var width : CGFloat
    public var height : CGFloat
    
    public var rotates : Bool
    
    public init(width: CGFloat, height: CGFloat, rotates: Bool) {
        self.width = width
        self.height = height
        self.rotates = rotates
    }
    
    public func CGPointValue(for direction : LayoutDirection) -> CGSize {
        if direction == .horizontal && self.rotates {
            return CGSize(width: self.height, height: self.width)
        } else {
            return CGSize(width: self.width, height: self.height)
        }
    }
}
