//
//  StatisticsViewModel.swift
//  FitnessApp
//
//  Created by Ilnur on 20.11.2025.
//

import Foundation

final class StatisticsViewModel {
    private let coordinator: IAppCoordinator
    private let workoutManager: WorkoutManager
    private let goalManager: GoalManager

    private(set) var exercises: [ExerciseStatsItem] = []

    init(
        coordinator: IAppCoordinator,
        workoutManager: WorkoutManager = .shared,
        goalManager: GoalManager = .shared
    ) {
        self.coordinator = coordinator
        self.workoutManager = workoutManager
        self.goalManager = goalManager
    }

    func loadWorkouts(
        onEmptyState: @escaping (Bool) -> Void,
        onCompletion: @escaping () -> Void
    ) {
        let allWorkouts = workoutManager.getAllWorkouts()
        let exerciseIds = Set(allWorkouts.map { $0.exerciseId })
        print("StatisticsViewModel: loaded \(allWorkouts.count) workouts - exercise IDs: \(exerciseIds)")

        exercises = exerciseIds.compactMap { exerciseId in
            guard let workout = allWorkouts.first(where: { $0.exerciseId == exerciseId }) else { return nil }
            return ExerciseStatsItem(exerciseId: exerciseId, exerciseName: workout.exerciseName)
        }.sorted { $0.exerciseName < $1.exerciseName }
        let names = exercises.map { $0.exerciseName }
        print("StatisticsViewModel: built exercise list names = \(names)")

        onEmptyState(exercises.isEmpty)
        onCompletion()
    }

    func countOfExercises() -> Int {
        exercises.count
    }

    func getModel() -> [ExerciseStatsItem] {
        exercises
    }

    func deleteExercise(at index: Int) {
        guard index >= 0, index < exercises.count else { return }
        let exercise = exercises[index]
        workoutManager.deleteWorkoutsForExercise(exerciseId: exercise.exerciseId)
        goalManager.deleteGoalsForExercise(exerciseId: exercise.exerciseId)
        exercises.remove(at: index)
    }

    func exerciseSelected(exerciseId: String) {
        coordinator.showExerciseStatistics(exerciseId: exerciseId)
    }
}
