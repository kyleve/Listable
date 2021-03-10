//
//  BinarySearch.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 3/2/21.
//

import Foundation


enum BinarySearch {
    
    enum Comparison : Equatable {
        
        case less
        case equal
        case greater
        
        static func compare(
            frame : CGRect,
            in parent : CGRect,
            direction : LayoutDirection
        ) -> Self
        {
            switch direction {
            case .vertical:
                if frame.maxY < parent.origin.y {
                    return .less
                } else if frame.minY > parent.maxY {
                    return .greater
                } else {
                    return .equal
                }
                
            case .horizontal:
                fatalError("TODO")
            }
        }
    }
    
    /// Implements a binary search to find the first object in an array
    /// that passes the given test, and then enumerates forwards until
    /// the `forEach` closure returns false.
    static func forEach<Element>(
        in array : Array<Element>,
        first isFirst : (Element) -> BinarySearch.Comparison,
        forEach : (Int, Element) -> Bool
    ) {
        guard let start = self.firstIndexPassing(in: array, isFirst: isFirst) else {
            return
        }
        
        for (index, item) in array[start..<array.endIndex].enumerated() {
            if forEach(index + start, item) == false { // TODO: I think the index here is wrong? Did the fix fix it?
                break
            }
        }
    }
    
    static func firstIndexPassing<Element>(
        in array : Array<Element>,
        isFirst : (Element) -> BinarySearch.Comparison
    ) -> Int?
    {
        guard let startGuess = self.binarySearch(in: array, for: isFirst, range: 0..<array.count) else {
            return nil
        }
        
        let slice = array[0...startGuess]
        
        for (index, element) in slice.reversed().enumerated() {
            let comparison = isFirst(element)
            
            if comparison == .less {
                return startGuess - index + 1
            }
        }
        
        return 0
    }
    
    static func binarySearch<Element>(
        in array : Array<Element>,
        for find : (Element) -> BinarySearch.Comparison,
        range : Range<Int>
    ) -> Int?
    {
        guard array.isEmpty == false else {
            return nil
        }
        
        var lower = 0
        var upper = array.count
        
        while lower < upper {
            let index = lower + (upper - lower) / 2
            
            let result = find(array[index])
            
            switch result {
            case .less:
                lower = index + 1
            case .equal:
                return index
            case .greater:
                upper = index
            }
        }
        
        return nil
    }
}
