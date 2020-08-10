//
//  TableViewDemosRootViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/24/19.
//

import UIKit
import Listable


public final class DemosRootViewController : ListViewController
{
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Demos"
    }
    
    func push(_ viewController : UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    public override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        list.layout = .demoLayout
        
        list.content.overscrollFooter = HeaderFooter(
            DemoHeader(title: "Thanks for using Listable!!")
        )
        
        list("list-view") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "List Views")
            )
        
            section += Item(
                DemoItem(text: "Basic Demo"),
                selectionStyle: .selectable(),
                onSelect : { _ in
                    self.push(CollectionViewBasicDemoViewController())
                }
            )
            
            if #available(iOS 13.0, *) {
                section += Item(
                    DemoItem(text: "SwiftUI Integration"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(SwiftUIListViewController())
                })
            }
            
            section += Item(
                DemoItem(text: "Blueprint Integration"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(BlueprintListDemoViewController())
            })

            section += Item(
                DemoItem(text: "Auto Scrolling (Bottom Pin)"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(AutoScrollingViewController())
            })
            
            if #available(iOS 13.0, *) {
                section += Item(
                    DemoItem(text: "List State & State Reader"),
                    selectionStyle: .tappable,
                    onSelect: { _ in
                        self.push(ListStateViewController())
                    }
                )
            }

            section += Item(
                DemoItem(text: "Itemization Editor"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(ItemizationEditorViewController())
            })
            
            section += Item(
                DemoItem(text: "English Dictionary Search"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(CollectionViewDictionaryDemoViewController())
            })
            
            section += Item(
                DemoItem(text: "Keyboard Testing"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(KeyboardTestingViewController())
            })
            
            section += Item(
                DemoItem(text: "Reordering (Experimental)"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(ReorderingViewController())
            })
            
            section += Item(
                DemoItem(text: "Invoices Payment Schedule"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(InvoicesPaymentScheduleDemoViewController())
            })
            
            section += Item(
                DemoItem(text: "Swipe Actions"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(SwipeActionsViewController())
            })
            
            section += Item(
                DemoItem(text: "Item Content Coordinator"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(CoordinatorViewController())
            })
            
            section += Item(
                DemoItem(text: "Item Insert & Remove Animations"),
                selectionStyle: .tappable,
                onSelect: { _ in
                    self.push(ItemInsertAndRemoveAnimationsViewController())
            })
        }
        
        list("layouts") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "Other Layouts")
            )
            
            section += Item(
                DemoItem(text: "Grid Layout"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(CustomLayoutsViewController())
            })
            
            section += Item(
                DemoItem(text: "Paged Layout"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(PagedViewController())
            })
            
            section += Item(
                DemoItem(text: "Horizontal Layout"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(HorizontalLayoutViewController())
            })
            
            section += Item(
                DemoItem(text: "Width Customization"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(WidthCustomizationViewController())
            })

            section += Item(
                DemoItem(text: "Spacing Customization"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(SpacingCustomizationViewController())
            })
        }
        
        list("selection-state") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "List View Selection")
            )

            section += Item(
                DemoItem(text: "Tappable Row"),
                selectionStyle: .tappable
            )
            
            section += Item(
                DemoItem(text: "Tappable Row (Slow Is Selected)"),
                selectionStyle: .tappable,
                onSelect: { _ in
                    Thread.sleep(forTimeInterval: 0.5)
                }
            )
        }
        
        list("collection-view") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "UICollectionViews")
            )

            section += Item(
                DemoItem(text: "Flow Layout"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(FlowLayoutViewController())
            })
        }
        
        list("scroll-view") { section in
            
            section.header = HeaderFooter(
                DemoHeader(title: "UIScrollViews")
            )
            
            section += Item(
                DemoItem(text: "Edges Playground"),
                selectionStyle: .tappable,
                onSelect : { _ in
                    self.push(ScrollViewEdgesPlaygroundViewController())
            })
        }
    }
}

