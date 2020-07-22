//
//  PresentationState.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/22/19.
//


/// A class used to manage the "live" / mutable state of the visible items in the list,
/// which is persistent across diffs of content (instances are only created or destroyed when an item enters or leaves the list).
final class PresentationState
{
    //
    // MARK: Properties
    //
        
    var refreshControl : RefreshControl.PresentationState?
    
    var header : HeaderFooterViewStatePair = .init()
    var footer : HeaderFooterViewStatePair = .init()
    
    var inputAccessory : ViewProvider.State? = nil
    
    var overscrollFooter : HeaderFooterViewStatePair = .init()
    
    var sections : [PresentationState.SectionState]
        
    private(set) var containsAllItems : Bool
    
    private(set) var contentIdentifier : AnyHashable?
    
    private let itemMeasurementCache = ReusableViewCache()
    private let headerFooterMeasurementCache = ReusableViewCache()
    
    //
    // MARK: Initialization
    //
        
    init()
    {
        self.refreshControl = nil
                
        self.sections = []
        
        self.containsAllItems = true
        
        self.contentIdentifier = nil
    }
    
    //
    // MARK: Accessing Data
    //
    
    var sectionModels : [Section] {
        return self.sections.map { section in
            var sectionModel = section.model
            
            sectionModel.items = section.items.map {
                $0.anyModel
            }
            
            return sectionModel
        }
    }
    
    var selectedIndexPaths : [IndexPath] {
        let indexes : [[IndexPath]] = self.sections.compactMapWithIndex { sectionIndex, _, section in
            return section.items.compactMapWithIndex { itemIndex, _, item in
                if item.isSelected {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                } else {
                    return nil
                }
            }
        }
        
        return indexes.flatMap { $0 }
    }
    
    func headerFooter(of kind : SupplementaryKind, in section : Int) -> HeaderFooterViewStatePair
    {
        switch kind {
        case .listHeader: return self.header
        case .listFooter: return self.footer
        case .sectionHeader: return self.sections[section].header
        case .sectionFooter: return self.sections[section].footer
        case .overscrollFooter: return self.overscrollFooter
        }
    }
    
    func item(at indexPath : IndexPath) -> AnyPresentationItemState
    {
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.item]
        
        return item
    }
    
    func sections(at indexes : [Int]) -> [SectionState]
    {
        var sections : [SectionState] = []
        
        indexes.forEach {
            sections.append(self.sections[$0])
        }
        
        return sections
    }
    
    public var lastIndexPath : IndexPath?
    {
        let nonEmptySections : [(index:Int, section:SectionState)] = self.sections.compactMapWithIndex { index, _, state in
            return state.items.isEmpty ? nil : (index, state)
        }
        
        guard let lastSection = nonEmptySections.last else {
            return nil
        }
        
        return IndexPath(item: (lastSection.section.items.count - 1), section: lastSection.index)
    }
    
    internal func indexPath(for itemToFind : AnyPresentationItemState) -> IndexPath?
    {
        for (sectionIndex, section) in self.sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                if item === itemToFind {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        
        return nil
    }
    
    internal func forEachItem(_ block : (IndexPath, AnyPresentationItemState) -> ())
    {
        self.sections.forEachWithIndex { sectionIndex, _, section in
            section.items.forEachWithIndex { itemIndex, _, item in
                block(IndexPath(item: itemIndex, section: sectionIndex), item)
            }
        }
    }
    
    //
    // MARK: Mutating Data
    //
    
    func moveItem(from : IndexPath, to : IndexPath)
    {
        guard from != to else {
            return
        }
        
        let item = self.item(at: from)
        
        self.remove(at: from)
        self.insert(item: item, at: to)
    }
    
    @discardableResult
    func remove(at indexPath : IndexPath) -> AnyPresentationItemState
    {
        return self.sections[indexPath.section].items.remove(at: indexPath.item)
    }
    
    func remove(item itemToRemove : AnyPresentationItemState) -> IndexPath?
    {
        guard let indexPath = self.indexPath(for: itemToRemove) else {
            return nil
        }
        
        self.sections[indexPath.section].removeItem(at: indexPath.item)
        
        return indexPath
    }
    
    func insert(item : AnyPresentationItemState, at indexPath : IndexPath)
    {
        self.sections[indexPath.section].insert(item: item, at: indexPath.item)
    }
    
    //
    // MARK: Height Caching
    //
    
    func resetAllCachedSizes()
    {
        self.sections.forEach { section in
            section.items.forEach { item in
                item.resetCachedSizes()
            }
        }
    }
    
    //
    // MARK: Updating Content & State
    //
    
    func update(
        with diff : SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>,
        slice : Content.Slice,
        dependencies: ItemStateDependencies,
        loggable : SignpostLoggable?
    ) {
        SignpostLogger.log(.begin, log: .updateContent, name: "Update Presentation State", for: loggable)
        
        defer {
            SignpostLogger.log(.end, log: .updateContent, name: "Update Presentation State", for: loggable)
        }
        
        self.containsAllItems = slice.containsAllItems
        
        self.contentIdentifier = slice.content.identifier
        
        self.header.state = SectionState.headerFooterState(with: self.header.state, new: slice.content.header)
        self.footer.state = SectionState.headerFooterState(with: self.footer.state, new: slice.content.footer)
        self.inputAccessory = ViewProvider.State.state(with: self.inputAccessory, new: slice.content.inputAccessory)
        self.overscrollFooter.state = SectionState.headerFooterState(with: self.overscrollFooter.state, new: slice.content.overscrollFooter)
        
        self.sections = diff.changes.transform(
            old: self.sections,
            removed: { _, section in section.wasRemoved() },
            added: { section in SectionState(with: section, dependencies: dependencies) },
            moved: { old, new, changes, section in section.update(with: old, new: new, changes: changes, dependencies: dependencies) },
            noChange: { old, new, changes, section in section.update(with: old, new: new, changes: changes, dependencies: dependencies) }
        )
    }
    
    internal func updateRefreshControl(with new : RefreshControl?, in view : UIScrollView)
    {
        if let existing = self.refreshControl, let new = new {
            existing.update(with: new)
        } else if self.refreshControl == nil, let new = new {
            let newControl = RefreshControl.PresentationState(new)
            view.refreshControl = newControl.view
            self.refreshControl = newControl
        } else if self.refreshControl != nil, new == nil {
            view.refreshControl = nil
            self.refreshControl = nil
        }
    }
    
    //
    // MARK: Cell & Supplementary View Registration
    //
    
    private var registeredCellObjectIdentifiers : Set<ObjectIdentifier> = Set()
    
    func registerCell(for item : AnyPresentationItemState, in view : UICollectionView)
    {
        let info = item.cellRegistrationInfo
        
        let identifier = ObjectIdentifier(info.class)
        
        guard self.registeredCellObjectIdentifiers.contains(identifier) == false else {
            return
        }
        
        self.registeredCellObjectIdentifiers.insert(identifier)
        
        view.register(info.class, forCellWithReuseIdentifier: info.reuseIdentifier)
    }
}


