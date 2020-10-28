//
//  ListSizing.swift
//  Listable
//
//  Created by Kyle Van Essen on 9/21/20.
//

import UIKit

///
/// Provides the possible options for how to size and measure a list when its measured size is queried
/// by the layout system.
///
/// You have two options: `.fillParent` and `.measureContent`.
///
/// When using  `.fillParent`, the full available fitting size will be taken up, regardless
/// of the size of the content itself.
///
/// When using `.measureContent`, the content will be measured within the provided fitting size
/// and the smallest of the two sizes will be returned.
/// ```
/// .fillParent:
/// ┌───────────┐
/// │┌─────────┐│
/// ││         ││
/// ││         ││
/// ││         ││
/// ││         ││
/// ││         ││
/// │└─────────┘│
/// └───────────┘
///
/// .measureContent
/// ┌───────────┐
/// │           │
/// │           │
/// │┌─────────┐│
/// ││         ││
/// ││         ││
/// ││         ││
/// │└─────────┘│
/// └───────────┘
/// ```
public enum ListSizing : Equatable
{
    /// When using  `.fillParent`, the full available space will be taken up, regardless
    /// of the content size of the list itself.
    ///
    /// Eg, if the fitting size passed to the list is (200w, 1000h), and the list's content
    /// is only (200w, 500h), (200w, 1000h) will still be returned.
    ///
    /// This is the setting you want to use when your list is being used to fill the content
    /// of a screen, such as if it is being presented in a navigation controller or tab bar controller.
    ///
    /// This option is the most performant, because no content measurement has to occur.
    case fillParent
    
    /// When using `.measureContent`, the content will be measured within the provided fitting size
    /// and the smallest of the two sizes will be returned.
    ///
    /// If you are putting a list into a sheet or popover, this is generally the `Sizing` type
    /// you will want to use, to ensure the sheet or popover takes up the minimum amount of space possible.
    case measureContent
}


extension ListView
{
    //
    // MARK: Measuring Lists
    //
        
    public static func contentSize(in fittingSize : CGSize, for properties : ListProperties.Build) -> CGSize {
        self.contentSize(in: fittingSize, for: .default(with: properties))
    }
    
    private static let measurementView : ListView = {
        let view = ListView()
        view.performsContentCallbacks = false
        return view
    }()
    
    public static func contentSize(in fittingSize : CGSize, for properties : ListProperties) -> CGSize {
        
        let view = Self.measurementView
                
        /// Push the updated content into the list.
        
        view.configure(with: properties)
                
        /// Set the size of the view to the fitting size, since the width or height
        /// will be used by the underlying layout to measure the required contentSize.
        ///
        /// We switch on the `direction` from the layout to provide the correct width or height.
        /// for the layout. Only the cross-axis of the direction – width for vertical, and height for
        /// horizontal.
        
        view.frame.size = view.collectionViewLayout.layout.direction.switch(
            vertical: CGSize(width: fittingSize.width, height: 100.0),
            horizontal: CGSize(width: 100.0, height: fittingSize.height)
        )
        
        let size = view.contentSize
        
        /// Now that we have the the measured contentSize,
        /// push empty content back into the list, so that no
        /// callback closures, etc, which may have been assigned
        /// by the developer, are retained for longer than expected.
        
        view.configure(with: .default())
        view.frame = .zero
        
        return CGSize(
            width: fittingSize.width > 0 ? min(fittingSize.width, size.width) : size.width,
            height: fittingSize.height > 0 ? min(fittingSize.height, size.height) : size.height
        )
    }
}
