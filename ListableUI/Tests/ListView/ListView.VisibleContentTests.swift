//
//  ListView.VisibleContentTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 5/17/20.
//

import XCTest
@testable import ListableUI

class ListView_VisibleContentTests : XCTestCase
{
    func test_update()
    {
        let listView = ListView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 150.0))
        
        listView.configure { list in
            
            list.appearance.backgroundColor = .black

            list.layout = .table {
                $0.stickySectionHeaders = false
            }
            
            list.header = HeaderFooter(
                TestHeaderFooter(color: .blue),
                sizing: .fixed(height: 50.0)
            )
            
            list.footer = HeaderFooter(
                TestHeaderFooter(color: .green),
                sizing: .fixed(height: 50.0)
            )
            
            list.overscrollFooter = HeaderFooter(
                TestHeaderFooter(color: .blue),
                sizing: .fixed(height: 50.0)
            )
            
            list += Section("section-1") { section in
                
                section.header = HeaderFooter(
                    TestHeaderFooter(color: .red),
                    sizing: .fixed(height: 50.0)
                )
                
                section.footer = HeaderFooter(
                    TestHeaderFooter(color: .red),
                    sizing: .fixed(height: 50.0)
                )
                
                section += Item(
                    TestContent(color: .init(white: 1.0, alpha: 1)),
                    sizing: .fixed(height: 100.0)
                )
                
                section += Item(
                    TestContent(color: .init(white: 0.9, alpha: 1)),
                    sizing: .fixed(height: 100.0)
                )
            }
        }
        
        // Scrolled to top.
        
        listView.collectionView.layoutIfNeeded()
        
        XCTAssertEqual(
            listView.visibleContent.info,
            
            ListView.VisibleContent.Info(
                headerFooters: [
                    .init(kind: .listHeader, indexPath: IndexPath(item: 0, section: 0)),
                    .init(kind: .sectionHeader, indexPath: IndexPath(item: 0, section: 0)),
                ],
                items: [
                    .init(identifier: Identifier<TestContent>(), indexPath: IndexPath(item: 0, section: 0))
                ]
            )
        )
        
        // Scroll down 50px, list header should no longer be visible.
        
        listView.collectionView.contentOffset.y += 50.0
        listView.collectionView.layoutIfNeeded()

        XCTAssertEqual(
            listView.visibleContent.info,
            
            ListView.VisibleContent.Info(
                headerFooters: [
                    .init(kind: .sectionHeader, indexPath: IndexPath(item: 0, section: 0)),
                ],
                items: [
                    .init(identifier: Identifier<TestContent>(), indexPath: IndexPath(item: 0, section: 0))
                ]
            )
        )
        
        // Scroll down another 50px, section header should no longer be visible,
        // next item should be visible.
        
        listView.collectionView.contentOffset.y += 50.0
        listView.collectionView.layoutIfNeeded()
                        
        XCTAssertEqual(
            listView.visibleContent.info,
            
            ListView.VisibleContent.Info(
                headerFooters: [],
                items: [
                    .init(identifier: Identifier<TestContent>(), indexPath: IndexPath(item: 0, section: 0)),
                    .init(identifier: Identifier<TestContent>(), indexPath: IndexPath(item: 1, section: 0))
                ]
            )
        )
        
        // Scroll down another 100px, first item should no longer be visible,
        // section footer should be visible.
        
        listView.collectionView.contentOffset.y += 100.0
        listView.collectionView.layoutIfNeeded()
                        
        XCTAssertEqual(
            listView.visibleContent.info,
            
            ListView.VisibleContent.Info(
                headerFooters: [
                    .init(kind: .sectionFooter, indexPath: IndexPath(item: 0, section: 0)),
                ],
                items: [
                    .init(identifier: Identifier<TestContent>(), indexPath: IndexPath(item: 1, section: 0))
                ]
            )
        )
        
        // Scroll down another 50px, list footer should now be visible.
        
        listView.collectionView.contentOffset.y += 50.0
        listView.collectionView.layoutIfNeeded()
                        
        XCTAssertEqual(
            listView.visibleContent.info,
            
            ListView.VisibleContent.Info(
                headerFooters: [
                    .init(kind: .sectionFooter, indexPath: IndexPath(item: 0, section: 0)),
                    .init(kind: .listFooter, indexPath: IndexPath(item: 0, section: 0)),
                ],
                items: [
                    .init(identifier: Identifier<TestContent>(), indexPath: IndexPath(item: 1, section: 0))
                ]
            )
        )
        
        // Scroll down another 50px, list overscroll footer should now be visible.
        
        listView.collectionView.contentOffset.y += 50.0
        listView.collectionView.layoutIfNeeded()
                        
        XCTAssertEqual(
            listView.visibleContent.info,
            
            ListView.VisibleContent.Info(
                headerFooters: [
                    .init(kind: .sectionFooter, indexPath: IndexPath(item: 0, section: 0)),
                    .init(kind: .listFooter, indexPath: IndexPath(item: 0, section: 0)),
                    .init(kind: .overscrollFooter, indexPath: IndexPath(item: 0, section: 0)),
                ],
                items: []
            )
        )
    }
}

fileprivate struct TestContent : ItemContent, Equatable
{
    var color : UIColor
    
    typealias ContentView = UIView
    
    var identifier: Identifier<TestContent> {
        .init()
    }
    
    func apply(to views: ItemContentViews<TestContent>, for reason: ApplyReason, with info: ApplyItemContentInfo)
    {
        views.content.backgroundColor = self.color
    }
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}

fileprivate struct TestHeaderFooter : HeaderFooterContent, Equatable
{
    var color : UIColor
    
    typealias ContentView = UIView
    
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        views.content.backgroundColor = self.color
    }
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}
