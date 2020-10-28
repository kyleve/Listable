//
//  DefaultListLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/19/19.
//

import Foundation
import UIKit

public extension LayoutDescription
{
    static func list(_ configure : @escaping (inout ListAppearance) -> () = { _ in }) -> Self
    {
        DefaultListLayout.describe(appearance: configure)
    }
}


///
/// `ListAppearance` defines the appearance and layout attribute for list layouts within a Listable list.
///
/// The below diagram shows where each of the properties on the `ListAppearance.Layout` values are
/// applied when laying out the list.
///
/// Note
/// ----
/// Do not edit this ASCII diagram directly.
/// Edit the `ListAppearance.monopic` file in this directory using Monodraw.
/// ```
/// ┌─────────────────────────────────────────────────────────────────┐
/// │                          padding.top                            │
/// │   ┌─────────────────────────────────────────────────────────┐   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                                                       ││   │
/// │   ││                      List Header                      ││   │
/// │   ││                                                       ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │                                                         │   │
/// │   │               headerToFirstSectionSpacing               │   │
/// │   │                                                         │   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                                                       ││   │
/// │   ││                    Section Header                     ││   │
/// │   ││                                                       ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │               sectionHeaderBottomSpacing                │   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                         Item                          ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │                       itemSpacing                       │   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                         Item                          ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │               itemToSectionFooterSpacing                │   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                                                       ││   │
/// │ p ││                    Section Footer                     ││ p │
/// │ a ││                                                       ││ a │
/// │ d │└───────────────────────────────────────────────────────┘│ d │
/// │ d │                                                         │ d │
/// │ i │               interSectionSpacingWithFooter             │ i │
/// │ n │                                                         │ n │
/// │ g │┌───────────────────────────────────────────────────────┐│ g │
/// │ . ││                                                       ││ . │
/// │ l ││                    Section Header                     ││ r │
/// │ e ││                                                       ││ i │
/// │ f │└───────────────────────────────────────────────────────┘│ g │
/// │ t │               sectionHeaderBottomSpacing                │ h │
/// │   │┌───────────────────────────────────────────────────────┐│ t │
/// │   ││                         Item                          ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │                       itemSpacing                       │   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                         Item                          ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │                                                         │   │
/// │   │              interSectionSpacingWithNoFooter            │   │
/// │   │                                                         │   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                                                       ││   │
/// │   ││                    Section Header                     ││   │
/// │   ││                                                       ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │               sectionHeaderBottomSpacing                │   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                         Item                          ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │                       itemSpacing                       │   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                         Item                          ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │                                                         │   │
/// │   │               lastSectionToFooterSpacing                │   │
/// │   │                                                         │   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                                                       ││   │
/// │   ││                      List Footer                      ││   │
/// │   ││                                                       ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   └─────────────────────────────────────────────────────────┘   │
/// │                         padding.bottom                          │
/// └─────────────────────────────────────────────────────────────────┘
/// ```
public struct ListAppearance : ListLayoutAppearance
{
    public var direction: LayoutDirection {
        .vertical
    }
    
    public var stickySectionHeaders : Bool
    
    /// Default sizing attributes for content in the list.
    public var sizing : Sizing
    
    /// Layout attributes for content in the list.
    public var layout : Layout
    
    public static var `default`: ListAppearance {
        return self.init()
    }
        
    /// Creates a new `ListAppearance` object.
    public init(
        stickySectionHeaders : Bool = true,
        sizing : Sizing = Sizing(),
        layout : Layout = Layout()
    ) {
        self.stickySectionHeaders = stickySectionHeaders
        self.sizing = sizing
        self.layout = layout
    }
    
    /// Sizing options for the list.
    public struct Sizing : Equatable
    {
        /// The default height for items in a list.
        public var itemHeight : CGFloat
        
        /// The default height for section headers in a list.
        public var sectionHeaderHeight : CGFloat
        /// The default height for section footer in a list.
        public var sectionFooterHeight : CGFloat
        
        /// The default height for the list's header.
        public var listHeaderHeight : CGFloat
        /// The default height for the list's footer.
        public var listFooterHeight : CGFloat
        /// The default height for the list's overscroll footer.
        public var overscrollFooterHeight : CGFloat
        
