//
//  ItemPosition.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/13/20.
//

import Foundation


public enum ItemPosition
{
    case single
    
    case first
    case middle
    case last
    
    public func listCorners(for direction : LayoutDirection) -> UIRectCorner {
        switch direction {
        case .vertical:
            switch self {
            case .single: return .allCorners
            case .first: return [.topLeft, .topRight]
            case .middle: return []
            case .last: return [.bottomLeft, .bottomRight]
            }
        case .horizontal:
            switch self {
            case .single: return .allCorners
            case .first: return [.bottomLeft, .topLeft]
            case .middle: return []
            case .last: return [.bottomRight, .topRight]
            }
        }
    }
}
