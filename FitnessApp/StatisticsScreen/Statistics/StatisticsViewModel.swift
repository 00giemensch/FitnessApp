//
//  StatisticsViewModel.swift
//  FitnessApp
//
//  Created by Ilnur on 20.11.2025.
//

import Foundation

final class StatisticsViewModel {
    private let coordinator: IAppCoordinator
    private let workoutRepository: WorkoutRepositoryProtocol
    private let goalRepository: GoalRepositoryProtocol

    private(set) var exercises: [ExerciseStatsItem] = []

    init(
        coordinator: IAppCoordinator,
        workoutRepository: WorkoutRepositoryProtocol,
        goalRepository: GoalRepositoryProtocol
    ) {
        self.coordinator = coordinator
        self.workoutRepository = workoutRepository
        self.goalRepository = goalRepository
    }

    func loadWorkouts(
        onEmptyState: @escaping (Bool) -> Void,
        onCompletion: @escaping () -> Void
    ) {
        let allWorkouts = workoutRepository.getAllWorkouts()
        let exerciseIds = Set(allWorkouts.map { $0.exerciseId })
        exercises = exerciseIds.compactMap { exerciseId in
            guard let workout = allWorkouts.first(where: { $0.exerciseId == exerciseId }) else { return nil }
            return ExerciseStatsItem(exerciseId: exerciseId, exerciseName: workout.exerciseName)
        }.sorted { $0.exerciseName < $1.exerciseName }
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
        workoutRepository.deleteWorkoutsForExercise(exerciseId: exercise.exerciseId)
        goalRepository.deleteGoalsForExercise(exerciseId: exercise.exerciseId)
        exercises.remove(at: index)
    }

    func exerciseSelected(exerciseId: String) {
        coordinator.showExerciseStatistics(exerciseId: exerciseId)
    }
}