        /// When providing the `ItemPosition` for items in a list, specifies the max spacing
        /// for items to be considered in the same group. For example, if this value is 1, and
        /// items are spaced 2pts apart, the items will be in a new group.
        public var itemPositionGroupingHeight : CGFloat
            
        public init(
            itemHeight : CGFloat = 50.0,
            sectionHeaderHeight : CGFloat = 60.0,
            sectionFooterHeight : CGFloat = 40.0,
            listHeaderHeight : CGFloat = 60.0,
            listFooterHeight : CGFloat = 60.0,
            overscrollFooterHeight : CGFloat = 60.0,
            itemPositionGroupingHeight : CGFloat = 0.0
        )
        {
            self.itemHeight = itemHeight
            self.sectionHeaderHeight = sectionHeaderHeight
            self.sectionFooterHeight = sectionFooterHeight
            self.listHeaderHeight = listHeaderHeight
            self.listFooterHeight = listFooterHeight
            self.overscrollFooterHeight = overscrollFooterHeight
            self.itemPositionGroupingHeight = itemPositionGroupingHeight
        }
        
        public mutating func set(with block: (inout Sizing) -> ())
        {
            var edited = self
            block(&edited)
            self = edited
        }
    }
    
    
    /// Layout options for the list.
    public struct Layout : Equatable
    {
        /// The padding to place around the outside of the content of the list.
        public var padding : UIEdgeInsets
        /// The width of the content of the list, which can be optionally constrained.
        public var width : WidthConstraint
        
        /// The spacing between the list header and the first section.
        /// Not applied if there is no list header.
        public var headerToFirstSectionSpacing : CGFloat

        /// The spacing to apply between sections, if the previous section has no footer.
        public var interSectionSpacingWithNoFooter : CGFloat
        /// The spacing to apply between sections, if the previous section has a footer.
        public var interSectionSpacingWithFooter : CGFloat
        
        /// The spacing to apply below a section header, before its items.
        /// Not applied if there is no section header.
        public var sectionHeaderBottomSpacing : CGFloat
        /// The spacing between individual items within a section in a list.
        public var itemSpacing : CGFloat
        /// The spacing between the last item in the section and the footer.
        /// Not applied if there is no section footer.
        public var itemToSectionFooterSpacing : CGFloat
        
        /// The spacing between the last section and the footer of the list.
        /// Not applied if there is no list footer.
        public var lastSectionToFooterSpacing : CGFloat
                
        /// Creates a new `Layout` with the provided options.
        public init(
            padding : UIEdgeInsets = .zero,
            width : WidthConstraint = .noConstraint,
            headerToFirstSectionSpacing : CGFloat = 0.0,
            interSectionSpacingWithNoFooter : CGFloat = 0.0,
            interSectionSpacingWithFooter : CGFloat = 0.0,
            sectionHeaderBottomSpacing : CGFloat = 0.0,
            itemSpacing : CGFloat = 0.0,
            itemToSectionFooterSpacing : CGFloat = 0.0,
            lastSectionToFooterSpacing : CGFloat = 0.0
        )
        {
            self.padding = padding
            self.width = width
            
            self.headerToFirstSectionSpacing = headerToFirstSectionSpacing
            
            self.interSectionSpacingWithNoFooter = interSectionSpacingWithNoFooter
            self.interSectionSpacingWithFooter = interSectionSpacingWithFooter
            
            self.sectionHeaderBottomSpacing = sectionHeaderBottomSpacing
            self.itemSpacing = itemSpacing
            self.itemToSectionFooterSpacing = itemToSectionFooterSpacing
            
            self.lastSectionToFooterSpacing = lastSectionToFooterSpacing
        }

        /// Easily mutate the `Layout` in place.
        public mutating func set(with block : (inout Layout) -> ())
        {
            var edited = self
            block(&edited)
            self = edited
        }
        
        /// Provides a width for layout.
        internal static func width(
            with width : CGFloat,
            padding : HorizontalPadding,
            constraint : WidthConstraint
        ) -> CGFloat
        {
            let paddedWidth = width - padding.left - padding.right
            
            return constraint.clamp(paddedWidth)
        }
    }
}


final class DefaultListLayout : ListLayout
{
    typealias LayoutAppearance = ListAppearance
    
