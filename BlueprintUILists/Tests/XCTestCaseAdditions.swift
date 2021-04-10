//
//  XCTestCaseAdditions.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest


extension XCTestCase
{
    func determineAverage(for seconds : TimeInterval, using block : () -> ()) {
        let start = Date()

        var iterations : Int = 0
        
        var lastUpdateDate = Date()

        repeat {
            block()
            
            iterations += 1
            
            if Date().timeIntervalSince(lastUpdateDate) >= 1 {
                lastUpdateDate = Date()
                print("Continuing Test...")
            }

        } while Date() < start + seconds

        let end = Date()

        let duration = end.timeIntervalSince(start)
        let average = duration / TimeInterval(iterations)

        print("Iterations: \(iterations), Average Time: \(average)")
    }
}
