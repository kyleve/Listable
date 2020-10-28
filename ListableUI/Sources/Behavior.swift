//
//  Behavior.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/13/19.
//

import Foundation
import UIKit

/// Controls various behaviors of the list view, such as keyboard dismissal, selection mode, and behavior
/// when the list content underflows the available space in the list view.
public struct Behavior : Equatable
{
    /// How the keyboard should be dismissed (if at all) based on scrolling of the list view.
    public var keyboardDismissMode : UIScrollView.KeyboardDismissMode
    
    /// How to adjust the `contentInset` of the list when the keyboard visibility changes.
    public var keyboardAdjustmentMode : KeyboardAdjustmentMode
    
    /// How the list should react when the user taps the application status bar.
    /// The default value of this enables scrolling to top.
    public var scrollsToTop : ScrollsToTop
    
    /// How the list should respond to selection attempts.
    public var selectionMode : SelectionMode
        
    /// How the list should behave when its content takes up less space than is available in the list view.
    /// TODO: This should move to individual layout types.
    public var underflow : Underflow
    
    /// A Boolean value that controls whether touches in the content view always lead to tracking.
    public var canCancelContentTouches : Bool
    
    /// A Boolean value that determines whether the scroll view delays the handling of touch-down gestures.
    public var delaysContentTouches : Bool
    
    /// Is paging enabled on the underlying scroll view.
    public var isPagingEnabled : Bool
    
    /// Creates a new `Behavior` based on the provided parameters.
    public init(
        keyboardDismissMode : UIScrollView.KeyboardDismissMode = .interactive,
        keyboardAdjustmentMode : KeyboardAdjustmentMode = .adjustsWhenVisible,
        scrollsToTop : ScrollsToTop = .enabled,
        selectionMode : SelectionMode = .single(),
        underflow : Underflow = Underflow(),
        canCancelContentTouches : Bool = true,
        delaysContentTouches : Bool = true,
        isPagingEnabled : Bool = false
    ) {
        self.keyboardDismissMode = keyboardDismissMode
        self.keyboardAdjustmentMode = keyboardAdjustmentMode
        
        self.scrollsToTop = scrollsToTop
        
        self.selectionMode = selectionMode
        self.underflow = underflow
        
        self.canCancelContentTouches = canCancelContentTouches
        self.delaysContentTouches = delaysContentTouches
        self.isPagingEnabled = false
    }
}

public extension Behavior
{
    /// How to adjust the `contentInset` of the list when the keyboard visibility changes.
    enum KeyboardAdjustmentMode : Equatable
    {
        /// The `contentInset` of the list is not adjusted when the keyboard appears or disappears.
        case none
        
        /// The `contentInset` of the list is adjusted when the keyboard appears or disappears.
        case adjustsWhenVisible
    }
    
    /// How to react when the user taps on the status bar of the application.
    enum ScrollsToTop : Equatable
    {
        /// No action is performed when the user taps on the status bar.
        case disabled
        
        /// When the user taps on the status bar, scroll to the top of the list.
        case enabled
    }
    
    /// The selection mode of the list view, which controls how many items (if any) can be selected at once.
    enum SelectionMode : Equatable
    {
        /// The list view does not allow any selections.
        case none
        
        /// The list view allows single selections. When an item is selected, the previously selected item (if any)
        /// will be deselected by the list. If you provide multiple selected items in your content description,
        /// the last selected item in the content will be selected.
        ///
        /// The default value for `clearsSelectionOnViewWillAppear` is true.
        /// This parameter allows mirroring the `clearsSelectionOnViewWillAppear`
        /// as available from `UITableViewController` or `UICollectionViewController`.
        ///
        /// Note
        /// ----
        /// This behaviour is implemented in `ListViewController`.
        /// If your list is not managed by a `ListViewController`, this parameter has no effect unless
        /// you manually call `clearSelectionDuringViewWillAppear` on `ListView` within
        /// your view controller's `viewWillAppear`.
        case single(clearsSelectionOnViewWillAppear : Bool = true)
        
        /// The list view allows multiple selections. It is your responsibility to update the content
        /// of the list to select and deselect items based on the selection of other items.
        case multiple
    }
    
    struct Underflow : Equatable
    {
        public var alwaysBounce : Bool
        public var alignment : Alignment
        
        public init(alwaysBounce : Bool = true, alignment : Alignment = .top)
        {
            self.alwaysBounce = alwaysBounce
            self.alignment = alignment
        }
        
        public enum Alignment : Equatable
        {
            case top
            case center
            case bottom
            
            func offsetFor(contentHeight : CGFloat, viewHeight: CGFloat) -> CGFloat
            {
                guard contentHeight < viewHeight else {
                    return 0.0
                }
                
                switch self {
                case .top: return 0.0
                case .center: return round((viewHeight - contentHeight) / 2.0)
                case .bottom: return viewHeight - contentHeight
                }
            }
        }
    }
}
