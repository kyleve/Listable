//
//  RefreshControl.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/4/19.
//

import Foundation
import UIKit

public struct RefreshControl
{
    public var isRefreshing : Bool
    
    public enum Title : Equatable
    {
        case string(String)
        case attributed(NSAttributedString)
    }
    
    public var title : Title?
    public var tintColor : UIColor?
    
    public typealias OnRefresh = () -> ()
    public var onRefresh : OnRefresh
    
    public init(
        isRefreshing: Bool,
        title : Title? = nil,
        tintColor : UIColor? = nil,
        onRefresh : @escaping OnRefresh
        )
    {
        self.isRefreshing = isRefreshing

        self.title = title
        self.tintColor = tintColor
        
        self.onRefresh = onRefresh
    }
    
    internal final class PresentationState
    {
        public var model : RefreshControl
        public var view : UIRefreshControl
        
        public init(_ model : RefreshControl)
        {
            self.model = model
            self.view = UIRefreshControl()
            
            self.view.addTarget(self, action: #selector(refreshControlChanged), for: .valueChanged)
        }
        
        func update(with control : RefreshControl)
        {
            self.model = control
            
            if let title = self.model.title {
                switch title {
                case .string(let string): self.view.attributedTitle = NSAttributedString(string: string)
                case .attributed(let string): self.view.attributedTitle = string
                }
            } else {
                self.view.attributedTitle = nil
            }
            
            self.view.tintColor = self.model.tintColor
            
            if self.model.isRefreshing {
                self.view.beginRefreshing()
            } else {
                self.view.endRefreshing()
            }
        }
        
        @objc func refreshControlChanged()
        {
            self.model.onRefresh()
        }
    }

}
