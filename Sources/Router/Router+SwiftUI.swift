//
//  Router+SwiftUI.swift
//  ReNavigation
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak, Pawel Zgoda-Ferchmin.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
extension Router {
    public func showOnRoot<V>(view: @escaping @autoclosure () -> V,
                              animated: Bool = true,
                              navigationBarHidden: Bool = true) where V: View {
        showOnRoot(loader: ReNavigation.Loader(view: view),
                   animated: animated,
                   navigationBarHidden: navigationBarHidden)
    }

    public func show<V, Item: NavigationItem>(on item: Item,
                                              view: @escaping @autoclosure () -> V,
                                              animated: Bool = true,
                                              navigationBarHidden: Bool = true,
                                              resetStack: Bool = false) where V: View {
        show(on: item,
             loader: ReNavigation.Loader(view: view),
             animated: animated,
             navigationBarHidden: navigationBarHidden,
             resetStack: resetStack)
    }

    public func push<V>(view: @escaping @autoclosure () -> V,
                        pop: PopMode? = nil,
                        animated: Bool = true,
                        clearBackground: Bool = false) where V: View {
        push(loader: ReNavigation.Loader(view: view, clearBackground: clearBackground),
             pop: pop,
             animated: animated)
    }

    public func showModal<V>(view: @escaping @autoclosure () -> V,
                             animated: Bool = true,
                             withNavigationController: Bool = true,
                             presentationStyle: UIModalPresentationStyle = .fullScreen,
                             preferredCornerRadius: CGFloat? = nil,
                             clearBackground: Bool = false) where V: View {
        showModal(loader: ReNavigation.Loader(view: view, clearBackground: clearBackground),
                  animated: animated,
                  withNavigationController: withNavigationController,
                  presentationStyle: presentationStyle,
                  preferredCornerRadius: preferredCornerRadius)
    }
}
