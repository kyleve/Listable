//
//  AnyItem.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


public protocol AnyItem : AnyItem_Internal
{
    var identifier : AnyIdentifier { get }
    
    var anyContent : Any { get }
    
    var sizing : Sizing { get set }
    
    var layouts : ItemLayouts { get }
    
    var selectionStyle : ItemSelectionStyle { get set }
    var autoScrollAction : AutoScrollAction? { get set }
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


extension Array {
    
    public mutating func mutateAt(index : Int, _ mutate : (inout Element) -> ()) {
        var element = self[index]
        mutate(&element)
        self[index] = element
    }
    
    public mutating func mutateEach(index : Int, _ mutate : (inout Element) -> ()) {
        for (index, element) in self.enumerated() {
            var element = element
            mutate(&element)
            self[index] = element
        }
    }
    
    public mutating func mutateFirst(_ mutate : (inout Element) -> ()) {
        guard self.isEmpty == false else {
            return
        }
        
        self.mutateAt(index: 0, mutate)
    }
    
    public mutating func mutateLast(_ mutate : (inout Element) -> ()) {
        guard self.isEmpty == false else {
            return
        }
        
        self.mutateAt(index: self.count - 1, mutate)
    }
}
