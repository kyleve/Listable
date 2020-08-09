//
//  GridListLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation

public extension LayoutDescription
{
    static func grid(_ configure : @escaping (inout GridAppearance) -> () = { _ in }) -> Self
    {
        GridListLayout.describe(appearance: configure)
    }
}

public struct GridAppearance : ListLayoutAppearance
{
    public var sizing : Sizing
    public var layout : Layout
    
    public var direction: LayoutDirection {
        .vertical
    }
    
    public var stickySectionHeaders : Bool
    
    public static var `default`: GridAppearance {
        return self.init()
    }
    
    public init(
        stickySectionHeaders : Bool = true,
        sizing : Sizing = Sizing(),
        layout : Layout = Layout()
    ) {
        self.stickySectionHeaders = stickySectionHeaders
        self.sizing = sizing
        self.layout = layout
    }
    
    public struct Sizing : Equatable
    {
        public var sectionHeaderHeight : CGFloat
        public var sectionFooterHeight : CGFloat
        
        public var listHeaderHeight : CGFloat
        public var listFooterHeight : CGFloat
        public var overscrollFooterHeight : CGFloat
            
        public init(
            sectionHeaderHeight : CGFloat = 60.0,
            sectionFooterHeight : CGFloat = 40.0,
            listHeaderHeight : CGFloat = 60.0,
            listFooterHeight : CGFloat = 60.0,
            overscrollFooterHeight : CGFloat = 60.0
        )
        {
            self.sectionHeaderHeight = sectionHeaderHeight
            self.sectionFooterHeight = sectionFooterHeight
            self.listHeaderHeight = listHeaderHeight
            self.listFooterHeight = listFooterHeight
            self.overscrollFooterHeight = overscrollFooterHeight
        }
        
        public mutating func set(with block: (inout Sizing) -> ())
        {
            var edited = self
            block(&edited)
            self = edited
        }
    }
    
    
    public enum ItemSize : Equatable {
        case fixedSize(FixedSize)
        case fixedCount(FixedCount)
        
        public struct FixedSize : Equatable {
        
            public var size : CGSize
            
            public var minHorizontalSpacing : CGFloat
            
            public init(
                size: CGSize,
                minHorizontalSpacing : CGFloat
            ) {
                self.size = size
                
                self.minHorizontalSpacing = minHorizontalSpacing
            }
            
            func layoutInfo(for contentWidth : CGFloat) -> LayoutInfo
            {
                let itemWidth = min(contentWidth, size.width)
                
                let columnCount = Int(floor(contentWidth / itemWidth))
                
                return self.layoutInfo(contentWidth: contentWidth, columnCount: columnCount, itemWidth: itemWidth)
            }
            
            private func layoutInfo(contentWidth : CGFloat, columnCount : Int, itemWidth : CGFloat) -> LayoutInfo
            {
                precondition(contentWidth >= itemWidth)
                
                let leftoverForSpacing = contentWidth - (CGFloat(columnCount) * itemWidth)
                
                let minTotalSpacing = minHorizontalSpacing * (CGFloat(columnCount) - 1)
                
                if columnCount == 1 {
                    // Degenerate case where there is no space left for a real grid; this is just a list.
                    
                    return LayoutInfo(
                        itemSize: CGSize(width: itemWidth, height: size.height),
                        horizontalSpacing: 0.0,
                        columnCount: 1
                    )
                } else if leftoverForSpacing < minTotalSpacing {
                    return self.layoutInfo(contentWidth: contentWidth, columnCount: columnCount-1, itemWidth: itemWidth)
                } else {
                    let horizontalSpacing = round(leftoverForSpacing / (CGFloat(columnCount) - 1))
                    
                    return LayoutInfo(
                        itemSize: CGSize(width: itemWidth, height: size.height),
                        horizontalSpacing: horizontalSpacing,
                        columnCount: columnCount
                    )
                }
            }
        }
        
        public struct FixedCount : Equatable {
            
            public var count : Int
            public var height : CGFloat
            
            public var horizontalSpacing : CGFloat
            
            public init(
                count: Int,
                height: CGFloat,
                horizontalSpacing: CGFloat
            ) {
                self.count = count
                self.height = height
                self.horizontalSpacing = horizontalSpacing
            }
            
