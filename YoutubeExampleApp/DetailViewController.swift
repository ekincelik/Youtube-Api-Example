//
//  DetailViewController.swift
//  Reference Music App
//
//  Created by Ekin Celik on 20/05/2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var detailDescriptionLabel: UILabel!

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.timestamp!.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}
