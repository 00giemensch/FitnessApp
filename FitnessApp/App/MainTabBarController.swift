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
        setupTabBar()
        setupCustomTabBar()
    }
    
    private func setupTabBar() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        homeVC.setupCustomBackButton()
        
        let statisticsVC = UINavigationController(rootViewController: StatisticsViewController())
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "chart.bar"), selectedImage: UIImage(systemName: "chart.bar.fill"))
        
        let exercisesVC = UINavigationController(rootViewController: WgerExercisesViewController())
        exercisesVC.tabBarItem = UITabBarItem(title: "Инструкции", image: UIImage(systemName: "dumbbell"), selectedImage: UIImage(systemName: "dumbbell.fill"))
        
        viewControllers = [homeVC, statisticsVC, exercisesVC]
        
        tabBar.tintColor = .appPurple
        tabBar.unselectedItemTintColor = .gray
    }
    
    private func setupCustomTabBar() {
        tabBar.layer.cornerRadius = 20
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

