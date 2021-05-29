//
//  PagedViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 6/4/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import BlueprintUILists
import BlueprintUICommonControls


final class PagedViewController : UIViewController
{
    let blueprintView = BlueprintView()
        
    override func loadView()
    {
        self.view = self.blueprintView
        
        self.update()
    }
    
    func update()
    {
        self.blueprintView.element = List { list in
                        
            list.layout = .paged {
                $0.direction = .vertical
            }
            
            list += Section("first") { section in
                section += DemoElement(color: .black)
                section += DemoElement(color: .white)
                section += DemoElement(color: .black)
                section += DemoElement(color: .white)
                section += DemoElement(color: .black)
            }
        }
    }
}

fileprivate struct DemoElement : BlueprintItemContent, Equatable
{
    var identifier: Identifier<DemoElement> {
        .init(self.color)
    }
    
    var color : UIColor
    
    func element(
        with info: ApplyItemContentInfo,
        send : @escaping Coordinator.SendAction
    ) -> Element
    {
        Box(backgroundColor: self.color)
    }
}
