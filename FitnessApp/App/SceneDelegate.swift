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
        
        let coordinator = AppCoordinator()
        
        self.appCoordinator = coordinator
        
        Task { @MainActor in
            coordinator.start(with: window)
        }

    }

  


}

