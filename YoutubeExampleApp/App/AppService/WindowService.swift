//
//  WindowService.swift
//  Axis
//
//  Created by Ekin Celik on 20/05/2020.
//  Copyright © 2020 Ekin Celik. All rights reserved.
//
import Foundation
import UIKit

public class WindowService: NSObject, AppService, UIGestureRecognizerDelegate {
    public var window: UIWindow?

    public func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = MainViewController()

        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.delegate = self
        window?.addGestureRecognizer(tapGesture)

        return true
    }

    public func applicationDidReceiveMemoryWarning(_: UIApplication) {}

    public func applicationDidBecomeActive(_: UIApplication) {}

    public func application(_: UIApplication, handleEventsForBackgroundURLSession _: String, completionHandler _: @escaping () -> Void) {}

    public func application(_: UIApplication, open _: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return true
    }
}
