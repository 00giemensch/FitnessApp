//
//  AppCoordinator.swift
//  FitnessApp
//
//  Created by Ilnur on 20.11.2025.
//

import UIKit
import Foundation

protocol IAppCoordinator: AnyObject {
    func showWorkoutSelection()
    func showWorkout(exerciseId: String, exerciseName: String)
    func showExerciseStatistics(exerciseId: String)
    func showExerciseDetails(exerciseId: Int)
}

final class AppCoordinator: IAppCoordinator {

    private let wgerService: WgerServiceProtocol
    private let workoutManager: WorkoutManagerProtocol
    private let goalManager: GoalManagerProtocol
    private let coreDataManager: CoreDataManagerProtocol
    
    private weak var window: UIWindow?
    
    private var currentNavigationController: UINavigationController? {
        guard let tabBarController = window?.rootViewController as? UITabBarController,
              let selectedVC = tabBarController.selectedViewController as? UINavigationController else {
            return nil
        }
        return selectedVC
    }
    
    func showWorkoutSelection() {
        let localExercisesVC = LocalExercisesViewController()
        localExercisesVC.coordinator = self
        currentNavigationController?.pushViewController(localExercisesVC, animated: true)
    }
    
    func showWorkout(exerciseId: String, exerciseName: String) {
        let workoutVC = WorkoutViewController(
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            workoutManager: workoutManager
        )
        currentNavigationController?.pushViewController(workoutVC, animated: true)
    }
    
    func showExerciseStatistics(exerciseId: String) {
        let statisticsVC = ExerciseStatisticsViewController(
            exerciseId: exerciseId,
            workoutManager: workoutManager,
            goalManager: goalManager
        )
        statisticsVC.coordinator = self
        currentNavigationController?.pushViewController(statisticsVC, animated: true)
    }
    
    func showExerciseDetails(exerciseId: Int) {
        let viewModel = WgerExerciseDetailViewModel(exerciseId: exerciseId, service: wgerService)
        let detailVC = WgerExerciseDetailViewController(exerciseId: exerciseId, viewModel: viewModel, service: wgerService)
        currentNavigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    let tabBarController: MainTabBarController = {
        let controller = MainTabBarController()
        return controller
    }()
    
    let homeNavigationController = UINavigationController()
    let statiscticsNavigationController = UINavigationController()
    let exercisesNavigationController = UINavigationController()
    
    public init(
        wgerService: WgerServiceProtocol,
        coreDataManager: CoreDataManagerProtocol,
        workoutManager: WorkoutManagerProtocol? = nil,
        goalManager: GoalManagerProtocol? = nil
    ) {
        self.wgerService = wgerService
        self.coreDataManager = coreDataManager
        
        self.workoutManager = workoutManager ?? WorkoutManager(coreDataManager: coreDataManager)
        self.goalManager = goalManager ?? GoalManager(coreDataManager: coreDataManager)
        
        tabBarController.viewControllers = [
            homeNavigationController,
            exercisesNavigationController,
            statiscticsNavigationController
        ]
    }
    
    func start(with window: UIWindow) {
        self.window = window
        setupTabBar()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func setupTabBar() {
        
        let homeVC = HomeViewController()
        homeVC.coordinator = self
        homeNavigationController.setViewControllers([homeVC], animated: false)
        homeNavigationController.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        let statisticsVC = StatisticsModuleFactory.makeStatisticsModule(
            coordinator: self,
            workoutManager: workoutManager,
            goalManager: goalManager
        )
        statiscticsNavigationController.setViewControllers([statisticsVC], animated: false)
        statiscticsNavigationController.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "chart.bar"), selectedImage: UIImage(systemName: "chart.bar.fill"))
        
        let exercisesViewModel = WgerExercisesViewModel(service: wgerService)
        let exercisesVC = WgerExercisesViewController(viewModel: exercisesViewModel)
        exercisesVC.coordinator = self
        exercisesNavigationController.setViewControllers([exercisesVC], animated: false)
        exercisesNavigationController.tabBarItem = UITabBarItem(title: "Инструкции", image: UIImage(systemName: "dumbbell"), selectedImage: UIImage(systemName: "dumbbell.fill"))
    }
}
