//
//  TableViewSource.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/4/19.
//

import UIKit

// TODO: Rename this all to ContentProvider?


public protocol ListViewSource
{
    associatedtype State:Equatable
    
    func content(with state : SourceState<State>, content : inout Content)
    
    func content(with state : SourceState<State>) -> Content
}


public extension ListViewSource
{
    func content(with state : SourceState<State>) -> Content
    {
        return Content() { content in
            self.content(with: state, content: &content)
        }
    }
}


internal protocol AnySourcePresenter
{
    func discard()
    
    func reloadContent() -> Content
}


internal final class SourcePresenter<Source:ListViewSource> : AnySourcePresenter
{
    let source : Source
    
    var state : Source.State {
        get { return self.sourceState.value }
        set { self.sourceState.value = newValue }
    }
    
    private var sourceState : SourceState<Source.State>
    
    init(initial : Source.State, source : Source, didChange : @escaping () -> () = {})
    {
        self.source = source
        
        self.sourceState = SourceState(initial: initial, didChange: didChange)
    }
    
    // MARK: TableViewSourceController
    
    func discard()
    {
        self.sourceState.discard()
    }
    
    internal func reloadContent() -> Content
    {
        return self.source.content(with: self.sourceState)
    }
}


public final class StateAccessor<State:Equatable>
{
    public var value : State {
        get { return self.get() }
        set { self.set(newValue) }
    }
    
    private let get : () -> State
    private let set : (State) -> ()
    
    internal init(get : @escaping () -> State, set : @escaping (State) -> ())
    {
        self.get = get
        self.set = set
    }
}


public final class SourceState<Value:Equatable>
{
    public var value : Value {
        didSet {
            guard self.value != oldValue else { return }
            
            self.didChange?()
        }
    }
    
    public func set(_ block : (inout Value) -> ())
    {
        var new = self.value
        
        block(&new)
        
        self.value = new
    }
    
    public init(initial value : Value, didChange : @escaping () -> ())
    {
        self.value = value
        
        self.didChange = didChange
    }
    
    public func discard()
    {
        self.didChange = nil
    }
    
    private var didChange : (() -> ())?
}


//
// MARK: Block-Driven Sources
//


public final class DynamicSource<Input:Equatable> : ListViewSource
{
    public typealias Builder = (SourceState<Input>, inout Content) -> ()
    
    let builder : Builder
    
    public init(with builder : @escaping Builder)
    {
        self.builder = builder
    }
    
    public func content(with state: SourceState<Input>, content: inout Content)
    {
        self.builder(state, &content)
    }
}


//
// MARK: Immutable Sources
//


public final class StaticSource : ListViewSource
{
    public struct State : Equatable
    {
        public init() {}
    }
    
    public let content : Content
    
    public init(with content : Content = Content())
    {
        self.content = content
    }
    
    public convenience init(with builder : Content.Build)
    {
        self.init(with: Content(with: builder))
    }
    
    public func content(with state: SourceState<StaticSource.State>, content: inout Content)
    {
        listableFatal()
    }
    
    public func content(with state: SourceState<StaticSource.State>) -> Content
    {
        return self.content
    }
}


//
// MARK: Timer For Reloading
//

internal final class ReloadTimer
{
    private var timer : Timer?
    
    typealias OnFire = () -> ()
    private var onFire : OnFire?
    
    init(onFire : @escaping OnFire)
    {
        self.onFire = onFire
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
    }
    
    @objc func timerFired()
    {
        self.onFire?()
        self.onFire = nil
        
        self.timer = nil
    }
}
