//
//  ListItemElement.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/10/19.
//


public extension Item where Element == ListItemElement
{
    static func list<Identifier:Hashable>(identifier : Identifier, sizing : ListItemSizing, build : ListDescription.Build) -> Item<ListItemElement>
    {
        return Item(
            with: ListItemElement(identifier: identifier, build: build),
            sizing: sizing.toStandardSizing,
            layout: ItemLayout(width: .fill)
        )
    }
}


public enum ListItemSizing : Equatable
{
    case `default`
    case fixed(width: CGFloat = 0.0, height : CGFloat = 0.0)
    
    var toStandardSizing : Sizing {
        switch self {
        case .default: return .default
        case .fixed(let w, let h): return .fixed(width: w, height: h)
        }
    }
}


public struct ListItemElement : ItemElement, ItemElementAppearance
{
    //
    // MARK: Public Properties
    //
    
    public var listDescription : ListDescription
    public var contentIdentifier : AnyHashable
    
    //
    // MARK: Initialization
    //
    
    public init<Identifier:Hashable>(identifier : Identifier, build : ListDescription.Build)
    {
        self.contentIdentifier = AnyHashable(identifier)
        
        self.listDescription = ListDescription(
            animatesChanges: true,
            layoutType: .list,
            appearance: .init(),
            behavior: .init(),
            autoScrollAction: .none,
            scrollInsets: .init(),
            accessibilityIdentifier: nil,
            debuggingIdentifier: nil,
            build: build
        )
    }
    
    //
    // MARK: ItemElement
    //
    
    public typealias Appearance = ListItemElement
    
    public var identifier: Identifier<ListItemElement> {
        return .init(self.contentIdentifier)
    }
    
    public func apply(to view : Appearance.ContentView, for reason: ApplyReason, with info : ApplyItemElementInfo)
    {
        view.setProperties(with: self.listDescription)
    }
    
    public func isEquivalent(to other: ListItemElement) -> Bool
    {
        return false
    }
    
    //
    // MARK: ItemElementAppearance
    //
    
    public typealias ContentView = ListView
    
    public static func createReusableItemView(frame : CGRect) -> ListView
    {
        return ListView(frame: frame)
    }
    
    public func update(view: ListView, with position: ItemPosition) { }
    
    public func apply(to view: ListView, with info : ApplyItemElementInfo) {}
}
