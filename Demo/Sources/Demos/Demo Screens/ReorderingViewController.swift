//
//  ReorderingViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/13/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit

import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls


final class ReorderingViewController : UIViewController
{
    let list = ListView()
    
    override func loadView()
    {
        self.view = self.list
        
        self.list.configure { list in
            
            list.appearance = .demoAppearance
            list.layout = .demoLayout
            
            list += Section("first") { section in
                section.header = HeaderFooter(DemoHeader(title: "First Section"))
                
                section += Item(ReorderItem(text: "0,0 Row")) { item in
                    
                    item.reordering = Reordering(didReorder: { result in
                        print("Moved")
                    })
                    
                }
                
                section += Item(ReorderItem(text: "0,1 Row")) { item in
                    
                    item.reordering = Reordering(didReorder: { result in
                        print("Moved")
                    })
                    
                }
                
                section += Item(ReorderItem(text: "0,2 Row")) { item in
                    
                    item.reordering = Reordering(didReorder: { result in
                        print("Moved")
                    })
                    
                }
            }
            
            list += Section("second") { section in
                section.header = HeaderFooter(DemoHeader(title: "Second Section"))
                
                section += Item(ReorderItem(text: "1,0  Row")) { item in
                    
                    item.reordering = Reordering(didReorder: { result in
                        print("Moved")
                    })
                    
                }
                
                section += Item(ReorderItem(text: "1,1 Row")) { item in
                    
                    item.reordering = Reordering(didReorder: { result in
                        print("Moved")
                    })
                    
                }
            }
        }
    }
}


struct ReorderItem : BlueprintItemContent, Equatable
{
    var text : String
    
    var identifier: Identifier<ReorderItem> {
        return .init(self.text)
    }
    
    func element(
        with info: ApplyItemContentInfo,
        send : @escaping Coordinator.SendAction
    ) -> Element
    {
        var box = Box(
            backgroundColor: .white,
            cornerStyle: .rounded(radius: 6.0),
            wrapping: Inset(
                uniformInset: 10.0,
                wrapping: Label(text: self.text)
            )
        )
        
        box.borderStyle = .solid(color: .white(0.9), width: 2.0)
        
        return ListReorderGesture(
            actions: info.reordering,
            wrapping: box
        )
    }
}
