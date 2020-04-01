//
//  ListDescription.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/9/19.
//

import Foundation


public struct ListDescription
{
    public var animatesChanges : Bool
    
    public var appearance : Appearance
    public var behavior : Behavior
    public var autoScrollingBehavior : AutoScrollingBehavior
    public var scrollInsets : ScrollInsets
    
    public var content : Content

    public typealias Build = (inout ListDescription) -> ()
    
    public init(
        animatesChanges: Bool,
        appearance : Appearance,
        behavior : Behavior,
        autoScrollingBehavior : AutoScrollingBehavior,
        scrollInsets : ScrollInsets,
        build : Build
    )
    {
        self.animatesChanges = animatesChanges
        self.appearance = appearance
        self.behavior = behavior
        self.autoScrollingBehavior = autoScrollingBehavior
        self.scrollInsets = scrollInsets
        
        self.content = Content()

        build(&self)
    }
    
    public mutating func add(_ section : Section)
    {
        self.content.sections.append(section)
    }
    
    public static func += (lhs : inout ListDescription, rhs : Section)
    {
        lhs.add(rhs)
    }
    
    public static func += (lhs : inout ListDescription, rhs : [Section])
    {
        lhs.content.sections += rhs
    }
}

