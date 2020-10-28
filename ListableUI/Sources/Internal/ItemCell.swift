//
//  ItemCell.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 9/22/19.
//

import UIKit


///
/// An internal cell type used to render items in the list.
///
/// Information on how cell selection appearance customization works:
/// https://developer.apple.com/documentation/uikit/uicollectionviewdelegate/changing_the_appearance_of_selected_and_highlighted_cells
///
final class ItemCell<Content:ItemContent> : UICollectionViewCell
{
    let contentContainer : ContentContainerView

    let background : Content.BackgroundView
    let selectedBackground : Content.SelectedBackgroundView

    override init(frame: CGRect)
    {
        let bounds = CGRect(origin: .zero, size: frame.size)
        
        self.contentContainer = ContentContainerView(frame: bounds)
        
        self.background = Content.createReusableBackgroundView(frame: bounds)
        self.selectedBackground = Content.createReusableSelectedBackgroundView(frame: bounds)
        
        super.init(frame: frame)
                
        self.backgroundView = self.background
        self.selectedBackgroundView = self.selectedBackground
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.layer.masksToBounds = false
        self.contentView.layer.masksToBounds = false

        self.contentView.addSubview(self.contentContainer)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { listableFatal() }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes
    {
        // Note – Please keep this comment in sync with the comment in SupplementaryContainerView.
        
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
    
    // MARK: UIView
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        self.contentContainer.contentView.sizeThatFits(size)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        self.contentContainer.contentView.systemLayoutSizeFitting(targetSize)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        self.contentContainer.contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }

    override func layoutSubviews()
    {
        super.layoutSubviews()
                
        self.contentContainer.frame = self.contentView.bounds
    }
}

