//
//  Section.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//


public struct Section
{
    //
    // MARK: Public Properties
    //
    
    /// The value which uniquely identifies the section within a list.
    public var identifier : Identifier<Section>
    
    /// The header, if any, associated with the section.
    public var header : AnyHeaderFooter?
    
    /// The footer, if any, associated with the section.
    public var footer : AnyHeaderFooter?
    
    /// The items, if any, associated with the section.
    public var items : [AnyItem]
    
    /// Check if the section contains any of the given types, which you specify via the `filters`
    /// parameter. If you do not specify a `filters` parameter, `[.items]` is used.
    public func contains(any filters : Set<ContentFilters> = [.items]) -> Bool {
        
        for filter in filters {
            switch filter {
            case .listHeader: break
            case .listFooter: break
            case .overscrollFooter: break
                
            case .sectionHeaders:
                if self.header != nil {
                    return true
                }
            case .sectionFooters:
                if self.footer != nil {
                    return true
                }
            case .items:
                if items.isEmpty == false {
                    return true
                }
            }
        }
        
        return false
    }
    
    //
    // MARK: Layout Specific Parameters
    //
    
    public var layouts : SectionLayouts = .init()
    
    //
    // MARK: Initialization
    //
    
    public typealias Configure = (inout Section) -> ()
    
    public init<IdentifierType:Hashable>(
        _ identifier : IdentifierType,
        layouts : SectionLayouts = .init(),
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        items : [AnyItem] = [],
        configure : Configure = { _ in }
    ) {
        self.identifier = Identifier<Section>(identifier)
        
        self.layouts = layouts
        
        self.header = header
        self.footer = footer
        
        self.items = items
        
        configure(&self)
    }
    
#if swift(>=5.4)
    public init<IdentifierType:Hashable>(
        _ identifier : IdentifierType,
        @ContentBuilder<AnyItemConvertible> items : () -> [AnyItemConvertible]
    ) {
        self.init(identifier)

        self(items)
    }
#endif
    
    //
    // MARK: Building Content
    //
    
#if swift(>=5.4)
    ///
    ///
    ///
    public mutating func callAsFunction(
        @ContentBuilder<AnyItemConvertible> _ content : () -> [AnyItemConvertible]
    ) {
        self.items += content().map { $0.asItem() }
    }
#endif

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
