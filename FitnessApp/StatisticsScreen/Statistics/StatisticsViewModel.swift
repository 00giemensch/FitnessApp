//
//  StatisticsViewModel.swift
//  FitnessApp
//
//  Created by Ilnur on 20.11.2025.
//

import Foundation

class StatisticsViewModel {
    
    var onEmpty: ((Bool) -> Void)?
    var onReloadData: (() -> ())?
    
    private var exercises: [ExerciseStatsItem] = []
    
    func countOfExercises() -> Int {
        exercises.count
    }
    
    func getModel() -> [ExerciseStatsItem] {
        return exercises
    }
    
    func removeItem(index: Int) {
        exercises.remove(at: index)
        if exercises.isEmpty {
            onEmpty?(true)
        }
    }
    
    func loadWorkouts() {
        let allWorkouts = WorkoutManager.shared.getAllWorkouts()
        let exerciseIds = Set(allWorkouts.map { $0.exerciseId })
        
        exercises = exerciseIds.compactMap { exerciseId in
            guard let workout = allWorkouts.first(where: { $0.exerciseId == exerciseId }) else { return nil }
            return ExerciseStatsItem(exerciseId: exerciseId, exerciseName: workout.exerciseName)
        }.sorted { $0.exerciseName < $1.exerciseName }
        
        if exercises.isEmpty {
            //emptyStateLabel.isHidden = false
            //tableView.isHidden = true
            onEmpty?(false)
        } else {
            //emptyStateLabel.isHidden = true
            //tableView.isHidden = false
            onEmpty?(true)
        }
        
        //tableView.reloadData()
        onReloadData?()
    }
    
    func deleteWorkoutsForExercise(exerciseId: String) {
        WorkoutManager.shared.deleteWorkoutsForExercise(exerciseId: exerciseId)
    }
    
    func deleteGoals(exerciseId: String) {
        GoalManager.shared.deleteGoalsForExercise(exerciseId: exerciseId)
    }
    
}
