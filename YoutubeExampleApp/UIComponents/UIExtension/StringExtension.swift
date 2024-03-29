//
//  StringExtension.swift
//  YoutubeExampleApp
//
//  Created by Ekin Celik on 31/10/2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import UIKit

extension String {
    func convertHtmlStringSymbols() -> String {
        let mainString = replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
        return mainString
    }

    func convertViewCountFormat() -> String? {
        var viewCount = self
        viewCount = viewCount.replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")
        let items = viewCount.components(separatedBy: " ")
        if items.count > 0 {
            let numberStr = items[0]
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let number = numberFormatter.number(from: numberStr)
            if let suffixString = number?.suffixNumber() {
                let formattedViewCount = "\(suffixString) views"
                return formattedViewCount
            }
        }
        return nil
    }

    func getYoutubeFormattedDuration() -> String {
        guard prefix(2) == "PT" else { return self }

        var hour = 0
        var minute = 0
        var second = 0

        let hRange = range(of: "H")
        let mRange = range(of: "M")
        let sRange = range(of: "S")

        if hRange != nil, let hourString = slice(from: "PT", to: "H"), let hourInt = Int(hourString) {
            hour = hourInt
            if mRange != nil, let minuteString = slice(from: "H", to: "M"), let minInt = Int(minuteString) {
                minute = minInt
                if sRange != nil, let secondString = slice(from: "M", to: "S"), let secInt = Int(secondString) {
                    second = secInt
                }
            } else if sRange != nil, let secondString = slice(from: "H", to: "S"), let secInt = Int(secondString) {
                second = secInt
            }
        } else if mRange != nil, let minuteString = slice(from: "PT", to: "M"), let minInt = Int(minuteString) {
            minute = minInt
            if sRange != nil, let secondString = slice(from: "M", to: "S"), let secInt = Int(secondString) {
                second = secInt
            }
        } else if sRange != nil, let secondString = slice(from: "PT", to: "S"), let secInt = Int(secondString) {
            second = secInt
        }

        let sum = (hour * 3600) + (minute * 60) + second

        if sum == 0 {
            return ""
        }

        let seconds = sum % 60
        let minutes = (sum / 60) % 60
        let hours = sum / 3600

        if hours == 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else if minutes == 0, hours == 0 {
            return String(format: "%%02d", seconds)
        }

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom ..< rangeTo])
    }
}
