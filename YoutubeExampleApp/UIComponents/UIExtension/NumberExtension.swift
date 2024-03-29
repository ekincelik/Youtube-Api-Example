//
//  NumberExtension.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 19.09.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import UIKit
extension Int {
    func formatPoints() -> String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1_000_000
        let billion = number / 1_000_000_000

        if billion >= 1.0 {
            return "\(round(billion * 10) / 10)B"
        } else if million >= 1.0 {
            return "\(round(million * 10) / 10)M"
        } else if thousand >= 1.0 {
            return "\(round(thousand * 10 / 10))K"
        } else {
            return "\(Int(number))"
        }
    }
}

extension NSNumber {
    func suffixNumber() -> String {
        var num: Double = doubleValue
        let sign = ((num < 0) ? "-" : "")
        num = fabs(num)
        if num < 1000.0 {
            return "\(sign)\(num)"
        }
        let exp = Int(log10(num) / 3.0) // log10(1000));
        let units: [String] = ["K", "M", "G", "T", "P", "E"]
        let roundedNum: Double = round(10 * num / pow(1000.0, Double(exp))) / 10

        return "\(sign)\(roundedNum)\(units[exp - 1])"
    }
}
