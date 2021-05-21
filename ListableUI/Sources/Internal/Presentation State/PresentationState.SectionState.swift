//
//  PresentationState.SectionState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/22/20.
//

import Foundation


extension PresentationState
{
    final class SectionState
    {
        var model : Section
        
        var header : HeaderFooterViewStatePair
        var footer : HeaderFooterViewStatePair
        
        var items : [AnyPresentationItemState]
        
        let performsContentCallbacks : Bool
        
        init(
            with model : Section,
            dependencies : ItemStateDependencies,
            updateCallbacks : UpdateCallbacks,
            performsContentCallbacks : Bool
        ) {
            self.model = model
                        
            self.header = .init(state: SectionState.newHeaderFooterState(
                with: model.header,
                performsContentCallbacks: performsContentCallbacks
            ))
            
            self.footer = .init(state: SectionState.newHeaderFooterState(
                with: model.footer,
                performsContentCallbacks: performsContentCallbacks
            ))
            
            self.performsContentCallbacks = performsContentCallbacks
            
            self.items = self.model.items.map {
                $0.newPresentationItemState(
                    with: dependencies,
                    updateCallbacks: updateCallbacks,
                    performsContentCallbacks: performsContentCallbacks
                ) as! AnyPresentationItemState
            }
        }
        
        func removeItem(at index : Int)
        {
            self.model.items.remove(at: index)
            self.items.remove(at: index)
        }
        
        func insert(item : AnyPresentationItemState, at index : Int)
        {
            self.model.items.insert(item.anyModel, at: index)
            self.items.insert(item, at: index)
        }
        
        func update(
            with oldSection : Section,
            new newSection : Section,
            changes : SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>.ItemChanges,
            reason: ApplyReason,
            dependencies : ItemStateDependencies,
            updateCallbacks : UpdateCallbacks
        ) {
            self.model = newSection
            
            let environment = dependencies.environmentProvider()
            
            self.header.update(
                with: SectionState.headerFooterState(
                    current: self.header.state,
                    new: self.model.header,
                    performsContentCallbacks: self.performsContentCallbacks
                ),
                reason: reason,
                environment: environment
            )
            
            self.footer.update(
                with: SectionState.headerFooterState(
                    current: self.footer.state,
                    new: self.model.footer,
                    performsContentCallbacks: self.performsContentCallbacks
                ),
                reason: reason,
                environment: environment
            )
            
            self.items = changes.transform(
                old: self.items,
                removed: {
                    _, item in item.wasRemoved(updateCallbacks: updateCallbacks)
                },
                added: {
                    $0.newPresentationItemState(
                        with: dependencies,
                        updateCallbacks: updateCallbacks,
                        performsContentCallbacks: self.performsContentCallbacks
                    ) as! AnyPresentationItemState
                },
                moved: { old, new, item in
                    item.setNew(item: new, reason: .moveFromList, updateCallbacks: updateCallbacks, environment: environment)
                },
                updated: { old, new, item in
                    item.setNew(item: new, reason: .updateFromList, updateCallbacks: updateCallbacks, environment: environment)
                },
                noChange: { old, new, item in
                    item.setNew(item: new, reason: .noChange, updateCallbacks: updateCallbacks, environment: environment)
                }
            )
        }
        
        func wasRemoved(updateCallbacks : UpdateCallbacks)
        {
            for item in self.items {
                item.wasRemoved(updateCallbacks: updateCallbacks)
            }
        }
        
        static func newHeaderFooterState(
            with new : AnyHeaderFooter?,
            performsContentCallbacks : Bool
        ) -> AnyPresentationHeaderFooterState?
        {
            if let new = new {
                return (new.newPresentationHeaderFooterState(performsContentCallbacks: performsContentCallbacks) as! AnyPresentationHeaderFooterState)
            } else {
                return nil
            }
        }
        
        static func headerFooterState(
            current : AnyPresentationHeaderFooterState?,
            new : AnyHeaderFooter?,
            performsContentCallbacks : Bool
        ) -> AnyPresentationHeaderFooterState?
        {
            if let current = current {
                if let new = new {
                    let isSameType = type(of: current.anyModel) == type(of: new)
                    
                    if isSameType {
                        // TODO: Update the thing here? I guess...
                        return current
                    } else {
                        return (new.newPresentationHeaderFooterState(performsContentCallbacks: performsContentCallbacks) as! AnyPresentationHeaderFooterState)
                    }
                } else {
                    return nil
                }
            } else {
                if let new = new {
                    return (new.newPresentationHeaderFooterState(performsContentCallbacks: performsContentCallbacks) as! AnyPresentationHeaderFooterState)
                } else {
                    return nil
                }
            }
        }
    }
}
