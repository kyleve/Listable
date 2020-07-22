//
//  KeyboardTestingViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/6/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit
import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls


final class KeyboardTestingViewController : UIViewController
{
    let listView = ListView()
    
    override func loadView()
    {
        self.view = self.listView
        
        self.listView.layout = .list {
            $0.layout.itemSpacing = 10.0
        }
        
        self.listView.configure { list in
            list.content.overscrollFooter = HeaderFooter(
                DemoHeader(title: "Thanks for using Listable!!")
            )
            
            list += Section("section") { section in
                section += Item(TextFieldElement(content: "Item 1"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 2"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 3"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 4"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 5"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 6"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 7"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 8"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 9"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 10"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 11"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 12"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 13"), sizing: .fixed(height: 100.0))
                section += Item(TextFieldElement(content: "Item 14"), sizing: .fixed(height: 100.0))
            }
            
            list.content.inputAccessory = ViewProvider {
                InputAccessory()
            }
        }
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Dismiss Keyboard", style: .plain, target: self, action: #selector(dismissKeyboard)),
            UIBarButtonItem(title: "Toggle Mode", style: .plain, target: self, action: #selector(toggleMode)),
        ]
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @objc func toggleMode()
    {
        switch self.listView.behavior.keyboardAdjustmentMode {
        case .none:
            self.listView.behavior.keyboardAdjustmentMode = .adjustsWhenVisible
        case .adjustsWhenVisible:
            self.listView.behavior.keyboardAdjustmentMode = .none
        }
    }
}

struct InputAccessory : ProxyElement
{
    var elementRepresentation: Element {
        Label(text: "Hello, World!")
    }
}

struct TextFieldElement : BlueprintItemContent, Equatable
{
    var content : String
    
    // MARK: BlueprintItemElement
    
    var identifier: Identifier<TextFieldElement> {
        return .init(self.content)
    }
    
    func element(with info : ApplyItemContentInfo) -> Element
    {
        let textField = TextField(text: self.content)
        
        return Box(
            backgroundColor: .init(white: 0.97, alpha: 1.0),
            cornerStyle: .square,
            wrapping: Inset(uniformInset: 20.0, wrapping: textField)
        )
    }
}
