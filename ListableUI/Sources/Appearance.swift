//
//  Appearance.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/17/19.
//

import UIKit

///
/// Contains all the properties which affect the appearance of all possible kinds of list layouts.
///
/// For properties that are specific to individual layouts, see the `layoutAppearance` property
/// on each layout type.
///
public struct Appearance : Equatable
{
    /// The background color for the list.
    public var backgroundColor : UIColor
    
    /// If the list should display its scroll indicators.
    public var showsScrollIndicators : Bool
        
    /// Creates a new appearance object with the provided options.
    public init(
        backgroundColor : UIColor = .white,
        showsScrollIndicators : Bool = true,
        configure : (inout Self) -> () = { _ in }
    ) {
        self.backgroundColor = backgroundColor
        
        self.showsScrollIndicators = showsScrollIndicators
        
        configure(&self)
    }
}
