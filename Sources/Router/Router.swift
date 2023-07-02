//
//  Router.swift
//  ReNavigation
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak, Pawel Zgoda-Ferchmin.
//

import Foundation
import UIKit
import SwiftUI

open class Router {
    public typealias NavigationCompletions = [UIViewController: () -> Void]

    var uiState: UIState
    var completions: NavigationCompletions

    public init(window: UIWindow,
                uiStateConfig: UIStateConfig) {
        self.uiState = UIState(window: window,
                               config: uiStateConfig)
        self.completions = [:]
        _ = swizzle
    }

    open func showOnRoot(loader: ReNavigation.Loader,
                           animated: Bool = true,
                           navigationBarHidden: Bool = true) {
        let uiState = self.uiState

        // dismiss modals
        NavigationDispatcher.main.async { completion in
            uiState.rootViewController.dismiss(animated: true,
                                               completion: completion)
        }

        let viewController = loader.load()
        NavigationDispatcher.main.async { completion in
            uiState.setRoot(controller: viewController,
                            animated: animated,
                            navigationBarHidden: navigationBarHidden,
                            completion: completion)
        }
    }

    open func show<Item: NavigationItem>(on item: Item,
                                           loader: ReNavigation.Loader,
                                           animated: Bool = true,
                                           navigationBarHidden: Bool = true,
                                           resetStack: Bool = false) {
        let uiState = uiState

        guard uiState.navigationContainerController?.selectedItem as? Item != item || resetStack else {
            pop(mode: .popToRoot)
            return
        }

        let isTabBarOnTop = uiState.rootViewController is TabBarViewController

        let containerController: NavigationContainerController
        if isTabBarOnTop {
            containerController = uiState.rootViewController as! NavigationContainerController
        } else {
            let config = uiState.config.navigationConfigs.first { $0.type is Item.Type }
            if case let .custom(configurator) = config?.config {
                containerController = configurator(config?.items ?? [])
            } else {
                let tabController = TabBarViewController(config: config,
                                                         uiState: uiState,
                                                         navigationControllerFactory: uiState.config.navigationController)
                tabController.loadViewIfNeeded()
                tabController.setup(items: config?.items ?? [])
                containerController = tabController
                uiState.navigationContainerController = tabController
            }
        }

        containerController.set(current: item)

        //set up current if empty (or reset)
        let topNavigationController = containerController
            .containers?
            .first { ($0.tabBarItem as? TabItem)?.navigationTab as? Item == item }

        if let topNavigationController,
           topNavigationController.viewControllers.isEmpty || resetStack {
            topNavigationController.setViewControllers([loader.load()],
                                                       animated: false)
        }

        if !isTabBarOnTop {
            NavigationDispatcher.main.async { completion in
                uiState.setRoot(controller: containerController,
                                animated: animated,
                                navigationBarHidden: navigationBarHidden,
                                completion: completion)
            }
        }

        NavigationDispatcher.main.async { completion in
            // dismiss modals
            uiState.rootViewController.dismiss(animated: true, completion: completion)
        }
    }

    open func push(loader: ReNavigation.Loader,
                     pop: PopMode? = nil,
                     animated: Bool = true) {
        let uiState = self.uiState
        let controller = loader.load()

        NavigationDispatcher.main.async { completion in
            //dismiss not needed modals
            let number = uiState.modalControllers.count - uiState.modalControllers.reversed().drop { !$0.hasNavigation }.count
            uiState.dismiss(animated: animated,
                            number: number,
                            completion: completion)
        }

        NavigationDispatcher.main.async { completion in
            guard let navigationController = uiState.navigationController else {
                assertionFailure("PushMiddleware: No navigation Controller")
                return
            }

            if let pop {
                var viewControllers = navigationController.viewControllers
                switch pop {
                case .resetStack:
                    viewControllers = []
                case .popToRoot:
                    viewControllers = viewControllers.dropLast(viewControllers.count - 1)
                case .pop(let count):
                    let dropCount = min(count, viewControllers.count)
                    viewControllers = viewControllers.dropLast(dropCount)
                }

                navigationController.setViewControllers(viewControllers + [controller],
                                                        animated: animated,
                                                        completion: completion)
            } else {
                navigationController.pushViewController(controller,
                                                        animated: animated,
                                                        completion: completion)
            }
        }
    }

    open func pop(mode: PopMode = .pop(1), animated: Bool = true) {
        guard uiState.topPresenter.children.count > 1 else { return }

        let uiState = self.uiState

        NavigationDispatcher.main.async { completion in
            switch mode {
            case .popToRoot, .resetStack:
                uiState.navigationController?.popToRootViewController(animated: animated,
                                                                      completion: completion)
            case .pop(let count):
                if count > 1 {
                    let viewControllers = uiState.navigationController?.viewControllers ?? []
                    let dropCount = min(count, viewControllers.count - 1) - 1
                    let newViewControllers = Array(viewControllers.dropLast(max(0, dropCount)))
                    uiState.navigationController?.setViewControllers(newViewControllers, animated: false)
                }
                uiState.navigationController?.popViewController(animated: animated,
                                                                completion: completion)
            }
        }
    }

    open func showModal(loader: ReNavigation.Loader,
                          animated: Bool = true,
                          withNavigationController: Bool = true,
                          presentationStyle: UIModalPresentationStyle = .fullScreen,
                          preferredCornerRadius: CGFloat? = nil) {
        let uiState = self.uiState
        let viewController = loader.load()

        NavigationDispatcher.main.async { completion in

            // block if previously modal is not finish dismiss animation
            guard uiState.modalControllers.last?.isBeingDismissed != true else {
                completion()
                return
            }

            let newModal: UIViewController
            if withNavigationController {
                let navController = uiState.config.navigationController()

                navController.viewControllers = [viewController]
                navController.modalTransitionStyle = viewController.modalTransitionStyle
                navController.modalPresentationStyle = viewController.modalPresentationStyle
                newModal = navController
            } else {
                newModal = viewController
            }

            newModal.modalPresentationStyle = presentationStyle

            if #available(iOS 15.0, *) {
                if newModal.modalPresentationStyle == .pageSheet || newModal.modalPresentationStyle == .formSheet,
                   let cornerRadius = preferredCornerRadius {
                    newModal.sheetPresentationController?.preferredCornerRadius = cornerRadius
                }
            }

            uiState.present(newModal, animated: animated, completion: completion)
        }
    }

    open func dismissModal(dismissAllViews: Bool = false, animated: Bool = true) {
        let uiState = self.uiState

        NavigationDispatcher.main.async { completion in
            if dismissAllViews {
                uiState.dismissAll(animated: animated, completion: completion)
            } else {
                uiState.dismiss(animated: animated, completion: completion)
            }
        }
    }
}
