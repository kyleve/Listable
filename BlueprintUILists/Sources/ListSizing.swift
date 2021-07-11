//
//  ListSizing.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 3/25/21.
//

import ListableUI


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
    
    /// When using `.measureContent`, the content of the list will be measured within the provided fitting size
    /// and the smallest of the two sizes will be returned.
    ///
    /// If you are putting a list into a sheet or popover (or even another list!), this is generally the `Sizing` type
    /// you will want to use, to ensure the sheet or popover takes up the minimum amount of space possible.
    ///
    /// - parameters:
    ///     - itemLimit: When measuring the list, how many items should be measured to determine the height. Defaults
    ///     to 50, which is usually enough to fill the `fittingSize`. If you truly want to determine the entire height of all of
    ///     the content in the list, set this to `nil` (but you should rarely need to do this). The lower this value, the less
    ///     overall measurement that has to occur (if the value is less than the number of items in the list), which improvements
    ///     measurement and layout performance.
    ///
    case measureContent(itemLimit : Int? = ListView.defaultContentSizeItemLimit)
}
