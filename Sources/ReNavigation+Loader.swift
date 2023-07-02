//
//  ReNavigation+Loader.swift
//  ReNavigation
//
//  Created by Paweł Zgoda-Ferchmin on 02/07/2023.
//

import Foundation
import UIKit
import SwiftUI

public extension ReNavigation {
    struct Loader {
        private var factory: () -> UIViewController

        public init(factory: @escaping () -> UIViewController) {
            self.factory = factory
        }

        public init(factory: @escaping @autoclosure () -> UIViewController) {
            self.init(factory: factory)
        }

        @available(iOS 13.0, *)
        public init<V: View>(view: @escaping () -> V,
                             clearBackground: Bool = false) {
            self.factory = {
                let host = UIHostingController(rootView: view())
                if clearBackground {
                    host.view.backgroundColor = .clear
                }
                return host
            }
        }

        @available(iOS 13.0, *)
        public init<V: View>(view: @escaping @autoclosure () -> V,
                             clearBackground: Bool = false) {
            self.init(view: view, clearBackground: clearBackground)
        }

        public func load() -> UIViewController {
            factory()
        }
    }
}