    static var defaults: ListLayoutDefaults {
        .init(itemInsertAndRemoveAnimations: .top)
    }
    
    var layoutAppearance: ListAppearance
    
    //
    // MARK: Public Properties
    //
    
    let appearance : Appearance
    let behavior : Behavior
    
    let content : ListLayoutContent
            
    var scrollViewProperties: ListLayoutScrollViewProperties {
        .init(
            isPagingEnabled: false,
            contentInsetAdjustmentBehavior: .automatic,
            allowsBounceVertical: true,
            allowsBounceHorizontal: true,
            allowsVerticalScrollIndicator: true,
            allowsHorizontalScrollIndicator: true
        )
    }
        
    //
    // MARK: Initialization
    //
    
    init(
        layoutAppearance : LayoutAppearance,
        appearance : Appearance,
        behavior : Behavior,
        content : ListLayoutContent
    ) {
        self.layoutAppearance = layoutAppearance
        self.appearance = appearance
        self.behavior = behavior
        
        self.content = content
    }
    
    //
    // MARK: Performing Layouts
    //
    
    func updateLayout(in collectionView : UICollectionView)
    {
        
    }
    
    func layout(
        delegate : CollectionViewLayoutDelegate,
        in collectionView : UICollectionView
    ) {
        let layout = self.layoutAppearance.layout
        let sizing = self.layoutAppearance.sizing
        
        let viewSize = collectionView.bounds.size
        
        let viewWidth = collectionView.bounds.width
        
        let rootWidth = ListAppearance.Layout.width(
            with: viewSize.width,
            padding: HorizontalPadding(left: layout.padding.left, right: layout.padding.right),
            constraint: layout.width
        )
                
        //
        // Item Positioning
        //
                
        /**
         Item positions are set and sent to the delegate first,
         in case the position affects the height calculation later in the layout pass.
         */
        self.setItemPositions()
        
        delegate.listViewLayoutUpdatedItemPositions(collectionView)
        
        //
        // Set Frame Origins
        //
        
        var lastContentMaxY : CGFloat = 0.0
        
        //
        // Header
        //
        
        switch direction {
        case .vertical:
            lastContentMaxY += layout.padding.top
            
        case .horizontal:
            lastContentMaxY += layout.padding.left
        }
        
        performLayout(for: self.content.header) { header in
            let hasListHeader = self.content.header.isPopulated
            
            let position = header.layout.width.position(with: viewSize, defaultWidth: rootWidth)
            
            let measureInfo = Sizing.MeasureInfo(
                sizeConstraint: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                defaultSize: CGSize(width: 0.0, height: sizing.listHeaderHeight),
                direction: .vertical
            )
            
            let height = header.measurer(measureInfo).height
            
            header.x = position.origin
            header.size = CGSize(width: position.width, height: height)
            header.y = lastContentMaxY
            
            if hasListHeader {
                lastContentMaxY += header.defaultFrame.maxY
            }
            
            if self.content.sections.isEmpty == false {
                lastContentMaxY += layout.headerToFirstSectionSpacing
            }
        }
        
        //
        // Sections
        //
        
        self.content.sections.forEachWithIndex { sectionIndex, isLast, section in
            
            let sectionPosition = section.layout.width.position(with: viewSize, defaultWidth: rootWidth)
            
            //
            // Section Header
            //
            
            let hasSectionHeader = section.header.isPopulated
            let hasSectionFooter = section.footer.isPopulated
            
            performLayout(for: section.header) { header in
                let width = header.layout.width.merge(with: section.layout.width)
                let position = width.position(with: viewSize, defaultWidth: sectionPosition.width)
                
                let measureInfo = Sizing.MeasureInfo(
                    sizeConstraint: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: 0.0, height: sizing.sectionHeaderHeight),
                    direction: .vertical
                )
                
                let height = header.measurer(measureInfo).height
                
                header.x = position.origin
                header.size = CGSize(width: position.width, height: height)
                header.y = lastContentMaxY
                
                if hasSectionHeader {
                    lastContentMaxY = section.header.defaultFrame.maxY
                    
                    if section.items.isEmpty == false {
                        lastContentMaxY += layout.sectionHeaderBottomSpacing
                    }
                }
            }
            
            //
            // Section Items
            //
            
            if section.columns.count == 1 {
                section.items.forEachWithIndex { itemIndex, isLast, item in
                    let width = item.layout.width.merge(with: section.layout.width)
                    let itemPosition = width.position(with: viewSize, defaultWidth: sectionPosition.width)
                    
                    let measureInfo = Sizing.MeasureInfo(
                        sizeConstraint: CGSize(width: itemPosition.width, height: .greatestFiniteMagnitude),
                        defaultSize: CGSize(width: 0.0, height: sizing.itemHeight),
                        direction: .vertical
                    )
                    
                    let height = item.measurer(measureInfo).height
                    
                    item.x = itemPosition.origin
                    item.y = lastContentMaxY
                    item.size = CGSize(width: itemPosition.width, height: height)
                    
                    lastContentMaxY += height

                    if isLast {
                        if hasSectionFooter {
                            lastContentMaxY += item.layout.itemToSectionFooterSpacing ?? layout.itemToSectionFooterSpacing
                        }
                    } else {
                        lastContentMaxY += item.layout.itemSpacing ?? layout.itemSpacing
                    }
                }
            } else {
                let itemWidth = round((sectionPosition.width - (section.columns.spacing * CGFloat(section.columns.count - 1))) / CGFloat(section.columns.count))
                
                let groupedItems = section.columns.group(values: section.items)
                
                groupedItems.forEachWithIndex { rowIndex, isLast, row in
                    var maxHeight : CGFloat = 0.0
                    var maxItemSpacing : CGFloat = 0.0
                    var maxItemToSectionFooterSpacing : CGFloat = 0.0
                    var columnXOrigin = sectionPosition.origin
                    
                    row.forEachWithIndex { columnIndex, isLast, item in
                        item.x = columnXOrigin
                        item.y = lastContentMaxY
                                                
                        let measureInfo = Sizing.MeasureInfo(
                            sizeConstraint: CGSize(width: itemWidth, height: .greatestFiniteMagnitude),
                            defaultSize: CGSize(width: 0.0, height: sizing.itemHeight),
                            direction: .vertical
                        )
                                                
                        let height = item.measurer(measureInfo).height
                        
                        let itemSpacing = item.layout.itemSpacing ?? layout.itemSpacing
                        let itemToSectionFooterSpacing = item.layout.itemToSectionFooterSpacing ?? layout.itemToSectionFooterSpacing
                        
                        item.size = CGSize(width: itemWidth, height: height)
                        
                        maxHeight = max(height, maxHeight)
                        maxItemSpacing = max(itemSpacing, maxItemSpacing)
                        maxItemToSectionFooterSpacing = max(itemToSectionFooterSpacing, maxItemToSectionFooterSpacing)
                        
                        columnXOrigin += (itemWidth + section.columns.spacing)
                    }
                    
                    lastContentMaxY += maxHeight
                    
                    if isLast {
                        if hasSectionFooter {
                            lastContentMaxY += maxItemToSectionFooterSpacing
                        }
                    } else {
                        lastContentMaxY += maxItemSpacing
                    }
                }
            }
            
            //
            // Section Footer
            //
            
            performLayout(for: section.footer) { footer in
                let width = footer.layout.width.merge(with: section.layout.width)
                let position = width.position(with: viewSize, defaultWidth: sectionPosition.width)
                
                let measureInfo = Sizing.MeasureInfo(
                    sizeConstraint: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: 0.0, height: sizing.sectionFooterHeight),
                    direction: .vertical
                )
                
                let height = footer.measurer(measureInfo).height
                
                footer.size = CGSize(width: position.width, height: height)
                footer.x = position.origin
                footer.y = lastContentMaxY
                
                if hasSectionFooter {
                    lastContentMaxY = footer.defaultFrame.maxY
                }
            }
            
