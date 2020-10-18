//
//  AppDelegate.swift
//  Checkout
//
//  Created by Kyle Van Essen on 6/14/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit
import BlueprintUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let vc = UIViewController()
        vc.view = BlueprintView(element: BasicExample())
        
        window.rootViewController = vc
        
        self.window = window
        
        window.makeKeyAndVisible()
        
        return true
    }
}