            func layoutInfo(for contentWidth : CGFloat) -> LayoutInfo
            {
                let totalSpacing = (horizontalSpacing * CGFloat(count - 1))
                let itemWidth = round((contentWidth - totalSpacing) / CGFloat(count))
                
                return LayoutInfo(
                    itemSize: CGSize(width: itemWidth, height: height),
                    horizontalSpacing: horizontalSpacing,
                    columnCount: count
                )
            }
        }
        
        func layoutInfo(for contentWidth : CGFloat) -> LayoutInfo
        {
            switch self {
            case .fixedSize(let info): return info.layoutInfo(for: contentWidth)
            case .fixedCount(let info): return info.layoutInfo(for: contentWidth)
            }
        }
        
        struct LayoutInfo
        {
            var itemSize : CGSize
            var horizontalSpacing : CGFloat
            var columnCount : Int
            
            func group(items : [ListLayoutContent.ItemInfo]) -> [[ListLayoutContent.ItemInfo]]
            {
                var items = items
                
                var grouped = [[ListLayoutContent.ItemInfo]]()
                
                while items.count > 0 {
                    grouped.append(items.safeDropFirst(self.columnCount))
                }
                
                return grouped
            }
        }
    }

    public struct Layout : Equatable
    {
        public var itemSize : ItemSize
        
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
        /// The spacing between rows in the grid.
        public var rowSpacing : CGFloat
        /// The spacing between the last item in the section and the footer.
        /// Not applied if there is no section footer.
        public var itemToSectionFooterSpacing : CGFloat
        
        /// The spacing between the last section and the footer of the list.
        /// Not applied if there is no list footer.
        public var lastSectionToFooterSpacing : CGFloat
                
        /// Creates a new `Layout` with the provided options.
        public init(
            itemSize : ItemSize = .fixedSize(.init(size: CGSize(width: 110.0, height: 90.0), minHorizontalSpacing: 10.0)),
            padding : UIEdgeInsets = .zero,
            width : WidthConstraint = .noConstraint,
            headerToFirstSectionSpacing : CGFloat = 10.0,
            interSectionSpacingWithNoFooter : CGFloat = 20.0,
            interSectionSpacingWithFooter : CGFloat = 20.0,
            sectionHeaderBottomSpacing : CGFloat = 10.0,
            rowSpacing : CGFloat = 10.0,
            itemToSectionFooterSpacing : CGFloat = 10.0,
            lastSectionToFooterSpacing : CGFloat = 10.0
        ) {
            self.itemSize = itemSize
            
            self.padding = padding
            self.width = width
            
            self.headerToFirstSectionSpacing = headerToFirstSectionSpacing
            
            self.interSectionSpacingWithNoFooter = interSectionSpacingWithNoFooter
            self.interSectionSpacingWithFooter = interSectionSpacingWithFooter
            
            self.sectionHeaderBottomSpacing = sectionHeaderBottomSpacing
            self.rowSpacing = rowSpacing
            self.itemToSectionFooterSpacing = itemToSectionFooterSpacing
            
            self.lastSectionToFooterSpacing = lastSectionToFooterSpacing
        }

        public mutating func set(with block : (inout Layout) -> ())
        {
            var edited = self
            block(&edited)
            self = edited
        }
        
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


final class GridListLayout : ListLayout
{
    typealias LayoutAppearance = GridAppearance
    
    static var defaults: ListLayoutDefaults {
        .init(itemInsertAndRemoveAnimations: .scaleDown)
    }
    
    var layoutAppearance: GridAppearance
    
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
        layoutAppearance: GridAppearance,
        appearance: Appearance,
        behavior: Behavior,
        content: ListLayoutContent
    ) {
        self.layoutAppearance = layoutAppearance
        self.appearance = appearance
        self.behavior = behavior
        
        self.content = content
    }

    //
    // MARK: Performing Layouts
    //
    
    func updateLayout(in collectionView: UICollectionView)
    {
        if self.layoutAppearance.stickySectionHeaders {
            self.applyStickySectionHeaders(in: collectionView)
        }
    }
    
