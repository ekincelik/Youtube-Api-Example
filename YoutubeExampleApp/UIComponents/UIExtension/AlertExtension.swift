//
//  AlertExtension.swift
//  YoutubeExampleApp
//
//  Created by Ekin Çelik on 20.09.2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import UIKit

class Alerts {
    static func showActionsheet(viewController: UIViewController, title: String, message: String, actions: [(String, UIAlertAction.Style)], completion: @escaping (_ index: Int) -> Void) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: isTablet ? .alert : .actionSheet)
        for (index, (title, style)) in actions.enumerated() {
            let alertAction = UIAlertAction(title: title, style: style) { _ in
                completion(index)
            }
            alertViewController.addAction(alertAction)
        }
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        }
        alertViewController.addAction(cancelAlertAction)
        viewController.present(alertViewController, animated: true, completion: nil)
    }
}
