//
//  ListView.DataSource.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/19/19.
//


internal extension ListView
{
    final class DataSource : NSObject, UICollectionViewDataSource
    {
        unowned var view : ListView!
        unowned var presentationState : PresentationState!

        func numberOfSections(in collectionView: UICollectionView) -> Int
        {
            return self.presentationState.sections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
        {
            let section = self.presentationState.sections[section]
            
            return section.items.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let item = self.presentationState.item(at: indexPath)
            
            self.presentationState.registerCell(for: item, in: collectionView)
            
            let cell = item.dequeueAndPrepareCollectionViewCell(in: collectionView, for: indexPath)
            
            cell.willBeProvided(to: self.view)
            
            return cell
        }
        
        private let headerFooterReuseCache = ReusableViewCache()
        
        func collectionView(
            _ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind kind: String,
            at indexPath: IndexPath
            ) -> UICollectionReusableView
        {
            let container = SupplementaryContainerView.dequeue(
                in: collectionView,
                for: kind,
                at: indexPath,
                reuseCache: self.headerFooterReuseCache
            )
            
            container.headerFooter = {
                switch SupplementaryKind(rawValue: kind)! {
                case .listHeader: return self.presentationState.header.state
                case .listFooter: return self.presentationState.footer.state
                case .sectionHeader: return self.presentationState.sections[indexPath.section].header.state
                case .sectionFooter: return self.presentationState.sections[indexPath.section].footer.state
                case .overscrollFooter: return self.presentationState.overscrollFooter.state
                }
            }()
            
            return container
        }
        
        func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.reordering != nil
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            moveItemAt sourceIndexPath: IndexPath,
            to destinationIndexPath: IndexPath
            )
        {
            let item = self.presentationState.item(at: destinationIndexPath)
                        
            item.moved(with: Reordering.Result(
                fromSection: self.presentationState.sections[sourceIndexPath.section].model,
                fromIndexPath: sourceIndexPath,
                toSection: self.presentationState.sections[destinationIndexPath.section].model,
                toIndexPath: destinationIndexPath
            ))
        }
    }
}
