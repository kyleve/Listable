//
//  DefaultListLayoutTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 5/8/20.
//

import XCTest

@testable import Listable


class ListAppearanceTests : XCTestCase
{
    func test_init()
    {
        let appearance = ListAppearance()
        
        XCTAssertEqual(appearance.sizing, ListAppearance.Sizing())
        XCTAssertEqual(appearance.layout, ListAppearance.Layout())
    }
}


class ListAppearance_SizingTests : XCTestCase
{
    func test_init()
    {
        let sizing = ListAppearance.Sizing()
        
        XCTAssertEqual(sizing.itemHeight, 50.0)
        XCTAssertEqual(sizing.sectionHeaderHeight, 60.0)
        XCTAssertEqual(sizing.sectionFooterHeight, 40.0)
        XCTAssertEqual(sizing.listHeaderHeight, 60.0)
        XCTAssertEqual(sizing.listFooterHeight, 60.0)
        XCTAssertEqual(sizing.overscrollFooterHeight, 60.0)
        XCTAssertEqual(sizing.itemPositionGroupingHeight, 0.0)
    }
}


class ListAppearance_LayoutTests : XCTestCase
{
    func test_init()
    {
        let layout = ListAppearance.Layout()
        
        XCTAssertEqual(layout.padding, UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
        XCTAssertEqual(layout.width, .noConstraint)
        XCTAssertEqual(layout.interSectionSpacingWithNoFooter, 0.0)
        XCTAssertEqual(layout.interSectionSpacingWithFooter, 0.0)
        XCTAssertEqual(layout.sectionHeaderBottomSpacing, 0.0)
        XCTAssertEqual(layout.itemSpacing, 0.0)
        XCTAssertEqual(layout.itemToSectionFooterSpacing, 0.0)
    }
    
    func test_width()
    {
        self.testcase("No width constraint") {
            XCTAssertEqual(110.0, ListAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .noConstraint))
        }
        
        self.testcase("Has width constraint") {
            XCTAssertEqual(100.0, ListAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .fixed(100.0)))
            XCTAssertEqual(110.0, ListAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .atMost(200.0)))
        }
    }
}


class DefaultListLayoutTests : XCTestCase
{
    // Note: This test is temporary to allow for further refactoring of the layout system. Will be replaced.
    
