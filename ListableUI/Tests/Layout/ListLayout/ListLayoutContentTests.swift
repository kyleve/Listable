//
//  ListLayoutContentTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 7/15/20.
//

import UIKit
import XCTest
@testable import ListableUI


class ListLayoutContentTests : XCTestCase
{
    func test_all()
    {
        let header = ListLayoutContent.SupplementaryItemInfo(
            kind: .listHeader,
            layouts: .init(),
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let footer = ListLayoutContent.SupplementaryItemInfo(
            kind: .listFooter,
            layouts: .init(),
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let overscroll = ListLayoutContent.SupplementaryItemInfo(
            kind: .overscrollFooter,
            layouts: .init(),
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let items : [ListLayoutContent.ItemInfo] = (0...1).map { index in
            .init(
                delegateProvidedIndexPath: IndexPath(item: index, section: 0),
                liveIndexPath: IndexPath(item: index, section: 0),
                layouts: .init(),
                insertAndRemoveAnimations: .fade,
                measurer: { _ in .zero }
            )
        }
                
        let section = ListLayoutContent.SectionInfo(
            layouts: .init(),
            header: nil,
            footer: nil,
            items: items
        )
        
        let content1 = ListLayoutContent(
            header: nil,
            footer: nil,
            overscrollFooter: nil,
            sections: [section]
        )
        
        // Shouldn't include header or footer if they are empty.
        
        AssertListLayoutContentItemEqual(content1.all, section.all)
        
        let content2 = ListLayoutContent(
            header: header,
            footer: footer,
            overscrollFooter: overscroll,
            sections: [section]
        )
        
        // Should include header and footer if they are populated.
        
        // Note that overscroll is explicitly not included, because it is a somewhat "special" case that
        // lives outside of the normal content bounds of the list.

        AssertListLayoutContentItemEqual(content2.all, [header] + section.all + [footer])
    }
    
    func test_setSectionContentsFrames()
    {
        /// This method only calls through to the section version, which is tested by `test_setContentsFrame` below.
    }
}


class ListLayoutContent_SectionInfoTests : XCTestCase
{
    func test_all()
    {
        let header = ListLayoutContent.SupplementaryItemInfo(
            kind: .sectionHeader,
            layouts: .init(),
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let footer = ListLayoutContent.SupplementaryItemInfo(
            kind: .sectionHeader,
            layouts: .init(),
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let items : [ListLayoutContent.ItemInfo] = (0...1).map { index in
            .init(
                delegateProvidedIndexPath: IndexPath(item: index, section: 0),
                liveIndexPath: IndexPath(item: index, section: 0),
                layouts: .init(),
                insertAndRemoveAnimations: .fade,
                measurer: { _ in .zero }
            )
        }
        
        // Shouldn't include header or footer if they are empty.
        
        let section1 = ListLayoutContent.SectionInfo(
            layouts: .init(),
            header: nil,
            footer: nil,
            items: items
        )
        
        AssertListLayoutContentItemEqual(section1.all, items as [ListLayoutContentItem])
        
        // Should include header and footer if they are populated.
        
        let section2 = ListLayoutContent.SectionInfo(
            layouts: .init(),
            header: header,
            footer: footer,
            items: items
        )
        
        AssertListLayoutContentItemEqual(section2.all, [header] + items + [footer] as [ListLayoutContentItem])
    }
    
    func test_setContentsFrame()
    {
        let header = ListLayoutContent.SupplementaryItemInfo(
            kind: .sectionHeader,
            layouts: .init(),
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let footer = ListLayoutContent.SupplementaryItemInfo(
            kind: .sectionHeader,
            layouts: .init(),
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let items : [ListLayoutContent.ItemInfo] = (0...1).map { index in
            .init(
                delegateProvidedIndexPath: IndexPath(item: index, section: 0),
                liveIndexPath: IndexPath(item: index, section: 0),
                layouts: .init(),
                insertAndRemoveAnimations: .fade,
                measurer: { _ in .zero }
            )
        }
                
        let section = ListLayoutContent.SectionInfo(
            layouts: .init(),
            header: header,
            footer: footer,
            items: items
        )
        
        header.size = CGSize(width: 80.0, height: 30.0)
        header.x = 10.0
        header.y = 10.0
        
        items[0].size = CGSize(width: 80.0, height: 30.0)
        items[0].x = 10.0
        items[0].y = 40.0
        
        items[1].size = CGSize(width: 80.0, height: 30.0)
        items[1].x = 10.0
        items[1].y = 70.0
        
        footer.size = CGSize(width: 80.0, height: 30.0)
        footer.x = 10.0
        footer.y = 100.0
        
        section.setContentsFrame()
        
        XCTAssertEqual(
            section.contentsFrame,
            CGRect(x: 10.0, y: 10.0, width: 80.0, height: 120.0)
        )
    }
}


class ListLayoutContent_SupplementaryItemInfoTests : XCTestCase
{
    
}


class ListLayoutContent_ItemInfoTests : XCTestCase
{
    
}


class ListLayoutContent_CGRectTests : XCTestCase
{
    func test_unioned()
    {
        // No rects
        
        XCTAssertEqual(CGRect.unioned(from: []), CGRect.zero)
        
        // Create our rects for testing.
        
        let rects : [CGRect] = [
            CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0),
            CGRect(x: 10.0, y: 10.0, width: 1.0, height: 1.0),
            CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0),
            CGRect(x: 20.0, y: 20.0, width: 90.0, height: 190.0),
            CGRect(x: 30.0, y: 30.0, width: 80.0, height: 180.0),
            CGRect(x: 50.0, y: 50.0, width: 20.0, height: 50.0),
        ]
        
        // Try in differing orders to ensure the same result is always produced.
        
        for _ in (0...100) {
            XCTAssertEqual(
                CGRect.unioned(from: rects.shuffled()),
                CGRect(x: 10.0, y: 10.0, width: 100.0, height: 200.0)
            )
        }
    }
}


fileprivate func AssertListLayoutContentItemEqual(
    _ lhs : [ListLayoutContentItem],
    _ rhs : [ListLayoutContentItem],
    file : StaticString = #file,
    line : UInt = #line
) {
    guard lhs.count == rhs.count else {
        XCTFail("Counts did not match.", file: (file), line: line)
        return
    }
    
    for (lhs, rhs) in zip(lhs, rhs) {
        XCTAssertTrue(lhs === rhs, "")
    }
}

