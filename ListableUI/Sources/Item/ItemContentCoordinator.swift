//
//  ItemContentCoordinator.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/19/20.
//


///
/// A type which lets you interactively manage the contents of an `Item` or `ItemContent`
/// within a list.
///
/// Eg, you might create a `ItemContentCoordinator` which listens to a
/// notification, and then updates a field on the `Item` or `ItemContent` in response
/// to this notification.
///
/// `ItemContentCoordinator` is created when an item is being prepared to be presented
/// on screen for the first time, and lives for as long as the item is present in the list. If you need
/// to pull in any changes to the item due to time passing, you can update the item within the
/// `wasCreated`callback.
///
/// There are default implementations of all `ItemContentCoordinator` methods. You only
/// need to provide implementations for the methods relevant to you.
///
/// Example
/// -------
/// A simple `ItemContentCoordinator` might look like this:
///
/// ```
/// final class MyCoordinator : ItemContentCoordinator
/// {
///     typealias ItemContentType = MyContentType
///
///     let actions: CoordinatorActions
///     let info: CoordinatorInfo
///     var view : View?
///
///     init(actions: CoordinatorActions, info: CoordinatorInfo)
///     {
///        self.actions = actions
///        self.info = info
///
///        NotificationCenter.default.addObserver(self, selector: #selector(downloadUpdated(:)), name: .DownloadProgressChanged, object: nil)
///     }
///
///     @objc func downloadUpdated(notification : Notification)
///     {
///         self.actions.update {
///             $0.content.downloadProgress = notification.userInfo["download_progress"] as! CGFloat
///         }
///     }
/// }
/// ```
///
public protocol ItemContentCoordinator : AnyObject
{
    /// The type of `ItemContent` associated with this coordinator.
    associatedtype ItemContentType : ItemContent
    
    /// A type, usually an enum, associated with the coordinator that can be used to
    /// send various kinds of actions / work from the `ItemContent`.
    associatedtype Action = Void
    
    typealias SendAction = (Self.Action) -> ()
    
    /// The item associated with the coordinator.
    typealias Item = ListableUI.Item<ItemContentType>
    
    // MARK: Actions & Info
    
    /// The available actions you can perform on the coordinated `Item`. Eg, updating it to a new value.
    var actions : ItemContentType.CoordinatorActions { get }
    
    /// Info about the coordinated `Item`, such as its original and current value.
    var info : ItemContentType.CoordinatorInfo { get }
    
    // MARK: Handling Actions
    
    func handle(action : Action)
    
    // MARK: Instance Lifecycle
    
    /// Invoked on the coordinator when it is first created and configured.
    func wasInserted(_ info : Item.OnInsert)
    
    /// Invoked on the coordinator when its owned item is removed from the list due to
    /// the item, or its entire section, being removed from the list.
    ///
    /// Not invoked during deallocation of a list.
    func wasRemoved(_ info : Item.OnRemove)
    
    /// Invoked on the coordinator when its owned item is moved inside a list due to its
    /// order changing.
    ///
    /// Not invoked when an item is manually re-ordered by a user.
    func wasMoved(_ info : Item.OnMove)
    
    /// Invoked on the coordinator when an external update is pushed onto the owned `Item`.
    /// This happens when the developer updates the content of the list, and the item is
    /// reported as changed via its `isEquivalent(to:)` method.
    func wasUpdated(_ info : Item.OnUpdate)
    
    // MARK: Visibility & View Lifecycle

    /// Invoked when the list is about to begin displaying the item with the given view.
    func willDisplay()

    /// Invoked when the list is about to complete displaying the item with the given view.
    func didEndDisplay()
    
    // MARK: Selection & Highlight Lifecycle
    
    /// Invoked when the item is selected, via either user interaction or the `selectionStyle`.
    func wasSelected()
    
    /// Invoked when the item is deselected, via either user interaction or the `selectionStyle`.
    func wasDeselected()
}


public extension ItemContentCoordinator
{
    // MARK: Instance Lifecycle
    
    func wasInserted(_ info : Item.OnInsert) {}
    
    func wasRemoved(_ info : Item.OnRemove) {}
    
    func wasMoved(_ info : Item.OnMove) {}
    
    func wasUpdated(_ info : Item.OnUpdate) {}
    
    // MARK: Visibility Lifecycle
        
    func willDisplay() {}

    func didEndDisplay() {}
    
    // MARK: Selection & Highlight Lifecycle
    
    func wasSelected() {}
    
    func wasDeselected() {}
}


public extension ItemContentCoordinator where Action == Void
{
    // MARK: Handling Actions
    
    func handle(action : Action) { }
}


/// The available actions you can perform as a coordinator, which are reported back to the list to manage the item.
public final class ItemContentCoordinatorActions<Content:ItemContent>
{
    private let currentProvider : () -> Item<Content>
    var updateCallback : (Item<Content>, ViewAnimation) -> ()
    
    init(current : @escaping () -> Item<Content>, update : @escaping (Item<Content>, ViewAnimation) -> ())
    {
        self.currentProvider = current
        self.updateCallback = update
    }

    ///
    /// Allows you to update the displayed item via the provided closure, with an optional
    /// animation or delay.
    ///
    /// Note that the `update` callback is invoked after the provided `delay`, and
    /// is passed the value of the `Item` at that point in time.
    ///
    /// ```
    /// func wasSelected() {
    ///    self.update(animation: .animated(0.15), after: 1.0) { item in
    ///       item.content.myProperty = true
    ///    }
    /// }
    /// ```
    public func update(
        animation: ViewAnimation = .default,
        after delay: TimeInterval = 0,
        update : @escaping (inout Item<Content>) -> ()
    ) {
        if delay > 0 {
            Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                var new = self.currentProvider()
                update(&new)
                
                self.updateCallback(new, animation)
            }
        } else {
            var new = self.currentProvider()
            update(&new)
            
            self.updateCallback(new, animation)
        }
    }
}


/// Information about the current and original state of the item.
public final class ItemContentCoordinatorInfo<Content:ItemContent>
{
    /// The original state of the item, as passed to the list.
    /// This is property is updated when the list is updated, and the
    /// `isEquivalent(to:)` reports a change to the item.
    public internal(set) var original : Item<Content>
    
    /// The current value of the item, including changes made
    /// by the coordinator itself.
    public var current : Item<Content> {
        self.currentProvider()
    }
    
    private let currentProvider : () -> Item<Content>
    
    init(original : Item<Content>, current : @escaping () -> Item<Content>)
    {
        self.original = original
        
        self.currentProvider = current
    }
}


/// The default `ItemContentCoordinator`, which performs no actions.
public final class DefaultItemContentCoordinator<Content:ItemContent> : ItemContentCoordinator
{
    public let actions : Content.CoordinatorActions
    public let info : Content.CoordinatorInfo
    
    internal init(
        actions: Content.CoordinatorActions,
        info: Content.CoordinatorInfo
    ) {
        self.actions = actions
        self.info = info
    }
}
