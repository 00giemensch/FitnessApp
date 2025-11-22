//
//  ExerciseStatisticsViewModel.swift
//  FitnessApp
//
//  Created by Ilnur on 21.11.2025.
//

import Foundation

final class ExerciseStatisticsViewModel {
    var onDataChanged: (() -> Void)?
    var onError: ((Error) -> Void)?

    private(set) var workouts: [Workout] = []
    private let exerciseId: String
    private let workoutRepository: WorkoutRepositoryProtocol
    private let goalRepository: GoalRepositoryProtocol

    init(
        exerciseId: String,
        workoutRepository: WorkoutRepositoryProtocol,
        goalRepository: GoalRepositoryProtocol
    ) {
        self.exerciseId = exerciseId
        self.workoutRepository = workoutRepository
        self.goalRepository = goalRepository
    }

    func loadWorkouts() {
        workouts = workoutRepository.getWorkoutsForExercise(exerciseId: exerciseId)
        onDataChanged?()
    }

    var titleText: String {
        workouts.first?.exerciseName ?? "Статистика"
    }

    var totalRepetitionsText: String {
        let total = workouts.reduce(0) { $0 + $1.totalRepetitions }
        return "Общее кол-во повторений: \(total)"
    }

    var bestResultText: String {
        let best = workouts.map { $0.bestResult }.max() ?? 0
        return "Лучший результат за подход: \(best)"
    }

    func saveGoal(type: GoalType, value: Int) {
        let goal = WorkoutGoal(exerciseId: exerciseId, type: type, value: value)
        goalRepository.saveGoal(goal)
        loadWorkouts()
    }
}

