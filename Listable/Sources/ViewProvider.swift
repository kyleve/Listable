//
//  ViewProvider.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/2/20.
//

import Foundation


public extension UIView
{
    static func provide(_ build : (inout ViewProvider.Builder<Self>) -> ()) -> ViewProvider
    {
        ViewProvider(Self.self, build: build)
    }
}

public struct ViewProvider
{
    let viewType : ObjectIdentifier
    let builder : AnyViewProviderBuilder
    
    public init<View:UIView>(_ type : View.Type, build : (inout Builder<View>) -> ())
    {
        self.viewType = ObjectIdentifier(View.self)
        
        var builder = Builder<View>()
        
        build(&builder)
        
        self.builder = builder
    }
    
    public struct Builder<View:UIView> : AnyViewProviderBuilder
    {
        public var create : () -> View = {
            View()
        }
        
        public var update : (View) -> () = { _ in }
        
        // MARK: AnyViewDescriptionBuilder
        
        func anyCreate() -> UIView
        {
            return self.create()
        }
        
        func anyUpdate(_ anyView : UIView) -> ()
        {
            let view = anyView as! View
            
            self.update(view)
        }
        
        func anyCreateAndUpdate() -> UIView
        {
            let view = self.create()
            
            self.update(view)
            
            return view
        }
    }
    
    final class State
    {
        var provider : ViewProvider {
            didSet {
                if self.provider.viewType == oldValue.viewType {
                    self.provider.builder.anyUpdate(self.view)
                } else {
                    self.view = self.provider.builder.anyCreateAndUpdate()
                }
            }
        }
        
        var view : UIView
        
        init(_ provider : ViewProvider)
        {
            self.provider = provider
            
            self.view = self.provider.builder.anyCreateAndUpdate()
        }
        
        static func state(with current : State?, new : ViewProvider?) -> State?
        {
            if let current = current {
                if let new = new {
                    current.provider = new
                    return current
                } else {
                    return nil
                }
            } else {
                if let new = new {
                    return State(new)
                } else {
                    return nil
                }
            }
        }
    }
}


protocol AnyViewProviderBuilder
{
    func anyCreate() -> UIView
    func anyUpdate(_ view : UIView) -> ()
    
    func anyCreateAndUpdate() -> UIView
}
