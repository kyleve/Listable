//
//  BlueprintHeaderFooterContent.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI
import ListableUI


/// Alias to allow less verbose creation of headers.
public typealias BlueprintHeaderContent = BlueprintHeaderFooterContent

/// Alias to allow less verbose creation of footers.
public typealias BlueprintFooterContent = BlueprintHeaderFooterContent


///
/// A `HeaderFooterContent` specialized for use with Blueprint. Instead of providing
/// custom views from `createReusable{...}View`, and then updating them in `apply(to:)`,
/// you instead provide Blueprint elements, and `Listable` handles mapping this to an underlying `BlueprintView`.
///
/// You do not need to provide any views; just Blueprint `Elements`. Do not
/// override the `createReusable{...}View` methods.
///
/// A non-tappable header that shows a label might look like this:
/// ```
/// struct MyHeaderContent : BlueprintHeaderFooterContent, Equatable
/// {
///     var title : String
///
///     var elementRepresentation: Element {
///         Label(text: self.title) {
///             $0.font = .systemFont(ofSize: 20.0, weight: .bold)
///         }
///         .inset(horizontal: 15.0, vertical: 10.0)
///     }
/// }
/// ```
/// The header is made `Equatable` in order to synthesize automatic conformance to `isEquivalent`,
/// based on the header's properties.
///
/// If you want to add support for rendering a background view and a pressed state, you should provide
/// both `background` and `pressedBackground` properties:
/// ```
/// var background : Element? {
///     Box(backgroundColor: .white)
/// }
///
/// var pressedBackground : Element? {
///     Box(backgroundColor: .lightGray)
/// }
/// ```
/// The ordering of the elements by z-index is as follows:
/// z-Index 3) `elementRepresentation`
/// z-Index 2) `pressedBackground` (Only if the header/footer is pressed, eg if the wrapping `HeaderFooter` has an `onTap` handler.)
/// z-Index 1) `background`
///
public protocol BlueprintHeaderFooterContent : HeaderFooterContent
where
    ContentView == BlueprintView,
    BackgroundView == BlueprintView,
    PressedBackgroundView == BlueprintView
{
    //
    // MARK: Creating Blueprint Element Representations
    //
    
    /// Required. Create and return the Blueprint element used to represent the content.
    var elementRepresentation : Element { get }
    
    /// Optional. Create and return the Blueprint element used to represent the background of the content.
    /// You usually provide this method alongside `pressedBackground`, if your header
    /// has an `onTap` handler.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns nil, and provides no background.
    ///
    var background : Element? { get }
    
    /// Optional. Create and return the Blueprint element used to represent the background of the content when it is pressed.
    /// You usually provide this method alongside `background`, if your header has an `onTap` handler.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns nil, and provides no selected background.
    ///
    var pressedBackground : Element? { get }
}


public extension BlueprintHeaderFooterContent
{
    //
    // MARK: BlueprintHeaderFooterContent
    //
    
    var background : Element? {
        nil
    }
    
    var pressedBackground : Element? {
        nil
    }
    
    //
    // MARK: HeaderFooterContent
    //
    
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        views.content.environment = info.environment.blueprintEnvironment
        views.content.element = self.elementRepresentation

        views.background.environment = info.environment.blueprintEnvironment
        views.background.element = self.background

        views.pressed.environment = info.environment.blueprintEnvironment        
        views.pressed.element = self.pressedBackground
        
        /// `BlueprintView` does not update its content until the next layout cycle.
        /// Force that layout cycle within this method if we're updating an already on-screen
        /// `ItemContent`, to ensure that we inherit any animation blocks we may be within.
        if reason == .wasUpdated {
            views.content.layoutIfNeeded()
            views.background.layoutIfNeeded()
            views.pressed.layoutIfNeeded()
        }
    }
    
    static func createReusableContentView(frame: CGRect) -> ContentView {
        self.newBlueprintView(with: frame)
    }
    
    static func createReusableBackgroundView(frame: CGRect) -> BackgroundView {
        self.newBlueprintView(with: frame)
    }
    
    static func createReusablePressedBackgroundView(frame: CGRect) -> PressedBackgroundView {
        self.newBlueprintView(with: frame)
    }
    
    private static func newBlueprintView(with frame : CGRect) -> BlueprintView {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
}
