//
//  CollectionViewLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 9/23/19.
//

import UIKit


final class CollectionViewLayout : UICollectionViewLayout
{
    //
    // MARK: Properties
    //
    
    unowned let delegate : CollectionViewLayoutDelegate
    
    let layoutType : ListLayoutType
    
    var appearance : Appearance {
        didSet {
            guard oldValue != self.appearance else {
                return
            }
            
            self.applyAppearance()
        }
    }
    
    private func applyAppearance()
    {
        guard self.collectionView != nil else {
            return
        }
        
        self.neededLayoutType.merge(with: .rebuild)
        self.invalidateLayout()
    }
    
    var behavior : Behavior {
        didSet {
            guard oldValue != self.behavior else {
                return
            }
            
            self.applyBehavior()
        }
    }
    
    private func applyBehavior()
    {
        guard self.collectionView != nil else {
            return
        }
        
        self.neededLayoutType.merge(with: .rebuild)
        self.invalidateLayout()
    }
    
    //
    // MARK: Initialization
    //
    
    init(
        delegate : CollectionViewLayoutDelegate,
        layoutType : ListLayoutType,
        appearance : Appearance,
        behavior : Behavior
    )
    {
        self.delegate = delegate
        
        self.layoutType = layoutType
        
        self.appearance = appearance
        self.behavior = behavior
        
        self.layout = self.layoutType.layoutType.init()
        self.previousLayout = self.layout
        
        self.changesDuringCurrentUpdate = UpdateItems(with: [])
        
        self.viewProperties = CollectionViewLayoutProperties()
        
        super.init()
        
        self.applyAppearance()
        self.applyBehavior()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { listableFatal() }
    
    //
    // MARK: Querying The Layout
    //
    
    func positionForItem(at indexPath : IndexPath) -> ItemPosition
    {
        let item = self.layout.content.item(at: indexPath)
        
        return item.position
    }
    
    //
    // MARK: Private Properties
    //
    
    private var layout : ListLayout
    private var previousLayout : ListLayout
    
    private var changesDuringCurrentUpdate : UpdateItems
    
    private var viewProperties : CollectionViewLayoutProperties
    
    //
    // MARK: Invalidation & Invalidation Contexts
    //
    
    private(set) var shouldAskForItemSizesDuringLayoutInvalidation : Bool = false
    
    func setShouldAskForItemSizesDuringLayoutInvalidation()
    {
        self.shouldAskForItemSizesDuringLayoutInvalidation = true
    }
    
    override class var invalidationContextClass: AnyClass {
        return InvalidationContext.self
    }
    
    override func invalidateLayout()
    {
        super.invalidateLayout()
        
        if self.shouldAskForItemSizesDuringLayoutInvalidation {
            self.neededLayoutType = .rebuild
            self.shouldAskForItemSizesDuringLayoutInvalidation = false
        }
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext)
    {
        let view = self.collectionView!
        let context = context as! InvalidationContext
        
        super.invalidateLayout(with: context)
        
        // Handle Moved Items
        
        if
            let from = context.previousIndexPathsForInteractivelyMovingItems,
            let to = context.targetIndexPathsForInteractivelyMovingItems
        {
            let from = from[0]
            let to = to[0]
            
            let item = self.layout.content.item(at: from)
            item.liveIndexPath = to
                    
            self.layout.content.move(from: from, to: to)
            
            if from != to {
                context.performedInteractiveMove = true
                self.layout.content.reindexLiveIndexPaths()
            }
        }
        
        // Handle View Width Changing
        
        context.viewPropertiesChanged = self.viewProperties != CollectionViewLayoutProperties(collectionView: view)
        
        // Update Needed Layout Type
                
        self.neededLayoutType.merge(with: context)
    }
    
    override func invalidationContextForEndingInteractiveMovementOfItems(
        toFinalIndexPaths indexPaths: [IndexPath],
        previousIndexPaths: [IndexPath],
        movementCancelled: Bool
    ) -> UICollectionViewLayoutInvalidationContext
    {
        listablePrecondition(movementCancelled == false, "Cancelling moves is currently not supported.")
        
        self.layout.content.reindexLiveIndexPaths()
        self.layout.content.reindexDelegateProvidedIndexPaths()
                                
        return super.invalidationContextForEndingInteractiveMovementOfItems(
            toFinalIndexPaths: indexPaths,
            previousIndexPaths: previousIndexPaths,
            movementCancelled: movementCancelled
        )
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        return true
    }
    
    private final class InvalidationContext : UICollectionViewLayoutInvalidationContext
    {
        var viewPropertiesChanged : Bool = false
        
        var performedInteractiveMove : Bool = false
    }
    
    //
    // MARK: Preparing For Layouts
    //
    
    private enum NeededLayoutType {
        case none
        case relayout
        case rebuild
        
        mutating func merge(with context : UICollectionViewLayoutInvalidationContext)
        {
            let context = context as! InvalidationContext
            
            let requeryDataSourceCounts = context.invalidateEverything || context.invalidateDataSourceCounts
            let needsRelayout = context.viewPropertiesChanged || context.performedInteractiveMove
            
            if requeryDataSourceCounts {
                self.merge(with: .rebuild)
            } else if needsRelayout {
                self.merge(with: .relayout)
            }
        }
        
        mutating func merge(with new : NeededLayoutType)
        {
            if new.priority > self.priority {
                self = new
            }
        }
        
        private var priority : Int {
            switch self {
            case .none: return 0
            case .relayout: return 1
            case .rebuild: return 2
            }
        }
        
        mutating func update(with success : Bool)
        {
            if success {
                self = .none
            }
        }
    }
    
    private var neededLayoutType : NeededLayoutType = .rebuild
        
    override func prepare()
    {
        super.prepare()

        self.changesDuringCurrentUpdate = UpdateItems(with: [])
        
        self.neededLayoutType.update(with: {
            switch self.neededLayoutType {
            case .none: return true
            case .relayout: return self.performRelayout()
            case .rebuild: return self.performRebuild()
            }
        }())
        
        self.layout.updateLayout(in: self.collectionView!)
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem])
    {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        self.changesDuringCurrentUpdate = UpdateItems(with: updateItems)
    }
    
