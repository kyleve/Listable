//
//  OnTapItemAnimationViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 3/2/21.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

import ListableUI
import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists

final class OnTapItemAnimationViewController : ListViewController {
    
    override func configure(list: inout ListProperties) {
        
        list.layout = .demoLayout
        
        list("items") { section in
                        
            section += items.map { item in
                Item(item) { item in
                    item.selectionStyle = .tappable
                }
            }
            
        }
    }
}

fileprivate struct ItemRow : BlueprintItemContent, Equatable {
    
    var name : String
    var price : String
    var onTapText : String = "Added"
    
    var isShowingPrice : Bool = true
    
    var identifier: Identifier<ItemRow> {
        .init(name)
    }
    
    func element(
        with info: ApplyItemContentInfo,
        send : @escaping Coordinator.SendAction
    ) -> Element
    {
        Row { row in
            row.verticalAlignment = .center
            
            row.addFlexible(child: Label(text: self.name) { label in
                label.font = .systemFont(ofSize: 18.0, weight: .semibold)
            })
            
            row.addFlexible(child: Overlay { overlay in
                overlay.add(
                    Label(text: self.price) { label in
                        label.font = .systemFont(ofSize: 16.0, weight: .semibold)
                    }
                    .opacity(isShowingPrice ? 1 : 0)
                )
                
                overlay.add(
                    Label(text: self.onTapText) { label in
                        label.font = .systemFont(ofSize: 16.0, weight: .semibold)
                    }
                    .opacity(isShowingPrice ? 0 : 1)
                )
            })
        }
        .inset(uniform: 10.0)
        .box(background: .white(0.95), corners: .rounded(radius: 10))
    }
    
    func makeCoordinator(
        actions: CoordinatorActions,
        info: CoordinatorInfo
    ) -> OnTapCoordinator
    {
        OnTapCoordinator(actions: actions, info: info)
    }
}

fileprivate final class OnTapCoordinator : ItemContentCoordinator {
    var actions: ItemRow.CoordinatorActions
    var info: ItemRow.CoordinatorInfo
        
    init(actions: ItemRow.CoordinatorActions, info: ItemRow.CoordinatorInfo) {
        self.actions = actions
        self.info = info
    }
    
    typealias ItemContentType = ItemRow
    
    func wasSelected() {
        self.actions.update { item in
            item.content.isShowingPrice = false
        }
        
        self.actions.update(after: 1.0) { item in
            item.content.isShowingPrice = true
        }
    }
}


fileprivate let items : [ItemRow] = [
    .init(name: "Coffee", price: "$4.00"),
    .init(name: "Cold Brew", price: "$5.00"),
    .init(name: "Espresso", price: "$6.00"),
    .init(name: "Flat White", price: "$5.00"),
    .init(name: "Iced Coffee", price: "$5.00"),
    .init(name: "Latte", price: "$6.00")
]
