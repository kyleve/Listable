//
//  AnyItem.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


public protocol AnyItem : AnyItemConvertible, AnyItem_Internal
{
    var identifier : AnyIdentifier { get }
    
    var anyContent : Any { get }
    
    var sizing : Sizing { get set }
    
    var layouts : ItemLayouts { get }
    
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
