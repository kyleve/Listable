//
//  ListLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation
import UIKit

public protocol ListLayout : AnyListLayout
{
    associatedtype LayoutAppearance:ListLayoutAppearance
    
    static var defaults : ListLayoutDefaults { get }
    
    var layoutAppearance : LayoutAppearance { get }
            
    init(
        layoutAppearance : LayoutAppearance,
        appearance : Appearance,
        behavior : Behavior,
        content : ListLayoutContent
    )
}


public extension ListLayout
{
    var direction: LayoutDirection {
        self.layoutAppearance.direction
    }
    
    var stickySectionHeaders: Bool {
        self.layoutAppearance.stickySectionHeaders
    }
}


public protocol AnyListLayout : AnyObject
{
    //
    // MARK: Public Properties
    //
    
    var appearance : Appearance { get }
    var behavior : Behavior { get }
    
    var content : ListLayoutContent { get }
            
    var scrollViewProperties : ListLayoutScrollViewProperties { get }
    
    var direction : LayoutDirection { get }
    
    var stickySectionHeaders : Bool { get }
    
    //
    // MARK: Performing Layouts
    //
    
    func updateLayout(in collectionView : UICollectionView)
    
    func layout(
        delegate : CollectionViewLayoutDelegate,
        in collectionView : UICollectionView
    )
    
    func setZIndexes()
}


public extension AnyListLayout
{
    func setZIndexes()
    {
        self.content.header.zIndex = 5
        
        self.content.sections.forEachWithIndex { sectionIndex, _, section in
            section.header.zIndex = 4
            
            section.items.forEach { item in
                item.zIndex = 3
            }
            
            section.footer.zIndex = 2
        }
        
        self.content.footer.zIndex = 1
        self.content.overscrollFooter.zIndex = 0
    }
}


public extension AnyListLayout
{
    func visibleContentFrame(for collectionView : UICollectionView) -> CGRect
    {
        CGRect(
            x: collectionView.contentOffset.x + collectionView.safeAreaInsets.left,
            y: collectionView.contentOffset.y + collectionView.safeAreaInsets.top,
            width: collectionView.bounds.size.width,
            height: collectionView.bounds.size.height
        )
    }
}


public extension AnyListLayout
{
    func positionStickySectionHeadersIfNeeded(in collectionView : UICollectionView)
    {
        guard self.stickySectionHeaders else {
            return
        }
        
        let visibleContentFrame = self.visibleContentFrame(for: collectionView)
        
        self.content.sections.forEachWithIndex { sectionIndex, isLast, section in
            let sectionMaxY = section.contentsFrame.maxY
            
            let header = section.header
            
            if header.defaultFrame.origin.y < visibleContentFrame.origin.y {
                
                // Make sure the pinned origin stays within the section's frame.
                
                header.pinnedY = min(
                    visibleContentFrame.origin.y,
                    sectionMaxY - header.size.height
                )
            } else {
                header.pinnedY = nil
            }
        }
    }
    
    func updateOverscrollFooterPosition(in collectionView : UICollectionView)
    {
        guard self.direction == .vertical else {
            // Currently only supported for vertical layouts.
            return
        }
        
        let footer = self.content.overscrollFooter
                
        let contentHeight = self.content.contentSize.height
        let viewHeight = collectionView.contentFrame.size.height
        
        // Overscroll positioning is done after we've sized the layout, because the overscroll footer does not actually
        // affect any form of layout or sizing. It appears only once the scroll view has been scrolled outside of its normal bounds.
        
        if contentHeight >= viewHeight {
            footer.y = contentHeight + collectionView.contentInset.bottom + collectionView.safeAreaInsets.bottom
        } else {
            footer.y = viewHeight - collectionView.contentInset.top - collectionView.safeAreaInsets.top
        }
    }
    
    func adjustPositionsForLayoutUnderflow(in collectionView : UICollectionView)
    {
        guard self.direction == .vertical else {
            // Currently only supported for vertical layouts.
            return
        }
        
        // Take into account the safe area, since that pushes content alignment down within our view.
        
        let safeAreaInsets : CGFloat = {
            switch self.direction {
            case .vertical: return collectionView.safeAreaInsets.top + collectionView.safeAreaInsets.bottom
            case .horizontal: return collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right
            }
        }()
        
        let contentHeight = self.content.contentSize.height
        let viewHeight = collectionView.bounds.height
        
        let additionalOffset = self.behavior.underflow.alignment.offsetFor(
            contentHeight: contentHeight,
            viewHeight: viewHeight - safeAreaInsets
        )
        
        // If we're pinned to the top of the view, there's no adjustment needed.
        
        guard additionalOffset > 0.0 else {
            return
        }
        
        // Provide additional adjustment.
        
        for section in self.content.sections {
            section.header.y += additionalOffset
            section.footer.y += additionalOffset
            
            for item in section.items {
                item.y += additionalOffset
            }
        }
    }
}
