//
//  ApplyReason.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//


/// Why the `Item` or `HeaderFooter` is being asked to apply an update to its presented views.
public enum ApplyReason : Hashable
{
    /// The view is about to be displayed on screen. Update should be performed with no animation.
    case willDisplay
    
    /// A view that is already visible is being updated.
    /// If your updates can contain animated transitions, you should animate this update.
    case wasUpdated
    
    /// The item is being measured to perform the layout of the list. Update should be performed with no animation.
    case measurement
    
    /// If you should use animations while applying the update.
    /// Check this boolean in your `apply` method to avoid
    /// having to `switch` over the value of `ApplyReason`.
    public var shouldAnimate : Bool {
        switch self {
        case .willDisplay: return false
        case .wasUpdated: return true
        case .measurement: return false
        }
    }
}

