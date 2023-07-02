//
//  TabItem.swift
//  ReNavigation
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak, Pawel Zgoda-Ferchmin.
//

import Foundation
import UIKit

class TabItem: UITabBarItem {
    let navigationTab: any NavigationItem
    let controlItem: UIControl?

    init(navigationTab: any NavigationItem, controlItem: UIControl?) {
        self.navigationTab = navigationTab
        self.controlItem = controlItem
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
