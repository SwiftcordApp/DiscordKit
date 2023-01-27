//
//  ComponentBuilder.swift
//  
//
//  Created by Vincent Kwok on 27/1/23.
//

import Foundation
import DiscordKitCore

@resultBuilder
public struct ComponentBuilder {
    public static func buildBlock(_ components: [Component]...) -> [Component] {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[Component]]) -> [Component] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: Component) -> [Component] {
        [expression]
    }

    public static func buildOptional(_ component: [Component]?) -> [Component] {
        component ?? []
    }
    public static func buildEither(first component: [Component]) -> [Component] {
        component
    }
    public static func buildEither(second component: [Component]) -> [Component] {
        component
    }
}
