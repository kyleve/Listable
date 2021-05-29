//
//  DemoTableViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 3/24/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//
import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls
import UIKit

final class SwipeActionsViewController: UIViewController  {
    private let blueprintView = BlueprintView()

    private var allowDeleting: Bool = true

    private var items = (0..<20).map { SwipeActionItem(isSaved: Bool.random(), identifier: $0) }

    override func loadView() {
        self.title = "Swipe Actions"

        self.view = self.blueprintView

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(toggleDelete)),
        ]

        self.reloadData()
    }

    func reloadData(animated: Bool = false) {

        self.blueprintView.element = List { list in

            list.animatesChanges = animated
            
            list.layout = .table { [weak self] in
                guard let self = self else { return }
                
                if #available(iOS 11, *) {
                    $0.layout.padding = UIEdgeInsets(top: 0.0, left: self.view.safeAreaInsets.left, bottom: 0.0, right: self.view.safeAreaInsets.right)
                }
            }

            list += Section("items") { section in
                section += self.items.map { item in
                    Item(
                        SwipeActionsDemoItem(item: item),
                        swipeActions: self.makeSwipeActions(for: item)
                    )
                }
            }
        }
    }

    private func makeSwipeActions(for item: SwipeActionItem) -> SwipeActionsConfiguration {
        var actions: [SwipeAction] = []

        if allowDeleting {
            actions.append(
                SwipeAction(
                    title: "Delete",
                    backgroundColor: .systemRed,
                    image: nil,
                    handler: { [weak self] expandActions in
                        self?.confirmDelete(item: item, expandActions: expandActions)
                })
            )
        }

        actions.append(
            SwipeAction(
                title: item.isSaved ? "Unsave" : "Save",
                backgroundColor: UIColor(displayP3Red: 0, green: 0.741, blue: 0.149, alpha: 1),
                image: nil,
                handler: { [weak self] expandActions in
                    self?.toggleSave(item: item)
                    expandActions(false)
            })
        )

        return SwipeActionsConfiguration(actions: actions, performsFirstActionWithFullSwipe: true)
    }

    @objc private func addItem() {
        let identifier = (items.last?.identifier ?? -1) + 1
        items.append(SwipeActionItem(isSaved: false, identifier: identifier))
        reloadData(animated: true)
    }

    @objc private func toggleDelete() {
        allowDeleting.toggle()
        reloadData()
    }

    private func confirmDelete(item: SwipeActionItem, expandActions: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: item.title, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            expandActions(false)
        })

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.items.removeAll(where: { $0 == item })
            self?.reloadData(animated: true)
            expandActions(true)
        })

        present(alert, animated: true, completion: nil)
    }

    private func toggleSave(item: SwipeActionItem) {
        guard let index = items.firstIndex(of: item) else { return }
        items[index].isSaved.toggle()
        reloadData(animated: true)

    }

    struct SwipeActionsDemoItem: BlueprintItemContent, Equatable {
        var item: SwipeActionItem

        var identifier: Identifier<SwipeActionsDemoItem> {
            return .init(item.identifier)
        }

        func element(
            with info: ApplyItemContentInfo,
            send : @escaping Coordinator.SendAction
        ) -> Element
        {
            return Column { column in

                column.horizontalAlignment = .fill

                let row = Row { row in

                    row.minimumHorizontalSpacing = 8
                    row.horizontalUnderflow = .spaceEvenly
                    row.verticalAlignment = .center
                    row.add(child: Label(text: self.item.title))

                    let bookmark = UIImage(named: "bookmark")!
                    
                    if item.isSaved {
                        var image = Image(image: bookmark)
                        image.contentMode = .center
                        row.add(child: image)
                    } else {
                        let spacer = Spacer(size: bookmark.size)
                        row.add(child: spacer)
                    }
                }

                let inset = Inset(uniformInset: 16, wrapping: row)
                column.add(child: inset)

                let color = UIColor(displayP3Red: 0.725, green: 0.729, blue: 0.741, alpha: 1)
                let separator = Inset(left: 16, wrapping: Rule(orientation: .horizontal, color: color))
                column.add(growPriority: 0, shrinkPriority: 0, child: separator)
            }
            .accessibility(label: "Swipeable item", value: item.title)
        }
    }

    struct SwipeActionItem: Equatable, Hashable {
        var isSaved: Bool
        var identifier: Int

        var title: String { "Item #\(identifier)" }
    }
}
