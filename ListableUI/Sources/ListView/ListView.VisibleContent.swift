//
//  ListView.VisibleContent.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/17/20.
//

import Foundation


extension ListView
{
    final class VisibleContent
    {
        private(set) var headerFooters : Set<HeaderFooter> = Set()
        private(set) var items : Set<Item> = Set()
        
        func update(with view : ListView)
        {
            let (newItems, newHeaderFooters) = self.calculateVisibleContent(in: view)
            
            // Find which items are newly visible (or are no longer visible).
            
            let removed = self.items.subtracting(newItems)
            let added = newItems.subtracting(self.items)
            
            removed.forEach {
                $0.item.setAndPerform(isDisplayed: false)
            }
            
            added.forEach {
                $0.item.setAndPerform(isDisplayed: true)
            }
                        
            self.items = newItems
            self.headerFooters = newHeaderFooters
            
            // Inform any state reader callbacks of the changes.
            
            let callStateReader = removed.isEmpty == false || added.isEmpty == false
            
            if callStateReader {
                ListStateObserver.perform(view.stateObserver.onVisibilityChanged, "Visibility Changed", with: view) { actions in
                    ListStateObserver.VisibilityChanged(
                        actions: actions,
                        positionInfo: view.scrollPositionInfo,
                        displayed: added.map { $0.item.anyModel },
                        endedDisplay: removed.map { $0.item.anyModel }
                    )
                }
            }
        }
        
        var info : Info {
            Info(
                headerFooters: Set(self.headerFooters.map {
                    Info.HeaderFooter(kind: $0.kind, indexPath: $0.indexPath)
                }),
                items: Set(self.items.map {
                    Info.Item(identifier: $0.item.anyModel.identifier, indexPath: $0.indexPath)
                })
            )
        }
        
        private func calculateVisibleContent(in view : ListView) -> (Set<Item>, Set<HeaderFooter>)
        {
            let visibleFrame = view.collectionView.bounds
            
            let visibleAttributes = view.collectionViewLayout.visibleLayoutAttributesForElements(in: visibleFrame) ?? []
            
            var items : Set<Item> = []
            var headerFooters : Set<HeaderFooter> = []
            
            for item in visibleAttributes {
                switch item.representedElementCategory {
                case .cell:
                    items.insert(Item(
                        indexPath: item.indexPath,
                        item: view.storage.presentationState.item(at: item.indexPath)
                    ))
                    
                case .supplementaryView:
                    let kind = SupplementaryKind(rawValue: item.representedElementKind!)!
                    
                    headerFooters.insert(HeaderFooter(
                        kind: kind,
                        indexPath: item.indexPath,
                        headerFooter: view.storage.presentationState.headerFooter(of: kind, in: item.indexPath.section)
                    ))
                    
                case .decorationView: fatalError()
                    
                @unknown default: assertionFailure("Unknown representedElementCategory type.")
                }
            }
            
            return (items, headerFooters)
        }
    }
}

extension ListView.VisibleContent
{
    struct HeaderFooter : Hashable
    {
        let kind : SupplementaryKind
        let indexPath : IndexPath
        
        let headerFooter : PresentationState.HeaderFooterViewStatePair
        
        static func == (lhs : Self, rhs : Self) -> Bool
        {
            lhs.kind == rhs.kind && lhs.indexPath == rhs.indexPath && lhs.headerFooter === rhs.headerFooter
        }
        
        func hash(into hasher: inout Hasher)
        {
            hasher.combine(self.kind)
            hasher.combine(self.indexPath)
            hasher.combine(ObjectIdentifier(self.headerFooter))
        }
    }
    
    struct Item : Hashable
    {
        let indexPath : IndexPath
        let item : AnyPresentationItemState
        
        static func == (lhs : Self, rhs : Self) -> Bool
        {
            lhs.indexPath == rhs.indexPath && lhs.item === rhs.item
        }
        
        func hash(into hasher: inout Hasher)
        {
            hasher.combine(self.indexPath)
            hasher.combine(ObjectIdentifier(self.item))
        }
    }
    
    /// Note: Because this type exposes index paths and the internal `SupplementaryKind`,
    /// it is intended for internal usage or unit testing purposes only.
    /// Public consumers and APIs should utilize `ListScrollPositionInfo`.
    struct Info : Equatable
    {
        var headerFooters : Set<HeaderFooter>
        var items : Set<Item>
        
        struct HeaderFooter : Hashable
        {
            var kind : SupplementaryKind
            var indexPath : IndexPath
        }
        
        struct Item : Hashable
        {
            var identifier : AnyIdentifier
            var indexPath : IndexPath
        }
    }
}
