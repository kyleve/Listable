//
//  ListView.CollectionViewChanges.swift
//  Listable
//
//  Created by Kyle Van Essen on 1/10/20.
//

import Foundation


internal extension ListView
{
    struct CollectionViewChanges : Equatable
    {
        typealias SectionChanges = SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>.SectionChanges
        typealias ItemChanges = SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>.ItemChanges
        
        var deletedSections : Set<Int> = []
        var insertedSections : Set<Int> = []
        var movedSections : Set<FromTo<Int>> = []
        
        var deletedItems : Set<IndexPath> = []
        var insertedItems : Set<IndexPath> = []
        var updatedItems : Set<IndexPath> = []
        var movedItems : Set<FromTo<IndexPath>> = []
                
        var hasIndexAffectingChanges : Bool {
            self.deletedSections.isEmpty == false ||
                self.insertedItems.isEmpty == false ||
                self.movedSections.isEmpty == false ||
                self.deletedItems.isEmpty == false ||
                self.insertedItems.isEmpty == false ||
                self.movedItems.isEmpty == false
        }
        
        struct FromTo<Value:Hashable> : Hashable {
            var from : Value
            var to : Value
        }
        
        init(sectionChanges changes : SectionChanges, transformMovesIntoDeletesAndInserts transformMoves : Bool)
        {
            // Inserted & Removed Sections
            
            self.deletedSections = Set(changes.removed.map(\.oldIndex))
            self.insertedSections = Set(changes.added.map(\.newIndex))
            
            // Moved Sections
            
            if transformMoves {
                self.deletedSections.formUnion(changes.moved.map(\.oldIndex))
                self.insertedSections.formUnion(changes.moved.map(\.newIndex))
            } else {
                self.movedSections = Set(changes.moved.map { .init(from: $0.oldIndex, to: $0.newIndex) })
            }
            
            // Deleted Items
            
            changes.moved.forEach {
                self.deletedItems.formUnion($0.itemChanges.removed.map(\.oldIndex))
            }
            
            changes.noChange.forEach {
                self.deletedItems.formUnion($0.itemChanges.removed.map(\.oldIndex))
            }
            
            // Inserted Items
            
            changes.moved.forEach {
                self.insertedItems.formUnion($0.itemChanges.added.map(\.newIndex))
            }
            
            changes.noChange.forEach {
                self.insertedItems.formUnion($0.itemChanges.added.map(\.newIndex))
            }
            
            // Updated Items
            
            changes.moved.forEach {
                self.updatedItems.formUnion($0.itemChanges.updated.map(\.oldIndex))
            }
            
            changes.noChange.forEach {
                self.updatedItems.formUnion($0.itemChanges.updated.map(\.oldIndex))
            }
            
            // Moved Items
            
            changes.moved.forEach {
                if transformMoves {
                    self.deletedItems.formUnion($0.itemChanges.moved.map(\.oldIndex))
                    self.insertedItems.formUnion($0.itemChanges.moved.map(\.newIndex))
                } else {
                    self.movedItems.formUnion($0.itemChanges.moved.map { .init(from: $0.oldIndex, to: $0.newIndex) })
                }
            }
            
            changes.noChange.forEach {
                if transformMoves {
                    self.deletedItems.formUnion($0.itemChanges.moved.map(\.oldIndex))
                    self.insertedItems.formUnion($0.itemChanges.moved.map(\.newIndex))
                } else {
                    self.movedItems.formUnion($0.itemChanges.moved.map { .init(from: $0.oldIndex, to: $0.newIndex) })
                }
            }
        }
        
        func apply(to view : UICollectionView) {
            
            //
            // Sections
            //
            
            // Deleted Sections
            
            let deletedSections = IndexSet(self.deletedSections)
        
            view.deleteSections(deletedSections)
            
            // Inserted Sections
            
            let insertedSections = IndexSet(self.insertedSections)

            view.insertSections(insertedSections)
            
            // Moved Sections
                  
            self.movedSections.forEach {
                view.moveSection($0.from, toSection: $0.to)
            }

            //
            // Items
            //
            
            let deletedItems = self.deletedItems
   
            view.deleteItems(at: Array(deletedItems))
            
            let insertedItems = self.insertedItems

            view.insertItems(at: Array(insertedItems))
            
            self.movedItems.forEach {
                view.moveItem(at: $0.from, to: $0.to)
            }
            
            //
            // Debug Logging
            //
            
            let debugging = ListableDebugging.debugging
            
            debugging.perform(if: \.logsCollectionViewDiffOperations) {
                
                print("Logging Collection View Diff Operations...")
                print("------------------------------------------")
                
                if deletedSections.isEmpty == false {
                    print("Deleting Sections : \(deletedSections.sorted())")
                }
                
                if insertedSections.isEmpty == false {
                    print("Inserting Sections: \(insertedSections.sorted())")
                }
                
                if self.movedSections.isEmpty == false {
                    print("Moving Sections   : \(self.movedSections.map { ($0.from, $0.to) })")
                }
                
                if deletedItems.isEmpty == false {
                    print("Deleting Items    : \(deletedItems.sorted())")
                }
                
                if insertedItems.isEmpty == false {
                    print("Inserting Items   : \(insertedItems.sorted())")
                }
                
                if self.movedItems.isEmpty == false {
                    print("Moving Items      : \(self.movedItems)")
                }
                
                print("")
            }
        }
    }
}
