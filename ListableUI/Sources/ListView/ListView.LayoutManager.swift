//
//  ListView.LayoutManager.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/3/20.
//

import Foundation
import UIKit


extension ListView
{
    final class LayoutManager
    {
        unowned let collectionView : UICollectionView
                
        private(set) var collectionViewLayout : CollectionViewLayout
        
        init(layout collectionViewLayout : CollectionViewLayout, collectionView : UICollectionView)
        {
            self.collectionViewLayout = collectionViewLayout
            self.collectionView = collectionView
        }
        
        func set(layout : LayoutDescription, animated : Bool, completion : @escaping () -> ())
        {
            if self.collectionViewLayout.layoutDescription.configuration.isSameLayoutType(as: layout.configuration) {
                self.collectionViewLayout.layoutDescription = layout
                
                let shouldRebuild = self.collectionViewLayout.layoutDescription.configuration.shouldRebuild(layout: self.collectionViewLayout.layout)
                
                if shouldRebuild {
                    /// TODO: We shouldn't need to rebuild in any case here; just push the new values through to the ListLayout.
                    self.collectionViewLayout.setNeedsRebuild()
                }
            } else {
                self.collectionViewLayout = CollectionViewLayout(
                    delegate: self.collectionViewLayout.delegate,
                    layoutDescription: layout,
                    appearance: self.collectionViewLayout.appearance,
                    behavior: self.collectionViewLayout.behavior
                )
                
                self.collectionView.setCollectionViewLayout(self.collectionViewLayout, animated: animated) { _ in
                    completion()
                }
            }
        }
    }
}
