//
//  MultiSelectViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/22/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import BlueprintUILists
import BlueprintUICommonControls


final class MultiSelectViewController : ListViewController
{
    override func configure(list: inout ListProperties) {
        
        list.behavior.selectionMode = .multiple
        
        list.layout = .table {
            $0.layout.itemSpacing = 10.0
            $0.layout.padding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }
        
        list.stateObserver.onSelectionChanged { change in
            print("Selection Changed from \(change.old) to \(change.new).")
        }
        
        list(1) { section in
            section += (1...100).map { row in
                Item(
                    SelectableRow(text: "Row #\(row)"),
                    selectionStyle: .selectable(isSelected: false)
                )
            }
        }
    }
}


fileprivate struct SelectableRow : BlueprintItemContent, Equatable {
    
    var text : String
    
    var identifier: Identifier<SelectableRow> {
        .init(self.text)
    }
    
    func element(
        with info: ApplyItemContentInfo,
        send : @escaping Coordinator.SendAction
    ) -> Element
    {
        Label(text: self.text) {
            $0.font = .systemFont(ofSize: 18.0, weight: .semibold)
        }
        .inset(uniform: 20.0)
    }
    
    func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        Box(backgroundColor: .white, cornerStyle: .rounded(radius: 15.0))
    }
    
    func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element? {
        Box(backgroundColor: .white(0.8), cornerStyle: .rounded(radius: 15.0))
    }
}
