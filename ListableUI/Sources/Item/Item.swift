//
//  Item.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//

import Foundation
import UIKit

public enum ItemPosition
{
    case single
    
    case first
    case middle
    case last
}


public protocol AnyItem : AnyItem_Internal
{
    var identifier : AnyIdentifier { get }
    
    var sizing : Sizing { get set }
    var layout : ItemLayout { get set }
    var selectionStyle : ItemSelectionStyle { get set }
    var insertAndRemoveAnimations : ItemInsertAndRemoveAnimations? { get set }
    var swipeActions : SwipeActionsConfiguration? { get set }
    
    var reordering : Reordering? { get set }
}


public protocol AnyItem_Internal
{
    func anyWasMoved(comparedTo other : AnyItem) -> Bool
    func anyIsEquivalent(to other : AnyItem) -> Bool
    
    func newPresentationItemState(
        with dependencies : ItemStateDependencies,
        updateCallbacks : UpdateCallbacks,
        performsContentCallbacks : Bool
    ) -> Any
}


public struct Item<Content:ItemContent> : AnyItem
{
    public var identifier : AnyIdentifier
    
    public var content : Content
    
    public var sizing : Sizing
    public var layout : ItemLayout
    
    public var selectionStyle : ItemSelectionStyle
    
    public var insertAndRemoveAnimations : ItemInsertAndRemoveAnimations?
    
    public var swipeActions : SwipeActionsConfiguration?

    public var reordering : Reordering?
        
    public var onDisplay : OnDisplay.Callback?
    public var onEndDisplay : OnEndDisplay.Callback?
    
    public var onSelect : OnSelect.Callback?
    public var onDeselect : OnDeselect.Callback?
    
    public var onInsert : OnInsert.Callback?
    public var onRemove : OnRemove.Callback?
    public var onMove : OnMove.Callback?
    public var onUpdate : OnUpdate.Callback?
    
    internal let reuseIdentifier : ReuseIdentifier<Content>
    
    public var debuggingIdentifier : String? = nil
    
    //
    // MARK: Initialization
    //
    
    public typealias Build = (inout Item) -> ()
    
    public init(
        _ content : Content,
        build : Build
    ) {
        self.init(content)
        
        build(&self)
    }
    
    public init(
        _ content : Content,
        sizing : Sizing? = nil,
        layout : ItemLayout? = nil,
        selectionStyle : ItemSelectionStyle? = nil,
        insertAndRemoveAnimations : ItemInsertAndRemoveAnimations? = nil,
        swipeActions : SwipeActionsConfiguration? = nil,
        reordering : Reordering? = nil,
        onDisplay : OnDisplay.Callback? = nil,
        onEndDisplay : OnEndDisplay.Callback? = nil,
        onSelect : OnSelect.Callback? = nil,
        onDeselect : OnDeselect.Callback? = nil,
        onInsert : OnInsert.Callback? = nil,
        onRemove : OnRemove.Callback? = nil,
        onMove : OnMove.Callback? = nil,
        onUpdate : OnUpdate.Callback? = nil
    ) {
        self.content = content
                
        if let sizing = sizing {
            self.sizing = sizing
        } else if let sizing = content.defaultItemProperties.sizing {
            self.sizing = sizing
        } else {
            self.sizing = .thatFits(.init(.atLeast(.default)))
        }
        
        if let layout = layout {
            self.layout = layout
        } else if let layout = content.defaultItemProperties.layout {
            self.layout = layout
        } else {
            self.layout = ItemLayout()
        }
        
        if let selectionStyle = selectionStyle {
            self.selectionStyle = selectionStyle
        } else if let selectionStyle = content.defaultItemProperties.selectionStyle {
            self.selectionStyle = selectionStyle
        } else {
            self.selectionStyle = .notSelectable
        }
        
        if let insertAndRemoveAnimations = insertAndRemoveAnimations {
            self.insertAndRemoveAnimations = insertAndRemoveAnimations
        } else if let insertAndRemoveAnimations = content.defaultItemProperties.insertAndRemoveAnimations {
            self.insertAndRemoveAnimations = insertAndRemoveAnimations
        }
        
        if let swipeActions = swipeActions {
            self.swipeActions = swipeActions
        } else if let swipeActions = content.defaultItemProperties.swipeActions {
            self.swipeActions = swipeActions
        } else {
            self.swipeActions = nil
        }
                
        self.reordering = reordering
                
        self.onDisplay = onDisplay
        self.onEndDisplay = onEndDisplay
        
        self.onSelect = onSelect
        self.onDeselect = onDeselect
        
        self.onInsert = onInsert
        self.onRemove = onRemove
        self.onMove = onMove
        self.onUpdate = onUpdate
        
        self.reuseIdentifier = .identifier(for: Content.self)
        
        self.identifier = self.content.identifier
    }
    
    // MARK: AnyItem_Internal
    
    public func anyIsEquivalent(to other : AnyItem) -> Bool
    {
        guard let other = other as? Item<Content> else {
            return false
        }
        
        return self.content.isEquivalent(to: other.content)
    }
    
    public func anyWasMoved(comparedTo other : AnyItem) -> Bool
    {
        guard let other = other as? Item<Content> else {
            return true
        }
        
        return self.content.wasMoved(comparedTo: other.content)
    }
    
    public func newPresentationItemState(
        with dependencies : ItemStateDependencies,
        updateCallbacks : UpdateCallbacks,
        performsContentCallbacks : Bool
    ) -> Any
    {
        PresentationState.ItemState(
            with: self,
            dependencies: dependencies,
            updateCallbacks: updateCallbacks,
            performsContentCallbacks : performsContentCallbacks
        )
    }
}


