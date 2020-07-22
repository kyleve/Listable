//
//  Content.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/21/19.
//



public struct Content
{
    //
    // MARK: Content Data
    //
    
    public var identifier : AnyHashable?

    public var refreshControl : RefreshControl?
    
    public var header : AnyHeaderFooter?
    public var footer : AnyHeaderFooter?
    
    public var inputAccessory : ViewProvider?
    
    public var overscrollFooter : AnyHeaderFooter?
    
    public var sections : [Section]
    
    public var sectionsWithItems : [Section] {
        self.sections.filter { $0.items.isEmpty == false }
    }
    
    public var itemCount : Int {
        return self.sections.reduce(0, { $0 + $1.items.count })
    }
    
    public var isEmpty : Bool {
        return self.sections.isEmpty || self.sections.allSatisfy { $0.isEmpty }
    }
    
    //
    // MARK: Initialization
    //
    
    public typealias Build = (inout Content) -> ()
    
    public init(with build : Build)
    {
        self.init()
        
        build(&self)
    }
    
    public init(
        identifier : AnyHashable? = nil,
        refreshControl : RefreshControl? = nil,
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        inputAccessory : ViewProvider? = nil,
        overscrollFooter : AnyHeaderFooter? = nil,
        sections : [Section] = []
        )
    {
        self.identifier = identifier
        
        self.refreshControl = refreshControl
        
        self.header = header
        self.footer = footer
        
        self.inputAccessory = inputAccessory
        
        self.overscrollFooter = overscrollFooter
        
        self.sections = sections
    }
    
    //
    // MARK: Finding Content
    //
    
    public var firstItem : AnyItem? {
        guard let first = self.sectionsWithItems.first?.items.first else {
            return nil
        }
        
        return first
    }
    
    public var lastItem : AnyItem? {
        guard let last = self.sectionsWithItems.last?.items.last else {
            return nil
        }
        
        return last
    }
    
    public func item(at indexPath : IndexPath) -> AnyItem
    {
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.item]
        
        return item
    }
    
    public func indexPath(for identifier : AnyIdentifier) -> IndexPath?
    {
        for (sectionIndex, section) in self.sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                if item.identifier == identifier {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        
        return nil
    }

    /// Returns the true last index path of the content, while the one in PresentationState
    /// is the last index of the loaded content.
    public func lastIndexPath() -> IndexPath?
    {
        guard let lastSectionIndexWithItems = sections.lastIndex(where: { !$0.items.isEmpty }) else {
            return nil
        }

        return IndexPath(
            item: sections[lastSectionIndexWithItems].items.count,
            section: lastSectionIndexWithItems
        )
    }
    
    //
    // MARK: Mutating Content
    //
    
    mutating func moveItem(from : IndexPath, to : IndexPath)
    {
        guard from != to else {
            return
        }
        
        let item = self.item(at: from)
        
        self.remove(at: from)
        self.insert(item: item, at: to)
    }
    
    public mutating func removeEmpty()
    {
        self.sections.removeAll {
            $0.items.isEmpty
        }
    }
    
    public mutating func add(_ section : Section)
    {
        self.sections.append(section)
    }
    
    public static func += (lhs : inout Content, rhs : Section)
    {
        lhs.add(rhs)
    }
    
    public static func += (lhs : inout Content, rhs : [Section])
    {
        lhs.sections += rhs
    }
    
    /// Allows streamlined creation of sections when building a list.
    ///
    /// Example
    /// -------
    /// ```
    /// listView.configure { list in
    ///     list("section-id") { section in
    ///         ...
    ///     }
    /// }
    /// ```
    public mutating func callAsFunction<Identifier:Hashable>(_ identifier : Identifier, build : Section.Build)
    {
        self += Section(identifier, build: build)
    }
    
    internal mutating func remove(at indexPath : IndexPath)
    {
        self.sections[indexPath.section].items.remove(at: indexPath.item)
    }
    
    internal mutating func insert(item : AnyItem, at indexPath : IndexPath)
    {
        self.sections[indexPath.section].items.insert(item, at: indexPath.item)
    }
    
    //
    // MARK: Slicing Content
    //
    
    internal func sliceTo(indexPath : IndexPath, plus additionalItems : Int = Content.Slice.defaultCount) -> Slice
    {
        var sliced = self
        
        var remaining : Int = indexPath.item + additionalItems
        
        sliced.sections = self.sections.compactMapWithIndex { sectionIndex, _, section in
            if sectionIndex < indexPath.section {
                return section
            } else {
                guard remaining > 0 else {
                    return nil
                }
                
                var section = section
                section.items = section.itemsUpTo(limit: remaining)
                remaining -= section.items.count
                
                return section
            }
        }
        
        return Slice(
            containsAllItems: self.itemCount == sliced.itemCount,
            content: sliced
        )
    }
}


internal extension Content
{
    struct Slice
    {
        static let defaultCount : Int = 250
        
        let containsAllItems : Bool
        let content : Content
        
        init(containsAllItems : Bool, content : Content)
        {
            self.containsAllItems = containsAllItems
            self.content = content
        }
        
        init()
        {
            self.containsAllItems = true
            self.content = Content()
        }
        
        enum UpdateReason : Equatable
        {
            case scrolledDown
            case didEndDecelerating
            
            case scrolledToTop
            
            case contentChanged(animated : Bool, identifierChanged : Bool)
            
            case transitionedToBounds(isEmpty : Bool)
            
            case programaticScrollDownTo(IndexPath)
        
            var animated : Bool {
                switch self {
                case .scrolledDown: return false
                case .didEndDecelerating: return false
                case .scrolledToTop: return false
                    
                case .contentChanged(let animated, let identifierChanged): return animated && identifierChanged == false
                    
                case .transitionedToBounds(_): return false
                    
                case .programaticScrollDownTo(_): return false
                }
            }
        }
    }
}
