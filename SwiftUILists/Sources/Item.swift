//
//  Item.swift
//  SwiftUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import Listable
import SwiftUI


//
// MARK: SwiftUI Elements
//

///
/// An `ItemContent` specialized for use with SwiftUI. Instead of providing
/// a custom view from `createReusableContentView`, and then updating it in `apply(to:)`,
/// you instead provide SwiftUI view trees, and `Listable` handles mapping this to an underlying SwiftUI view.
///
@available(iOS 13.0, *)
public protocol SwiftUIItemContent : ItemContent
    where
    ContentView == SwiftUIContentView,
    BackgroundView == SwiftUIContentView,
    SelectedBackgroundView == SwiftUIContentView
{
    //
    // MARK: Creating SwiftUI View Representations
    //
    
    associatedtype ContentType : SwiftUI.View

    /// Required. Create and return the SwiftUI view used to represent the content.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the view
    /// based on the current state of the item.
    ///
    func content(with info : ApplyItemContentInfo) -> ContentType
    
    associatedtype BackgroundType : SwiftUI.View = EmptyView

    /// Optional. Create and return the SwiftUI view used to represent the background of the content.
    /// You usually provide this method alongside `selectedBackground(with:)`, if your content
    /// supports selection or highlighting.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the view
    /// based on the current state of the item.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns an `EmptyView`.
    ///
    func background(with info : ApplyItemContentInfo) -> BackgroundType
    
    associatedtype SelectedBackgroundType : SwiftUI.View = BackgroundType

    /// Optional. Create and return the SwiftUI view used to represent the background of the content when it is selected or highlighted.
    /// You usually provide this method alongside `background(with:)`, if your content supports selection or highlighting.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the view
    /// based on the current state of the item.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns an `EmptyView`.
    ///
    func selectedBackground(with info : ApplyItemContentInfo) -> SelectedBackgroundType
}


@available(iOS 13.0, *)
public extension SwiftUIItemContent where BackgroundType == EmptyView
{
    //
    // MARK: Default Implementations
    //

    /// By default, content has no background.
    func background(with info : ApplyItemContentInfo) -> BackgroundType
    {
        EmptyView()
    }
}


@available(iOS 13.0, *)
public extension SwiftUIItemContent where SelectedBackgroundType == EmptyView
{
    //
    // MARK: Default Implementations
    //

    /// By default, content has no selected background.
    func selectedBackground(with info : ApplyItemContentInfo) -> SelectedBackgroundType
    {
        EmptyView()
    }
}


@available(iOS 13.0, *)
public extension SwiftUIItemContent
{
    //
    // MARK: ItemContent
    //

    /// Maps the `SwiftUIItemContent` methods into the underlying `SwiftUIContentView` used to render the element.
    func apply(to views : ItemContentViews<Self>, for reason: ApplyReason, with info : ApplyItemContentInfo)
    {
        views.content.rootView = self.rootView(wrapping: self.content(with: info))
        views.background.rootView = self.rootView(wrapping: self.background(with: info))
        views.selectedBackground.rootView = self.rootView(wrapping: self.selectedBackground(with: info))
    }
    
    private func rootView<ViewType:View>(wrapping view : ViewType) -> AnyView
    {
        AnyView(
            view.edgesIgnoringSafeArea(.all)
        )
    }

    /// Creates the view used to render the content of the item.
    static func createReusableContentView(frame: CGRect) -> ContentView
    {
        SwiftUIContentView(frame: frame)
    }

    /// Creates the view used to render the background of the item.
    static func createReusableBackgroundView(frame: CGRect) -> BackgroundView
    {
        SwiftUIContentView(frame: frame)
    }
    
    /// Creates the view used to render the background of the item.
    static func createReusableSelectedBackgroundView(frame: CGRect) -> SelectedBackgroundView
    {
        SwiftUIContentView(frame: frame)
    }
}
