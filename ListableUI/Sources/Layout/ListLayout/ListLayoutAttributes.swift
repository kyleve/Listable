//
//  ListLayoutAttributes.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/7/20.
//

import Foundation
import UIKit


public struct ListLayoutAttributes : Equatable {
    
    var contentSize : CGSize
    
    var header : Supplementary?
    var footer : Supplementary?
    var overscrollFooter : Supplementary?
    
    var sections : [Section]
    
    public struct Section : Equatable {
        var frame : CGRect
        
        var header : Supplementary?
        var footer : Supplementary?
        var items : [Item]
    }
    
    public struct Supplementary : Equatable {
        var frame : CGRect
    }
    
    public struct Item : Equatable {
        var frame : CGRect
    }
}


extension ListLayoutAttributes {
    var stringRepresentation : String {
        var output = ""
        dump(self, to: &output)
        
        return output
    }
}
