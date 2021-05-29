//
//  Item.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 9/10/20.
//

import ListableUI
import BlueprintUI


extension Item
{
    ///
    /// Provides a way to create an `Item` for your Blueprint elements without
    /// requiring the creation of a new `BlueprintItemContent` struct.
    ///
    /// Most arguments on this method are not required – you must only
    /// provide an input, a key path for the backing identifier value, and an element provider.
    ///
    /// Note
    /// ----
    /// This initializer is helpful if you have to nest an existing element that needs to be used in
    /// a single place, without needing to define an entirely new type.
    ///
    /// If your item is to be used in more than one place, it is recommended that you
    /// create a `BlueprintItemContent` struct to share logic to avoid duplicate code.
    ///
    /// Example
    /// -------
    /// ```
    /// Item(podcast, identifier: \.name) { lhs, rhs in
    ///     lhs.value != rhs.value
    /// } element: { podcast, info in
    ///     PodcastElement(podcast: podcast)
    /// } background: { podcast, info in
    ///     Box(...)
    /// } selectedBackground: { podcast, info in
    ///     Box(...)
    /// } configure: { item in
    ///     item.selectionStyle = .tappable
    /// }
    /// ```
    public init<Represented, IDType:Hashable>(
        _ representing : Represented,
        
        identifier : KeyPath<Represented, IDType>,
        
        isEquivalent : @escaping (Represented, Represented) -> Bool,
        
        element : @escaping (Represented, ApplyItemContentInfo) -> Element,
        background : @escaping (Represented, ApplyItemContentInfo) -> Element? = { _, _ in nil },
        selectedBackground : @escaping (Represented, ApplyItemContentInfo) -> Element? = { _, _ in nil },
        
        configure : (inout Item<BlueprintItemContentWrapper<Represented, IDType>>) -> () = { _ in }
        
    ) where Content == BlueprintItemContentWrapper<Represented, IDType>
    {
        self.init(
            BlueprintItemContentWrapper<Represented, IDType>(
                representing: representing,
                
                identifierKeyPath: identifier,
                
                isEquivalentProvider: isEquivalent,
                elementProvider: element,
                backgroundProvider: background,
                selectedBackgroundProvider: selectedBackground
            ),
            configure: configure
        )
    }
    
    ///
    /// Provides a way to create an `Item` for your Blueprint elements without
    /// requiring the creation of a new `BlueprintItemContent` struct.
    ///
    /// Most arguments on this method are not required – you must only
    /// provide an input, a key path for the backing identifier value, and an element provider.
    ///
    /// Note
    /// ----
    /// This initializer is helpful if you have to nest an existing element that needs to be used in
    /// a single place, without needing to define an entirely new type.
    ///
    /// If your item is to be used in more than one place, it is recommended that you
    /// create a `BlueprintItemContent` struct to share logic to avoid duplicate code.
    ///
    /// Example
    /// -------
    /// ```
    /// Item(podcast, identifier: \.name) { podcast, info in
    ///     PodcastElement(podcast: podcast)
    /// } background: { podcast, info in
    ///     Box(...)
    /// } selectedBackground: { podcast, info in
    ///     Box(...)
    /// } configure: { item in
    ///     item.selectionStyle = .tappable
    /// }
    /// ```
    public init<Represented, IDType:Hashable>(
        _ representing : Represented,
        
        identifier : KeyPath<Represented, IDType>,

        element : @escaping (Represented, ApplyItemContentInfo) -> Element,
        background : @escaping (Represented, ApplyItemContentInfo) -> Element? = { _, _ in nil },
        selectedBackground : @escaping (Represented, ApplyItemContentInfo) -> Element? = { _, _ in nil },
        
        configure : (inout Item<BlueprintItemContentWrapper<Represented, IDType>>) -> () = { _ in }
        
    ) where Content == BlueprintItemContentWrapper<Represented, IDType>, Represented:Equatable
    {
        self.init(
            BlueprintItemContentWrapper<Represented, IDType>(
                representing: representing,
                
                identifierKeyPath: identifier,
                
                isEquivalentProvider: { $0 == $1 },
                elementProvider: element,
                backgroundProvider: background,
                selectedBackgroundProvider: selectedBackground
            ),
            configure: configure
        )
    }
}


/// The `BlueprintItemContent` type that is used to provide
/// a lightweight way to present an `Element`, without needing to provide an entirely
/// new `BlueprintItemContent` type.
public struct BlueprintItemContentWrapper<Represented, IDType:Hashable> : BlueprintItemContent
{
    public let representing : Represented

    let identifierKeyPath : KeyPath<Represented, IDType>
    let isEquivalentProvider : (Represented, Represented) -> Bool
    let elementProvider : (Represented, ApplyItemContentInfo) -> Element
    let backgroundProvider : (Represented, ApplyItemContentInfo) -> Element?
    let selectedBackgroundProvider : (Represented, ApplyItemContentInfo) -> Element?
    
    public var identifier: Identifier<Self> {
        .init(self.representing[keyPath: self.identifierKeyPath])
    }
    
    public func isEquivalent(to other: Self) -> Bool {
        self.isEquivalentProvider(self.representing, other.representing)
    }
    
    public func element(
        with info: ApplyItemContentInfo,
        send : @escaping Coordinator.SendAction
    ) -> Element {
        self.elementProvider(self.representing, info)
    }
    
    public func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        self.backgroundProvider(self.representing, info)
    }
    
    public func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element? {
        self.selectedBackgroundProvider(self.representing, info)
    }
}
