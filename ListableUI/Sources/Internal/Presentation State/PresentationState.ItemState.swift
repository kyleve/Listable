//
//  PresentationState.ItemState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/22/20.
//

import Foundation


protocol AnyPresentationItemState : AnyObject
{
    var isDisplayed : Bool { get }
    func setAndPerform(isDisplayed: Bool)
    
    var itemPosition : ItemPosition { get set }
    
    var anyModel : AnyItem { get }
    
    var reorderingActions : ReorderingActions { get }
        
    var cellRegistrationInfo : (class:AnyClass, reuseIdentifier:String) { get }
    
    func dequeueAndPrepareCollectionViewCell(
        in collectionView : UICollectionView,
        for indexPath : IndexPath,
        environment : ListEnvironment
    ) -> AnyItemCell
    
    func applyTo(
        cell anyCell : UICollectionViewCell,
        itemState : ListableUI.ItemState,
        reason : ApplyReason,
        environment : ListEnvironment
    )
    
    func applyToVisibleCell(with environment : ListEnvironment)
        
    func setNew(item anyItem : AnyItem, reason : PresentationState.ItemUpdateReason, updateCallbacks : UpdateCallbacks)
    
    func willDisplay(cell : UICollectionViewCell, in collectionView : UICollectionView, for indexPath : IndexPath)
    func didEndDisplay()
    
    func wasRemoved(updateCallbacks : UpdateCallbacks)
    
    var isSelected : Bool { get }
    func set(isSelected: Bool, performCallbacks: Bool)
    
    func resetCachedSizes()
    
    func size(
        for info : Sizing.MeasureInfo,
        cache : ReusableViewCache,
        environment : ListEnvironment
    ) -> CGSize
    
    func moved(with result : Reordering.Result)
}


protocol ItemContentCoordinatorDelegate : AnyObject
{
    func coordinatorUpdated(for item : AnyItem)
}


public struct ItemStateDependencies
{
    weak var reorderingDelegate : ReorderingActionsDelegate?
    weak var coordinatorDelegate : ItemContentCoordinatorDelegate?
    
    var environmentProvider : () -> ListEnvironment
}


extension PresentationState
{
    enum ItemUpdateReason : CaseIterable
    {
        case moveFromList
        case updateFromList
        case updateFromItemCoordinator
        case noChange
    }
    
    final class ItemState<Content:ItemContent> : AnyPresentationItemState
    {
        var model : Item<Content> {
            self.storage.model
        }
        
        let performsContentCallbacks : Bool
        
        private(set) var coordination : Coordination
        
        struct Coordination {
            var coordinator : Content.Coordinator?
            
            let actions : ItemContentCoordinatorActions<Content>
            let info : ItemContentCoordinatorInfo<Content>
        }
        
        let reorderingActions: ReorderingActions
        
        var itemPosition : ItemPosition
        
        let storage : Storage
        
        init(
            with model : Item<Content>,
            dependencies : ItemStateDependencies,
            updateCallbacks : UpdateCallbacks,
            performsContentCallbacks : Bool
        ) {
            self.reorderingActions = ReorderingActions()
            self.itemPosition = .single
        
            self.cellRegistrationInfo = (ItemCell<Content>.self, model.reuseIdentifier.stringValue)
                        
            let storage = Storage(model)
            self.storage = storage
            
            self.performsContentCallbacks = performsContentCallbacks
                        
            let actions = ItemContentCoordinatorActions(
                current: { storage.model },
                update: { new, _ in
                    
                    /// This is a temporary update callback, in case the initialization of the
                    /// coordinator causes an update to the item itself.
                    
                    storage.model = new
                }
            )

            let info = ItemContentCoordinatorInfo(
                original: storage.model,
                current: { storage.model }
            )
            
            let coordinator = self.performsContentCallbacks ? model.content.makeCoordinator(actions: actions, info: info) : nil
            
            self.coordination = Coordination(
                coordinator: coordinator,
                actions: actions,
                info: info
            )
            
            self.reorderingActions.item = self
            self.reorderingActions.delegate = dependencies.reorderingDelegate
            
            /// Now that the presentation state is entirely configured, set up the final
            /// update callback, which triggers a `setNew` call, alongside informing the
            /// `listView` that changes have occurred.
            
            weak var coordinatorDelegate = dependencies.coordinatorDelegate
            
            self.coordination.actions.updateCallback = { [weak self, weak coordinatorDelegate] new, animation in
                guard let self = self, let delegate = coordinatorDelegate else {
                    return
                }
                
                self.setNew(item: new, reason: .updateFromItemCoordinator, updateCallbacks: UpdateCallbacks(.immediate))
                
                animation.perform {
                    self.applyToVisibleCell(with: dependencies.environmentProvider())
                    delegate.coordinatorUpdated(for: self.anyModel)
                }
            }
            
            self.storage.didSetState = { [weak self] old, new in
                self?.updateCoordinatorWithStateChange(old: old, new: new)
            }
            
            /// Now that we are set up, notify callbacks.
            
            updateCallbacks.add(if: self.performsContentCallbacks) {
                self.model.onInsert?(.init(item: self.model))
                self.coordination.coordinator?.wasInserted(.init(item: self.model))
            }
        }
        
