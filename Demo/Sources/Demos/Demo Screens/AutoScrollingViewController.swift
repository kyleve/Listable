//
//  BottomPinnedViewController.swift
//  Demo
//
//  Created by Kyle Bashour on 3/5/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit

import ListableUI
import BlueprintUILists
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
        let last = items.last?.identifier
        
        items.append(BottomPinnedItem(text: "Item \(items.count)"))
        
        updateItems(autoScrollIfVisible: last)
    }

    @objc private func removeItem()
    {
        if !items.isEmpty {
            items.removeLast()
            updateItems()
        }
    }

    private func updateItems(autoScrollIfVisible lastItem : AnyIdentifier? = nil) {
        
        self.list.configure { list in
            list.appearance = .demoAppearance
            list.layout = .demoLayout

            let items = self.items.map { Item($0) }
            list += Section("items", items: items)

            if let last = items.last {
                
                list.autoScrollAction = .scrollTo(
                    .lastItem,
                    onInsertOf: last.identifier,
                    position: .init(position: .bottom),
                    animation: .default,
                    shouldPerform: { info in
                        // Only scroll to the bottom if the bottom item is already visible.
                        if let identifier = lastItem {
                            return info.visibleItems.contains(identifier)
                        } else {
                            return false
                        }
                    },
                    didPerform: { info in
                        print("Did scroll: \(info)")
                    }
                )
            }

            let itemization = [
                BottomPinnedItem(text: "Tax $2.00"),
                BottomPinnedItem(text: "Discount $4.00"),
                BottomPinnedItem(text: "Total $10.00"),
            ]

            list += Section("itemization", items: itemization.map { Item($0) })
        }
    }
}


struct BottomPinnedItem : BlueprintItemContent, Equatable
{
    var text : String

    var identifier: Identifier<BottomPinnedItem> {
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
        return box
    }
}