    func test_layout_vertical()
    {
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 200.0, height: 700.0)))
        listView.layoutType = .list
        
        listView.setContent { list in
            
            list.appearance.direction = .vertical
            
            list.content.header = HeaderFooter(with: TestingHeaderFooterElement(), appearance: TestingHeaderFooterElement.Appearance(color: .blue), sizing: .fixed(height: 50.0))
            list.content.footer = HeaderFooter(with: TestingHeaderFooterElement(), appearance: TestingHeaderFooterElement.Appearance(color: .blue), sizing: .fixed(height: 70.0))
            
            list += Section(identifier: "first") { section in
                
                section.header = HeaderFooter(with: TestingHeaderFooterElement(), appearance: TestingHeaderFooterElement.Appearance(color: .green), sizing: .fixed(height: 55.0))
                section.footer = HeaderFooter(with: TestingHeaderFooterElement(), appearance: TestingHeaderFooterElement.Appearance(color: .green), sizing: .fixed(height: 45.0))
                
                section += Item(with: TestingItemElement(), appearance: TestingItemElement.Appearance(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(height: 20.0))
            }
            
            list += Section(identifier: "second") { section in
                section += Item(with: TestingItemElement(), appearance: TestingItemElement.Appearance(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(height: 40.0))
                section += Item(with: TestingItemElement(), appearance: TestingItemElement.Appearance(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(height: 60.0))
            }
        }
        
        let layout = DefaultListLayout(delegate: listView.delegate, appearance: listView.appearance, behavior: listView.behavior, in: listView.collectionView)
        _ = layout.layout(delegate: listView.delegate, in: listView.collectionView)
        
        let attributes = layout.content.layoutAttributes
        
        let expectedAttributes = ListLayoutAttributes(
            header: .init(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 50.0)),
            footer: .init(frame: CGRect(x: 0.0, y: 270.0, width: 200.0, height: 70.0)),
            overscrollFooter: nil,
            sections: [
                .init(
                    frame: CGRect(x: 0.0, y: 50.0, width: 200.0, height: 120.0),
                    header: .init(frame: CGRect(x: 0.0, y: 50.0, width: 200.0, height: 55.0)),
                    footer: .init(frame: CGRect(x: 0.0, y: 125.0, width: 200.0, height: 45.0)),
                items: [
                    .init(frame: CGRect(x: 0.0, y: 105.0, width: 200.0, height: 20.0))
                    ]
                ),

                .init(
                    frame: CGRect(x: 0.0, y: 170.0, width: 200.0, height: 100.0),
                header: nil,
                footer: nil,
                items: [
                    .init(frame: CGRect(x: 0.0, y: 170.0, width: 200.0, height: 40.0)),
                    .init(frame: CGRect(x: 0.0, y: 210.0, width: 200.0, height: 60.0)),
                    ]
                ),
            
            ]
        )
                
        XCTAssertEqual(attributes, expectedAttributes)
    }
    
    // Note: This test is temporary to allow for further refactoring of the layout system. Will be replaced.
    
    func test_layout_horizontal()
    {
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 700.0, height: 200.0)))
        listView.layoutType = .list
        
        listView.setContent { list in
            
            list.appearance.direction = .horizontal
            
            list.content.header = HeaderFooter(with: TestingHeaderFooterElement(), appearance: TestingHeaderFooterElement.Appearance(color: .blue), sizing: .fixed(height: 50.0))
            list.content.footer = HeaderFooter(with: TestingHeaderFooterElement(), appearance: TestingHeaderFooterElement.Appearance(color: .blue), sizing: .fixed(height: 70.0))
            
            list += Section(identifier: "first") { section in
                
                section.header = HeaderFooter(with: TestingHeaderFooterElement(), appearance: TestingHeaderFooterElement.Appearance(color: .green), sizing: .fixed(height: 55.0))
                section.footer = HeaderFooter(with: TestingHeaderFooterElement(), appearance: TestingHeaderFooterElement.Appearance(color: .green), sizing: .fixed(height: 45.0))
                
                section += Item(with: TestingItemElement(), appearance: TestingItemElement.Appearance(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(height: 20.0))
            }
            
            list += Section(identifier: "second") { section in
                section += Item(with: TestingItemElement(), appearance: TestingItemElement.Appearance(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(height: 40.0))
                section += Item(with: TestingItemElement(), appearance: TestingItemElement.Appearance(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(height: 60.0))
            }
        }
        
        let layout = DefaultListLayout(delegate: listView.delegate, appearance: listView.appearance, behavior: listView.behavior, in: listView.collectionView)
        _ = layout.layout(delegate: listView.delegate, in: listView.collectionView)
        
        let attributes = layout.content.layoutAttributes
        
        let expectedAttributes = ListLayoutAttributes(
            header: .init(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 200.0)),
            footer: .init(frame: CGRect(x: 270.0, y: 0.0, width: 70.0, height: 200.0)),
            overscrollFooter: nil,
            sections: [
                .init(
                    frame: CGRect(x: 50.0, y: 0.0, width: 120.0, height: 200.0),
                    header: .init(frame: CGRect(x: 50.0, y: 0.0, width: 55.0, height: 200.0)),
                    footer: .init(frame: CGRect(x: 125.0, y: 0.0, width: 45.0, height: 200.0)),
                items: [
                    .init(frame: CGRect(x: 105.0, y: 0.0, width: 20.0, height: 200.0))
                    ]
                ),

                .init(
                    frame: CGRect(x: 170.0, y: 0.0, width: 100.0, height: 200.0),
                header: nil,
                footer: nil,
                items: [
                    .init(frame: CGRect(x: 170.0, y: 0.0, width: 40.0, height: 200.0)),
                    .init(frame: CGRect(x: 210.0, y: 0.0, width: 60.0, height: 200.0)),
                    ]
                )
            ]
        )
                
        XCTAssertEqual(attributes, expectedAttributes)
    }
}


fileprivate struct TestingHeaderFooterElement : HeaderFooterElement {
    
    func apply(to view: UIView, reason: ApplyReason) {
        // Nothing
    }
    
    func isEquivalent(to other: TestingHeaderFooterElement) -> Bool {
        false
    }
    
    struct Appearance : HeaderFooterElementAppearance {
        
        var color : UIColor

        typealias ContentView = UIView
        
        static func createReusableHeaderFooterView(frame: CGRect) -> UIView {
            UIView(frame: frame)
        }
        
        func apply(to view: UIView) {
            view.backgroundColor = self.color
        }
        
        func isEquivalent(to other: TestingHeaderFooterElement.Appearance) -> Bool {
            false
        }
    }
}


fileprivate struct TestingItemElement : ItemElement {
    
    var identifier: Identifier<TestingItemElement> {
        .init("testing")
    }
    
    func apply(to view: Appearance.ContentView, for reason: ApplyReason, with info: ApplyItemElementInfo) {
        // Nothing
    }
    
    func isEquivalent(to other: TestingItemElement) -> Bool {
        false
    }
    
    struct Appearance : ItemElementAppearance {
        
        var color : UIColor
        
        typealias ContentView = UIView
        
        static func createReusableItemView(frame: CGRect) -> UIView {
            UIView(frame: frame)
        }
        
        func apply(to view: UIView, with info: ApplyItemElementInfo) {
            view.backgroundColor = self.color
        }
        
        func isEquivalent(to other: TestingItemElement.Appearance) -> Bool {
            false
        }
    }
}
