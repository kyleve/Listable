//
//  PresentationState.HeaderFooterState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/22/20.
//

import Foundation
import UIKit

protocol AnyPresentationHeaderFooterState : AnyObject
{
    var anyModel : AnyHeaderFooter { get }
        
    func dequeueAndPrepareReusableHeaderFooterView(in cache : ReusableViewCache, frame : CGRect) -> UIView
    func enqueueReusableHeaderFooterView(_ view : UIView, in cache : ReusableViewCache)
    
    func applyTo(view anyView : UIView, reason : ApplyReason)
    
    func setNew(headerFooter anyHeaderFooter : AnyHeaderFooter)
    
    func resetCachedSizes()
    func size(for info : Sizing.MeasureInfo, cache : ReusableViewCache) -> CGSize
}


extension PresentationState
{
    final class HeaderFooterViewStatePair
    {
        var state : AnyPresentationHeaderFooterState? {
            didSet {
                guard oldValue !== self.state else {
                    return
                }
                
                guard let container = self.visibleContainer else {
                    return
                }
                
                container.headerFooter = self.state
            }
        }
        
        private(set) var visibleContainer : SupplementaryContainerView?
        
        func willDisplay(view : SupplementaryContainerView)
        {
            self.visibleContainer = view
        }
        
        func didEndDisplay()
        {
            self.visibleContainer = nil
        }
        
        func applyToVisibleView()
        {
            guard let view = visibleContainer?.content, let state = self.state else {
                return
            }
            
            state.applyTo(view: view, reason: .wasUpdated)
        }
    }
    
    final class HeaderFooterState<Content:HeaderFooterContent> : AnyPresentationHeaderFooterState
    {
        var model : HeaderFooter<Content>
        
        let performsContentCallbacks : Bool
                
        init(_ model : HeaderFooter<Content>, performsContentCallbacks : Bool)
        {
            self.model = model
            self.performsContentCallbacks = performsContentCallbacks
        }
        
        // MARK: AnyPresentationHeaderFooterState
        
        var anyModel: AnyHeaderFooter {
            return self.model
        }
                
        func dequeueAndPrepareReusableHeaderFooterView(in cache : ReusableViewCache, frame : CGRect) -> UIView
        {
            let view = cache.pop(with: self.model.reuseIdentifier) {
                HeaderFooterContentView<Content>(frame: frame)
            }
            
            self.applyTo(view: view, reason: .willDisplay)
            
            return view
        }
        
        func enqueueReusableHeaderFooterView(_ view : UIView, in cache : ReusableViewCache)
        {
            cache.push(view, with: self.model.reuseIdentifier)
        }
        
        func applyTo(view : UIView, reason : ApplyReason)
        {
            let view = view as! HeaderFooterContentView<Content>
            
            let views = HeaderFooterContentViews<Content>(
                content: view.content,
                background: view.background,
                pressed: view.pressedBackground
            )
            
            view.onTap = self.model.onTap.map { onTap in { [weak self] in
                    guard let self = self else { return }
                    
                    onTap(self.model.content)
                }
            }
            
            self.model.content.apply(to: views, reason: reason)
        }
        
        func setNew(headerFooter anyHeaderFooter: AnyHeaderFooter)
        {
            let oldModel = self.model
            
            self.model = anyHeaderFooter as! HeaderFooter<Content>
            
            let isEquivalent = self.model.anyIsEquivalent(to: oldModel)
            
            if isEquivalent == false {
                self.resetCachedSizes()
            }
        }
        
        private var cachedSizes : [SizeKey:CGSize] = [:]
        
        func resetCachedSizes()
        {
            self.cachedSizes.removeAll()
        }
        
        func size(for info : Sizing.MeasureInfo, cache : ReusableViewCache) -> CGSize
        {
            guard info.sizeConstraint.isEmpty == false else {
                return .zero
            }
            
            let key = SizeKey(
                width: info.sizeConstraint.width,
                height: info.sizeConstraint.height,
                layoutDirection: info.direction,
                sizing: self.model.sizing
            )
            
            if let size = self.cachedSizes[key] {
                return size
            } else {
                SignpostLogger.log(.begin, log: .updateContent, name: "Measure HeaderFooter", for: self.model)
                
                let size : CGSize = cache.use(
                    with: self.model.reuseIdentifier,
                    create: {
                        return HeaderFooterContentView<Content>(frame: .zero)
                }, { view in
                    let views = HeaderFooterContentViews<Content>(
                        content: view.content,
                        background: view.background,
                        pressed: view.pressedBackground
                    )
                    
                    self.model.content.apply(to: views, reason: .willDisplay)
                    
                    return self.model.sizing.measure(with: view, info: info)
                })
                
                self.cachedSizes[key] = size
                
                SignpostLogger.log(.end, log: .updateContent, name: "Measure HeaderFooter", for: self.model)
                
                return size
            }
        }
    }
}
