//
//  AutoScrollAction.swift
//  ListableUI
//
//  Created by Kyle Bashour on 3/30/20.
//

import Foundation


/// Options for auto-scrolling to items when the list is updated.
public enum AutoScrollAction {

    /// Scrolls to the specified item when the list is updated if the item was inserted in this update.
    case onInsert(OnInsert)

    /// Scrolls to the specified item when the list is updated if the item was inserted in this update.
    ///
    /// If you would like to control if this scroll should occur on insert, pass a `shouldPerform` closure,
    /// which will be called when the item is inserted, to give you a chance to confirm or reject the scroll
    /// action. The `ListScrollPositionInfo` passed to your closure provides the current state of the list,
    /// including visible content edges and visible items. If you do not pass a `shouldPerform` closure,
    /// the action will be performed on insert.
    ///
    /// Example
    /// -------
    /// ```
    /// // ID of item which should trigger a scroll event (eg the last item in the list).
    /// let identifier = myItem.identifier
    ///
    /// let action = .scrollTo(
    ///     .lastItem,
    ///     onInsertOf: identifier,
    ///     position: .init(position: .bottom),
    ///     animation: .default
    /// ) { info in
    ///    // Only scroll to the item if the bottom of the list is already visible.
    ///    return state.isLastItemVisible
    /// } didPerform : { info in
    ///     // Called when the scroll action occurs.
    /// }
    /// ```
    /// - Parameters
    ///     - destination: Where the list should scroll to on insert. If not specified, the value passed to `onInsertOf` will be used.
    ///     - position: The position to scroll the list to.
    ///     - animation: The animation type to perform. Note: Will only animate if the list update itself is animated.
    ///     - shouldPerform: A block which lets you control if the auto scroll action should be performed based on the state of the list.
    ///     - didPerform: A block which is called when the action is performed. If the item causing insertion is inserted multiple times,
    ///     this block will be called multiple times.
    ///
    public static func onInsert(
        scrollTo destination : ScrollDestination? = nil,
        position: ScrollPosition,
        animation: ScrollAnimation = .none,
        priority : Int = 0,
        shouldPerform : @escaping (ListScrollPositionInfo) -> Bool = { _ in true },
        didPerform : @escaping (ListScrollPositionInfo) -> () = { _ in }
    ) -> AutoScrollAction
    {
        .onInsert(.init(
            destination: destination,
            position: position,
            animation: animation,
            priority : priority,
            shouldPerform: shouldPerform,
            didPerform: didPerform
        ))
    }
}


extension AutoScrollAction
{
    /// Where to scroll as a result of an `AutoScrollAction`.
    public enum ScrollDestination : Equatable
    {
        /// Scroll to the first item in the list.
        case firstItem
        
        /// Scroll to the last item in the list.
        case lastItem
        
        /// Scroll to the item with the specified identifier.
        case item(AnyIdentifier)
        
        func destination(with content : Content) -> AnyIdentifier? {
            switch self {
            case .firstItem: return content.firstItem?.identifier
            case .lastItem: return content.lastItem?.identifier
            case .item(let identifier): return identifier
            }
        }
    }
    
    
    /// Values used to configure the `scrollToItem(onInsertOf:)` action.
    public struct OnInsert
    {
        /// The item in the list to scroll to when the `insertedIdentifier` is inserted.
        /// If nil, the item will scroll to itself on insert.
        public var destination : ScrollDestination?
        
        /// The desired scroll position,
        public var position : ScrollPosition
        
        /// How to animate the change.
        ///
        /// Note
        /// ----
        /// The action will only be animated if it is animated, **and** the list update itself is
        /// animated. Otherwise, no animation occurs.
        public var animation : ScrollAnimation
        
        /// If multiple `OnInsert` actions occur at once, the one with the highest priority will win.
        /// If multiple inserted items have the same priority, the first one is used.
        public var priority : Int
        
        /// An additional check you may provide to approve or reject the scroll action.
        public var shouldPerform : (ListScrollPositionInfo) -> Bool
        
        /// Called when the list performs the insertion.
        public var didPerform : (ListScrollPositionInfo) -> ()
    }
}
