//
//  CustomBackButton.swift
//  FitnessApp
//
//  Created by Ilnur on 16.11.2025.
//

import UIKit

extension UINavigationController {
    func setupCustomBackButton() {
        let backButtonImage = UIImage(systemName: "chevron.left")
        let backButton = UIBarButtonItemAppearance()
        backButton.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        let appearance = UINavigationBarAppearance()
        appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        appearance.backButtonAppearance = backButton
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        
        navigationBar.tintColor = .label
    }
}