        // MARK: AnyPresentationItemState
        
        private(set) var isDisplayed : Bool = false
        
        private var hasDisplayed : Bool = false
        private var hasEndedDisplay : Bool = false
        
        func setAndPerform(isDisplayed: Bool) {
            guard self.isDisplayed != isDisplayed else {
                return
            }
            
            self.isDisplayed = isDisplayed
            
            if self.isDisplayed {
                if self.performsContentCallbacks {
                    self.model.onDisplay?(.init(
                        item: self.model,
                        isFirstDisplay: self.hasDisplayed == false
                        )
                    )
                }
                
                self.hasDisplayed = true
            } else {
                if self.performsContentCallbacks {
                    self.model.onEndDisplay?(.init(
                        item: self.model,
                        isFirstEndDisplay: self.hasEndedDisplay == false
                        )
                    )
                }
                
                self.hasEndedDisplay = true
            }
        }
                
        var anyModel : AnyItem {
            return self.model
        }
        
        var cellRegistrationInfo : (class:AnyClass, reuseIdentifier:String)
        
        func dequeueAndPrepareCollectionViewCell(
            in collectionView : UICollectionView,
            for indexPath : IndexPath,
            environment : ListEnvironment
        ) -> AnyItemCell
        {
            let anyCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellRegistrationInfo.reuseIdentifier, for: indexPath)
            
            let cell = anyCell as! ItemCell<Content>
            
            // Theme cell & apply content.
            
            let itemState = ListableUI.ItemState(cell: cell)
            
            self.applyTo(
                cell: cell,
                itemState: itemState,
                reason: .willDisplay,
                environment: environment
            )
            
            return cell
        }
        
        func applyTo(
            cell anyCell : UICollectionViewCell,
            itemState : ListableUI.ItemState,
            reason : ApplyReason,
            environment : ListEnvironment
        ) {
            let cell = anyCell as! ItemCell<Content>
            
            let applyInfo = ApplyItemContentInfo(
                state: itemState,
                position: self.itemPosition,
                reordering: self.reorderingActions,
                environment: environment
            )
            
            // Apply Model State
            
            self.model.content.apply(
                to: ItemContentViews(content: cell.contentContainer.contentView, background: cell.background, selectedBackground: cell.selectedBackground),
                for: reason,
                with: applyInfo,
                send : { _ in
                    fatalError("TODO")
                }
            )
                        
            // Apply Swipe To Action Appearance
            if let actions = self.model.swipeActions {
                cell.contentContainer.registerSwipeActionsIfNeeded(actions: actions, reason: reason)
            } else {
                cell.contentContainer.deregisterSwipeIfNeeded()
            }
        }
        
        func applyToVisibleCell(with environment : ListEnvironment)
        {
            guard let cell = self.storage.state.visibleCell else {
                return
            }
            
            self.applyTo(
                cell: cell,
                itemState: .init(cell: cell),
                reason: .wasUpdated,
                environment: environment
            )
        }
        
        func setNew(item anyItem: AnyItem, reason: ItemUpdateReason, updateCallbacks : UpdateCallbacks)
        {
            let old = self.model
            let new = anyItem as! Item<Content>
            
            self.storage.model = new
            
            if old.selectionStyle != new.selectionStyle {
                self.storage.state.isSelected = new.selectionStyle.isSelected
            }
            
            switch reason {
            case .moveFromList:
                self.coordination.info.original = new
 
                updateCallbacks.add(if: self.performsContentCallbacks) {
                    self.coordination.coordinator?.wasMoved(.init(old: old, new: new))
                    self.model.onMove?(.init(old: old, new: new))
                }
            case .updateFromList:
                self.coordination.info.original = new
                
                updateCallbacks.add(if: self.performsContentCallbacks) {
                    self.coordination.coordinator?.wasUpdated(.init(old: old, new: new))
                    self.model.onUpdate?(.init(old: old, new: new))
                }
            case .updateFromItemCoordinator:
                updateCallbacks.add(if: self.performsContentCallbacks) {
                    self.model.onUpdate?(.init(old: old, new: new))
                }
            case .noChange: break
            }

            if reason != .noChange {
                self.resetCachedSizes()
            }
        }
        
