//
//  SectionedDiff.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/22/19.
//

import Foundation


struct SectionedDiff<Section, SectionIdentifier:Hashable, Item, ItemIdentifier:Hashable>
{
    let old : [Section]
    let new : [Section]
    
    let changes : SectionChanges
    
    init(old : [Section], new: [Section], configuration : Configuration)
    {
        self.old = old
        self.new = new
        
        self.changes = SectionChanges(
            old: old,
            new: new,
            configuration: configuration
        )
    }
    
    struct Configuration
    {
        var section : SectionProviders
        var item : ItemProviders
        
        init(section : SectionProviders, item : ItemProviders)
        {
            self.section = section
            self.item = item
        }
        
        struct SectionProviders
        {
            var identifier : (Section) -> SectionIdentifier
            
            var items : (Section) -> [Item]
            
            var movedHint : (Section, Section) -> Bool
            
            init(
                identifier : @escaping (Section) -> SectionIdentifier,
                items : @escaping (Section) -> [Item],
                movedHint : @escaping (Section, Section) -> Bool
                )
            {
                self.identifier = identifier
                self.items = items
                self.movedHint = movedHint
            }
        }
        
        struct ItemProviders
        {
            var identifier : (Item) -> ItemIdentifier
            
            var updated : (Item, Item) -> Bool
            var movedHint : (Item, Item) -> Bool
            
            init(
                identifier : @escaping (Item) -> ItemIdentifier,
                updated : @escaping (Item, Item) -> Bool,
                movedHint : @escaping (Item, Item) -> Bool
                )
            {
                self.identifier = identifier
                self.updated = updated
                self.movedHint = movedHint
            }
        }
    }
    
    struct SectionChanges
    {
        let added : [Added]
        let removed : [Removed]
        
        let moved : [Moved]
        let noChange : [NoChange]
        
        let insertedItems : Set<IdentifiedItem>
        let removedItems : Set<IdentifiedItem>
        
        let sectionsChangeCount : Int
        let itemsChangeCount : Int
        
        var totalChangeCount : Int {
            self.sectionsChangeCount + self.itemsChangeCount
        }
        
        var isEmpty : Bool {
            self.totalChangeCount == 0
        }
        
        private let diff : ArrayDiff<Section, SectionIdentifier>
        
        init(old : [Section], new : [Section], configuration : Configuration)
        {
            self.diff = ArrayDiff(
                old: old,
                new: new,
                identifierProvider: { configuration.section.identifier($0) },
                movedHint: { configuration.section.movedHint($0, $1) },
                updated: { _, _ in false }
            )
            
            self.added = diff.added.map {
                Added(
                    identifier: $0.identifier,
                    newIndex: $0.newIndex,
                    newValue: $0.new
                )
            }
            
            self.removed = diff.removed.map {
                Removed(
                    identifier: $0.identifier,
                    oldIndex: $0.oldIndex,
                    oldValue: $0.old
                )
            }
            
            self.moved = diff.moved.map {
                Moved(
                    identifier: $0.identifier,
                    oldIndex: $0.old.oldIndex,
                    newIndex: $0.new.newIndex,
                    oldValue: $0.old.old,
                    newValue: $0.new.new,
                    
                    itemChanges: SectionedDiff.ItemChanges(
                        old: $0.old.old,
                        oldIndex: $0.old.oldIndex,
                        new: $0.new.new,
                        newIndex: $0.new.newIndex,
                        configuration: configuration
                    )
                )
            }
            
            self.noChange = diff.noChange.map {
                NoChange(
                    identifier: $0.identifier,
                    oldIndex: $0.oldIndex,
                    newIndex: $0.newIndex,
                    oldValue: $0.old,
                    newValue: $0.new,
                    
                    itemChanges: SectionedDiff.ItemChanges(
                        old: $0.old,
                        oldIndex: $0.oldIndex,
                        new: $0.new,
                        newIndex: $0.newIndex,
                        configuration: configuration
                    )
                )
            }
            
            let sectionsChangeCount =
                self.added.count
                + self.removed.count
                + self.moved.count
            
            let itemsChangeCount =
                self.moved.reduce(0, { $0 + $1.itemChanges.changeCount })
                + self.noChange.reduce(0, { $0 + $1.itemChanges.changeCount })
            
            self.sectionsChangeCount = sectionsChangeCount
            self.itemsChangeCount = itemsChangeCount
            
            let hasChanges = itemsChangeCount > 0 || sectionsChangeCount > 0
            
            if hasChanges {
                let oldItems = Self.identifiedItems(in: old, configuration: configuration)
                let newItems = Self.identifiedItems(in: new, configuration: configuration)
                
                self.insertedItems = newItems.subtracting(oldItems)
                self.removedItems = oldItems.subtracting(newItems)
            } else {
                self.insertedItems = []
                self.removedItems = []
            }
            
            listablePrecondition(diff.updated.isEmpty, "Must not have any updates for sections; sections can only move.")
        }
        