    //
    // MARK: Finishing Layouts
    //
    
    override func finalizeCollectionViewUpdates()
    {
        super.finalizeCollectionViewUpdates()
        
        self.changesDuringCurrentUpdate = UpdateItems(with: [])
    }
    
    //
    // MARK: Performing Layouts
    //
    
    private func performRelayout() -> Bool
    {
        let view = self.collectionView!
        
        self.delegate.listViewLayoutUpdatedItemPositions(view)
        
        let didLayout = self.layout.layout(
            delegate: self.delegate,
            in: view
        )
        
        if didLayout {
            self.layout.content.setSectionContentsFrames()
            
            let viewHeight = self.appearance.direction.height(for: view.bounds.size)
        
            self.layout.adjustPositionsForLayoutUnderflow(contentHeight: self.layout.contentSize.height, viewHeight: viewHeight, in: view)
        
            self.layout.updateLayout(in: view)
            
            self.viewProperties = CollectionViewLayoutProperties(collectionView: view)
        }
                
        return didLayout
    }
    
    private func performRebuild() -> Bool
    {
        self.previousLayout = self.layout
        
        self.layout = self.layoutType.layoutType.init(
            delegate: self.delegate,
            appearance: self.appearance,
            behavior: self.behavior,
            in: self.collectionView!
        )
        
        return self.performRelayout()
    }
    
    //
    // MARK: UICollectionViewLayout Methods
    //
    
    override var collectionViewContentSize : CGSize
    {
        return self.layout.contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        return self.layout.content.layoutAttributes(in: rect)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return self.layout.content.layoutAttributes(at: indexPath)
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return self.layout.content.supplementaryLayoutAttributes(of: elementKind, at: indexPath)
    }
    
    //
    // MARK: UICollectionViewLayout Methods: Insertions & Removals
    //

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasInserted = self.changesDuringCurrentUpdate.insertedItems.contains(.init(newIndexPath: itemIndexPath))

        if wasInserted {
            let attributes = self.layout.content.layoutAttributes(at: itemIndexPath)
            
            attributes.frame.origin.y -= attributes.frame.size.height
            attributes.alpha = 0.0

            return attributes
        } else {
            let wasSectionInserted = self.changesDuringCurrentUpdate.insertedSections.contains(.init(newIndex: itemIndexPath.section))
            
            let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
            
            if wasSectionInserted == false {
                attributes?.alpha = 1.0
            }
            
            return attributes
        }
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasItemDeleted = self.changesDuringCurrentUpdate.deletedItems.contains(.init(oldIndexPath: itemIndexPath))
        
        if wasItemDeleted {
            let attributes = self.previousLayout.content.layoutAttributes(at: itemIndexPath)

            attributes.frame.origin.y -= attributes.frame.size.height
            attributes.alpha = 0.0

            return attributes
        } else {
            let wasSectionDeleted = self.changesDuringCurrentUpdate.deletedSections.contains(.init(oldIndex: itemIndexPath.section))
            
            let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
            
            if wasSectionDeleted == false {
                attributes?.alpha = 1.0
            }
            
            return attributes
        }
    }
    
    override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasInserted = self.changesDuringCurrentUpdate.insertedSections.contains(.init(newIndex: elementIndexPath.section))
        let attributes = super.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)
        
        if wasInserted == false {
            attributes?.alpha = 1.0
        }
        
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasDeleted = self.changesDuringCurrentUpdate.deletedSections.contains(.init(oldIndex: elementIndexPath.section))
        let attributes = super.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)
        
        if wasDeleted == false {
            attributes?.alpha = 1.0
        }
        
        return attributes
    }
    
    //
    // MARK: UICollectionViewLayout Methods: Moving Items
    //
    
    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes
    {
        let defaultAttributes = self.layout.content.layoutAttributes(at: indexPath)
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        
        attributes.center.x = defaultAttributes.center.x
        
        return attributes
    }
}


