//
//  List.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI

import ListableUI


///
/// A Blueprint element which can be used to display a Listable `ListView` within
/// an element tree.
///
/// You should use the `List` element as follows, just like you'd use the `configure(with:)` method
/// on `ListView` itself.
/// ```
/// List { list in
///     list.header = HeaderFooter(PodcastsHeader())
///
///     let podcasts = Podcast.podcasts.sorted { $0.episode < $1.episode }
///
///     list += Section("podcasts") { section in
///
///         section.header = HeaderFooter(PodcastsSectionHeader())
///
///         section += podcasts.map { podcast in
///             PodcastRow(podcast: podcast)
///         }
///     }
/// }
/// ```
/// The parameter passed to the initialization closure is an instance of `ListProperties`,
/// which holds the various configuration options and content for the list. See `ListProperties` for
/// a full overview of all the configuration options available such as animation, layout configuration, etc.
///
/// When being laid out, a `List` will take up as much space as it is allowed. If you'd like to constrain
/// the size of a list, wrap it in a `ConstrainedSize`, or other size constraining element.
///
public struct List : Element
{
    /// The properties which back the on-screen list.
    ///
    /// When it comes time to render the `List` on screen,
    /// `ListView.configure(with: properties)` is called
    /// to update the on-screen list with the provided properties.
    public var properties : ListProperties
    
    /// How the `List` is measured when the element is laid out
    /// by Blueprint.  Defaults to `.fillParent`, which means
    /// it will take up all the size it is given. You can change this to
    /// `.measureContent` to instead measure the optimal size.
    ///
    /// See the `ListSizing` documentation for more.
    public var sizing : ListSizing
    
    //
    // MARK: Initialization
    //
        
    /// Create a new list, configured with the provided properties,
    /// configured with the provided `ListProperties` builder.
    public init(
        sizing : ListSizing = .fillParent,
        configure : ListProperties.Configure
    ) {
        self.sizing = sizing
        
        self.properties = .default(with: configure)
    }
    
#if swift(>=5.4)
    /// Create a new list, configured with the provided properties,
    /// configured with the provided `ListProperties` builder.
    public init(
        sizing : ListSizing = .fillParent,
        configure : ListProperties.Configure = { _ in },
        @ContentBuilder<Section> build : () -> [Section]
    ) {
        self.sizing = sizing
        
        self.properties = .default(with: configure)
        
        self.properties += build()
    }
#endif
    
    //
    // MARK: Element
    //
        
    public var content : ElementContent {
        ElementContent { size, env in
            ListContent(
                properties: self.properties,
                sizing: self.sizing,
                environment: env
            )
        }
    }
    
    public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription? {
        nil
    }
}


extension List {
    
    fileprivate struct ListContent : Element {
        
        var properties : ListProperties
        var sizing : ListSizing
        
        init(
            properties : ListProperties,
            sizing : ListSizing,
            environment : Environment
        ) {
            var properties = properties
            
            properties.environment.blueprintEnvironment = environment
            
            self.properties = properties
            self.sizing = sizing
        }
        
        // MARK: Element
            
        public var content : ElementContent {
            switch self.sizing {
            case .fillParent:
                return ElementContent { constraint -> CGSize in
                    constraint.maximum
                }
                
            case .measureContent(let key, let limit):
                return ElementContent(
                    measurementCachingKey: {
                        if let key = key {
                            return MeasurementCachingKey(type: Self.self, input: key)
                        } else {
                            return nil
                        }
                    }()
                ) { constraint -> CGSize in
                    ListView.contentSize(
                        in: constraint.maximum,
                        for: self.properties,
                        itemLimit: limit
                    )
                }
            }
        }
        
        public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription?
        {
            ListView.describe { config in
                config.builder = {
                    ListView(frame: bounds, appearance: self.properties.appearance)
                }
                
                config.apply { listView in
                    listView.configure(with: self.properties)
                }
            }
        }
    }
}