public extension Item
{
    /// Value passed to the `onDisplay` callback for `Item`.
    struct OnDisplay
    {
        public typealias Callback = (OnDisplay) -> ()

        public var item : Item
        
        public var isFirstDisplay : Bool
    }
    
    /// Value passed to the `onEndDisplay` callback for `Item`.
    struct OnEndDisplay
    {
        public typealias Callback = (OnEndDisplay) -> ()

        public var item : Item
        
        public var isFirstEndDisplay : Bool
    }
    
    /// Value passed to the `onSelect` callback for `Item`.
    struct OnSelect
    {
        public typealias Callback = (OnSelect) -> ()
        
        public var item : Item
    }
    
    /// Value passed to the `onDeselect` callback for `Item`.
    struct OnDeselect
    {
        public typealias Callback = (OnDeselect) -> ()

        public var item : Item
    }
    
    struct OnInsert
    {
        public typealias Callback = (OnInsert) -> ()
        
        public var item : Item
    }
    
    struct OnRemove
    {
        public typealias Callback = (OnRemove) -> ()
        
        public var item : Item
    }
    
    struct OnMove
    {
        public typealias Callback = (OnMove) -> ()
        
        public var old : Item
        public var new : Item
    }
    
    struct OnUpdate
    {
        public typealias Callback = (OnUpdate) -> ()
        
        public var old : Item
        public var new : Item
    }
}


/// Allows specifying default properties to apply to an item when it is initialized,
/// if those values are not provided to the initializer.
/// Only non-nil values are used – if you do not want to provide a default value,
/// simply leave the property nil.
///
/// The order of precedence used when assigning values is:
/// 1) The value passed to the initializer.
/// 2) The value from `defaultItemProperties` on the contained `ItemContent`, if non-nil.
/// 3) A standard, default value.
public struct DefaultItemProperties<Content:ItemContent>
{
    public var sizing : Sizing?
    public var layout : ItemLayout?
    
    public var selectionStyle : ItemSelectionStyle?
    
    public var insertAndRemoveAnimations : ItemInsertAndRemoveAnimations?
    
    public var swipeActions : SwipeActionsConfiguration?
    
    public init(
        sizing : Sizing? = nil,
        layout : ItemLayout? = nil,
        selectionStyle : ItemSelectionStyle? = nil,
        insertAndRemoveAnimations : ItemInsertAndRemoveAnimations? = nil,
        swipeActions : SwipeActionsConfiguration? = nil
    ) {
        self.sizing = sizing
        self.layout = layout
        self.selectionStyle = selectionStyle
        self.insertAndRemoveAnimations = insertAndRemoveAnimations
        self.swipeActions = swipeActions
    }
}


extension Item : SignpostLoggable
{
    var signpostInfo : SignpostLoggingInfo {
        SignpostLoggingInfo(
            identifier: self.debuggingIdentifier,
            instanceIdentifier: self.identifier.debugDescription
        )
    }
}


public struct Reordering
{
    public var sections : Sections
    
    public typealias CanReorder = (Result) -> Bool
    public var canReorder : CanReorder?
    
    public typealias DidReorder = (Result) -> ()
    public var didReorder : DidReorder
    
    public init(
        sections : Sections = .same,
        canReorder : CanReorder? = nil,
        didReorder : @escaping DidReorder
    ) {
        self.sections = sections
        self.canReorder = canReorder
        self.didReorder = didReorder
    }
    
    public enum Sections : Equatable
    {
        case same
    }
    
    public struct Result
    {
        public var fromSection : Section
        public var fromIndexPath : IndexPath
        
        public var toSection : Section
        public var toIndexPath : IndexPath
    }
}


public struct ItemLayout : Equatable
{
    public var itemSpacing : CGFloat?
    public var itemToSectionFooterSpacing : CGFloat?
    
    public var width : CustomWidth
        
    public init(
        itemSpacing : CGFloat? = nil,
        itemToSectionFooterSpacing : CGFloat? = nil,
        width : CustomWidth = .default
    ) {
        self.itemSpacing = itemSpacing
        self.itemSpacing = itemSpacing
        
        self.width = width
    }
}


public struct ItemState : Hashable
{
    public init(isSelected : Bool, isHighlighted : Bool)
    {
        self.isSelected = isSelected
        self.isHighlighted = isHighlighted
    }
    
    public init(cell : UICollectionViewCell)
    {
        self.isSelected = cell.isSelected
        self.isHighlighted = cell.isHighlighted
    }
    
    /// If the item is currently selected.
    public var isSelected : Bool
    
    /// If the item is currently highlighted.
    public var isHighlighted : Bool
    
    /// If the item is either selected or highlighted.
    public var isActive : Bool {
        self.isSelected || self.isHighlighted
    }
}


/// Controls the selection style and behavior of an item in a list.
public enum ItemSelectionStyle : Equatable
{
    /// The item is not selectable at all.
    case notSelectable
    
    /// The item is temporarily selectable. Once the user lifts their finger, the item is deselected.
    case tappable
    
    /// The item is persistently selectable. Once the user lifts their finger, the item is maintained.
    case selectable(isSelected : Bool = false)
    
    var isSelected : Bool {
        switch self {
        case .notSelectable: return false
        case .tappable: return false
        case .selectable(let selected): return selected
        }
    }
    
    var isSelectable : Bool {
        switch self {
        case .notSelectable: return false
        case .tappable: return true
        case .selectable(_): return true
        }
    }
}
