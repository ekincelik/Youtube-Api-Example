//
//  ReusableCell.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 14.09.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import Foundation
import UIKit

public protocol ReusableCell: AnyObject {
    static var reuseIdentifier: String { get }
}

public extension ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public extension UICollectionView {
    func register(reusableCell: ReusableCell.Type) {
        register(reusableCell, forCellWithReuseIdentifier: reusableCell.reuseIdentifier)
    }
}

public extension UITableView {
    func register(reusable: ReusableCell.Type) {
        register(reusable, forCellReuseIdentifier: reusable.reuseIdentifier)
    }
}
