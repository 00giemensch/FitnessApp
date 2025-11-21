//
//  MainTabBarController.swift
//  FitnessApp
//
//  Created by Ilnur on 16.11.2025.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabBar()
    }

    
    private func setupCustomTabBar() {
        tabBar.clipsToBounds = true
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        appearance.stackedLayoutAppearance.selected.iconColor = .appPurple
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(red: 0.66, green: 0.19, blue: 0.77, alpha: 1.0)]
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}