        private static func identifiedItems(in sections : [Section], configuration : Configuration) -> Set<IdentifiedItem> {
            
            var items = Set<IdentifiedItem>()
            
            for (sectionIndex, section) in sections.enumerated() {
                for (itemIndex, item) in configuration.section.items(section).enumerated() {
                    items.insert(
                        .init(
                            identifier: configuration.item.identifier(item),
                            indexPath: IndexPath(item: itemIndex, section: sectionIndex),
                            value: item
                        )
                    )
                }
            }
            
            return items
        }
        
        struct IdentifiedItem : Hashable {
            
            let identifier : ItemIdentifier
            let indexPath : IndexPath
            let value : Item
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(self.identifier)
            }
            
            static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.identifier == rhs.identifier
            }
        }
        
        struct Added
        {
            let identifier : SectionIdentifier
            
            let newIndex : Int
            
            let newValue : Section
        }
        
        struct Removed
        {
            let identifier : SectionIdentifier
            
            let oldIndex : Int
            
            let oldValue : Section
        }
        
        struct Moved
        {
            let identifier : SectionIdentifier
            
            let oldIndex : Int
            let newIndex : Int
            
            let oldValue : Section
            let newValue : Section
            
            let itemChanges : ItemChanges
        }
        
        struct NoChange
        {
            let identifier : SectionIdentifier
            
            let oldIndex : Int
            let newIndex : Int
            
            let oldValue : Section
            let newValue : Section
            
            let itemChanges : ItemChanges
        }
    }
    
    
    struct ItemChanges
    {
        let added : [Added]
        let removed : [Removed]
        
        let moved : [Moved]
        let updated : [Updated]
        let noChange : [NoChange]
        
        let changeCount : Int
        
        let diff : ArrayDiff<Item, ItemIdentifier>
        
        init(old : Section, oldIndex : Int, new : Section, newIndex : Int, configuration: Configuration)
        {
            self.init(
                old: configuration.section.items(old),
                oldIndex: oldIndex,
                new: configuration.section.items(new),
                newIndex: newIndex,
                configuration: configuration
            )
        }
        
        init(old : [Item], oldIndex : Int, new : [Item], newIndex : Int, configuration : Configuration)
        {
            self.diff = ArrayDiff(
                old: old,
                new: new,
                identifierProvider: { configuration.item.identifier($0) },
                movedHint: { configuration.item.movedHint($0, $1) },
                updated: { configuration.item.updated($0, $1) }
            )
            
            self.added = diff.added.map {
                Added(
                    identifier: $0.identifier,
                    newIndex: IndexPath(item: $0.newIndex, section: newIndex),
                    newValue: $0.new
                )
            }
            
            self.removed = diff.removed.map {
                Removed(
                    identifier: $0.identifier,
                    oldIndex: IndexPath(item: $0.oldIndex, section: oldIndex),
                    oldValue: $0.old
                )
            }
            
            self.moved = diff.moved.map {
                Moved(
                    identifier: $0.identifier,
                    oldIndex: IndexPath(item: $0.old.oldIndex, section: oldIndex),
                    newIndex: IndexPath(item: $0.new.newIndex, section: newIndex),
                    oldValue: $0.old.old,
                    newValue: $0.new.new
                )
            }
            
            self.updated = diff.updated.map {
                Updated(
                    identifier: $0.identifier,
                    oldIndex: IndexPath(item: $0.oldIndex, section: oldIndex),
                    newIndex: IndexPath(item: $0.newIndex, section: newIndex),
                    oldValue: $0.old,
                    newValue: $0.new
                )
            }
            
            self.noChange = diff.noChange.map {
                NoChange(
                    identifier: $0.identifier,
                    oldIndex: IndexPath(item: $0.oldIndex, section: oldIndex),
                    newIndex: IndexPath(item: $0.newIndex, section: newIndex),
                    oldValue: $0.old,
                    newValue: $0.new
                )
            }
            
            self.changeCount = self.added.count
                + self.removed.count
                + self.moved.count
                + self.updated.count
        }
        
        struct Added
        {
            let identifier : ItemIdentifier
            
            let newIndex : IndexPath
            
            let newValue : Item
        }
        
        struct Removed
        {
            let identifier : ItemIdentifier
            
            let oldIndex : IndexPath
            
            let oldValue : Item
        }
        
        struct Moved
        {
            let identifier : ItemIdentifier
            
            let oldIndex : IndexPath
            let newIndex : IndexPath
            
            var oldValue : Item
            var newValue : Item
        }
        
        struct Updated
        {
            let identifier : ItemIdentifier
            
            let oldIndex : IndexPath
            let newIndex : IndexPath
            
            let oldValue : Item
            let newValue : Item
        }
        
        struct NoChange
        {
            let identifier : ItemIdentifier
            
            let oldIndex : IndexPath
            let newIndex : IndexPath
            
            let oldValue : Item
            let newValue : Item
        }
    }
}

