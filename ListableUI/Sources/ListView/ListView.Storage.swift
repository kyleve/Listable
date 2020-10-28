//
//  ListView.Storage.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/19/19.
//

import UIKit


internal extension ListView
{
    final class Storage
    {
        var allContent : Content = Content()
        
        let presentationState : PresentationState = PresentationState()
        
        func moveItem(from : IndexPath, to : IndexPath)
        {
            self.allContent.moveItem(from: from, to: to)
            self.presentationState.moveItem(from: from, to: to)
        }
        
        func remove(item itemToRemove : AnyPresentationItemState) -> IndexPath?
        {
            if let indexPath = self.presentationState.remove(item: itemToRemove) {
                self.allContent.remove(at: indexPath)
                return indexPath
            } else {
                return nil
            }
        }
    }
}
