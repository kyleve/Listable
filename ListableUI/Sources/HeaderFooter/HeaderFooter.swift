//
//  HeaderFooter.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//

import UIKit

public protocol AnyHeaderFooter : AnyHeaderFooter_Internal
{
    var sizing : Sizing { get set }
    var layout : HeaderFooterLayout { get set }
}

public protocol AnyHeaderFooter_Internal
{
    var layout : HeaderFooterLayout { get }
    
    func apply(to headerFooterView : UIView, reason: ApplyReason)
    
    func anyIsEquivalent(to other : AnyHeaderFooter) -> Bool
    
    func newPresentationHeaderFooterState(performsContentCallbacks : Bool) -> Any
}


public typealias Header<Content:HeaderFooterContent> = HeaderFooter<Content>
public typealias Footer<Content:HeaderFooterContent> = HeaderFooter<Content>

public struct HeaderFooter<Content:HeaderFooterContent> : AnyHeaderFooter
{
    public var content : Content
    
    public var sizing : Sizing
    public var layout : HeaderFooterLayout
    
    public typealias OnTap = (Content) -> ()
    public var onTap : OnTap?
    
    public var debuggingIdentifier : String? = nil
    
    internal let reuseIdentifier : ReuseIdentifier<Content>
    
    //
    // MARK: Initialization
    //
    
    public typealias Build = (inout HeaderFooter) -> ()
    
    public init(
        _ content : Content,
        build : Build
    ) {
        self.init(content)
        
        build(&self)
    }
    
    public init(
        _ content : Content,
        sizing : Sizing = .thatFits(.init(.atLeast(.default))),
        layout : HeaderFooterLayout = HeaderFooterLayout(),
        onTap : OnTap? = nil
    ) {
        self.content = content
        
        self.sizing = sizing
        self.layout = layout
        
        self.onTap = onTap
        
        self.reuseIdentifier = ReuseIdentifier.identifier(for: Content.self)
    }
    
    // MARK: AnyHeaderFooter_Internal
    
    public func apply(to anyView : UIView, reason: ApplyReason)
    {
        let view = anyView as! HeaderFooterContentView<Content>
        
        let views = HeaderFooterContentViews<Content>(
            content: view.content,
            background: view.background,
            pressed: view.pressedBackground
        )
        
        self.content.apply(to: views, reason: reason)
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


public struct HeaderFooterLayout : Equatable
{
    public var width : CustomWidth
        
    public init(
        width : CustomWidth = .default
    ) {
        self.width = width
    }
}
