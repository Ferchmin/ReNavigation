//
//  UINavigationController+Navigation.swift
//  ReNavigation
//
//  Created by Paweł Zgoda-Ferchmin on 02/07/2023.
//

import Foundation
import UIKit

extension ReNavigationController {
    func pushViewController(_ viewController: UIViewController,
                            animated: Bool,
                            completion: @escaping () -> Void) {
        completions[viewController] = completion
        pushViewController(viewController, animated: animated)
    }

    func setViewControllers(_ viewControllers: [UIViewController],
                            animated: Bool,
                            completion: @escaping () -> Void) {
        if let viewController = viewControllers.last {
            completions[viewController] = completion
        } else {
            completion()
        }
        setViewControllers(viewControllers, animated: animated)
    }

    func popViewController(animated: Bool,
                           completion: @escaping () -> Void) {
        if popViewController(animated: animated) != nil,
           animated == true,
           let viewController = viewControllers.last {
            completions[viewController] = completion
        } else {
            completion()
        }
    }

    func popToRootViewController(animated: Bool,
                                 completion: @escaping () -> Void) {
        if popToRootViewController(animated: animated) != nil,
           animated == true,
           let viewController = viewControllers.last {
            completions[viewController] = completion
        } else {
            completion()
        }
    }
}
