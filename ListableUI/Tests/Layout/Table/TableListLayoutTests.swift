//
//  TableListLayoutTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 5/8/20.
//

import XCTest
import Snapshot

@testable import ListableUI


class TableAppearanceTests : XCTestCase
{
    func test_init()
    {
        let appearance = TableAppearance()
        
        XCTAssertEqual(appearance.sizing, TableAppearance.Sizing())
        XCTAssertEqual(appearance.layout, TableAppearance.Layout())
    }
}


class TableAppearance_SizingTests : XCTestCase
{
    func test_init()
    {
        let sizing = TableAppearance.Sizing()
        
        XCTAssertEqual(sizing.itemHeight, 50.0)
        XCTAssertEqual(sizing.sectionHeaderHeight, 60.0)
        XCTAssertEqual(sizing.sectionFooterHeight, 40.0)
        XCTAssertEqual(sizing.listHeaderHeight, 60.0)
        XCTAssertEqual(sizing.listFooterHeight, 60.0)
        XCTAssertEqual(sizing.overscrollFooterHeight, 60.0)
        XCTAssertEqual(sizing.itemPositionGroupingHeight, 0.0)
    }
}


class TableAppearance_LayoutTests : XCTestCase
{
    func test_init()
    {
        let layout = TableAppearance.Layout()
        
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
            XCTAssertEqual(110.0, TableAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .noConstraint))
        }
        
        self.testcase("Has width constraint") {
            XCTAssertEqual(100.0, TableAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .fixed(100.0)))
            XCTAssertEqual(110.0, TableAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .atMost(200.0)))
        }
    }
}


class TableListLayoutTests : XCTestCase
{
    func test_layout_vertical_includingHeader()
    {
        let listView = self.list(includeHeader: true)
        
        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }

    func test_layout_vertical_excludingHeader()
    {
        let listView = self.list(includeHeader: false)

        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)

        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    func list(includeHeader: Bool) -> ListView
    {
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 200.0, height: 200.0)))
        
        listView.configure { list in

            list.layout = .table {
                $0.layout = .init(
                    padding: UIEdgeInsets(top: 10.0, left: 20.0, bottom: 30.0, right: 40.0),
                    width: .noConstraint,
                    headerToFirstSectionSpacing: 10.0,
                    interSectionSpacingWithNoFooter: 15.0,
                    interSectionSpacingWithFooter: 20.0,
                    sectionHeaderBottomSpacing: 10.0,
                    itemSpacing: 5.0,
                    itemToSectionFooterSpacing: 10.0,
                    lastSectionToFooterSpacing: 20.0
                )
            }

            if includeHeader {
                list.header = HeaderFooter(TestingHeaderFooterContent(color: .blue), sizing: .fixed(height: 50.0))
            }

            list.footer = HeaderFooter(TestingHeaderFooterContent(color: .blue), sizing: .fixed(height: 70.0))
            
            list += Section("first") { section in
                section.layouts.table.customInterSectionSpacing = 30

                section.header = HeaderFooter(TestingHeaderFooterContent(color: .green), sizing: .fixed(height: 30.0))
                section.footer = HeaderFooter(TestingHeaderFooterContent(color: .green), sizing: .fixed(height: 40.0))
                
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(height: 20.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(height: 20.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.3)), sizing: .fixed(height: 20.0))
            }
            
            list += Section("second") { section in
                section.header = HeaderFooter(TestingHeaderFooterContent(color: .green), sizing: .fixed(height: 30.0))
                section.footer = HeaderFooter(TestingHeaderFooterContent(color: .green), sizing: .fixed(height: 40.0))
                
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(height: 30.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(height: 40.0))
            }
            
            list += Section("third") { section in
                section.header = HeaderFooter(TestingHeaderFooterContent(color: .green), sizing: .fixed(height: 30.0))
                
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(height: 10.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(height: 20.0))
            }
            
            list += Section("fourth") { section in
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(height: 10.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(height: 20.0))
            }
        }
        
        listView.collectionView.layoutIfNeeded()
        
        return listView
    }
    
}


fileprivate struct TestingHeaderFooterContent : HeaderFooterContent {
    
    var color : UIColor
    
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        views.content.backgroundColor = self.color
    }
    
    func isEquivalent(to other: TestingHeaderFooterContent) -> Bool {
        false
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}


fileprivate struct TestingItemContent : ItemContent {
    
    var color : UIColor
    
    var identifier: Identifier<TestingItemContent> {
        .init("testing")
    }
    
    func apply(to views: ItemContentViews<Self>, for reason: ApplyReason, with info: ApplyItemContentInfo)
    {
        views.content.backgroundColor = self.color
    }
    
    func isEquivalent(to other: TestingItemContent) -> Bool {
        false
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}
