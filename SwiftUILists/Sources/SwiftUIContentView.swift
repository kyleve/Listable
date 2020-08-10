//
//  SwiftUIContentView.swift
//  SwiftUILists
//
//  Created by Kyle Van Essen on 5/31/20.
//

import SwiftUI


@available(iOS 13.0, *)
public final class SwiftUIContentView : UIView, ItemCellContentView
{
    var rootView : AnyView {
        get {
            self.controller.rootView
        }
        set {
            self.controller.rootView = newValue
        }
    }
        
    private let controller : UIHostingController<AnyView>
    
    public override init(frame: CGRect)
    {
        self.controller = UIHostingController(rootView: AnyView(EmptyView()))

        super.init(frame: frame)
        
        self.addSubview(self.controller.view)
        
        self.backgroundColor = .clear
        self.isOpaque = false
        
        self.controller.view.backgroundColor = .clear
        self.controller.view.isOpaque = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: UIView
    
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.controller.view.frame = self.bounds
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        return self.controller.view.sizeThatFits(size)
    }
    
    // MARK: ItemCellContentView
    
    public weak var containingViewController : UIViewController? = nil {
        didSet {
            if oldValue === self.containingViewController {
                return
            }
            
            if let parent = self.containingViewController {
                parent.addChild(self.controller)
                self.controller.didMove(toParent: parent)
            } else {
                self.controller.willMove(toParent: nil)
                self.controller.removeFromParent()

            }
        }
    }
    
    public func willDisplay()
    {
        if self.containingViewController != nil {
            return
        }
        
        fatalError("The `containingViewController` was not set on `SwiftUIContentView` before it was about to be presented. This will break embedded view controllers in SwiftUI view trees. This property is normally set automatically by Listable. If you are allocating this view manually, set the `containingViewController` property manually.")
    }
}
