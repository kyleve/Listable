//
//  BottomPinnedViewController.swift
//  Demo
//
//  Created by Kyle Bashour on 3/5/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls


final class AutoScrollingViewController : UIViewController
{
    let list = ListView()

    private var items: [BottomPinnedItem] = []

    override func loadView()
    {
        self.view = self.list
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        for _ in 0..<7 {
            addItem()
        }

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem)),
            UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(removeItem)),
        ]
    }

    @objc private func addItem()
    {
        items.append(BottomPinnedItem(text: "Item \(items.count)"))
        updateItems()
    }

    @objc private func removeItem()
    {
        if !items.isEmpty {
            items.removeLast()
            updateItems()
        }
    }

    private func updateItems() {
        self.list.setContent { list in
            list.appearance = demoAppearance

            let items = self.items.map { Item(with: $0) }
            list += Section(identifier: "items", items: items)

            if let last = items.last {
                list.autoScrollAction = .scrollToItemOnInsert(last, position: .init(position: .bottom), animated: true)
            }

            let itemization = [
                BottomPinnedItem(text: "Tax $2.00"),
                BottomPinnedItem(text: "Discount $4.00"),
                BottomPinnedItem(text: "Total $10.00"),
            ]

            list += Section(identifier: "itemization", items: itemization.map { Item(with: $0) })
        }
    }
}


struct BottomPinnedItem : BlueprintItemElement, Equatable
{
    var text : String

    var identifier: Identifier<BottomPinnedItem> {
        return .init(self.text)
    }

    func element(with info : ApplyItemElementInfo) -> Element
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
        return box
    }
}