extension PresentationState
{
    struct SizeKey : Hashable
    {
        var width : CGFloat
        var height : CGFloat
        var layoutDirection : LayoutDirection
        var sizing : Sizing
    }
}


extension PresentationState
{
    func toListLayoutContent(
        defaults: ListLayoutDefaults
    ) -> ListLayoutContent
    {
        ListLayoutContent(
            header: {
                guard let header = self.header.state else { return nil }
                
                return .init(
                    kind: .listHeader,
                    layout: header.anyModel.layout,
                    isPopulated: true,
                    measurer: { info in
                        header.size(for: info, cache: self.headerFooterMeasurementCache)
                    }
                )
            }(),
            footer: {
                guard let footer = self.footer.state else { return nil }
                
                return .init(
                    kind: .listFooter,
                    layout: footer.anyModel.layout,
                    isPopulated: true,
                    measurer: { info in
                        footer.size(for: info, cache: self.headerFooterMeasurementCache)
                    }
                )
            }(),
            overscrollFooter: {
                guard let footer = self.overscrollFooter.state else { return nil }
                
                return .init(
                    kind: .overscrollFooter,
                    layout: footer.anyModel.layout,
                    isPopulated: true,
                    measurer: { info in
                        footer.size(for: info, cache: self.headerFooterMeasurementCache)
                    }
                )
            }(),
            sections: self.sections.mapWithIndex { sectionIndex, _, section in
                .init(
                    layout: section.model.layout,
                    header: {
                        guard let header = section.header.state else { return nil }
                        
                        return .init(
                            kind: .sectionHeader,
                            layout: header.anyModel.layout,
                            isPopulated: true,
                            measurer: { info in
                                header.size(for: info, cache: self.headerFooterMeasurementCache)
                            }
                        )
                    }(),
                    footer: {
                        guard let footer = section.footer.state else { return nil }
                        
                        return .init(
                            kind: .sectionFooter,
                            layout: footer.anyModel.layout,
                            isPopulated: true,
                            measurer: { info in
                                footer.size(for: info, cache: self.headerFooterMeasurementCache)
                            }
                        )
                    }(),
                    columns: section.model.columns,
                    items: section.items.mapWithIndex { itemIndex, _, item in
                        .init(
                            delegateProvidedIndexPath: IndexPath(item: itemIndex, section: sectionIndex),
                            liveIndexPath: IndexPath(item: itemIndex, section: sectionIndex),
                            layout: item.anyModel.layout,
                            insertAndRemoveAnimations: item.anyModel.insertAndRemoveAnimations ?? defaults.itemInsertAndRemoveAnimations,
                            measurer: { info in
                                item.size(for: info, cache: self.itemMeasurementCache)
                            }
                        )
                    }
                )
            }
        )
    }
}
