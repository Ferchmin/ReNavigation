//
//  TabBarViewController.swift
//  ReNavigation
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak, Pawel Zgoda-Ferchmin.
//

import Foundation
import UIKit

public protocol NavigationContainerController where Self: UIViewController {
    var currentNavigationController: UINavigationController? { get }
    var containers: [UINavigationController]? { get }
    var selectedItem: (any NavigationItem)? { get }

    func set<T: NavigationItem>(current: T)
}

class TabBarViewController: UITabBarController, NavigationContainerController {
    @ReNavigation.Router private var router

    override open var childForStatusBarStyle: UIViewController? {
        currentNavigationController?.topViewController
    }

    public var currentNavigationController: UINavigationController? {
        guard selectedIndex >= 0 && selectedIndex < containers?.count ?? 0 else { return nil }
        return containers?[selectedIndex]
    }

    var selectedItem: (any NavigationItem)? {
        (selectedViewController?.tabBarItem as? TabItem)?.navigationTab
    }

    var containers: [UINavigationController]? {
        viewControllers?.compactMap { $0 as? UINavigationController }
    }

    private var customTabBar: TabBar { tabBar as! TabBar}

    private let uiState: UIState
    private let config: NavigationConfig?
    private let navigationControllerFactory: () -> UINavigationController

    init(config: NavigationConfig?,
         uiState: UIState,
         navigationControllerFactory: @escaping () -> UINavigationController) {
        self.config = config
        self.navigationControllerFactory = navigationControllerFactory
        self.uiState = uiState
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        setValue(TabBar(), forKey: "tabBar")
        super.viewDidLoad()

        delegate = self
    }

    func setup(items: [any NavigationItem]) {
        let tabItems: [UITabBarItem]
        if case let .customTabBar(configurator) = config?.config {
            let result = configurator(customTabBar, items)
            customTabBar.height = result.height
            let customView = result.overelay
            let controlItems = result.controls

            controlItems.enumerated().forEach { index, elem in
                elem.addTarget(self, action: #selector(touchUpInside(control: )), for: .touchUpInside)
                elem.tag = index
            }

            tabItems = zip(items, controlItems).map {
                TabItem(navigationTab: $0, controlItem: $1)
            }

            customTabBar.customView = customView
            customTabBar.controlItems = controlItems

            moreNavigationController.navigationBar.isHidden = true
        } else {
            let tabBarItems = items.map { TabItem(navigationTab: $0, controlItem: nil) }
            tabItems = tabBarItems

            if case let .uiTabBar(configurator) = config?.config {
                let result = configurator(customTabBar, tabBarItems.map { (item: $0.navigationTab, uiTabBarItem: $0) })
                customTabBar.customView = result.overlay
                customTabBar.controlItems = nil
                customTabBar.height = result.height
            } else {
                customTabBar.customView = nil
                customTabBar.controlItems = nil
                customTabBar.height = nil
            }

            moreNavigationController.navigationBar.isHidden = false
        }

        viewControllers = tabItems.map { tab in
            let controller = navigationControllerFactory()
            controller.tabBarItem = tab
            return controller
        }
    }

    @objc dynamic func touchUpInside(control: UIControl) {
        let index = control.tag
        guard index >= 0 && index < viewControllers?.count ?? 0,
              let viewController = self.viewControllers?[index] else { return }
        navigate(to: viewController)
    }

    func set<T: NavigationItem>(current: T) {
        guard let selected = viewControllers?
            .first(where: { ($0.tabBarItem as? TabItem)?.navigationTab as? T == current }) else { return }

        selectedViewController = selected
        customTabBar._selectedItem = selectedViewController?.tabBarItem
    }

    private func navigate(to viewController: UIViewController) {
        guard let tab = viewController.tabBarItem as? TabItem else { return }
        router.show(on: tab.navigationTab,
                    loader: tab.navigationTab.loader)
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController,
                                 shouldSelect viewController: UIViewController) -> Bool {
        DispatchQueue.main.async { [weak self] in
            self?.navigate(to: viewController)
        }
        return false
    }
}
