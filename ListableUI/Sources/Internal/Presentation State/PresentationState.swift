//
//  PresentationState.swift
//  ListableUI
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
        
    var refreshControl : RefreshControlState? = nil
    
    var header : HeaderFooterViewStatePair = .init()
    var footer : HeaderFooterViewStatePair = .init()
    var overscrollFooter : HeaderFooterViewStatePair = .init()
    
    var sections : [PresentationState.SectionState] = []
        
    var performsContentCallbacks : Bool = true
        
    private(set) var containsAllItems : Bool = true
    
    private(set) var contentIdentifier : AnyHashable? = nil
    
    private let itemMeasurementCache = ReusableViewCache()
    private let headerFooterMeasurementCache = ReusableViewCache()
    
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
    
    var selectedItems : [AnyPresentationItemState] {
        let items : [[AnyPresentationItemState]] = self.sections.compactMap { section in
            section.items.compactMap { item in
                item.isSelected ? item : nil
            }
        }
        
        return items.flatMap { $0 }
    }
    
    var selectedIndexPaths : [IndexPath] {
        let indexes : [[IndexPath]] = self.sections.compactMapWithIndex { sectionIndex, _, section in
            section.items.compactMapWithIndex { itemIndex, _, item in
                item.isSelected ? IndexPath(item: itemIndex, section: sectionIndex) : nil
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
        updateCallbacks : UpdateCallbacks,
        loggable : SignpostLoggable?
    ) {
        SignpostLogger.log(.begin, log: .updateContent, name: "Update Presentation State", for: loggable)
        
        defer {
            SignpostLogger.log(.end, log: .updateContent, name: "Update Presentation State", for: loggable)
        }
        
        self.containsAllItems = slice.containsAllItems
        
        self.contentIdentifier = slice.content.identifier
        
        self.header.state = SectionState.headerFooterState(
            with: self.header.state,
            new: slice.content.header,
            performsContentCallbacks: self.performsContentCallbacks
        )
        
        self.footer.state = SectionState.headerFooterState(
            with: self.footer.state,
            new: slice.content.footer,
            performsContentCallbacks: self.performsContentCallbacks
        )
        
        self.overscrollFooter.state = SectionState.headerFooterState(
            with: self.overscrollFooter.state,
            new: slice.content.overscrollFooter,
            performsContentCallbacks: self.performsContentCallbacks
        )
        
        self.sections = diff.changes.transform(
            old: self.sections,
            removed: { _, section in
                section.wasRemoved(updateCallbacks: updateCallbacks)
            },
            added: { section in
                SectionState(
                    with: section,
                    dependencies: dependencies,
                    updateCallbacks: updateCallbacks,
                    performsContentCallbacks: self.performsContentCallbacks
                )
            },
            moved: { old, new, changes, section in
                section.update(
                    with: old, new:new,
                    changes: changes,
                    dependencies: dependencies,
                    updateCallbacks: updateCallbacks
                )
            },
            noChange: { old, new, changes, section in
                section.update(
                    with: old, new: new,
                    changes: changes,
                    dependencies: dependencies,
                    updateCallbacks: updateCallbacks
                )
            }
        )
    }
    
    internal func updateRefreshControl(with new : RefreshControl?, in view : UIScrollView)
    {
        if let existing = self.refreshControl, let new = new {
            existing.update(with: new)
        } else if self.refreshControl == nil, let new = new {
            let newControl = RefreshControlState(new)
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
    enum UpdateReason : Equatable
    {
        case scrolledDown
        case didEndDecelerating
        
        case scrolledToTop
        
        case contentChanged(animated : Bool, identifierChanged : Bool)
        
        case transitionedToBounds(isEmpty : Bool)
        
        case programaticScrollDownTo(IndexPath)
    
        var animated : Bool {
            switch self {
            case .scrolledDown: return false
            case .didEndDecelerating: return false
            case .scrolledToTop: return false
                
            case .contentChanged(let animated, let identifierChanged): return animated && identifierChanged == false
                
            case .transitionedToBounds(_): return false
                
            case .programaticScrollDownTo(_): return false
            }
        }
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
        defaults: ListLayoutDefaults,
        environment : ListEnvironment
    ) -> ListLayoutContent
    {
        ListLayoutContent(
            header: {
                guard let header = self.header.state else { return nil }
                
                return .init(
                    kind: .listHeader,
                    layouts: header.anyModel.layouts,
                    isPopulated: true,
                    measurer: { info in
                        header.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                    }
                )
            }(),
            footer: {
                guard let footer = self.footer.state else { return nil }
                
                return .init(
                    kind: .listFooter,
                    layouts: footer.anyModel.layouts,
                    isPopulated: true,
                    measurer: { info in
                        footer.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                    }
                )
            }(),
            overscrollFooter: {
                guard let footer = self.overscrollFooter.state else { return nil }
                
                return .init(
                    kind: .overscrollFooter,
                    layouts: footer.anyModel.layouts,
                    isPopulated: true,
                    measurer: { info in
                        footer.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                    }
                )
            }(),
            sections: self.sections.mapWithIndex { sectionIndex, _, section in
                .init(
                    layouts: section.model.layouts,
                    header: {
                        guard let header = section.header.state else { return nil }
                        
                        return .init(
                            kind: .sectionHeader,
                            layouts: header.anyModel.layouts,
                            isPopulated: true,
                            measurer: { info in
                                header.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                            }
                        )
                    }(),
                    footer: {
                        guard let footer = section.footer.state else { return nil }
                        
                        return .init(
                            kind: .sectionFooter,
                            layouts: footer.anyModel.layouts,
                            isPopulated: true,
                            measurer: { info in
                                footer.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                            }
                        )
                    }(),
                    items: section.items.mapWithIndex { itemIndex, _, item in
                        .init(
                            delegateProvidedIndexPath: IndexPath(item: itemIndex, section: sectionIndex),
                            liveIndexPath: IndexPath(item: itemIndex, section: sectionIndex),
                            layouts: item.anyModel.layouts,
                            insertAndRemoveAnimations: item.anyModel.insertAndRemoveAnimations ?? defaults.itemInsertAndRemoveAnimations,
                            measurer: { info in
                                item.size(for: info, cache: self.itemMeasurementCache, environment: environment)
                            }
                        )
                    }
                )
            }
        )
    }
}
