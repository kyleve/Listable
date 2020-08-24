//
//  SettingsAppletErrorViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 8/21/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit
import Listable
import BlueprintLists
import BlueprintUICommonControls


final class SettingsAppletErrorViewController : ListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Toggle", style: .plain, target: self, action: #selector(toggleFilter))
    }
    
    override func configure(list: inout ListProperties) {
        
        if self.isFiltered == false {
            list("Checkout") { section in
                section.header = HeaderFooter(HeaderContent(title: "Checkout"))
            }
            
            list("Hardware") { section in
                section.header = HeaderFooter(HeaderContent(title: "Hardware"))
            }
            
            list("Security") { section in
                section.header = HeaderFooter(HeaderContent(title: "Security"))
            }
            
            list("Account") { section in
                section.header = HeaderFooter(HeaderContent(title: "Account"))
            }
            
            list("Customers") { section in
                section.header = HeaderFooter(HeaderContent(title: "Customers"))
            }
            
            list("Separator") { section in
                section += Item(SeparatorItem(), sizing: .thatFits())
            }
            
            list("Add Ons") { section in
                section += ItemContent(text: "[Add On] Cash Management", inset: false)
                section += ItemContent(text: "[Add On] Gift Cards", inset: false)
                section += ItemContent(text: "[Add On] Online checkout", inset: false)
                section += ItemContent(text: "[Add On] Open Tickets", inset: false)
                section += ItemContent(text: "[Add On] Orders", inset: false)
                section += ItemContent(text: "[Add On] Time tracking", inset: false)
            }
        } else {
            list("Checkout") { section in
                section.header = HeaderFooter(HeaderContent(title: "Checkout"))
                
                section += ItemContent(text: "Payment types", inset: true)
                section += ItemContent(text: "Customer management", inset: true)
            }
            
            /// Customers and Account swap during the update. Removing this swap resolves the issue.
            
            list("Customers") { section in
                section.header = HeaderFooter(HeaderContent(title: "Customers"))
                
                section += ItemContent(text: "Configure profiles", inset: true)
            }
            
            list("Account") { section in
                section.header = HeaderFooter(HeaderContent(title: "Account"))
                
                section += ItemContent(text: "Business information", inset: true)
            }
            
            list("Separator") { section in
                section += Item(SeparatorItem(), sizing: .thatFits())
            }
            
            list("Add Ons") { section in
                section += ItemContent(text: "[Add On] Gift Cards", inset: false)
                section += ItemContent(text: "[Add On] Time tracking", inset: false)
            }
        }
    }
    
    var isFiltered : Bool = false
    
    @objc private func toggleFilter() {
        
        self.isFiltered.toggle()
        
        self.reload(animated: true)
    }
}


fileprivate struct HeaderContent : BlueprintHeaderFooterContent, Equatable {
    
    var title : String
    
    var elementRepresentation: Element {
        Label(text: self.title)
            .inset(uniform: 20.0)
    }
}


fileprivate struct ItemContent : BlueprintItemContent, Equatable {
    
    var text : String
    
    var inset : Bool
    
    var identifier: Identifier<ItemContent> {
        .init(self.text)
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Label(text: self.text)
            .inset(top: 20.0, bottom: 20.0, left: inset ? 40.0 : 20.0, right: 20.0)
    }
}

fileprivate struct SeparatorItem : BlueprintItemContent, Equatable {
    
    var identifier: Identifier<SeparatorItem> {
        .init()
    }
    
    static func createReusableContentView(frame: CGRect) -> ContentView
    {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Box(backgroundColor: .lightGray)
            .constrainedTo(height: .absolute(15.0))
    }
}
