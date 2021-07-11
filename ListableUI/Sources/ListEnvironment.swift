//
//  ListEnvironment.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/26/20.
//


/// An environment of keys and values that are passed to every `ItemContent` and `HeaderFooter`
/// during layout and measurement, to allow passing down data.
///
/// This type is similar to the SwiftUI or Blueprint `Environment`, where you define a `ListEnvironmentKey`,
/// and then provide a custom getter and setter to read and write the content:
///
/// ```
/// enum MyLayoutTypeKey : ListEnvironmentKey {
///     var defaultValue : MyLayoutType {
///         .defaultLayout
///     }
/// }
///
/// extension ListEnvironment {
///     var myLayoutType : MyLayoutType {
///         get { self[MyLayoutTypeKey.self] }
///         set { self[MyLayoutTypeKey.self] = newValue }
///     }
/// }
/// ```
///
/// You can retrieve the `ListEnvironment` through the `info` object passed in `ItemContent` and `HeaderFooter`'s
/// `apply(to:for:with:)` methods.
///
/// ```
/// func apply(
///     to views : ItemContentViews<Self>,
///     for reason: ApplyReason,
///     with info : ApplyItemContentInfo
/// ) {
///    switch info.environment.myLayoutType {
///       ...
///    }
/// }
/// ```
public struct ListEnvironment {
    
    /// A default "empty" environment, with no values overridden.
    /// Each key will return its default value.
    public static let empty = ListEnvironment()
    
    public init(_ configure : (inout ListEnvironment) -> () = { _ in }) {
        configure(&self)
    }

    /// Gets or sets an environment value by its key.
    public subscript<Key>(key: Key.Type) -> Key.Value where Key: ListEnvironmentKey {
        get {
            let objectId = ObjectIdentifier(key)

            if let value = values[objectId] {
                return value as! Key.Value
            }

            return key.defaultValue
        }
        set {
            values[ObjectIdentifier(key)] = newValue
        }
    }
    
    private var values: [ObjectIdentifier: Any] = [:]
}


/// Defines a value stored in the `ListEnvironment` of a list.
///
/// See `ListEnvironment` for more info and examples.
public protocol ListEnvironmentKey {
    
    /// The type of value stored by this key.
    associatedtype Value

    /// The default value that will be vended by an `Environment` for this key if no other value has been set.
    static var defaultValue: Self.Value { get }
}