            // Add additional padding from config.
            
            if isLast {
                if self.content.footer.isPopulated {
                    lastContentMaxY += layout.lastSectionToFooterSpacing
                }
            } else {
                let additionalSectionSpacing: CGFloat
                if let customInterSectionSpacing = section.layout.customInterSectionSpacing {
                    additionalSectionSpacing = customInterSectionSpacing
                } else {
                    additionalSectionSpacing = hasSectionFooter
                        ? layout.interSectionSpacingWithFooter
                        : layout.interSectionSpacingWithNoFooter
                }
                
                lastContentMaxY += additionalSectionSpacing
            }
        }
        
        //
        // Footer
        //
        
        performLayout(for: self.content.footer) { footer in
            let hasFooter = footer.isPopulated
            
            let position = footer.layout.width.position(with: viewSize, defaultWidth: rootWidth)
            
            let measureInfo = Sizing.MeasureInfo(
                sizeConstraint: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                defaultSize: CGSize(width: 0.0, height: sizing.listFooterHeight),
                direction: .vertical
            )
            
            let height = footer.measurer(measureInfo).height
            
            footer.size = CGSize(width: position.width, height: height)
            footer.x = position.origin
            footer.y = lastContentMaxY
            
            if hasFooter {
                lastContentMaxY = footer.defaultFrame.maxY
            }
        }
        
        switch direction {
        case .vertical: lastContentMaxY += layout.padding.bottom
        case .horizontal: lastContentMaxY += layout.padding.right
        }
        
        //
        // Overscroll Footer
        //
                    
        performLayout(for: self.content.overscrollFooter) { footer in
            let position = footer.layout.width.position(with: viewSize, defaultWidth: rootWidth)
            
            let measureInfo = Sizing.MeasureInfo(
                sizeConstraint: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                defaultSize: CGSize(width: 0.0, height: sizing.overscrollFooterHeight),
                direction: .vertical
            )
            
            let height = footer.measurer(measureInfo).height
            
            footer.x = position.origin
            footer.size = CGSize(width: position.width, height: height)
        }
        
        //
        // Remaining Calculations
        //
        
        self.content.contentSize = CGSize(width: viewWidth, height: lastContentMaxY)
    }
    
    private func setItemPositions()
    {
        self.content.sections.forEach { section in
            section.setItemPositions(with: self.layoutAppearance)
        }
    }
}


