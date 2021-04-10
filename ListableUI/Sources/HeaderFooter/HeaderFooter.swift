//
//  HeaderFooter.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//


public typealias Header<Content:HeaderFooterContent> = HeaderFooter<Content>
public typealias Footer<Content:HeaderFooterContent> = HeaderFooter<Content>


public struct HeaderFooter<Content:HeaderFooterContent> : AnyHeaderFooter
{
    public var content : Content
    
    public var sizing : Sizing
    public var layouts : HeaderFooterLayouts
    
    public typealias OnTap = (Content) -> ()
    public var onTap : OnTap?
    
    public var debuggingIdentifier : String? = nil
    
    internal let reuseIdentifier : ReuseIdentifier<Content>
    
    //
    // MARK: Initialization
    //
    
    public typealias Configure = (inout HeaderFooter) -> ()
    
    public init(
        _ content : Content,
        configure : Configure
    ) {
        self.init(content)
        
        configure(&self)
    }
    
    public init(
        _ content : Content,
        sizing : Sizing = .thatFits(.init(.atLeast(.default))),
        layouts : HeaderFooterLayouts = .init(),
        onTap : OnTap? = nil
    ) {
        assertIsValueType(Content.self)
        
        self.content = content
        
        self.sizing = sizing
        self.layouts = layouts
        
        self.onTap = onTap
        
        self.reuseIdentifier = ReuseIdentifier.identifier(for: Content.self)
    }
    
    // MARK: AnyHeaderFooter
    
    public var alwaysReappliesToVisibleView : Bool {
        self.content.alwaysReappliesToVisibleView
    }
    
    // MARK: AnyHeaderFooter_Internal
    
    public func apply(
        to anyView : UIView,
        for reason : ApplyReason,
        with info : ApplyHeaderFooterContentInfo
    ) {
        let view = anyView as! HeaderFooterContentView<Content>
        
        let views = HeaderFooterContentViews<Content>(
            content: view.content,
            background: view.background,
            pressed: view.pressedBackground
        )
        
        self.content.apply(
            to: views,
            for: reason,
            with: info
        )
    }
        
    public func anyIsEquivalent(to other : AnyHeaderFooter) -> Bool
    {
        guard let other = other as? HeaderFooter<Content> else {
            return false
        }
        
        return self.content.isEquivalent(to: other.content)
    }
    
    public func newPresentationHeaderFooterState(performsContentCallbacks : Bool) -> Any
    {
        return PresentationState.HeaderFooterState(self, performsContentCallbacks: performsContentCallbacks)
    }
}


extension HeaderFooter : SignpostLoggable
{
    var signpostInfo : SignpostLoggingInfo {
        SignpostLoggingInfo(
            identifier: self.debuggingIdentifier,
            instanceIdentifier: nil
        )
    }
}
