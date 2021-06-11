//
//  ListTests.swift
//  BlueprintUILists-Unit-Tests
//
//  Created by Kyle Van Essen on 10/26/20.
//

import XCTest
import BlueprintUI

@testable import BlueprintUILists


class ListTests : XCTestCase {
    
    func test_environment_passthrough() {
        let view = BlueprintView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
        
        var callCount : Int = 0
        
        let callback = {
            callCount += 1
        }
        
        view.element = List { list in
            
            list.header = HeaderFooter(TestHeaderContent(wasCalled: callback))
            list.footer = HeaderFooter(TestHeaderContent(wasCalled: callback))
            
            list("section") { section in
                
                section.header = HeaderFooter(TestHeaderContent(wasCalled: callback))
                section.footer = HeaderFooter(TestHeaderContent(wasCalled: callback))
                
                section += TestItemContent(wasCalled: callback)
                section += TestItemContent(wasCalled: callback)
            }
        }.adaptedEnvironment { env in
            env[TestingKey.self] = true
        }
        
        // Should have no calls yet – we haven't laid out the view.
        XCTAssertEqual(callCount, 0)
        
        view.layoutIfNeeded()
        
        // Expecting one call for every header, footer, and item's content, background, and pressed background.
        XCTAssertEqual(callCount, 36)
    }
}


fileprivate struct TestHeaderContent : BlueprintHeaderFooterContent {
    
    var wasCalled : () -> ()
    
    var elementRepresentation: Element {
        self.wasCalled()
        
        return EnvironmentReader { env in
            XCTAssertTrue(env[TestingKey.self])
            return Empty()
        }
    }
    
    var background: Element? {
        self.wasCalled()
        
        return EnvironmentReader { env in
            XCTAssertTrue(env[TestingKey.self])
            return Empty()
        }
    }
    
    var pressedBackground: Element? {
        self.wasCalled()
        
        return EnvironmentReader { env in
            XCTAssertTrue(env[TestingKey.self])
            return Empty()
        }
    }
    
    func isEquivalent(to other: TestHeaderContent) -> Bool {
        true
    }
}


fileprivate struct TestItemContent : BlueprintItemContent {
    
    var wasCalled : () -> ()
    
    var identifier: Identifier<TestItemContent> {
        .init()
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        self.wasCalled()
        
        return EnvironmentReader { env in
            XCTAssertTrue(env[TestingKey.self])
            return Empty()
        }
    }
    
    func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        self.wasCalled()
        
        return EnvironmentReader { env in
            XCTAssertTrue(env[TestingKey.self])
            return Empty()
        }
    }
    
    func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element? {
        self.wasCalled()
        
        return EnvironmentReader { env in
            XCTAssertTrue(env[TestingKey.self])
            return Empty()
        }
    }
    
    func isEquivalent(to other: TestItemContent) -> Bool {
        true
    }
}


fileprivate struct TestingKey : EnvironmentKey {
    static var defaultValue: Bool {
        false
    }
}
