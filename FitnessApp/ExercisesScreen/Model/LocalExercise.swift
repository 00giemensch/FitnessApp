//
//  LocalExercise.swift
//  FitnessApp
//
//  Created by Ilnur on 13.11.2025.
//

import Foundation

struct LocalExercise {
    let id: String
    let name: String
    let isAvailable: Bool
    
    static let allExercises: [LocalExercise] = [
        LocalExercise(id: "pullups", name: "Турник", isAvailable: true),
        LocalExercise(id: "pushups", name: "Анжуманя", isAvailable: true),
        LocalExercise(id: "crunches", name: "Пресс качат", isAvailable: true),
        LocalExercise(id: "running", name: "Бегит", isAvailable: false),
        LocalExercise(id: "dumbbells", name: "Гантбли", isAvailable: false)
    ]
}
