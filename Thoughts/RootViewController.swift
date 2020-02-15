//
//  RootViewController.swift
//  Thoughts
//
//  Created by Jeremy Jung on 2/15/20.
//  Copyright © 2020 Jeremy Jung. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewController = ThoughtViewController()
        
        viewController.tabBarItem = UITabBarItem(title: "Thoughts", image: UIImage(named: "house-7"), selectedImage: UIImage(named: "house-7"))
        
        let profileViewController = ProfileViewController()
        
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "man-7"), selectedImage: UIImage(named: "man-7"))
        
        let viewControllerList = [viewController, profileViewController]
        
        viewControllers = viewControllerList
        viewControllers = viewControllerList.map {UINavigationController(rootViewController: $0)}

}

}

