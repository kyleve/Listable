//
//  EmbeddedList.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/10/19.
//

import UIKit

public extension Item where Content == EmbeddedList
{
    /// Creates an `Item` which can be used to embed a list inside another list,
    /// for example if you'd like to place a horizontally scrollable list within a vertically scrolling
    /// list, or vice versa.
    ///
    /// ```
    /// section += .list(
    ///     "my-identifier",
    ///     sizing: .fixed(height: 200)
    /// ) { list in
    ///
    ///     list.layout = .list {
    ///         $0.direction = .horizontal
    ///     }
    ///
    ///     list += Section("section-id") {
    ///         ...
    ///     }
    /// }
    /// ```
    static func list<Identifier:Hashable>(
        _ identifier : Identifier,
        sizing : EmbeddedList.Sizing,
        build : ListProperties.Build
    ) -> Item<EmbeddedList>
    {
        Item(
            EmbeddedList(identifier: identifier, build: build),
            sizing: sizing.toStandardSizing,
            layout: ItemLayout(width: .fill)
        )
    }
}


public extension EmbeddedList
{
    /// How you specify sizing for an embedded list. The surface area
    /// of this `Sizing` enum is intentionally reduced from the standard `Sizing`
    /// enum, because several of those values do not make sense for embedded lists.
    enum Sizing : Equatable
    {
        /// Falls back to the default sizing of `Item`s in the list view.
        case `default`
        
        /// A fixed size item with the given width or height.
        ///
        /// Note: Depending on the list layout type, only one of width or height may be used.
        /// Eg, for list layouts, vertical lists only use the height, and horizontal lists only use the width.
        case fixed(width: CGFloat = 0.0, height : CGFloat = 0.0)
        
        var toStandardSizing : ListableUI.Sizing {
            switch self {
            case .default: return .default
            case .fixed(let w, let h): return .fixed(width: w, height: h)
            }
        }
    }
}


/// Describes item content which can be used to embed a list inside another list,
/// for example if you'd like to place a horizontally scrollable list within a vertically scrolling
/// list, or vice versa.
///
/// You rarely use this type directly. Instead, use the static `.list` function on `Item`.
///
/// Internal TODO: This should use a coordinator to manage the scroll position of the contained list
/// during cell reuse.
///
public struct EmbeddedList : ItemContent
{
    //
    // MARK: Public Properties
    //
    
    public var properties : ListProperties
    public var contentIdentifier : AnyHashable
    
    //
    // MARK: Initialization
    //
    
    public init<Identifier:Hashable>(identifier : Identifier, build : ListProperties.Build)
    {
        self.contentIdentifier = AnyHashable(identifier)
        
        self.properties = ListProperties(
            animatesChanges: true,
            layout: .list(),
            appearance: .init {
                $0.showsScrollIndicators = false
            },
            scrollIndicatorInsets: .init(),
            behavior: .init(),
            autoScrollAction: .none,
            accessibilityIdentifier: nil,
            debuggingIdentifier: nil,
            build: build
        )
    }
    
    //
    // MARK: ItemContent
    //
        
    public typealias ContentView = ListView
    
    public var identifier: Identifier<EmbeddedList> {
        return .init(self.contentIdentifier)
    }
    
    public func apply(to views : ItemContentViews<Self>, for reason: ApplyReason, with info : ApplyItemContentInfo)
    {
        views.content.configure(with: self.properties)
    }
    
    public func isEquivalent(to other: EmbeddedList) -> Bool
    {
        return false
    }
    
    public static func createReusableContentView(frame : CGRect) -> ListView
    {
        ListView(frame: frame)
    }
}
