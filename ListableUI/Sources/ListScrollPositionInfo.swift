//
//  ListScrollPositionInfo.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/4/20.
//

import Foundation
import UIKit


/// Information about the current scroll position of a list,
/// including which edges of the list are visible, and which items are visible.
///
/// This is useful within callback APIs where you as a developer may want to
/// perform different behavior based on the position of the list, eg, do you
/// want to allow an auto-scroll action, etc.
public struct ListScrollPositionInfo : Equatable {
    
    //
    // MARK: Public
    //
    
    /// Which items within the list are currently visible.
    public var visibleItems : Set<AnyIdentifier>
    
    /// If the first item list is partially visible.
    public var isFirstItemVisible : Bool
    
    /// If the last item list is partially visible.
    public var isLastItemVisible : Bool
    
    ///
    /// Used to retrieve the visible content edges for the list's content.
    ///
    /// Eg, for vertical lists:
    /// - If the list is scrolled all the way to the bottom, the visible edges are the left, right, and bottom.
    /// - If the list is scrolled all the way to the top, the visible edges are the left, right, and top.
    ///
    /// You can use this method to determine how and where the list is scrolled if you want to modify
    /// behavior based on the current scroll position.
    ///
    /// Examples
    /// ---------
    /// ```
    /// +---------------+   +---------------+      +-----------------+    +--------------------+
    /// |all            |   |top, left      |      |top, left, right |    |left, right, bottom |
    /// +---------------+   +---------------+      +-----------------+    +--------------------+
    /// List                List                   List
    /// +---------------+   +---------------+      +---------------+      +---------------+
    /// |               |   |               |      |               |      |Content@@@@@@@@|
    /// | +-----------+ |   | +-------------+-+    |               |      |@@@@@@@@@@@@@@@|
    /// | |Content@@@@| |   | |Content@@@@@@|@|    |               |      List@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    +---------------+      +---------------+
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |Content@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | |@@@@@@@@@@@| |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// | +-----------+ |   | |@@@@@@@@@@@@@|@|    |@@@@@@@@@@@@@@@|      |@@@@@@@@@@@@@@@|
    /// +---------------+   +-+-------------+@|    +---------------+      +---------------+
    ///                       |@@@@@@@@@@@@@@@|    |@@@@@@@@@@@@@@@|      |               |
    ///                       +---------------+    |@@@@@@@@@@@@@@@|      |               |
    ///                                            |@@@@@@@@@@@@@@@|      |               |
    ///                                            +---------------+      +---------------+
    /// ```
    /// Safe Area Insets
    /// -----------------
    /// You can control whether `safeAreaInsets` should be taken into account via the `includingSafeAreaEdges` parameter.
    ///
    /// Generally, you want to include the `safeAreaInsets` for the top, left, and right, but may want to exclude the bottom
    /// if you consider the bottom edge visible if it's visible below the home indicator on a home button-less iPhone or iPad.
    ///
    public func visibleContentEdges(includingSafeAreaEdges safeAreaEdges : UIRectEdge = .all) -> UIRectEdge
    {
        let safeArea = self.scrollViewState.safeAreaInsets.masked(by: safeAreaEdges)
        
        return UIRectEdge.visibleScrollViewContentEdges(
            bounds: self.scrollViewState.bounds,
            contentSize: self.scrollViewState.contentSize,
            safeAreaInsets: safeArea
        )
    }
    
    //
    // MARK: Private
    //
    
    private let scrollViewState : ScrollViewState
    
    /// Creates a `ListScrollPositionInfo` for the provided scroll view.
    public init(
        scrollView : UIScrollView,
        visibleItems : Set<AnyIdentifier>,
        isFirstItemVisible : Bool,
        isLastItemVisible : Bool
    ) {
        self.scrollViewState = ScrollViewState(
            bounds: scrollView.bounds,
            contentSize : scrollView.contentSize,
            safeAreaInsets: scrollView.safeAreaInsets
        )
        
        self.visibleItems = visibleItems
        
        self.isFirstItemVisible = isFirstItemVisible
        self.isLastItemVisible = isLastItemVisible
    }
    
    struct ScrollViewState : Equatable
    {
        var bounds : CGRect
        var contentSize : CGSize
        var safeAreaInsets : UIEdgeInsets
    }
}

extension UIEdgeInsets
{
    func masked(by edges : UIRectEdge) -> UIEdgeInsets
    {
        var insets = UIEdgeInsets()
        
        if edges.contains(.top) {
            insets.top = self.top
        }
        
        if edges.contains(.left) {
            insets.left = self.left
        }
        
        if edges.contains(.bottom) {
            insets.bottom = self.bottom
        }
        
        if edges.contains(.right) {
            insets.right = self.right
        }
        
        return insets
    }
}

extension UIRectEdge : CustomDebugStringConvertible
{
    static func visibleScrollViewContentEdges(
        bounds : CGRect,
        contentSize : CGSize,
        safeAreaInsets : UIEdgeInsets
    ) -> UIRectEdge
    {
        let insetBounds = bounds.inset(by: safeAreaInsets)
                
        var edges = UIRectEdge()
        
        if insetBounds.minY <= 0.0 {
            edges.formUnion(.top)
        }
        
        if insetBounds.minX <= 0.0 {
            edges.formUnion(.left)
        }
        
        if insetBounds.maxY >= contentSize.height {
            edges.formUnion(.bottom)
        }
        
        if insetBounds.maxX >= contentSize.width {
            edges.formUnion(.right)
        }
        
        return edges
    }
    
    public var debugDescription: String {
        var components = [String]()
        
        if self.contains(.top) {
            components += [".top"]
        }
        
        if self.contains(.left) {
            components += [".left"]
        }
        
        if self.contains(.bottom) {
            components += [".bottom"]
        }
        
        if self.contains(.right) {
            components += [".right"]
        }
        
        return "UIRectEdge(\(components.joined(separator: ", ")))"
    }
}
