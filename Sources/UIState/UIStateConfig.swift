//
//  UIStateConfig.swift
//  ReNavigation
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak, Pawel Zgoda-Ferchmin.
//

import Foundation
import UIKit

public struct UIStateConfig {
    let initialController: () -> UIViewController
    let navigationController: () -> ReNavigationController
    let navigationConfigs: [NavigationConfig]
    let navigationBarHidden: Bool

    public init(initialController: @escaping @autoclosure () -> UIViewController = UIViewController(),
                navigationController: (() -> ReNavigationController)? = nil,
                navigationConfigs: [NavigationConfig] = [],
                navigationBarHidden: Bool = true) {
        self.initialController = initialController
        self.navigationController = navigationController ?? { ReNavigationController() }
        self.navigationConfigs = navigationConfigs
        self.navigationBarHidden = navigationBarHidden
    }
}
