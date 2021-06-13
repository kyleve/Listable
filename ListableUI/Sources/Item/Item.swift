//
//  Item.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//


public struct Item<Content:ItemContent> : AnyItem, AnyItemConvertible
{
    public var identifier : AnyIdentifier
    
    public var content : Content
    
    public var sizing : Sizing
    public var layouts : ItemLayouts
    
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
    
    public typealias Configure = (inout Item) -> ()
    
    public init(
        _ content : Content,
        configure : Configure
    ) {
        self.init(content)
        
        configure(&self)
    }
    
    public init(
        _ content : Content,
        sizing : Sizing? = nil,
        layouts : ItemLayouts? = nil,
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
        assertIsValueType(Content.self)
        
        self.content = content
                
        if let sizing = sizing {
            self.sizing = sizing
        } else if let sizing = content.defaultItemProperties.sizing {
            self.sizing = sizing
        } else {
            self.sizing = .thatFits(.init(.atLeast(.default)))
        }
        
        if let layouts = layouts {
            self.layouts = layouts
        } else if let layouts = content.defaultItemProperties.layouts {
            self.layouts = layouts
        } else {
            self.layouts = ItemLayouts()
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
    
    // MARK: AnyItem
    
    public var anyContent: Any {
        self.content
    }
    
    // MARK: AnyItemConvertible
    
    public func asItem() -> AnyItem {
        self
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


extension Item : SignpostLoggable
{
    var signpostInfo : SignpostLoggingInfo {
        SignpostLoggingInfo(
            identifier: self.debuggingIdentifier,
            instanceIdentifier: self.identifier.debugDescription
        )
    }
}
