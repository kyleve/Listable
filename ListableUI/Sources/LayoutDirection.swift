//
//  LayoutDirection.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/10/19.
//


///
/// Describes the given direction / axis that a layout uses when flowing its content.
///
/// Traditional table views / lists you see use a `.vertical` layout direction, however,
/// you may want to use `.horizontal` for embedded lists that scroll
/// horizontally in a larger vertical list, similar to what you would see in the iOS App Store,
/// or for a list that users can scroll left to right.
/// ```
/// .vertical:
/// ┌─────────┐
/// │┌───────┐│
/// ││       ││
/// │└───────┘│
/// │┌───────┐│
/// ││       ││
/// │└───────┘│
/// │┌───────┐│
/// ││       ││
/// │└───────┘│
/// └─────────┘
///
/// .horizontal:
/// ┌────────────────────┐
/// │┌────┐ ┌────┐ ┌────┐│
/// ││    │ │    │ │    ││
/// ││    │ │    │ │    ││
/// │└────┘ └────┘ └────┘│
/// └────────────────────┘
/// ```
/// When writing custom list layouts, `LayoutDirection` provides many helper methods
/// to convert the coordinates of `CGSize`, `CGPoint`, `CGRect`, etc, to horizontal or vertical
/// layout directions. See the extensions in this file for more details.
///
public enum LayoutDirection : Hashable
{
    /// A list layout which lays out top to bottom.
    /// ```
    /// ┌─────────┐
    /// │┌───────┐│
    /// ││       ││
    /// │└───────┘│
    /// │┌───────┐│
    /// ││       ││
    /// │└───────┘│
    /// │┌───────┐│
    /// ││       ││
    /// │└───────┘│
    /// └─────────┘
    /// ```
    case vertical
    
    /// A list layout which lays out left to right (or leading to trailing, depending on implementation).
    /// ```
    /// ┌────────────────────┐
    /// │┌────┐ ┌────┐ ┌────┐│
    /// ││    │ │    │ │    ││
    /// ││    │ │    │ │    ││
    /// │└────┘ └────┘ └────┘│
    /// └────────────────────┘
    /// ```
    case horizontal
}


extension LayoutDirection
{
    /// When writing a layout, use this method to return differing values based on
    /// the direction. The passed closures will only be evaluated if they are for the current direction.
    public func `switch`<Value>(vertical : () -> Value, horizontal : () -> Value) -> Value {
        switch self {
        case .vertical: return vertical()
        case .horizontal: return horizontal()
        }
    }
    
    /// When writing a layout, use this method to return differing values based on
    /// the direction. The passed autoclosures will only be evaluated if they are for the current direction.
    public func `switch`<Value>(vertical : @autoclosure () -> Value, horizontal : @autoclosure () -> Value) -> Value {
        switch self {
        case .vertical: return vertical()
        case .horizontal: return horizontal()
        }
    }
}


extension LayoutDirection
{
    //
    // MARK: Creating & Reading Values
    //
    
    /// `.vertical`: Returns the **height** of the provided size.
    /// `.horizontal`: Returns the **width** of the provided size.
    public func height(for size : CGSize) -> CGFloat
    {
        switch self {
        case .vertical: return size.height
        case .horizontal: return size.width
        }
    }
    
    /// `.vertical`: Returns the **width** of the provided size.
    /// `.horizontal`: Returns the **height** of the provided size.
    public func width(for size : CGSize) -> CGFloat
    {
        switch self {
        case .vertical: return size.width
        case .horizontal: return size.height
        }
    }
    
    /// `.vertical`: Returns a `CGPoint` made with `(x, y)`.
    /// `.horizontal`: Returns a `CGPoint` made with `(y, x)`.
    public func point(x : CGFloat, y : CGFloat) -> CGPoint
    {
        switch self {
        case .vertical: return CGPoint(x: x, y: y)
        case .horizontal: return CGPoint(x: y, y: x)
        }
    }
    
    /// `.vertical`: Returns the provided size.
    /// `.horizontal`: Returns a size created by swapping the width and height.
    public func size(for size : CGSize) -> CGSize
    {
        switch self {
        case .vertical: return CGSize(width: size.width, height: size.height)
        case .horizontal: return CGSize(width: size.height, height: size.width)
        }
    }
    
    /// `.vertical`: Returns a `CGSize` made with `(width, height)`.
    /// `.horizontal`: Returns a `CGSize` made with `(height, width)`.
    public func size(width : CGFloat, height : CGFloat) -> CGSize
    {
        switch self {
        case .vertical: return CGSize(width: width, height: height)
        case .horizontal: return CGSize(width: height, height: width)
        }
    }
    
    /// `.vertical`: Returns the **maxY** of the frame.
    /// `.horizontal`: Returns the **maxX** of the frame.
    public func maxY(for frame : CGRect) -> CGFloat
    {
        switch self {
        case .vertical: return frame.maxY
        case .horizontal: return frame.maxX
        }
    }
    
    /// `.vertical`: Returns the **maxX** of the frame.
    /// `.horizontal`: Returns the **maxY** of the frame.
    public func maxX(for frame : CGRect) -> CGFloat
    {
        switch self {
        case .vertical: return frame.maxX
        case .horizontal: return frame.maxY
        }
    }
    
    /// `.vertical`: Returns the **x** of the point.
    /// `.horizontal`: Returns the **y** of the point.
    public func x(for point : CGPoint) -> CGFloat
    {
        switch self {
        case .vertical: return point.x
        case .horizontal: return point.y
        }
    }
    
    /// `.vertical`: Returns the **y** of the point.
    /// `.horizontal`: Returns the **x** of the point.
    public func y(for point : CGPoint) -> CGFloat
    {
        switch self {
        case .vertical: return point.y
        case .horizontal: return point.x
        }
    }
    
    /// `.vertical`: Returns the **top** of the insets.
    /// `.horizontal`: Returns the **left** of the insets.
    public func top(with insets : UIEdgeInsets) -> CGFloat
    {
        switch self {
        case .vertical: return insets.top
        case .horizontal: return insets.left
        }
    }
    
    /// `.vertical`: Returns the **bottom** of the insets.
    /// `.horizontal`: Returns the **right** of the insets.
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
    
    func set<Value>(
        for direction : LayoutDirection,
        vertical : ReferenceWritableKeyPath<Self,Value>,
        horizontal : ReferenceWritableKeyPath<Self,Value>,
        value : Value
    ) {
        switch direction {
        case .vertical:
            self[keyPath: vertical] = value
        case .horizontal:
            self[keyPath: horizontal] = value
        }
    }
}
