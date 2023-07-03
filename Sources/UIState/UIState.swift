//
//  UIState.swift
//  ReNavigation
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak, Pawel Zgoda-Ferchmin.
//

import Foundation
import UIKit

public final class UIState {
    private let window: UIWindow
    private let uiStateMainController: ReNavigationController

    public internal(set) var modalControllers: [UIViewController] = []

    public let config: UIStateConfig

    public init(window: UIWindow, config: UIStateConfig) {
        self.window = window
        self.config = config
        self.uiStateMainController = config.navigationController()
        uiStateMainController.view.bounds = window.bounds
        uiStateMainController.setNavigationBarHidden(config.navigationBarHidden, animated: false)
        uiStateMainController.setViewControllers([config.initialController()], animated: false)

        window.rootViewController = uiStateMainController
    }

    public func setRoot(controller: UIViewController,
                        animated: Bool,
                        navigationBarHidden: Bool,
                        completion: @escaping () -> Void) {
        if uiStateMainController.isNavigationBarHidden != navigationBarHidden {
            uiStateMainController.setNavigationBarHidden(navigationBarHidden, animated: animated)
        }
        uiStateMainController.setViewControllers([controller],
                                                 animated: animated,
                                                 completion: completion)
    }

    public var rootViewController: UIViewController {
        uiStateMainController.viewControllers[0]
    }

    public var navigationController: ReNavigationController? {
        modalControllers
            .compactMap { $0 as? ReNavigationController }
            .last ?? (rootViewController as? NavigationContainerController)?
            .currentNavigationController as? ReNavigationController ?? uiStateMainController
    }

    var topPresenter: UIViewController {
        modalControllers.last ?? rootViewController
    }

    public func present(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        topPresenter.present(viewController, animated: animated) { [topPresenter] in
            topPresenter.setNeedsStatusBarAppearanceUpdate()
            completion()
        }
        modalControllers.append(viewController)
    }

    public func dismissAll(animated: Bool, completion: @escaping () -> Void) {
        dismiss(animated: animated, number: Int.max, completion: completion)
    }

    public func dismiss(animated: Bool, number: Int = 1, completion: @escaping () -> Void) {
        let number = modalControllers.count >= number ? number : modalControllers.count
        guard number > 0 else {
            completion()
            return
        }
        modalControllers.removeLast(number)
        topPresenter.dismiss(animated: animated) { [topPresenter] in
            topPresenter.setNeedsStatusBarAppearanceUpdate()
            completion()
        }
    }

    public func pop(animated: Bool, completion: @escaping () -> Void) {
        navigationController?.popViewController(animated: animated, completion: completion)
    }
}
