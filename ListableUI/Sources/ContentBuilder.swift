//
//  ContentBuilder.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/10/21.
//

#if swift(>=5.4)


///
/// Provides generic result builders to provide a SwiftUI-like DSL for building content.
///
/// Links
/// ----
/// https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md
/// https://www.swiftbysundell.com/articles/deep-dive-into-swift-function-builders/
///
/// TODO: Map does not work yet. I think I need to make array conform to AnyItemConvertible? But that didnt quite work...
///
@resultBuilder public enum ContentBuilder<ContentType> {
    
    /// The type of individual statement expressions in the transformed function.
    public typealias Expression = ContentType

    /// The type of a partial result.
    public typealias Component = [ContentType]

    /// The type of the final returned result.
    public typealias FinalResult = [ContentType]
    
    public static func buildBlock() -> Component {
        []
    }
    
    /// Required by every result builder to build combined results from
    /// statement blocks.
    public static func buildBlock(_ components: Component...) -> Component {
        components.reduce(into: []) { $0 += $1 }
    }
    
    public static func buildBlock(_ components: Expression...) -> Component {
        components
        //components.reduce(into: []) { $0 += $1 }
    }

    /// If declared, provides contextual type information for statement
    /// expressions to translate them into partial results.
    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }

    /// Enables support for `if` statements that do not have an `else`.
    public static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch'
    /// statements by folding conditional results into a single result.
    public static func buildEither(first component: Component) -> Component {
        component
    }

    /// With buildEither(first:), enables support for 'if-else' and 'switch'
    /// statements by folding conditional results into a single result.
    public static func buildEither(second component: Component) -> Component {
        component
    }

    /// Enables support for 'for..in' loops by combining the
    /// results of all iterations into a single result.
    public static func buildArray(_ components: [Component]) -> Component {
        components.reduce(into: []) { $0 += $1 }
    }

    /// If declared, this will be called on the partial result of an 'if
    /// #available' block to allow the result builder to erase type
    /// information.
    public static func buildLimitedAvailability(_ component: Component) -> Component {
        component
    }

    /// If declared, this will be called on the partial result from the outermost
    /// block statement to produce the final returned result.
    public static func buildFinalResult(_ component: Component) -> FinalResult {
        component
    }
}

#endif
