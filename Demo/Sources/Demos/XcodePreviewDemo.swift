//
//  XcodePreviewDemo.swift
//  Demo
//
//  Created by Kyle Van Essen on 6/9/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import SwiftUI
import BlueprintUICommonControls
import BlueprintUILists
import ListableUI


fileprivate struct XcodePreviewDemoContent : BlueprintItemContent, Equatable
{
    var text : String
    
    var identifier: Identifier<XcodePreviewDemoContent> {
        return .init(text)
    }
    
    func element(with info : ApplyItemContentInfo) -> Element
    {
        Row { row in
            row.verticalAlignment = .fill
            row.horizontalUnderflow = .growProportionally
            row.minimumHorizontalSpacing = 10.0
            
            row.add(
                growPriority: 0,
                shrinkPriority: 0,
                child: Image(image: UIImage(named: "kyle.png"))
                    .box(corners: .rounded(radius: 10.0), clipsContent: true)
                    .constrainedTo(width: .absolute(70.0), height: .absolute(70.0))
                    .aligned(vertically: .top, horizontally: .fill)
            )
            
            row.add(child: Column { column in
                column.horizontalAlignment = .fill
                column.verticalUnderflow = .justifyToCenter
                column.minimumVerticalSpacing = 10.0
                
                let color : UIColor = {
                    if info.state.isSelected {
                          return .white
                      } else if info.state.isHighlighted {
                          return .white
                      } else {
                          return .black
                      }
                }()
                
                column.add(child: Label(text: self.text) {
                    $0.font = .systemFont(ofSize: 16.0, weight: .medium)
                    $0.color = color
                })
                
                column.add(child: Label(text: "2 days ago") {
                    $0.font = .systemFont(ofSize: 12.0, weight: .medium)
                    $0.color = color
                })
            })
        }
        .inset(horizontal: 15.0, vertical: 15.0)
    }
    
    func backgroundElement(with info: ApplyItemContentInfo) -> Element?
    {
        Box(
            backgroundColor: .white,
            cornerStyle: .rounded(radius: 0.0),
            shadowStyle: .simple(radius: 2.0, opacity: 0.25, offset: .init(width: 0.0, height: 1.0), color: .black)
        )
    }
    
    func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element?
    {
        Box(
            backgroundColor: info.state.isSelected ? .white(0.2) : .white(0.5),
            cornerStyle: .rounded(radius: 0.0),
            shadowStyle: .simple(radius: 2.0, opacity: 0.25, offset: .init(width: 0.0, height: 1.0), color: .black)
        )
    }
}


#if DEBUG && canImport(SwiftUI) && !arch(i386) && !arch(arm)

@available(iOS 13.0, *)
struct XcodePreviewDemo_Preview : PreviewProvider {
    static var previews: some View {
        ItemPreview.withAllItemStates(
            for: Item(XcodePreviewDemoContent(
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam vestibulum, dui id lacinia rutrum."
            ))
        )
    }
}

#endif
