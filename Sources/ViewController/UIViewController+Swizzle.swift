//
//  UIViewController+Swizzle.swift
//  ReNavigation
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak, Pawel Zgoda-Ferchmin.
//

import Foundation
import UIKit

var swizzle: Void = UIViewController.swizzleDidDisapear()

// swizzle viewDidDissapear
private extension UIViewController {
    private struct AssociatedKeys {
        static var didDisapearClosureKey = "com.db.didDisapear"
    }

    private typealias ViewDidDisappearFunction = @convention(c) (UIViewController, Selector, Bool) -> Void
    private typealias ViewDidDisappearBlock = @convention(block) (UIViewController, Bool) -> Void

    static func swizzleDidDisapear() {
        var implementation: IMP?

        let swizzledBlock: ViewDidDisappearBlock = { calledViewController, animated in
            let selector = #selector(UIViewController.viewDidDisappear(_:))
            let uiState = ReNavigation.shared.uiState

            if calledViewController.isBeingDismissed,
               uiState.modalControllers.last?.isBeingDismissed == true {
                ReNavigation.shared.uiState.modalControllers.removeLast()
            }

            if let implementation = implementation {
                let viewDidAppear: ViewDidDisappearFunction = unsafeBitCast(implementation,
                                                                            to: ViewDidDisappearFunction.self)
                viewDidAppear(calledViewController, selector, animated)
            }

        }
        implementation = swizzleViewDidDisappear(UIViewController.self, to: swizzledBlock)
    }

    private static func swizzleViewDidDisappear(_ class_: AnyClass, to block: @escaping ViewDidDisappearBlock) -> IMP? {
        let selector = #selector(UIViewController.viewDidDisappear(_:))
        let method: Method? = class_getInstanceMethod(class_, selector)
        let newImplementation: IMP = imp_implementationWithBlock(unsafeBitCast(block, to: AnyObject.self))

        if let method = method {
            let types = method_getTypeEncoding(method)
            return class_replaceMethod(class_, selector, newImplementation, types)
        } else {
            class_addMethod(class_, selector, newImplementation, "")
            return nil
        }
    }
}
