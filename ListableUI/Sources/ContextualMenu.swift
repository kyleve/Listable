//
//  ContextualMenu.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 2/7/21.
//

import Foundation


public struct ContextualMenu {
    
    public var isAvailable : Bool
    
    public var preview : () -> UIViewController?
    
    public var commit : () -> ()
    
    // TODO: Handle preview animations
    
    public init(
        isAvailable : Bool,
        preview : @escaping () -> UIViewController,
        commit : @escaping () -> ()
    ) {
        self.isAvailable = isAvailable
        self.preview = preview
        self.commit = commit
    }
    
    @available(iOS 13.0, *)
    func toUIContextMenuConfiguration() -> UIContextMenuConfiguration {
        
        guard self.isAvailable else {
            return .init()
        }
        
        return UIContextMenuConfiguration(
            identifier: nil, // TODO
            previewProvider: {
                self.preview()
            },
            actionProvider: { suggested in
               UIMenu()
            }
        )
    }
}

