//
//  SceneDelegate.swift
//  FitnessApp
//
//  Created by Ilnur on 13.11.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window
        
        // Создаём контекст Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        // Создаём менеджеры
        let coreDataManager = CoreDataManager(context: context)
        let wgerCache = WgerCache()
        let wgerService = WgerService(cache: wgerCache)
        
        // Создаём координатор со всеми зависимостями
        let coordinator = AppCoordinator(
            wgerService: wgerService,
            coreDataManager: coreDataManager
        )
        
        self.appCoordinator = coordinator
        
        Task { @MainActor in
            coordinator.start(with: window)
        }

    }

  


}

