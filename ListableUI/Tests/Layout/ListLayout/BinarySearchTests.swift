//
//  BinarySearchTests.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 3/2/21.
//

import XCTest
@testable import ListableUI


let binarySearchVerticalRects : [CGRect] = [
    CGRect(x: 0, y: 0, width: 100, height: 10),
    CGRect(x: 0, y: 10, width: 100, height: 10),
    CGRect(x: 0, y: 20, width: 100, height: 10),
    CGRect(x: 0, y: 30, width: 100, height: 10),
    CGRect(x: 0, y: 40, width: 100, height: 10),
    CGRect(x: 0, y: 50, width: 100, height: 10),
    CGRect(x: 0, y: 60, width: 100, height: 10),
    CGRect(x: 0, y: 70, width: 100, height: 10),
    CGRect(x: 0, y: 80, width: 100, height: 10),
    CGRect(x: 0, y: 90, width: 100, height: 10),
]


class BinarySearch_Tests : XCTestCase {
    
    func test_forEachForwardFrom() {
        // TODO...
    }
    
    func test_fowardFrom() {
        
        self.testcase("vertical") {
            let rects = binarySearchVerticalRects
            
            XCTAssertEqual(
                rects.forwardFrom {
                    .compare(
                        frame: $0,
                        in: CGRect(x: 0, y: 0, width: 100, height: 30),
                        direction: .vertical
                    )
                },
                
                0
            )
            
            XCTAssertEqual(
                rects.forwardFrom {
                    .compare(
                        frame: $0,
                        in: CGRect(x: 0, y: 25, width: 100, height: 30),
                        direction: .vertical
                    )
                },
                
                2
            )
        }
    }
    
    func test_binarySearch() {
        
        self.testcase("vertical") {
            let rects = binarySearchVerticalRects
            
            XCTAssertEqual(
                rects.binarySearch(
                    for: {
                        .compare(
                            frame: $0,
                            in: CGRect(x: 0, y: 25, width: 100, height: 1),
                            direction: .vertical
                        )
                    },
                    in: 0..<rects.count
                ),
                
                2
            )
            
            XCTAssertEqual(
                rects.binarySearch(
                    for: {
                        .compare(
                            frame: $0,
                            in: CGRect(x: 0, y: 25, width: 100, height: 30),
                            direction: .vertical
                        )
                    },
                    in: 0..<rects.count
                ),
                
                5
            )
        }
    }
}


class BinarySearch_ComparisonTests : XCTestCase {
    
    func test_compare() {
        
        self.testcase("vertical") {
            
            XCTAssertEqual(
                BinarySearchComparison.compare(
                    frame: CGRect(x: 0, y: -11, width: 100, height: 10),
                    in: CGRect(x: 0, y: 0, width: 100, height: 100),
                    direction: .vertical
                ),
                
                .less
            )
            
            XCTAssertEqual(
                BinarySearchComparison.compare(
                    frame: CGRect(x: 0, y: -10, width: 100, height: 10),
                    in: CGRect(x: 0, y: 0, width: 100, height: 100),
                    direction: .vertical
                ),
                
                .equal
            )
                    
            XCTAssertEqual(
                BinarySearchComparison.compare(
                    frame: CGRect(x: 0, y: 0, width: 100, height: 10),
                    in: CGRect(x: 0, y: 0, width: 100, height: 100),
                    direction: .vertical
                ),
                
                .equal
            )
            
            XCTAssertEqual(
                BinarySearchComparison.compare(
                    frame: CGRect(x: 0, y: 100, width: 100, height: 10),
                    in: CGRect(x: 0, y: 0, width: 100, height: 100),
                    direction: .vertical
                ),
                
                .equal
            )

            XCTAssertEqual(
                BinarySearchComparison.compare(
                    frame: CGRect(x: 0, y: 101, width: 100, height: 10),
                    in: CGRect(x: 0, y: 0, width: 100, height: 100),
                    direction: .vertical
                ),
                
                .greater
            )
        }
        
        self.testcase("horizontal") {
            
        }
    }
}
