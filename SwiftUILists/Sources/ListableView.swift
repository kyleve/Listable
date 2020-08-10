//
//  ListableView.swift
//  SwiftUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import SwiftUI
@testable import Listable


@available(iOS 13.0, *)
public struct ListableView : UIViewControllerRepresentable
{
    public var properties : ListProperties

    //
    // MARK: Initialization
    //
        
    public init(build : ListProperties.Build)
    {
        self.properties = .default(with: build)
    }
    
    //
    // MARK: UIViewRepresentable
    //
    
    public typealias UIViewControllerType = ViewController
    
    public func makeUIViewController(context: Context) -> ViewController
    {
        ViewController()
    }
    
    public func updateUIViewController(_ viewController: ViewController, context: Context)
    {
        viewController.properties = self.properties
    }
    
    public final class ViewController : ListViewController
    {
        var properties : ListProperties? {
            didSet {
                self.reload(animated: true)
            }
        }
        
        public override func viewDidLoad()
        {
            super.viewDidLoad()
            
            self.listView?.containingViewController = self
        }
        
        public override func configure(list: inout ListProperties) {
            guard let properties = self.properties else {
                return
            }
            
            list = properties
        }
    }
}
