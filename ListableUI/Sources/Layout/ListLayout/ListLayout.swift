//
//  ListLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation


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
            let sectionMaxY = direction.maxY(for: section.contentsFrame)
            
            let header = section.header
            
            if direction.y(for: header.defaultFrame.origin) < direction.y(for: visibleContentFrame.origin) {
                
                // Make sure the pinned origin stays within the section's frame.
                switch direction {
                case .vertical:
                    header.pinnedY = min(visibleContentFrame.origin.y, sectionMaxY - header.size.height)
                    
                case .horizontal:
                    header.pinnedX = min(visibleContentFrame.origin.x, sectionMaxY - header.size.width)
                }
            } else {
                header.pinnedY = nil
                header.pinnedX = nil
            }
        }
    }
    
    func updateOverscrollFooterPosition(in collectionView : UICollectionView)
    {
        let footer = self.content.overscrollFooter
                
        let contentHeight = direction.height(for: self.content.contentSize)
        let viewHeight = direction.height(for: collectionView.contentFrame.size)
        
        // Overscroll positioning is done after we've sized the layout, because the overscroll footer does not actually
        // affect any form of layout or sizing. It appears only once the scroll view has been scrolled outside of its normal bounds.
        
        footer.set(for: direction, vertical: \.y, horizontal: \.x) {
            if contentHeight >= viewHeight {
                return contentHeight + direction.bottom(with: collectionView.contentInset) + direction.bottom(with: collectionView.safeAreaInsets)
            } else {
                return viewHeight - direction.top(with: collectionView.contentInset) - direction.top(with: collectionView.safeAreaInsets)
            }
        }
    }
    
    func adjustPositionsForLayoutUnderflow(in collectionView : UICollectionView)
    {
        // Take into account the safe area, since that pushes content alignment down within our view.
        
        let safeAreaInsets : CGFloat = self.direction.switch(
            vertical: collectionView.safeAreaInsets.top + collectionView.safeAreaInsets.bottom,
            horizontal: collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right
        )
        
        let contentHeight = direction.height(for: self.content.contentSize)
        let viewHeight = direction.height(for: collectionView.bounds.size)
        
        let additionalOffset = self.behavior.underflow.alignment.offsetFor(
            contentHeight: contentHeight,
            viewHeight: viewHeight - safeAreaInsets
        )
        
        // If we're pinned to the top of the view, there's no adjustment needed.
        
        guard additionalOffset > 0.0 else {
            return
        }
        
        // Provide additional adjustment.
        
        self.content.header.set(for: direction, vertical: \.y, horizontal: \.x, value: additionalOffset)
        self.content.footer.set(for: direction, vertical: \.y, horizontal: \.x, value: additionalOffset)
        
        for section in self.content.sections {
            
            section.header.set(for: direction, vertical: \.y, horizontal: \.x, value: additionalOffset)
            section.footer.set(for: direction, vertical: \.y, horizontal: \.x, value: additionalOffset)
            
            for item in section.items {
                item.set(for: direction, vertical: \.y, horizontal: \.x) { additionalOffset }
            }
        }
    }
}
