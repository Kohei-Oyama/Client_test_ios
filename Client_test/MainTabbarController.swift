//
//  MainTabb.swift
//  Client_test
//
//  Created by Kohei Oyama on 2017/04/09.
//  Copyright © 2017年 Oyama. All rights reserved.
//

import UIKit

class MainTabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstNav: UINavigationController = UINavigationController(rootViewController: ViewController())
        firstNav.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.mostRecent, tag: 1)
        let secondNav: UINavigationController = UINavigationController(rootViewController: MainViewController())
        secondNav.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.mostViewed, tag: 2)
        
        let myTabs = [
            firstNav,
            secondNav,
            ]
        
        self.setViewControllers(myTabs, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