extension SectionedDiff.SectionChanges.Added : Equatable where Section:Equatable, Item:Equatable {}
extension SectionedDiff.SectionChanges.Removed : Equatable where Section:Equatable, Item:Equatable {}
extension SectionedDiff.SectionChanges.Moved : Equatable where Section:Equatable, Item:Equatable {}
extension SectionedDiff.SectionChanges.NoChange : Equatable where Section:Equatable, Item:Equatable {}

extension SectionedDiff.ItemChanges : Equatable where Item:Equatable {}

extension SectionedDiff.ItemChanges.Added : Equatable where Item:Equatable {}
extension SectionedDiff.ItemChanges.Removed : Equatable where Item:Equatable {}
extension SectionedDiff.ItemChanges.Moved : Equatable where Item:Equatable {}
extension SectionedDiff.ItemChanges.Updated : Equatable where Item:Equatable {}
extension SectionedDiff.ItemChanges.NoChange : Equatable where Item:Equatable {}


extension SectionedDiff.SectionChanges
{
    func transform<Mapped>(
        old : [Mapped],
        removed : (Section, Mapped) -> (),
        added : (Section) -> Mapped,
        moved : (Section, Section, SectionedDiff.ItemChanges, inout Mapped) -> (),
        noChange : (Section, Section, SectionedDiff.ItemChanges, inout Mapped) -> ()
        ) -> [Mapped]
    {
        let removes : [Removal<Mapped>] = (self.removed.map({
            removed($0.oldValue, old[$0.oldIndex])
            return .remove(old[$0.oldIndex], $0)
        }) + self.moved.map({
            .move(old[$0.oldIndex], $0)
        })).sorted(by: {$0.oldIndex > $1.oldIndex})
        
        let inserts : [Insertion<Mapped>] = (self.added.map({
            let value = added($0.newValue)
            return .add(value, $0)
        }) + self.moved.map({
            var value = old[$0.oldIndex]
            moved($0.oldValue, $0.newValue, $0.itemChanges, &value)
            return .move(value, $0)
        })).sorted(by: {$0.newIndex < $1.newIndex})
        
        var new = old
        
        removes.forEach {
            new.remove(at: $0.oldIndex)
        }
        
        inserts.forEach {
            new.insert($0.mapped, at: $0.newIndex)
        }
        
        // Now that index changes are complete, perform no change messaging.
        
        self.noChange.forEach {
            var value = new[$0.newIndex]
            noChange($0.oldValue, $0.newValue, $0.itemChanges, &value)
            new[$0.newIndex] = value
        }
        
        return new
    }
    
