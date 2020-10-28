//
//  ReorderingActions.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/14/19.
//

import UIKit

protocol ReorderingActionsDelegate : AnyObject
{
    func beginInteractiveMovementFor(item : AnyPresentationItemState) -> Bool
    func updateInteractiveMovementTargetPosition(with recognizer : UIPanGestureRecognizer)
    func endInteractiveMovement()
    func cancelInteractiveMovement()
}


public final class ReorderingActions
{
    public private(set) var isMoving : Bool
    
    internal weak var item : AnyPresentationItemState?
    internal weak var delegate : ReorderingActionsDelegate?
    
    init()
    {
        self.isMoving = false
    }
    
    public func beginMoving() -> Bool
    {
        guard self.isMoving == false else {
            return true
        }
        
        self.isMoving = true
        
        if let delegate = self.delegate, let item = self.item {
            return delegate.beginInteractiveMovementFor(item: item)
        } else {
            return false
        }
    }
    
    public func moved(with recognizer : UIPanGestureRecognizer)
    {
        guard self.isMoving else {
            return
        }
        
        self.delegate?.updateInteractiveMovementTargetPosition(with: recognizer)
    }
    
    public func end()
    {
        guard self.isMoving else {
            return
        }
        
        self.isMoving = false
        
        self.delegate?.endInteractiveMovement()
    }
}
