//
//  NavigationItem.swift
//  ReNavigation
//
//  Created by Grzegorz Jurzak, Daniel Plachta, Dariusz Grzeszczak, Pawel Zgoda-Ferchmin.
//

import Foundation
import UIKit

public protocol NavigationItem: Equatable {
    var loader: ReNavigation.Loader { get }
}
