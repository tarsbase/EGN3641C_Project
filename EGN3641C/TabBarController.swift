//
//  TabBarController.swift
//  
//
//  Created by Brandon Baker on 12/1/19.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var disconnect : () -> Void = { }

    let browseVC = BrowseTableViewController()
    let joinVC = CallManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barTintColor = .white
        tabBar.tintColor = .primary
        tabBar.isTranslucent = false
        
        joinVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "phone"), tag: 0)
        disconnect = joinVC.disconnect ?? {}
        browseVC.currentTabBarController = self

        browseVC.tabBarItem = UITabBarItem(title: "Rooms", image: UIImage(named: "list"), tag: 1)
        browseVC.disconnect = disconnect
        let tabBarList = [joinVC, browseVC]

        viewControllers = tabBarList as! [UIViewController]
        self.delegate = self
    }
    func setDisconnect() {
        browseVC.disconnect = disconnect
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        browseVC.loadRooms()
    }
}