//
// MARK: Layout Extensions
//


internal extension UIView
{
    var lst_safeAreaInsets : UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
}


//
// MARK: Invalidation Helpers
//


struct CollectionViewLayoutProperties : Equatable
 {
     let size : CGSize
     let safeAreaInsets : UIEdgeInsets
     let contentInset : UIEdgeInsets

     init()
     {
         self.size = .zero
         self.safeAreaInsets = .zero
         self.contentInset = .zero
     }

     init(collectionView : UICollectionView)
     {
         self.size = collectionView.bounds.size
         self.safeAreaInsets = collectionView.lst_safeAreaInsets
         self.contentInset = collectionView.contentInset
     }
 }


//
// MARK: Delegate For Layout Information
//


public protocol CollectionViewLayoutDelegate : AnyObject
{
    func listViewLayoutUpdatedItemPositions(_ collectionView : UICollectionView)
    
    func sizeForItem(at indexPath : IndexPath, in collectionView : UICollectionView, measuredIn sizeConstraint : CGSize, defaultSize : CGSize, layoutDirection : LayoutDirection) -> CGSize
    func layoutForItem(at indexPath : IndexPath, in collectionView : UICollectionView) -> ItemLayout
    
    func hasListHeader(in collectionView : UICollectionView) -> Bool
    func sizeForListHeader(in collectionView : UICollectionView, measuredIn sizeConstraint : CGSize, defaultSize : CGSize, layoutDirection : LayoutDirection) -> CGSize
    func layoutForListHeader(in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func hasListFooter(in collectionView : UICollectionView) -> Bool
    func sizeForListFooter(in collectionView : UICollectionView, measuredIn sizeConstraint : CGSize, defaultSize : CGSize, layoutDirection : LayoutDirection) -> CGSize
    func layoutForListFooter(in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func hasOverscrollFooter(in collectionView : UICollectionView) -> Bool
    func sizeForOverscrollFooter(in collectionView : UICollectionView, measuredIn sizeConstraint : CGSize, defaultSize : CGSize, layoutDirection : LayoutDirection) -> CGSize
    func layoutForOverscrollFooter(in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func layoutFor(section sectionIndex : Int, in collectionView : UICollectionView) -> Section.Layout
    
    func hasHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
    func sizeForHeader(in sectionIndex : Int, in collectionView : UICollectionView, measuredIn sizeConstraint : CGSize, defaultSize : CGSize, layoutDirection : LayoutDirection) -> CGSize
    func layoutForHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func hasFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
    func sizeForFooter(in sectionIndex : Int, in collectionView : UICollectionView, measuredIn sizeConstraint : CGSize, defaultSize : CGSize, layoutDirection : LayoutDirection) -> CGSize
    func layoutForFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func columnLayout(for sectionIndex : Int, in collectionView : UICollectionView) -> Section.Columns
}


//
// MARK: Update Information From Collection View Layout
//

fileprivate struct UpdateItems : Equatable
{
    let insertedSections : Set<InsertSection>
    let deletedSections : Set<DeleteSection>
    
    let insertedItems : Set<InsertItem>
    let deletedItems : Set<DeleteItem>
    
    init(with updateItems : [UICollectionViewUpdateItem])
    {
       var insertedSections = Set<InsertSection>()
       var deletedSections = Set<DeleteSection>()

       var insertedItems = Set<InsertItem>()
       var deletedItems = Set<DeleteItem>()

       for item in updateItems {
            switch item.updateAction {
            case .insert:
                let indexPath = item.indexPathAfterUpdate!
                
                if indexPath.item == NSNotFound {
                    insertedSections.insert(.init(newIndex: indexPath.section))
                } else {
                    insertedItems.insert(.init(newIndexPath: indexPath))
                }
                
            case .delete:
                let indexPath = item.indexPathBeforeUpdate!
                
                if indexPath.item == NSNotFound {
                    deletedSections.insert(.init(oldIndex: indexPath.section))
                } else {
                    deletedItems.insert(.init(oldIndexPath: indexPath))
                }
                
            case .move: break
            case .reload: break
            case .none: break
                
            @unknown default: listableFatal()
            }
        }
        
        self.insertedSections = insertedSections
        self.deletedSections = deletedSections
        
        self.insertedItems = insertedItems
        self.deletedItems = deletedItems
    }
    
    struct InsertSection : Hashable
    {
        var newIndex : Int
    }
    
    struct DeleteSection : Hashable
    {
        var oldIndex : Int
    }
    
    struct InsertItem : Hashable
    {
        var newIndexPath : IndexPath
    }
    
    struct DeleteItem : Hashable
    {
        var oldIndexPath : IndexPath
    }
}
