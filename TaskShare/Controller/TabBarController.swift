//
//  TabBarController.swift
//  TaskShare
//
//  Created by Stacey Moore on 10/1/21.
//

import UIKit

class TabBarController: UITabBarController {

    var colors = Colors()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        colors.setSelectedColor()
        tabBar.tintColor = colors.getCurrentColor()
    }

}