fileprivate extension ListLayoutContent.SectionInfo
{
    func setItemPositions(with appearance : ListAppearance)
    {
        if self.columns.count == 1 {
            let groups = ListLayoutContent.SectionInfo.grouped(
                items: self.items,
                groupingHeight: appearance.sizing.itemPositionGroupingHeight,
                appearance: appearance
            )
            
            groups.forEach { group in
                let itemCount = group.count
                
                group.forEachWithIndex { index, isLast, item in
                    
                    if itemCount == 1 {
                        item.position = .single
                    } else {
                        if index == 0 {
                            item.position = .first
                        } else if isLast {
                            item.position = .last
                        } else {
                            item.position = .middle
                        }
                    }
                }
            }
        } else {
            // If we have columns, every item will receive "single" positioning for now.
            // Depending on use, we may want to make this smarter.
            
            self.items.forEach { $0.position = .single }
        }
    }
    
    private static func grouped(items : [ListLayoutContent.ItemInfo], groupingHeight : CGFloat, appearance : ListAppearance) -> [[ListLayoutContent.ItemInfo]]
    {
        var all = [[ListLayoutContent.ItemInfo]]()
        var current = [ListLayoutContent.ItemInfo]()
        
        var lastSpacing : CGFloat = 0.0
        
        items.forEachWithIndex { index, isLast, item in
            let inNewGroup = groupingHeight == 0.0 ? lastSpacing > 0.0 : lastSpacing > groupingHeight
            
            if inNewGroup {
                all.append(current)
                current = []
            }
            
            current.append(item)
            
            lastSpacing = item.layout.itemSpacing ?? appearance.layout.itemSpacing
        }
        
        if current.isEmpty == false {
            all.append(current)
        }
        
        return all
    }

}


fileprivate extension Section.Columns
{
    func group<Value>(values : [Value]) -> [[Value]]
    {
        var values = values
        
        var grouped : [[Value]] = []
        
        while values.count > 0 {
            grouped.append(values.safeDropFirst(self.count))
        }
        
        return grouped
    }
}


fileprivate extension Array
{
    mutating func safeDropFirst(_ count : Int) -> [Element]
    {
        let safeCount = Swift.min(self.count, count)
        let values = self[0..<safeCount]
        
        self.removeFirst(safeCount)
        
        return Array(values)
    }
}


fileprivate func performLayout<Input>(for input : Input, _ block : (Input) -> ())
{
    block(input)
}
