//
//  AppCoordinator.swift
//  FitnessApp
//
//  Created by Ilnur on 20.11.2025.
//

import UIKit
import Foundation

final class AppCoordinator {
    
    let tabBarController: MainTabBarController = {
        let controller = MainTabBarController()
        return controller
    }()
    
    private let rootNavigationController: UINavigationController = {
        let controller = UINavigationController()
        return controller
    }()
    
    let homeNavigationController = UINavigationController()
    let statiscticsNavigationController = UINavigationController()
    let exercisesNavigationController = UINavigationController()
    
    public init() {
        tabBarController.viewControllers = [
            homeNavigationController,
            exercisesNavigationController,
            statiscticsNavigationController
        ]
    }
    
    func start(with window: UIWindow) {
        setupTabBar()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func setupTabBar() {
        
        let homeVC = HomeViewController()
        homeNavigationController.setViewControllers([homeVC], animated: false)
        homeNavigationController.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        //homeVC.setupCustomBackButton()
        
        let statisticsVC = StatisticsViewController()
        statiscticsNavigationController.setViewControllers([statisticsVC], animated: false)
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "chart.bar"), selectedImage: UIImage(systemName: "chart.bar.fill"))
        
        let exercisesVC = WgerExercisesViewController()
        exercisesNavigationController.setViewControllers([exercisesVC], animated: false)
        exercisesVC.tabBarItem = UITabBarItem(title: "Инструкции", image: UIImage(systemName: "dumbbell"), selectedImage: UIImage(systemName: "dumbbell.fill"))
    }
}
