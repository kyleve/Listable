//
//  CollectionViewAppearance.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/20/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls


extension Appearance
{
    static var demoAppearance = Appearance {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
    }
}

extension LayoutDescription
{
    static var demoLayout : Self {
        .list {
            $0.layout = .init(
                padding: UIEdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0),
                width: .atMost(600.0),
                interSectionSpacingWithNoFooter: 20.0,
                interSectionSpacingWithFooter: 20.0,
                sectionHeaderBottomSpacing: 15.0,
                itemSpacing: 10.0,
                itemToSectionFooterSpacing: 10.0
            )
        }
    }
}


extension UIColor
{
    static func white(_ blend : CGFloat) -> UIColor
    {
        return UIColor(white: blend, alpha: 1.0)
    }
}


struct DemoHeader : BlueprintHeaderFooterContent, Equatable
{
    var title : String
    
    var elementRepresentation: Element {
        Label(text: self.title) {
            $0.font = .systemFont(ofSize: 20.0, weight: .bold)
        }
        .inset(horizontal: 15.0, vertical: 10.0)
        .box(
            background: .white,
            corners: .rounded(radius: 10.0),
            shadow: .simple(radius: 2.0, opacity: 0.2, offset: .init(width: 0.0, height: 1.0), color: .black)
        )
    }
}

struct DemoHeader2 : BlueprintHeaderFooterContent, Equatable
{
    var title : String
    
    var elementRepresentation: Element {
        Label(text: self.title) {
            $0.font = .systemFont(ofSize: 20.0, weight: .bold)
        }
        .inset(horizontal: 15.0, vertical: 30.0)
        .box(
            background: .white,
            corners: .rounded(radius: 10.0),
            shadow: .simple(radius: 2.0, opacity: 0.2, offset: .init(width: 0.0, height: 1.0), color: .black)
        )
    }
}


struct DemoItem : BlueprintItemContent, Equatable
{
    var text : String
    
    var identifier: Identifier<DemoItem> {
        return .init(self.text)
    }

    typealias SwipeActionsView = DefaultSwipeActionsView
    
    func element(with info : ApplyItemContentInfo) -> Element
    {
        Label(text: self.text) {
            $0.font = .systemFont(ofSize: 16.0, weight: .medium)
            $0.color = info.state.isActive ? .white : .darkGray
        }
        .inset(horizontal: 15.0, vertical: 10.0)
    }
    
    func backgroundElement(with info: ApplyItemContentInfo) -> Element?
    {
        Box(
            backgroundColor: .white,
            cornerStyle: .rounded(radius: 8.0),
            shadowStyle: .simple(radius: 2.0, opacity: 0.15, offset: .init(width: 0.0, height: 1.0), color: .black)
        )
    }
    
    func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element?
    {
        Box(
            /// The `isHighlighted` check allows us to differentiate between highlighted and selected appearance.
            /// If you do not want to differ the appearance of highlighted vs. selected, you can omit this check.
            backgroundColor: info.state.isHighlighted ? .white(0.1) : .white(0.2),
            
            cornerStyle: .rounded(radius: 8.0),
            shadowStyle: .simple(radius: 2.0, opacity: 0.15, offset: .init(width: 0.0, height: 1.0), color: .black)
        )
    }
}


struct DemoFooter : BlueprintHeaderFooterContent, Equatable
{
    var text : String
    
    var elementRepresentation: Element {
        return Centered(Label(text: self.text))
    }
}


struct Toggle : Element {
    var isOn : Bool
    
    var onToggle : (Bool) -> ()
    
    var content: ElementContent {
        return ElementContent(layout: Layout())
    }
    
    func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription?
    {
        return ViewDescription(ToggleView.self) { config in
            config.builder = {
                return ToggleView()
            }
            
            config.apply { toggle in
                toggle.isOn = self.isOn
                toggle.onToggle = self.onToggle
            }
        }
    }
    
    private final class ToggleView : UISwitch
    {
        var onToggle : (Bool) -> () = { _ in }
        
        override init(frame: CGRect)
        {
            super.init(frame: frame)
            
            self.addTarget(self, action: #selector(toggled), for: .valueChanged)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        @objc func toggled()
        {
            self.onToggle(self.isOn)
        }
    }
    
    private struct Layout : BlueprintUI.Layout
    {
        static let measurementSwitch = ToggleView()
        
        func measure(in constraint: SizeConstraint, items: [(traits: (), content: Measurable)]) -> CGSize
        {
            return Layout.measurementSwitch.sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        }
        
        func layout(size: CGSize, items: [(traits: (), content: Measurable)]) -> [LayoutAttributes]
        {
            return []
        }
    }
}
