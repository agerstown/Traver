//
//  MainTabBarController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/27/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isStatusBarHidden = false
        
        if let items = self.tabBar.items {
            for item in items {
                item.title = item.title?.localized()
            }
        }
        
        self.tabBar.tintColor = UIColor.darkBlueTraverColor
    }
}
