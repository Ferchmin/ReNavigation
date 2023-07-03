//
//  ReNavigation.swift
//  ReNavigation
//
//  Created by Paweł Zgoda-Ferchmin on 02/07/2023.
//

import Foundation
import UIKit

public enum ReNavigation {
    public static var shared: ReNavigationRouter {
        _shared ?? _default
    }

    private static var _shared: ReNavigationRouter?
    private static var _default: ReNavigationRouter = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        return ReNavigationRouter(window: window, uiStateConfig: .init())
    }()

    public static func initialize(for window: UIWindow, uiConfig: UIStateConfig) {
        let router = ReNavigationRouter(window: window, uiStateConfig: uiConfig)
        ReNavigation._shared = router
    }
}

extension ReNavigation {
    @propertyWrapper
    public final class Router {
        /// wrapped value of view model
        public lazy var wrappedValue: ReNavigationRouter = ReNavigation.shared

        /// Initializes property wrapper
        /// - Parameter navigator: user provided navigator that will be used intsted of ReNavigation provided
        public init(with navigator: ReNavigationRouter? = nil) {
            if let navigator = navigator {
                wrappedValue = navigator
            }
        }
    }

    @propertyWrapper
    final class Completions {
        /// wrapped value of view model
        var wrappedValue: [UIViewController: () -> Void] {
            get { ReNavigation.shared.completions }
            set { ReNavigation.shared.completions = newValue }
        }

        public init() { }
    }
}
