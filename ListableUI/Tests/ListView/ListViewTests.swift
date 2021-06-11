//
//  ListViewTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest

@testable import ListableUI



class ListViewTests: XCTestCase
{
    func test_no_retain_cycles()
    {
        // Verify that there's no retain cycles within the list,
        // by making a list, putting content in it, and then waiting
        // for the list to be deallocated by testing a weak pointer.
        
        weak var weakList : ListView? = nil
        
        autoreleasepool {
            var listView : ListView? = ListView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
            
            listView?.configure { list in
                
                list.header = HeaderFooter(TestSupplementary())
                list.footer = HeaderFooter(TestSupplementary())
                list.overscrollFooter = HeaderFooter(TestSupplementary())

                list("content") { section in
                    section.header = HeaderFooter(TestSupplementary())
                    section.footer = HeaderFooter(TestSupplementary())
                    
                    section += TestContent(content: "1")
                    section += TestContent(content: "2")
                    section += TestContent(content: "3")
                }
            }

            self.waitForOneRunloop()
            
            weakList = listView
            
            listView = nil
        }
        
        self.waitFor {
            weakList == nil
        }
    }
    
    func test_changing_supplementary_views()
    {
        // Ensure that we can swap out a supplementary view without any other changes.
        // Before nesting the supplementary views provided by the developer in a container
        // view that is always present, this code would crash because the collection
        // view does not know to refresh the views.
        
        let listView = ListView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
                
        listView.configure { list in
            list.animatesChanges = false
            
            list += Section("a-section")
            list.content.overscrollFooter = HeaderFooter(TestSupplementary())
        }
        
        listView.collectionView.contentOffset.y = 100
        self.waitForOneRunloop()
        
        listView.configure { list in
            list.animatesChanges = false
            
            list += Section("a-section")
            list.content.overscrollFooter = nil
        }
        
        listView.collectionView.contentOffset.y = 100
        self.waitForOneRunloop()
        
        listView.configure { list in
            list.animatesChanges = false
            
            list += Section("a-section")
            list.content.overscrollFooter = HeaderFooter(TestSupplementary())
        }
        
        listView.collectionView.contentOffset.y = 100
        self.waitForOneRunloop()
    }
    
    func test_calculateScrollViewInsets()
    {
        let listView = ListView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
        
        listView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        
        self.testcase("Nil Keyboard Frame") {
            let (content, scroll) = listView.calculateScrollViewInsets(with: nil)
            
            XCTAssertEqual(
                content,
                UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            )
            
            XCTAssertEqual(
                scroll,
                UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
            )
        }
        
        self.testcase("Non-Overlapping Keyboard Frame") {
            let (content, scroll) = listView.calculateScrollViewInsets(with: .nonOverlapping)
            
            XCTAssertEqual(
                content,
                UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            )
            
            XCTAssertEqual(
                scroll,
                UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
            )
        }
        
        self.testcase("Overlapping Keyboard Frame") {
            let (content, scroll) = listView.calculateScrollViewInsets(
                with:.overlapping(frame: CGRect(x: 0, y: 200, width: 200, height: 200))
            )
            
            XCTAssertEqual(
                content,
                UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
            )
            
            XCTAssertEqual(
                scroll,
                UIEdgeInsets(top: 10, left: 20, bottom: 200, right: 40)
            )
        }
    }
    
    func test_change_size() {
        
        /// Ensure we respect the size of the view changing via both bounds and frame.
        /// Frame is usually used via manual layout or Blueprint, whereas bounds is
        /// set by autolayout if a developer is using autolayout.
        
        self.testcase("set bounds") {
            let view = ListView()
            view.bounds.size = CGSize(width: 200, height: 200)
            
            XCTAssertEqual(view.collectionView.bounds.size, CGSize(width: 200, height: 200))
        }
        
        self.testcase("set frame") {
            let view = ListView()
            view.frame.size = CGSize(width: 200, height: 200)
            
            XCTAssertEqual(view.collectionView.bounds.size, CGSize(width: 200, height: 200))
        }
    }
    
    func test_changing_to_empty_frame_does_not_crash() {
        
        let view = ListView()
        view.frame.size = CGSize(width: 200, height: 400)
        
        view.configure { list in
            
            for section in 1...5 {
                
                list(section) { section in
                    section.header = HeaderFooter(
                        TestSupplementary(),
                        sizing: .fixed(height: 50)
                    )
                    
                    for row in 1...10 {
                        section += Item(
                            TestContent(content: row),
                            sizing: .fixed(height: 50)
                        )
                    }
                }
            }
        }
        
        /// Force the cells in the collection view to be updated.
        view.collectionView.layoutIfNeeded()
        
        /// Changing the view width to an empty size removes content
        /// from the inner collection view, because laying out content
        /// with zero area is meaningless.
        ///
        /// This test is here because this change would previously crash at this line,
        /// because the collection view layout's `visibleLayoutAttributesForElements`
        /// had not yet updated, leaving us with invalid index paths.
        view.frame.size.width = 0.0
        
        view.collectionView.layoutIfNeeded()
        
        view.frame.size.width = 200
        
        view.collectionView.layoutIfNeeded()
    }
}


fileprivate struct TestContent : ItemContent, Equatable
{
    var content : AnyHashable
    
    var identifier: Identifier<TestContent> {
        return .init(self.content)
    }
    
    func apply(
        to views: ItemContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyItemContentInfo
    ) {
        views.content.backgroundColor = .red
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }
}


fileprivate struct TestSupplementary : HeaderFooterContent, Equatable
{
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        views.content.backgroundColor = .blue
    }
    
    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }
}
