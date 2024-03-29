//
//  UISearchBarExtension.swift
//  YoutubeExampleApp
//
//  Created by Ekin Celik on 21/12/2020.
//
//

import UIKit

extension UISearchBar {
    private func getViewElement<T>(type _: T.Type) -> T? {
        let svs = subviews.flatMap { $0.subviews }
        guard let element = svs.first(where: { $0 is T }) as? T else { return nil }
        return element
    }

    func getSearchBarTextField() -> UITextField? {
        getViewElement(type: UITextField.self)
    }

    func setTextColor(_ color: UIColor) {
        if let textField = getSearchBarTextField() {
            textField.textColor = color
        }
    }
}
