//
//  LocalExercisesViewModel.swift
//  FitnessApp
//
//  Created by Ilnur on 21.11.2025.
//

import Foundation

final class LocalExercisesViewModel {
    var onExercisesChanged: (() -> Void)?
    var onError: ((String) -> Void)?

    private(set) var exercises: [LocalExercise] = LocalExercise.allExercises

    var availableExercises: [LocalExercise] {
        exercises.filter { $0.isAvailable }
    }

    func getExercise(at index: Int) -> LocalExercise? {
        guard index >= 0, index < exercises.count else { return nil }
        return exercises[index]
    }

    func refresh() {
        exercises = LocalExercise.allExercises
        onExercisesChanged?()
    }

    func startWorkout(for index: Int) -> LocalExercise? {
        guard let exercise = getExercise(at: index), exercise.isAvailable else { return nil }
        return exercise
    }
}


