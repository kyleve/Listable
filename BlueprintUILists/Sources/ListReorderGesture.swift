//
//  ListReorderGesture.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 11/14/19.
//

import BlueprintUI
import ListableUI


///
/// An element that wraps your provided element, to enable support
/// for user-driven re-ordering in a list view.
///
/// If you do not support reordering items, you do not need
/// to add this element anywhere in your hierarchy.
///
/// This element on its own has no visual appearance. Thus, you should
/// still render your own reorder dragger / handle / etc in the passed in element.
///
/// In the below example, we see how to set up the content of a simple item, which contains
/// a text label and a reorder grabber.
///
/// ```
/// func element(with info : ApplyItemContentInfo) -> Element
/// {
///     Row { row in
///         row.add(child: Label(text: "..."))
///
///         row.add(child: ListReorderGesture(actions: info.actions, wrapping: MyReorderGrabber()))
///
///         // Could also be written as:
///         row.add(child: MyReorderGrabber().listReorderGesture(with: info.reordering))
///     }
/// }
/// ```
public struct ListReorderGesture : Element
{
    /// The element which is being wrapped by the reorder gesture.
    public var element : Element
    
    /// If the gesture is enabled or not.
    public var isEnabled : Bool
    
    typealias OnStart = () -> Bool
    var onStart : OnStart
    
    typealias OnMove = (UIPanGestureRecognizer) -> ()
    var onMove : OnMove
    
    typealias OnDone = () -> ()
    var onDone : OnDone
    
    /// Creates a new re-order gesture which wraps the provided element.
    /// 
    /// This element on its own has no visual appearance. Thus, you should
    /// still render your own reorder dragger / handle / etc in the passed in element.
    public init(
        isEnabled : Bool = true,
        actions : ReorderingActions,
        wrapping element : () -> Element
    ) {
        self.isEnabled =  isEnabled
        
        self.onStart = { actions.beginMoving() }
        self.onMove = { actions.moved(with: $0) }
        self.onDone = { actions.end() }
        
        self.element = element()
    }

    //
    // MARK: Element
    //
    
    public var content: ElementContent {
        return ElementContent(child: self.element)
    }
    
    public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription?
    {
        return ViewDescription(WrapperView.self) { config in
            config.builder = {
                WrapperView(frame: bounds, wrapping: self)
            }
            
            config.apply { view in
                view.recognizer.isEnabled = self.isEnabled
                
                view.recognizer.onStart = self.onStart
                view.recognizer.onMove = self.onMove
                view.recognizer.onDone = self.onDone
            }
        }
    }
}


public extension Element
{
    /// Wraps the element in a re-order gesture.
    func listReorderGesture(with actions : ReorderingActions, isEnabled : Bool = true) -> Element
    {
        ListReorderGesture(isEnabled: isEnabled, actions: actions, wrapping: { self })
    }
}


fileprivate extension ListReorderGesture
{
    private final class GestureRecognizer : UIPanGestureRecognizer
    {
        public var onStart : OnStart? = nil
        public var onMove : OnMove? = nil
        public var onDone : OnDone? = nil
        
        override init(target: Any?, action: Selector?)
        {
            super.init(target: target, action: action)
            
            self.addTarget(self, action: #selector(updated))
            
            self.minimumNumberOfTouches = 1
            self.maximumNumberOfTouches = 1
        }
                
        @objc func updated()
        {
            switch self.state {
            case .possible: break
            case .began:
                let canStart = self.onStart?()
                
                if canStart == false {
                    self.state = .cancelled
                }
            case .changed:
                self.onMove?(self)

            case .ended: self.onDone?()
            case .cancelled, .failed: self.onDone?()
                
            @unknown default: listableFatal()
            }
        }
    }
    
    private final class WrapperView : UIView
    {
        let recognizer : GestureRecognizer
        
        init(frame: CGRect, wrapping : ListReorderGesture)
        {
            self.recognizer = GestureRecognizer()
            
            super.init(frame: frame)
            
            self.isOpaque = false
            self.clipsToBounds = false
            self.backgroundColor = .clear
            
            self.addGestureRecognizer(self.recognizer)
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            listableFatal()
        }
    }
}
