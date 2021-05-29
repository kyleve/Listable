//
//  SpacingCustomizationViewController.swift
//  Demo
//
//  Created by Gil Birman on 6/9/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//


import UIKit
import ListableUI
import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists


final class SpacingCustomizationViewController : UIViewController
{
    let listView = ListView()

    override func loadView()
    {
        self.view = self.listView

        self.listView.configure { list in
            
            list.layout = .table {
                $0.layout.set {
                    $0.padding = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
                    $0.itemSpacing = 20.0
                    $0.interSectionSpacingWithFooter = 20.0
                    $0.interSectionSpacingWithNoFooter = 20.0
                }
            }

            list += Section("default") { section in
                section += Item(
                    CardElement(title: "Default Row In Default Section", color: .white(0.95)),
                    sizing: .thatFits()
                )
            }

            list += Section("custom-50") { section in

                section.layouts.table = .init(customInterSectionSpacing: 50)

                section += Item(
                    CardElement(title: "Default Row In 50 Spacing Section", color: .white(0.95)),
                    sizing: .thatFits()
                )
            }

            list += Section("custom-100") { section in

                section.layouts.table = .init(customInterSectionSpacing: 100)

                section += Item(
                    CardElement(title: "Default Row In 100 Spacing Section", color: .white(0.95)),
                    sizing: .thatFits()
                )
            }

            list += Section("default-2") { section in
                section += Item(
                    CardElement(title: "Default Row In another Default Section", color: .white(0.95)),
                    sizing: .thatFits()
                )
            }
        }
    }
}


fileprivate struct CardElement : BlueprintItemContent, Equatable
{
    var title : String
    var color : UIColor

    //
    // MARK: BlueprintItemElement
    //

    var identifier: Identifier<CardElement> {
        return .init(self.title)
    }

    func element(
        with info: ApplyItemContentInfo,
        send : @escaping Coordinator.SendAction
    ) -> Element
    {
        return Box(
            backgroundColor: self.color,
            cornerStyle: .rounded(radius: 5.0),
            wrapping: Inset(uniformInset: 10.0, wrapping: Label(text: self.title) {
                $0.font = .systemFont(ofSize: 16.0, weight: .bold)
            })
        )
    }
}
