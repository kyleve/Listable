//
//  HorizontalLayoutViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/10/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit
import Listable
import BlueprintUI
import BlueprintUICommonControls
import BlueprintLists


final class HorizontalLayoutViewController : UIViewController
{
    let listView = ListView()
    
    override func loadView()
    {
        self.view = self.listView
        
        self.listView.setContent { list in
                        
            list.appearance.list.layout.itemSpacing = 20.0
            list.appearance.list.layout.padding = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
            
            list.content.overscrollFooter = HeaderFooter(
                with: HorizontalHeader(title: "Thanks for using Listable!!", color: .white(0.65)),
                sizing: .fixed(height: 100.0)
            )
            
            list += Section(identifier: "Cards") { section in
                section += Item(
                    with: CardElement(title: "This is the first card", detail: "Isn't it neat?", color: .white(0.95)),
                    sizing: .fixed(height: 200)
                )
                
                section += Item.list(identifier: "carousel", sizing: .fixed(height: 400)) { horizontal in

                    horizontal.appearance.direction = .horizontal

                    horizontal.appearance.list.layout.set {
                        $0.itemSpacing = 20.0
                        $0.sectionHeaderBottomSpacing = 20.0
                    }

                    horizontal.scrollInsets = .init(
                        top: list.appearance.list.layout.padding.left,
                        bottom: list.appearance.list.layout.padding.right
                    )

                    horizontal.content.overscrollFooter = HeaderFooter(
                        with: HorizontalHeader(title: "Thanks for using Listable!!", color: .white(0.65)),
                        sizing: .fixed(height: 100.0)
                    )

                    horizontal += Section(identifier: "cards") { section in

                        section.header = HeaderFooter(
                            with: HorizontalHeader(title: "Header", color: .white(0.65)),
                            sizing: .fixed(height: 100.0)
                        )

                        section.columns = .init(count: 2, spacing: 20.0)

                        section += Item(
                            with: CardElement(title: "This is the first card", detail: "Isn't it neat?", color: .white(0.90)),
                            sizing: .fixed(height: 300)
                        )

                        section += Item(
                            with: CardElement(title: "This is the second card", detail: "Isn't it neat?", color: .white(0.85)),
                            sizing: .fixed(height: 300)
                        )

                        section += Item(
                            with: CardElement(title: "This is the third card", detail: "Isn't it neat?", color: .white(0.80)),
                            sizing: .fixed(height: 300)
                        )

                        section += Item(
                            with: CardElement(title: "This is the fourth card", detail: "Isn't it neat?", color: .white(0.75)),
                            sizing: .fixed(height: 300)
                        )

                        section += Item(
                            with: CardElement(title: "This is the fifth card", detail: "Isn't it neat?", color: .white(0.70)),
                            sizing: .fixed(height: 300)
                        )

                        section += Item(
                            with: CardElement(title: "This is the sixth card", detail: "Isn't it neat?", color: .white(0.65)),
                            sizing: .fixed(height: 300)
                        )
                    }
                }
                
                section += Item(
                    with: CardElement(title: "This is the second card", detail: "Isn't it neat?", color: .white(0.95)),
                    sizing: .fixed(height: 200)
                )
                
                section += Item(
                    with: CardElement(title: "This is the third card", detail: "Isn't it neat?", color: .white(0.95)),
                    sizing: .fixed(height: 200)
                )
            }
        }
    }
}


fileprivate struct HorizontalHeader : BlueprintHeaderFooterElement, Equatable
{
    var title : String
    var color : UIColor
    
    var element: Element {
        return Box(
            backgroundColor: self.color,
            cornerStyle: .rounded(radius: 15.0),
            wrapping: Inset(uniformInset: 10.0,  wrapping: Label(text: self.title) {
                $0.font = .systemFont(ofSize: 18.0, weight: .bold)
            })
        )
    }
}

fileprivate struct CardElement : BlueprintItemElement, Equatable
{
    var title : String
    var detail : String
    var color : UIColor
    
    func element(with info : ApplyItemElementInfo) -> Element
    {
        return Box(
            backgroundColor: self.color,
            cornerStyle: .rounded(radius: 15.0),
            wrapping: Inset(uniformInset: 30.0, wrapping: Column { column in
                
                column.verticalUnderflow = .growProportionally
                column.horizontalAlignment = .fill
                
                column.add(growPriority: 0.0, child: Label(text: self.title) {
                    $0.font = .systemFont(ofSize: 24.0, weight: .bold)
                })
                
                column.add(growPriority: 0.0, child: Spacer(size: .init(width: 20.0, height: 20.0)))
                
                column.add(growPriority: 0.0, child: Label(text: self.detail) {
                    $0.font = .systemFont(ofSize: 18.0, weight: .semibold)
                })
            })
        )
    }
    
    var identifier: Identifier<CardElement> {
        return .init(self.title)
    }
    
}
