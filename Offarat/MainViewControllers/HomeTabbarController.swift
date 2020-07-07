//
//  HomeTabbarController.swift
//  Darahem
//
//  Created by Dulal Hossain on 13/10/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit

class HomeTabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = .white
        self.tabBar.tintColor = Color.colorPrimary
        
        selectedIndex = 2
    }

}
