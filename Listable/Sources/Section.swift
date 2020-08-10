//
//  Section.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public struct Section
{
    //
    // MARK: Public Properties
    //
    
    public var info : AnySectionInfo
    
    public var layout : Layout
    public var columns : Columns
    
    public var header : AnyHeaderFooter?
    public var footer : AnyHeaderFooter?
    
    public var items : [AnyItem]
    
    public var isEmpty : Bool {
        return self.items.isEmpty
    }
    
    //
    // MARK: Initialization
    //
    
    public typealias Build = (inout Section) -> ()
    
    public init<Identifier:Hashable>(
        _ identifier : Identifier,
        build : Build
    ) {
        self.init(identifier)
        
        build(&self)
    }

    public init<Info:SectionInfo>(
        _ info: Info,
        build : Build
    ) {
        self.init(info)
        
        build(&self)
    }
    
    public init<Identifier:Hashable>(
        _ identifier : Identifier,
        layout : Layout = Layout(),
        columns : Columns = .one,
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        items : [AnyItem] = []
    ) {
        self.init(
            HashableSectionInfo(identifier),
            layout: layout,
            columns: columns,
            header: header,
            footer: footer,
            items: items
        )
    }
    
    public init<Info:SectionInfo>(
        _ info: Info,
        layout : Layout = Layout(),
        columns : Columns = .one,
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        items : [AnyItem] = []
    ) {
        self.info = info
        
        self.layout = layout
        self.columns = columns
        
        self.header = header
        self.footer = footer
        
        self.items = items
    }
    
    //
    // MARK: Adding & Removing Single Items
    //
    
    public mutating func add(_ item : AnyItem)
    {
        self.items.append(item)
    }
    
    public static func += (lhs : inout Section, rhs : AnyItem)
    {
        lhs.add(rhs)
    }
    
    public static func += <Content:ItemContent>(lhs : inout Section, rhs : Item<Content>)
    {
        lhs.add(rhs)
    }
    
    public static func += <Content:ItemContent>(lhs : inout Section, rhs : Content)
    {
        lhs += Item(rhs)
    }
    
    //
    // MARK: Adding & Removing Multiple Items
    //
    
    public static func += (lhs : inout Section, rhs : [AnyItem])
    {
        lhs.items += rhs
    }
    
    public static func += <Content:ItemContent>(lhs : inout Section, rhs : [Item<Content>])
    {
        lhs.items += rhs
    }
    
    public static func += <Content:ItemContent>(lhs : inout Section, rhs : [Content])
    {
        lhs.items += rhs.map { Item($0) }
    }
    
    //
    // MARK: Slicing
    //
    
    internal func itemsUpTo(limit : Int) -> [AnyItem]
    {
        let end = min(self.items.count, limit)
        
        return Array(self.items[0..<end])
    }
}


public extension Section
{
    struct Layout : Equatable
    {
        public var width : CustomWidth

        /// Overrides the calculated spacing after this section
        public var customInterSectionSpacing : CGFloat?
        
        public init(width : CustomWidth = .default, customInterSectionSpacing : CGFloat? = nil)
        {
            self.width = width
            self.customInterSectionSpacing = customInterSectionSpacing
        }
    }
    
    struct Columns
    {
        public var count : Int
        public var spacing : CGFloat
        
        public static var one : Columns {
            return Columns(count: 1, spacing: 0.0)
        }
        
        public init(count : Int = 1, spacing : CGFloat = 0.0)
        {
            precondition(count >= 1, "Columns must be greater than or equal to 1.")
            precondition(spacing >= 0.0, "Spacing must be greater than or equal to 0.")
            
            self.count = count
            self.spacing = spacing
        }
    }
}


public protocol SectionInfo : AnySectionInfo
{
    //
    // MARK: Identifying Content & Changes
    //
    
    var identifier : Identifier<Self> { get }
    
    func wasMoved(comparedTo other : Self) -> Bool
}


public protocol AnySectionInfo
{
    //
    // MARK: Identifying Content & Changes
    //
    
    var anyIdentifier : AnyIdentifier { get }
    
    func anyWasMoved(comparedTo other : AnySectionInfo) -> Bool
}


public extension SectionInfo
{
    var anyIdentifier : AnyIdentifier {
        self.identifier
    }
    
    func anyWasMoved(comparedTo other : AnySectionInfo) -> Bool
    {
        guard let other = other as? Self else {
            return true
        }
        
        return self.wasMoved(comparedTo: other)
    }
}


private struct HashableSectionInfo<Value:Hashable> : SectionInfo
{
    var value : Value
    
    init(_ value : Value)
    {
        self.value = value
    }
    
    // MARK: SectionInfo
    
    var identifier : Identifier<HashableSectionInfo> {
        return .init(self.value)
    }
    
    func wasMoved(comparedTo other : HashableSectionInfo) -> Bool
    {
        return self.value != other.value
    }
}
