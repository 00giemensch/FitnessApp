//
//  UIView+.swift
//  FitnessApp
//
//  Created by Ilnur on 17.11.2025.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { addSubview($0) }
    }
}