    private enum Insertion<Mapped>
    {
        case add(Mapped, Added)
        case move(Mapped, Moved)
        
        var mapped : Mapped {
            switch self {
            case .add(let mapped, _): return mapped
            case .move(let mapped, _): return mapped
            }
        }
        
        var newIndex : Int {
            switch self {
            case .add(_, let added): return added.newIndex
            case .move(_, let move): return move.newIndex
            }
        }
    }
    
    private enum Removal<Mapped>
    {
        case remove(Mapped, Removed)
        case move(Mapped, Moved)
        
        var mapped : Mapped {
            switch self {
            case .remove(let mapped, _): return mapped
            case .move(let mapped, _): return mapped
            }
        }
        
        var oldIndex : Int {
            switch self {
            case .remove(_, let remove): return remove.oldIndex
            case .move(_, let move): return move.oldIndex
            }
        }
    }
}


extension SectionedDiff.ItemChanges
{
    func transform<Mapped>(
        old : [Mapped],
        removed : (Item, Mapped) -> (),
        added : (Item) -> Mapped,
        moved : (Item, Item, inout Mapped) -> (),
        updated : (Item, Item, inout Mapped) -> (),
        noChange : (Item, Item, inout Mapped) -> ()
        ) -> [Mapped]
    {
        // Built mutative changes, sort to ensure changes are not destructive.
        
        let removes : [Removal<Mapped>] = (self.removed.map({
            removed($0.oldValue, old[$0.oldIndex.item])
            return .remove(old[$0.oldIndex.item], $0)
        }) + self.moved.map({
            return .move(old[$0.oldIndex.item], $0)
        })).sorted(by: { $0.oldIndex > $1.oldIndex })
        
        let inserts : [Insertion<Mapped>] = (self.added.map({
            let value = added($0.newValue)
            return .add(value, $0)
        }) + self.moved.map({
            var value = old[$0.oldIndex.item]
            moved($0.oldValue, $0.newValue, &value)
            return .move(value, $0)
        })).sorted(by: { $0.newIndex < $1.newIndex })
        
        var new = old
        
        removes.forEach {
            new.remove(at: $0.oldIndex)
        }
        
        inserts.forEach {
            new.insert($0.mapped, at: $0.newIndex)
        }
        
        // Now that index changes are complete, perform update and no change messaging.
        
        self.updated.forEach {
            var value = new[$0.newIndex.item]
            updated($0.oldValue, $0.newValue, &value)
            new[$0.newIndex.item] = value
        }
        
        self.noChange.forEach {
            var value = new[$0.newIndex.item]
            noChange($0.oldValue, $0.newValue, &value)
            new[$0.newIndex.item] = value
        }
        
        return new
    }
    
    private enum Insertion<Mapped>
    {
        case add(Mapped, Added)
        case move(Mapped, Moved)
        
        var mapped : Mapped {
            switch self {
            case .add(let mapped, _): return mapped
            case .move(let mapped, _): return mapped
            }
        }
        
        var newIndex : Int {
            switch self {
            case .add(_, let added): return added.newIndex.item
            case .move(_, let move): return move.newIndex.item
            }
        }
    }
    
    private enum Removal<Mapped>
    {
        case remove(Mapped, Removed)
        case move(Mapped, Moved)
        
        var mapped : Mapped {
            switch self {
            case .remove(let mapped, _): return mapped
            case .move(let mapped, _): return mapped
            }
        }
        
        var oldIndex : Int {
            switch self {
            case .remove(_, let remove): return remove.oldIndex.item
            case .move(_, let move): return move.oldIndex.item
            }
        }
    }
}