        func willDisplay(cell anyCell : UICollectionViewCell, in collectionView : UICollectionView, for indexPath : IndexPath)
        {
            let cell = (anyCell as! ItemCell<Content>)
            
            self.storage.state.visibleCell = cell
        }
        
        func didEndDisplay()
        {
            self.storage.state.visibleCell = nil
        }
        
        func wasRemoved(updateCallbacks : UpdateCallbacks)
        {
            updateCallbacks.add(if: self.performsContentCallbacks) {
                self.model.onRemove?(.init(item: self.model))
                self.coordination.coordinator?.wasRemoved(.init(item: self.model))
            }
        }
        
        var isSelected: Bool {
            self.storage.state.isSelected
        }
                
        func set(isSelected: Bool, performCallbacks: Bool)
        {
            self.storage.state.isSelected = isSelected
            
            if performCallbacks {
                /// Schedule the caller-provided callbacks to happen after one runloop. Why?
                ///
                /// Because this method is called from within `UICollectionViewDelegate` callbacks,
                /// This delay gives the `UICollectionView` time to schedule any necessary animations
                /// for changes to the highlight and selection state – otherwise, these animations get
                /// stuck behind the call to the `onSelect` or `onDeselect` blocks, which creates the appearance
                /// of a laggy UI if these callbacks are slow.
                DispatchQueue.main.async {
                    if isSelected {
                        if let onSelect = self.model.onSelect {
                            SignpostLogger.log(log: .listInteraction, name: "Item onSelect", for: self.model) {
                                onSelect(.init(item: self.model))
                            }
                        }
                    } else {
                        if let onDeselect = self.model.onDeselect {
                            SignpostLogger.log(log: .listInteraction, name: "Item onDeselect", for: self.model) {
                                onDeselect(.init(item: self.model))
                            }
                        }
                    }
                }
            }
        }
        
        func updateCoordinatorWithStateChange(old : State, new : State)
        {
            guard let coordinator = self.coordination.coordinator else {
                return
            }
            
            if old.isSelected != new.isSelected {
                if new.isSelected {
                    coordinator.wasSelected()
                } else {
                    coordinator.wasDeselected()
                }
            }
            
            if old.visibleCell != new.visibleCell {
                if new.visibleCell != nil {
                    coordinator.willDisplay()
                } else {
                    coordinator.didEndDisplay()
                }
            }
        }
        
        private var cachedSizes : [SizeKey:CGSize] = [:]
        
        func resetCachedSizes()
        {
            self.cachedSizes.removeAll()
        }
        
        func size(
            for info : Sizing.MeasureInfo,
            cache : ReusableViewCache,
            environment : ListEnvironment
        ) -> CGSize
        {
            guard info.sizeConstraint.isEmpty == false else {
                return .zero
            }
            
            let key = SizeKey(
                width: info.sizeConstraint.width,
                height: info.sizeConstraint.height,
                layoutDirection: info.direction,
                sizing: self.model.sizing
            )
            
            if let size = self.cachedSizes[key] {
                return size
            } else {
                SignpostLogger.log(.begin, log: .updateContent, name: "Measure ItemContent", for: self.model)
                
                let size : CGSize = cache.use(
                    with: self.model.reuseIdentifier,
                    create: {
                        return ItemCell<Content>()
                }, { cell in
                    let itemState = ListableUI.ItemState(isSelected: false, isHighlighted: false)
                    
                    self.applyTo(
                        cell: cell,
                        itemState: itemState,
                        reason: .willDisplay,
                        environment: environment
                    )
                    
                    return self.model.sizing.measure(with: cell, info: info)
                })
                
                self.cachedSizes[key] = size
                
                SignpostLogger.log(.end, log: .updateContent, name: "Measure ItemContent", for: self.model)
                
                return size
            }
        }
        
        func moved(with result : Reordering.Result)
        {
            self.model.reordering?.didReorder(result)
        }
    }
}


extension PresentationState.ItemState
{
    final class Storage {
        
        var didSetState : (State, State) -> () = { _, _ in }
        
        var model : Item<Content> {
            willSet {
                guard self.model.identifier == newValue.identifier else {
                    fatalError("Cannot change the identifier of an item while updating it. Changed from '\(self.model.identifier)' to '\(newValue.identifier)'.")
                }
            }
        }
        
        var state : State {
            didSet {
                guard oldValue != self.state else {
                    return
                }
                
                self.didSetState(oldValue, self.state)
            }
        }
        
        init(_ model : Item<Content>)
        {
            self.model = model
            
            self.state = State(isSelected: self.model.selectionStyle.isSelected, visibleCell: nil)
        }
    }
    
    internal struct State : Equatable
    {
        var isSelected : Bool
        var visibleCell : ItemCell<Content>?
    }
}
