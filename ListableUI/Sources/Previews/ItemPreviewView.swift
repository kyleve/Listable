//
//  ItemPreviewView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/8/20.
//

import UIKit


///
/// A view you can use to test the various possible states that your `ItemContent` can be in.
///
/// This view is usually used alongside snapshot tests, to capture your `ItemContent` in
/// its selected or highlighted, or to see how it reacts to different sizing configuration.
///
/// If you'd like to use this view alongside Xcode previews, see `ItemPreview`.
///
/// Note
/// ----
/// This view sizes itself to fit the provided `Item` when you call its `view.update(..)` method.
/// You do not need to call `layoutIfNeeded()` or `sizeToFit()`, etc, to properly size
/// and lay out the view.
///
public final class ItemPreviewView : UIView {
      
    /// The list used to render the content.
    private let listView : ListView
    
    //
    // MARK: Initialization
    //
    
    /// Creates a preview for the given width.
    public init()
    {
        self.listView = ListView()
        
        super.init(frame: .zero)
        
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        self.addSubview(self.listView)
    }
    
    /// Creates a preview for the given item and parameters, and then lays out the preview view.
    public convenience init(
        with width : CGFloat = UIScreen.main.bounds.width,
        state : ItemState = .init(isSelected: false, isHighlighted: false),
        appearance : ItemPreviewAppearance = .init(),
        item : AnyItem
    ) {
        self.init()
        
        self.update(with: width, state: state, appearance: appearance, item: item)
    }
    
    //
    // MARK: Setting Content
    //
    
    /// Updates the item for the given parameters.
    /// This method changes the view's size; you dont need to resize the view after setting an item.
    public func update(
        with width : CGFloat = UIScreen.main.bounds.width,
        state : ItemState = .init(isSelected: false, isHighlighted: false),
        appearance : ItemPreviewAppearance = .init(),
        item : AnyItem
    ) {
        listablePrecondition(width > 0, "Must provide a non-zero width.")
        
        /// Lists do not layout and size if their frame is empty.
        /// Start with a placeholder size to allow layout.
        self.frame.size.width = width
        self.frame.size.height = 100.0
        self.layoutIfNeeded()
        
        self.listView.configure { list in
            appearance.configure(list: &list)
            
            list += Section("section") { section in
                section += item
            }
        }
        
        /// Force the list to layout so by the time this function returns,
        /// the preview is sized and laid out.
        self.listView.collectionView.layoutIfNeeded()
        
        self.frame.size.height = self.listView.contentSize.height
        self.layoutIfNeeded()
        
        /// Update the cell for the preview.
        
        let indexPath = IndexPath(item: 0, section: 0)
        
        guard let cell = self.listView.collectionView.cellForItem(at: indexPath) else {
            listableFatal("Internal Error: Could not find index path for 'ItemPreviewView's content.")
        }
        
        let presentationState = self.listView.storage.presentationState.item(at: indexPath)
        
        cell.isHighlighted = state.isHighlighted
        cell.isSelected = state.isSelected
        
        presentationState.applyTo(
            cell: cell,
            itemState: state,
            direction: .vertical, // TODO: Pass me in
            reason: .willDisplay
        )
    }
    
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }
    
    //
    // MARK: UIView
    //
    
    public override func layoutSubviews() {
        super.layoutSubviews()
                
        self.listView.frame = self.bounds
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        self.listView.contentSize
    }
    
    public override var intrinsicContentSize: CGSize {
        self.listView.contentSize
    }
}
