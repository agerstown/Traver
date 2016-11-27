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
        self.tabBar.items?[0].title = "Profile".localized()
        self.tabBar.items?[1].title = "Recommendations".localized()
        self.tabBar.items?[2].title = "Settings".localized()
    }
}
