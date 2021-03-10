//
//  LongListPerformanceTestViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 3/1/21.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

import ListableUI


final class LongListPerformanceTestViewController : ListViewController {
    
    override func configure(list: inout ListProperties) {
        
        list.layout = .table {
            $0.layout.itemSpacing = 10
        }
        
        for section in 1...20 {
            
            list(section) { section in
                
                for row in 1...10_000 {
                    
                    section += Item(
                        BasicContent(row: row),
                        sizing: .fixed(height: 50)
                    )
                }
            }
        }
    }
}


fileprivate struct BasicContent : ItemContent, Equatable {
    
    var row : Int
    
    var identifier: Identifier<BasicContent> {
        .init(self.row)
    }
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
    
    func apply(
        to views: ItemContentViews<BasicContent>,
        for reason: ApplyReason,
        with info: ApplyItemContentInfo
    ) {
        views.content.backgroundColor = .white(0.9)
    }
}
