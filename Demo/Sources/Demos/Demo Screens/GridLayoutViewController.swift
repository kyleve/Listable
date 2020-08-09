//
//  CustomLayoutsViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 5/3/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls


final class GridLayoutViewController : ListViewController
{
    override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        
        list.layout = .grid {
            $0.layout.padding = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        }
        
        list += (1...10).map { sectionIndex in
            Section(sectionIndex) { section in
                
                section.header = HeaderFooter(DemoHeader(title: "Section \(sectionIndex)"))
                
                section += (1...sectionIndex).map { rowIndex in
                    DemoItem(text: "Row \(rowIndex)")
                }
            }
        }
    }
}
