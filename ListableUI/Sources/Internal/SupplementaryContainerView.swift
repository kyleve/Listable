//
//  SupplementaryContainerView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 9/30/19.
//

import UIKit


/**
 The supplementary view provided to the UICollectionView, which is used
 to contain every actual header and footer view within the list.
 
 Regardless of if a section has a header or footer provided by the developer,
 we always return a supplementary view – if there's no header or footer, it has
 zero height.
 
 Why this extra layer of indirection?
 --------------------------------------
 Within collection views, supplementary views (how you model headers, footers)
 are attached to individual index paths. So, Listable models headers and footers
 as attached to (0,0) for list headers and footers, and (sectionIndex, 0)
 for section headers and footers. All good so far.

 The problem arises when you want to swap out a header or footer without
 changing the row at the (x, 0) index path. The collection view does not
 know to re-query for those associated headers, because we didn't actually
 reload or change that (x, 0) item.
 
 Thus, we always provide this container supplementary view – and swap the content
 of the header or footer in or out as needed as it changes. As mentioned above,
 if there is no actual header or footer to show, the view has zero height.
 */
final class SupplementaryContainerView : UICollectionReusableView
{
    //
    // MARK: Registering & Dequeuing Cells
    //
    
    static let reuseIdentifier = "Listable.SupplementaryContainerView"
    
    static func register(in collectionView: UICollectionView, for kind : String)
    {
        collectionView.register(
            SupplementaryContainerView.self,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: SupplementaryContainerView.reuseIdentifier
        )
    }
    
    static func dequeue(
        in collectionView: UICollectionView,
        for kind : String,
        at indexPath : IndexPath,
        reuseCache : ReusableViewCache
    ) -> SupplementaryContainerView
    {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SupplementaryContainerView.reuseIdentifier,
            for: indexPath
        ) as! SupplementaryContainerView
        
        view.reuseCache = reuseCache
        
        return view
    }
    
    //
    // MARK: Content
    //
    
    var headerFooter : AnyPresentationHeaderFooterState? {
        didSet {
            guard oldValue !== self.headerFooter else {
                return
            }
            
            let cache = self.reuseCache!
            
            if let old = oldValue, let content = self.content {
                old.enqueueReusableHeaderFooterView(content, in: cache)
            }
            
            if let headerFooter = self.headerFooter {
                self.content = headerFooter.dequeueAndPrepareReusableHeaderFooterView(in: cache, frame: self.bounds)
            } else {
                self.content = nil
            }
        }
    }
    
    var reuseCache : ReusableViewCache?
    
    private(set) var content : UIView? {
        didSet {
            if let old = oldValue {
                old.removeFromSuperview()
            }
            
            if let new = self.content {
                self.addSubview(new)
            }
            
            self.setNeedsLayout()
        }
    }
    
    //
    // MARK: Initialization
    //
        
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.layer.masksToBounds = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { listableFatal() }
    
    // MARK: UICollectionReusableView
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes
    {
        // Note – Please keep this comment in sync with the comment in ItemCell.
        
        /**
         Listable already properly sizes each cell. We do not use self-sizing cells.
         Thus, just return the existing layout attributes.
         
         This avoids an expensive call to sizeThatFits to "re-size" the cell to the same size
         during each of UICollectionView's layout passes:
         
         #0  ItemElementCell.sizeThatFits(_:)
         #1  @objc ItemElementCell.sizeThatFits(_:) ()
         #2  -[UICollectionViewCell systemLayoutSizeFittingSize:withHorizontalFittingPriority:verticalFittingPriority:] ()
         #3  -[UICollectionReusableView preferredLayoutAttributesFittingAttributes:] ()
         #4  -[UICollectionReusableView _preferredLayoutAttributesFittingAttributes:] ()
         #5  -[UICollectionView _checkForPreferredAttributesInView:originalAttributes:] ()
         #6  -[UICollectionView _updateVisibleCellsNow:] ()
         #7  -[UICollectionView layoutSubviews] ()
         
         Returning the passed in value without calling super is OK, per the docs:
         https://developer.apple.com/documentation/uikit/uicollectionreusableview/1620132-preferredlayoutattributesfitting
         
           | The default implementation of this method adjusts the size values to accommodate changes made by a self-sizing cell.
           | Subclasses can override this method and use it to adjust other layout attributes too.
           | If you override this method and want the cell size adjustments, call super first and make your own modifications to the returned attributes.
         
         Important part being "If you override this method **and want the cell size adjustments**, call super first".
         
         We do not want these. Thus, this is fine.
         */
        
        return layoutAttributes
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        self.headerFooter = nil
    }
    
    //
    // MARK: UIView
    //
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        guard let content = self.content else {
            return .zero
        }
        
        return content.sizeThatFits(size)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        
        guard let content = self.content else {
            return .zero
        }
        
        return content.systemLayoutSizeFitting(targetSize)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        
        guard let content = self.content else {
            return .zero
        }
        
        return content.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if let content = self.content {
            content.frame = self.bounds
        }
    }
}
