//
//  ReNavigationController.swift
//  ReNavigation
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak, Pawel Zgoda-Ferchmin.
//

import Foundation
import UIKit

open class ReNavigationController: UINavigationController {
    @ReNavigation.Completions var completions
    
    @objc private var _delegate = Delegate()

    public override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        super.delegate = _delegate
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        super.delegate = _delegate
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        super.delegate = _delegate
    }

    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        super.delegate = _delegate
    }

    open override var delegate: UINavigationControllerDelegate? {
        get { _delegate.delegate }
        set { _delegate.delegate = newValue }
    }

    private class Delegate: NSObject, UINavigationControllerDelegate {
        @ReNavigation.Completions private var completions

        var delegate: UINavigationControllerDelegate?

        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            delegate?.responds(to: aSelector) == true ? delegate : self
        }

        override func responds(to aSelector: Selector!) -> Bool {
            super.responds(to: aSelector) || delegate?.responds(to: aSelector) ?? false
        }

        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            delegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
            completions[viewController]?()
            completions[viewController] = nil
        }
    }
}
