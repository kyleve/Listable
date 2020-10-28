//
//  SwipeActions.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//

import Foundation
import UIKit


/// Use SwipeActionsConfiguration to configure an item with SwipeActions.
/// These are actions that are revealed when swiping on the cell.
public struct SwipeActionsConfiguration {

    /// The actions to display when the cell is swiped.
    public var actions : [SwipeAction]

    /// Whether the first action is performed automatically with a full swipe.
    public var performsFirstActionWithFullSwipe : Bool
    
    public init(action : SwipeAction, performsFirstActionWithFullSwipe : Bool = false) {
        self.init(actions: [action], performsFirstActionWithFullSwipe: performsFirstActionWithFullSwipe)
    }
    
    public init(actions : [SwipeAction], performsFirstActionWithFullSwipe : Bool = false) {
        self.actions = actions
        self.performsFirstActionWithFullSwipe = performsFirstActionWithFullSwipe
    }
}

/// Create SwipeActions to define actions that can be performed in a SwipeActionsConfiguration.
public struct SwipeAction {

    /// The completion handler to call after performing the swipe action.
    ///
    /// Pass in `true` to expand the actions (typically only used when deleting the row)
    /// or `false` to collapse them.
    public typealias CompletionHandler = (_ expandActions: Bool) -> Void

    /// The completion handler called when the action is tapped.
    public typealias Handler = (@escaping CompletionHandler) -> Void

    public var title: String?
    public var backgroundColor: UIColor?
    public var image: UIImage?

    public var handler: Handler
    
    public init(title: String, backgroundColor: UIColor, image: UIImage? = nil, handler: @escaping Handler) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.image = image
        self.handler = handler
    }
}
