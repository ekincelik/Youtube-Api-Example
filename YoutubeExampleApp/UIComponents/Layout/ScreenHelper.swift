//
//  ScreenHelper.swift
//  YoutubeExampleApp
//
//  Created by Ekin Celik on 31/10/2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//
import Foundation
import UIKit

public let screenWidth: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
public let screenHeight: CGFloat = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)

// Device type
public let isTablet = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