    func layout(
        delegate : CollectionViewLayoutDelegate,
        in collectionView : UICollectionView
    ) {
        let gridSizing = layoutAppearance.sizing
        let gridLayout = layoutAppearance.layout
        
        // TODO: Need to figure out how the width constraint and centering + paddding works.
        
        let viewWidth = collectionView.bounds.width
        let contentWidth = gridLayout.width.clamp(viewWidth - gridLayout.padding.left - gridLayout.padding.right)
        let xOrigin = gridLayout.padding.left
        
        var lastMaxY : CGFloat = gridLayout.padding.top
        
        performLayout(for: content.header) { header in
            guard header.isPopulated else {
                return
            }
            
            header.x = xOrigin
            header.y = lastMaxY
            
            let measureInfo = Sizing.MeasureInfo(
                sizeConstraint: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                defaultSize: CGSize(width: contentWidth, height: gridSizing.listHeaderHeight),
                direction: .vertical
            )
            
            header.size = header.measurer(measureInfo)
            
            lastMaxY = header.defaultFrame.maxY
            
            if content.sections.isEmpty == false {
                lastMaxY += gridLayout.headerToFirstSectionSpacing
            }
        }
        
        let layoutInfo = gridLayout.itemSize.layoutInfo(for: contentWidth)
        
        content.sections.forEachWithIndex { index, isLast, section in
            
            performLayout(for: section.header) { header in
                guard header.isPopulated else {
                    return
                }
                
                header.x = xOrigin
                header.y = lastMaxY
                
                let measureInfo = Sizing.MeasureInfo(
                    sizeConstraint: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: contentWidth, height: gridSizing.sectionHeaderHeight),
                    direction: .vertical
                )
                
                header.size = header.measurer(measureInfo)
                
                lastMaxY = header.defaultFrame.maxY
                
                if section.items.isEmpty == false {
                    lastMaxY += layoutAppearance.layout.sectionHeaderBottomSpacing
                }
            }
            
            let rows = layoutInfo.group(items: section.items)
            
            rows.forEachWithIndex { rowIndex, isLastRow, row in
                
                var xPosition = xOrigin
                
                // TODO: When there is only one row; need to center the item, I think?
                
                row.forEachWithIndex { columnIndex, isLastColumn, item in
                    
                    item.x = xPosition
                    item.y = lastMaxY
                    item.size = layoutInfo.itemSize
                    
                    xPosition += layoutInfo.itemSize.width
                    xPosition += layoutInfo.horizontalSpacing
                }
                
                lastMaxY += layoutInfo.itemSize.height
                
                if isLastRow {
                    lastMaxY += layoutAppearance.layout.itemToSectionFooterSpacing
                } else {
                    lastMaxY += gridLayout.rowSpacing
                }
            }

            performLayout(for: section.footer) { footer in
                guard footer.isPopulated else {
                    return
                }
                
                footer.x = xOrigin
                footer.y = lastMaxY
                
                let measureInfo = Sizing.MeasureInfo(
                    sizeConstraint: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: contentWidth, height: gridSizing.sectionFooterHeight),
                    direction: .vertical
                )
                
                footer.size = footer.measurer(measureInfo)
                
                lastMaxY = footer.defaultFrame.maxY
            }
            
            if isLast {
                lastMaxY += gridLayout.lastSectionToFooterSpacing
            } else {
                if section.footer.isPopulated {
                    lastMaxY += gridLayout.interSectionSpacingWithFooter
                } else {
                    lastMaxY += gridLayout.interSectionSpacingWithNoFooter
                }
            }
        }
        
        performLayout(for: content.footer) { footer in
            guard footer.isPopulated else {
                return
            }
            
            footer.x = xOrigin
            footer.y = lastMaxY
            
            let measureInfo = Sizing.MeasureInfo(
                sizeConstraint: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                defaultSize: CGSize(width: contentWidth, height: gridSizing.listFooterHeight),
                direction: .vertical
            )
            
            footer.size = footer.measurer(measureInfo)
            
            lastMaxY = footer.defaultFrame.maxY
        }
        
        lastMaxY += gridLayout.padding.bottom
        
        self.content.contentSize = CGSize(width: contentWidth, height: lastMaxY)
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


