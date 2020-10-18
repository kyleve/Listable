//
//  Content.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/21/19.
//



public struct Content
{
    //
    // MARK: Content Data
    //
    
    /// The identifier for the content, defaults to nil.
    /// You don't need to set this value – but if you do, and change it to another value,
    /// the list will reload without animation.
    public var identifier : AnyHashable?
    
    ///
    public var pagingBehavior : PagingBehavior

    /// The refresh control, if any, associated with the list.
    public var refreshControl : RefreshControl?
    
    /// The header for the list, usually displayed before all other content.
    public var header : AnyHeaderFooter?
    /// The footer for the list, usually displayed after all other content.
    public var footer : AnyHeaderFooter?
    
    /// The overscroll footer for the list, which is displayed below the bottom bounds of the visible frame,
    /// so it is only visible if the user manually scrolls the list up to make it visible.
    public var overscrollFooter : AnyHeaderFooter?
    
    /// All sections in the list.
    public var sections : [Section]
    
    /// Any sections that have a non-zero number of items.
    public var nonEmptySections : [Section] {
        self.sections.filter { $0.items.isEmpty == false }
    }
    
    /// The total number of items in all of the sections in the list.
    public var itemCount : Int {
        return self.sections.reduce(0, { $0 + $1.items.count })
    }
    
    /// Check if the content contains any of the given types, which you specify via the `filters`
    /// parameter. If you do not specify a `filters` parameter, `[.items]` is used.
    public func contains(any filters : Set<ContentFilters> = [.items]) -> Bool {
        
        for filter in filters {
            switch filter {
            case .listHeader:
                if self.header != nil {
                    return true
                }
            case .listFooter:
                if self.footer != nil {
                    return true
                }
            case .overscrollFooter:
                if self.overscrollFooter != nil {
                    return true
                }
                
            case .sectionHeaders: break
            case .sectionFooters: break
            case .items: break
            }
        }
        
        for section in self.sections {
            if section.contains(any: filters) {
                return true
            }
        }
        
        return false
    }
    
    //
    // MARK: Initialization
    //
    
    public typealias Build = (inout Content) -> ()
    
    /// Creates a new instance, configured as needed via the provided builder block.
    public init(with build : Build)
    {
        self.init()
        
        build(&self)
    }
    
    /// Creates a new instance with the provided parameters.
    /// All parameters are optional, pass only what you need to customize.
    public init(
        identifier : AnyHashable? = nil,
        pagingBehavior : PagingBehavior = .paged(),
        refreshControl : RefreshControl? = nil,
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        overscrollFooter : AnyHeaderFooter? = nil,
        sections : [Section] = []
    ) {
        self.identifier = identifier
        self.pagingBehavior = pagingBehavior
        
        self.refreshControl = refreshControl
        
        self.header = header
        self.footer = footer
        
        self.overscrollFooter = overscrollFooter
        
        self.sections = sections
    }
    
    //
    // MARK: Finding Content
    //
    
    /// The first `Item` in the content. Returns nil if there is no content in any section.
    public var firstItem : AnyItem? {
        guard let first = self.nonEmptySections.first?.items.first else {
            return nil
        }
        
        return first
    }
    
    /// The last `Item` in the content. Returns nil if there is no content in any section.
    public var lastItem : AnyItem? {
        guard let last = self.nonEmptySections.last?.items.last else {
            return nil
        }
        
        return last
    }
    
    /// Returns the `Item` at the given `IndexPath`.
    /// The `IndexPath` must be valid. If it is not, a fatal error will occur,
    public func item(at indexPath : IndexPath) -> AnyItem
    {
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.item]
        
        return item
    }
    
    /// Returns the first `IndexPath` for the contained `Item` with the given `AnyIdentifier`,
    /// if it can be found. If nothing is found, nil is returned.
    /// If you have multiple `Item`s with the same identifier, the first one will be returned.
    public func firstIndexPath(for identifier : AnyIdentifier) -> IndexPath?
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

    /// Returns the `IndexPath` of the last `Item` in the content.
    /// Returns nil if there are no `Item`s in the content.
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
    
    /// /// Moves the `Item` at the `from` index path to the `to` index path.
    /// If the index paths are the same, nothing occurs.
    mutating func moveItem(from : IndexPath, to : IndexPath)
    {
        guard from != to else {
            return
        }
        
        let item = self.item(at: from)
        
        self.remove(at: from)
        self.insert(item: item, at: to)
    }
    
    /// Removes all `Section`s that do not contain any `Item`s.
    public mutating func removeEmpty()
    {
        self.sections.removeAll {
            $0.items.isEmpty
        }
    }
    
    /// Appends a `Section` to the end of the `Content`.
    public mutating func add(_ section : Section)
    {
        self.sections.append(section)
    }
    
    /// Appends a `Section` to the end of the `Content`.
    public static func += (lhs : inout Content, rhs : Section)
    {
        lhs.add(rhs)
    }
    
    /// Appends a list of `Section`s to the end of the `Content`.
    public static func += (lhs : inout Content, rhs : [Section])
    {
        lhs.sections += rhs
    }
    
    ///
    /// Allows streamlined creation of sections when building a list, leveraging Swift's `callAsFunction`
    /// feature, allowing treating objects as function calls.
    ///
    /// In layperson's terms, this allows you to replace code like this:
    /// ```
    /// listView.configure { list in
    ///     list += Section("section-id") { section in
    ///         ...
    ///     }
    /// }
    /// ```
    /// With this code, which is functionally identical:
    /// ```
    /// listView.configure { list in
    ///     list("section-id") { section in
    ///         ...
    ///     }
    /// }
    ///
    public mutating func callAsFunction<Identifier:Hashable>(_ identifier : Identifier, build : Section.Build)
    {
        self += Section(identifier, build: build)
    }
}


public extension Content
{
    ///
    enum PagingBehavior : Equatable
    {
        ///
        case paged(at: Int = 250)
        
        ///
        case includeAllContent
        
        
        func pageSize(with itemCount : Int) -> Int {
            switch self {
            case .paged(let size): return size
            case .includeAllContent: return itemCount
            }
        }
    }
}


internal extension Content
{
    struct Slice
    {
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
    }
    
    /// Removes the `Item` at the given `IndexPath`.
    mutating func remove(at indexPath : IndexPath)
    {
        self.sections[indexPath.section].items.remove(at: indexPath.item)
    }
    
    /// Inserts the `Item` at the given `IndexPath`.
    mutating func insert(item : AnyItem, at indexPath : IndexPath)
    {
        self.sections[indexPath.section].items.insert(item, at: indexPath.item)
    }
    
    //
    // MARK: Slicing Content
    //
    
    /// Creates a `Slice` of `Content` that allows cutting down a large list of `Content` to a more appropriate size
    /// for display within a list. This is used by the presentation system to avoid needing to expensively measure and
    /// lay out every item in long lists.
    ///
    /// Eg, if you provide 10,000 items to a list, we don't need to put all of those into the list right away. We only need to show
    /// enough to render the list to its current scroll position, plus some overscroll. This allows pretty significant performance
    /// optimizations for long lists that are not scrolled to the bottom, by culling most items.
    ///
    func sliceTo(indexPath : IndexPath) -> Slice
    {
        var sliced = self
        
        var remaining : Int = indexPath.item + self.pagingBehavior.pageSize(with: self.itemCount)
        
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
