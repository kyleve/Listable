//
//  TableViewDemosRootViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/24/19.
//

import UIKit
import ListableUI


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
        
        list.overscrollFooter = HeaderFooter(
            DemoHeader(title: "Thanks for using Listable!!")
        )
        
        list {
            Section("list-view") { section in
                
                section.header = HeaderFooter(
                    DemoHeader(title: "List Views")
                )
                
                section {
                    Item(
                        DemoItem(text: "Basic Demo"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(CollectionViewBasicDemoViewController())
                        }
                    )
                    
                    Item(
                        DemoItem(text: "Blueprint Integration"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(BlueprintListDemoViewController())
                    })

                    Item(
                        DemoItem(text: "Auto Scrolling (Bottom Pin)"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(AutoScrollingViewController())
                    })
                    
                    if #available(iOS 13.0, *) {
                        Item(
                            DemoItem(text: "List State & State Reader"),
                            selectionStyle: .selectable(),
                            onSelect: { _ in
                                self.push(ListStateViewController())
                            }
                        )
                    }

                    Item(
                        DemoItem(text: "Itemization Editor"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(ItemizationEditorViewController())
                    })
                    
                    Item(
                        DemoItem(text: "English Dictionary Search"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(CollectionViewDictionaryDemoViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Keyboard Inset (Full Screen List)"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(KeyboardTestingViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Keyboard Inset (Appears Later)"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(ListAppearsAfterKeyboardViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Reordering (Experimental)"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(ReorderingViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Multi-Select"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(MultiSelectViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Invoices Payment Schedule"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(InvoicesPaymentScheduleDemoViewController())
                    })

                    Item(
                        DemoItem(text: "Refresh Control"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(RefreshControlOffsetAdjustmentViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Swipe Actions"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(SwipeActionsViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Localized Collation"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(LocalizedCollationViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Item Insert & Remove Animations"),
                        selectionStyle: .selectable(),
                        onSelect: { _ in
                            self.push(ItemInsertAndRemoveAnimationsViewController())
                    })

                    Item(
                        DemoItem(text: "Manual Selection Management"),
                        selectionStyle: .selectable(),
                        onSelect: { _ in
                            self.push(ManualSelectionManagementViewController())
                        }
                    )
                    
                    Item(
                        DemoItem(text: "Accordion View"),
                        selectionStyle: .tappable,
                        onSelect: { _ in
                            self.push(AccordionViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Using Autolayout"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(AutoLayoutDemoViewController())
                    })
                }
            }
            
            Section("coordinator") { section in

                section.header = HeaderFooter(
                    DemoHeader(title: "Item Coordinator")
                )

                section {
                    Item(
                        DemoItem(text: "Expand / Collapse Items"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(CoordinatorViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Animating On Tap"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(OnTapItemAnimationViewController())
                    })
                }
            }
            
            Section("layouts") { section in
                
                section.header = HeaderFooter(
                    DemoHeader(title: "Other Layouts")
                )

                section {
                    Item(
                        DemoItem(text: "Grid Layout"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(CustomLayoutsViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Paged Layout"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(PagedViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Horizontal Layout"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(HorizontalLayoutViewController())
                    })
                    
                    Item(
                        DemoItem(text: "Width Customization"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(WidthCustomizationViewController())
                    })

                    Item(
                        DemoItem(text: "Spacing Customization"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(SpacingCustomizationViewController())
                    })
                }
            }
            
            Section("selection-state") { section in

                section.header = HeaderFooter(
                    DemoHeader(title: "List View Selection")
                )
                
                section {
                    Item(
                        DemoItem(text: "Tappable Row"),
                        selectionStyle: .tappable
                    )
                    
                    Item(
                        DemoItem(text: "Tappable Row (Slow Is Selected)"),
                        selectionStyle: .tappable,
                        onSelect: { _ in
                            Thread.sleep(forTimeInterval: 0.5)
                        }
                    )
                }
            }
            
            Section("collection-view") { section in

                section.header = HeaderFooter(
                    DemoHeader(title: "UICollectionViews")
                )
            
                section {
                    Item(
                        DemoItem(text: "Flow Layout"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(FlowLayoutViewController())
                    })
                }
            }
            
            Section("scroll-view") { section in

                section.header = HeaderFooter(
                    DemoHeader(title: "UIScrollViews")
                )
                
                section {
                    Item(
                        DemoItem(text: "Edges Playground"),
                        selectionStyle: .selectable(),
                        onSelect : { _ in
                            self.push(ScrollViewEdgesPlaygroundViewController())
                    })
                }
            }
        }
    }
}

