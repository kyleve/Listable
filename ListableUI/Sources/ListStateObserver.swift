//
//  ListStateObserver.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/9/20.
//

import Foundation


/// Allows reading state and events based on state changes within the list view.
/// For example, you can determine when a user scrolls, when the content of a list
/// changes, etc.
///
/// This is useful if you want to log these events to a logging or debugging system,
/// or potentially perform actions on the list based on some change.
///
/// Every callback has its own data type, filled with information relevant to that callback.
/// Every callback also contains a `ListActions` to perform actions back on the list.
///
/// You can register for each callback type multiple times – eg to split apart different pieces of
/// functionality. Eg, two calls to `onDidScroll` registers two callbacks.
///
/// Example
/// -------
/// ```
/// ListStateObserver { observer in
///     observer.onDidScroll { info in
///         // Called whenever the list is scrolled.
///     }
///
///     observer.onContentChanged { info in
///         // Called when items are inserted or removed.
///     }
/// }
/// ```
/// Note that the duration of performing all callbacks is logged to `os_signpost`. If you find that
/// your application is running slowly, and you have registered `ListStateObserver` callbacks,
/// use Instruments.app to see what callback is slow.
///
public struct ListStateObserver {
    
    /// Creates and optionally allows you to configure an observer.
    public init(_ configure : (inout ListStateObserver) -> () = { _ in })
    {
        configure(&self)
    }
    
    //
    // MARK: Responding To Scrolling
    //
    
    public typealias OnDidScroll = (DidScroll) -> ()

    /// Registers a callback which will be called when the list view is scrolled, or is
    /// scrolled to top.
    ///
    /// **Note** This callback is called very frequently when the user is scrolling
    /// the list. As such, make sure any work you do in the callback is efficient.
    public mutating func onDidScroll( _ callback : @escaping OnDidScroll)
    {
        self.onDidScroll.append(callback)
    }
    
    /// Parameters available for `OnDidScroll` callbacks.
    public struct DidScroll {
        public let actions : ListActions
        public let positionInfo : ListScrollPositionInfo
    }
    
    private(set) var onDidScroll : [OnDidScroll] = []
    
    //
    // MARK: Responding To Content Updates
    //
    
    public typealias OnContentUpdated = (ContentUpdated) -> ()
    
    /// Registers a callback which will be called when the list view's content is updated
    /// due to a call to `setContent`.
    ///
    /// **Note**: This method is called even if there were no actual changes made during the `setContent`
    /// call. To see if there were changes, check the `hadChanges` property on `ContentUpdated`.
    public mutating func onContentUpdated( _ callback : @escaping OnContentUpdated)
    {
        self.onContentUpdated.append(callback)
    }
    
    /// Parameters available for `OnContentUpdated` callbacks.
    public struct ContentUpdated {
        public let hadChanges : Bool
        
        public let actions : ListActions
        public let positionInfo : ListScrollPositionInfo
    }
    
    private(set) var onContentUpdated : [OnContentUpdated] = []
    
    //
    // MARK: Responding To Visibility Changes
    //
    
    public typealias OnVisibilityChanged = (VisibilityChanged) -> ()
    
    /// Registers a callback which will be called when the list view's content is changed – eg through
    /// inserted, removed, updated, moved items or sections.
    public mutating func onVisibilityChanged( _ callback : @escaping OnVisibilityChanged)
    {
        self.onVisibilityChanged.append(callback)
    }
    
    /// Parameters available for `OnVisibilityChanged` callbacks.
    public struct VisibilityChanged {
        public let actions : ListActions
        public let positionInfo : ListScrollPositionInfo
        
        public let displayed : [AnyItem]
        public let endedDisplay : [AnyItem]
    }
    
    private(set) var onVisibilityChanged : [OnVisibilityChanged] = []
    
    //
    // MARK: Responding To Frame Changes
    //
    
    public typealias OnFrameChanged = (FrameChanged) -> ()
    
    /// Registers a callback which will be called when the list view's frame is changed.
    public mutating func onFrameChanged(_ callback : @escaping OnFrameChanged)
    {
        self.onFrameChanged.append(callback)
    }
    
    /// Parameters available for `OnFrameChanged` callbacks.
    public struct FrameChanged {
        public let actions : ListActions
        public let positionInfo : ListScrollPositionInfo

        public let old : CGRect
        public let new : CGRect
    }
    
    private(set) var onFrameChanged : [OnFrameChanged] = []
    
    //
    // MARK: Internal Methods
    //
    
    static func perform<CallbackInfo>(
        _ callbacks : Array<(CallbackInfo) -> ()>,
        _ loggingName : StaticString,
        with listView : ListView, makeInfo : (ListActions) -> (CallbackInfo)
    ){
        guard callbacks.isEmpty == false else {
            return
        }
        
        var actions = ListActions()
        actions.listView = listView
        
        let callbackInfo = makeInfo(actions)
        
        SignpostLogger.log(log: .stateObserver, name: loggingName, for: listView) {
            callbacks.forEach {
                $0(callbackInfo)
            }
        }
        
        actions.listView = nil
    }
}
