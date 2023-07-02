//
//  NavigationConfig.swift
//  ReNavigation
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak, Pawel Zgoda-Ferchmin.
//

import Foundation
import UIKit

public struct NavigationConfig {
    public typealias TabBarItems<T> = (_ tabBar: UITabBar, _ items: [(item: T, uiTabBarItem: UITabBarItem)]) -> TabBarItemsResult
    public typealias CustomControls<T> = (_ tabBar: UITabBar, _ items: [T]) -> CustomControlsResult
    public typealias Custom<T> = (_ items: [T]) -> NavigationContainerController

    enum Config<T> {
        case uiTabBar(TabBarItems<T>)
        case customTabBar(CustomControls<T>)
        case custom(Custom<T>)
    }

    public enum ConfigError: Error {
        case tooManyElements
    }

    let type: Any
    let items: [any NavigationItem]
    let config: Config<any NavigationItem>

    public init<T>(_ creator: @escaping TabBarItems<T>, for items: [T]) throws where T: NavigationItem {
        guard items.count <= 5 else { throw ConfigError.tooManyElements }

        self.items = items
        self.type = T.self
        self.config = .uiTabBar { tabBar, items in
            creator(tabBar, items.compactMap {
                guard let item = $0.item as? T else { return nil }
                return (item: item, uiTabBarItem: $0.uiTabBarItem)
            })
        }
    }

    public init<T>(_ creator: @escaping CustomControls<T>, for items: [T]) where T: NavigationItem {
        self.items = items
        self.type = T.self
        self.config = .customTabBar { tabBar, items in
            creator(tabBar, items.compactMap { $0 as? T })
        }
    }

    public init<T>(_ creator: @escaping Custom<T>, for items: [T]) where T: NavigationItem {
        self.items = items
        self.type = T.self
        self.config = .custom { items in
            creator(items.compactMap { $0 as? T })
        }
    }
}

public struct TabBarItemsResult {
    public let height: (() -> CGFloat)?
    public let overlay: UIView?

    public init(height: (() -> CGFloat)? = nil, overlay: UIView? = nil) {
        self.height = height
        self.overlay = overlay
    }
}

public struct CustomControlsResult {
    public let height: (() -> CGFloat)?
    public let overelay: UIView
    public let controls: [UIControl]

    public init(height: (() -> CGFloat)? = nil, overelay: UIView, controls: [UIControl]) {
        self.height = height
        self.overelay = overelay
        self.controls = controls
    }
}
