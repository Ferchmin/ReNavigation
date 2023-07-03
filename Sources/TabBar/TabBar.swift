//
//  TabBar.swift
//  ReNavigation
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak, Pawel Zgoda-Ferchmin.
//

import Foundation
import UIKit

class TabBar: UITabBar {
    var customView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let customView = customView else { return }
            customView.frame = bounds
            addSubview(customView)
        }
    }

    var controlItems: [UIControl]?

    var height: (() -> CGFloat)? {
        didSet {
            _height = height?()
            setNeedsLayout()
        }
    }

    private var _height: CGFloat?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        _height = height?()

        customView?.frame = bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
        guard controlItems != nil else { return }
        subviews
            .compactMap { $0 as? UIControl }
            .filter { $0 != customView }
            .forEach { $0.removeFromSuperview() }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        if let height = _height {
            size.height = height + safeAreaInsets.bottom
        }
        return size
    }

    var _selectedItem: UITabBarItem? {
        didSet {
            if  _selectedItem != oldValue,
                let tabBarItem = _selectedItem as? TabItem,
                let control = tabBarItem.controlItem {

                controlItems?.forEach {
                    $0.isSelected = $0 == control
                }
            }
        }
    }

    override var selectedItem: UITabBarItem? {
        get {
            _selectedItem
        }
        set {
            super.selectedItem = newValue
            _selectedItem = newValue
        }
    }
}
