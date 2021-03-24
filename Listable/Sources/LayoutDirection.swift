//
//  LayoutDirection.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/10/19.
//


public enum LayoutDirection : Hashable
{
    case vertical
    case horizontal
    
    public func `switch`<Value>(vertical : () -> Value, horizontal : () -> Value) -> Value {
        switch self {
        case .vertical: return vertical()
        case .horizontal: return horizontal()
        }
    }
    
    public func `switch`<Value>(vertical : @autoclosure () -> Value, horizontal : @autoclosure () -> Value) -> Value {
        switch self {
        case .vertical: return vertical()
        case .horizontal: return horizontal()
        }
    }
    
    //
    // MARK: Creating & Reading Values
    //
    
    public func height(for size : CGSize) -> CGFloat
    {
        switch self {
        case .vertical: return size.height
        case .horizontal: return size.width
        }
    }
    
    public func width(for size : CGSize) -> CGFloat
    {
        switch self {
        case .vertical: return size.width
        case .horizontal: return size.height
        }
    }
    
    public func point(x : CGFloat, y : CGFloat) -> CGPoint
    {
        switch self {
        case .vertical: return CGPoint(x: x, y: y)
        case .horizontal: return CGPoint(x: y, y: x)
        }
    }
    
    public func size(for size : CGSize) -> CGSize
    {
        switch self {
        case .vertical: return CGSize(width: size.width, height: size.height)
        case .horizontal: return CGSize(width: size.height, height: size.width)
        }
    }
    
    public func size(width : CGFloat, height : CGFloat) -> CGSize
    {
        switch self {
        case .vertical: return CGSize(width: width, height: height)
        case .horizontal: return CGSize(width: height, height: width)
        }
    }
    
    public func maxY(for frame : CGRect) -> CGFloat
    {
        switch self {
        case .vertical: return frame.maxY
        case .horizontal: return frame.maxX
        }
    }
    
    public func maxX(for frame : CGRect) -> CGFloat
    {
        switch self {
        case .vertical: return frame.maxX
        case .horizontal: return frame.maxY
        }
    }
    
    public func x(for point : CGPoint) -> CGFloat
    {
        switch self {
        case .vertical: return point.x
        case .horizontal: return point.y
        }
    }
    
    public func y(for point : CGPoint) -> CGFloat
    {
        switch self {
        case .vertical: return point.y
        case .horizontal: return point.x
        }
    }
    
    public func top(with insets : UIEdgeInsets) -> CGFloat
    {
        switch self {
        case .vertical: return insets.top
        case .horizontal: return insets.left
        }
    }
    
    public func bottom(with insets : UIEdgeInsets) -> CGFloat
    {
        switch self {
        case .vertical: return insets.bottom
        case .horizontal: return insets.right
        }
    }
}


protocol LayoutDirectionVarying : AnyObject {
    
    func set<Value>(
        for direction : LayoutDirection,
        vertical : ReferenceWritableKeyPath<Self,Value>,
        horizontal : ReferenceWritableKeyPath<Self,Value>,
        value : () -> Value
    )
}


extension LayoutDirectionVarying {
    
    func set<Value>(
        for direction : LayoutDirection,
        vertical : ReferenceWritableKeyPath<Self,Value>,
        horizontal : ReferenceWritableKeyPath<Self,Value>,
        value : () -> Value
    ) {
        switch direction {
        case .vertical:
            self[keyPath: vertical] = value()
        case .horizontal:
            self[keyPath: horizontal] = value()
        }
    }
}
