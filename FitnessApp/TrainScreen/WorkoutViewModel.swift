//
//  WorkoutViewModel.swift
//  FitnessApp
//
//  Created by Ilnur on 22.11.2025.
//

import Foundation

struct WorkoutSetData {
    var repetitions: Int?
}

final class WorkoutViewModel {
    let exerciseId: String
    let exerciseName: String
    
    private let workoutRepository: WorkoutRepositoryProtocol
    private(set) var sets: [WorkoutSetData] = []
    
    init(
        exerciseId: String,
        exerciseName: String,
        workoutRepository: WorkoutRepositoryProtocol
    ) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.workoutRepository = workoutRepository
    }
    
    func addSet() -> Bool {
        if let lastSet = sets.last, lastSet.repetitions == nil {
            return false
        }
        sets.append(WorkoutSetData(repetitions: nil))
        return true
    }
    
    func updateSetRepetitions(at index: Int, repetitions: Int) {
        guard index >= 0, index < sets.count else { return }
        sets[index].repetitions = repetitions
    }
    
    func getValidSets() -> [WorkoutSet] {
        return sets.compactMap { set -> WorkoutSet? in
            guard let reps = set.repetitions, reps > 0 else { return nil }
            return WorkoutSet(repetitions: reps, date: Date())
        }
    }
    
    func saveWorkout() {
        let validSets = getValidSets()
        guard !validSets.isEmpty else { return }
        
        let allWorkouts = workoutRepository.getAllWorkouts()
        
        if let existingWorkout = allWorkouts.first(where: { workout in
            workout.exerciseId == exerciseId &&
            Calendar.current.isDate(workout.date, inSameDayAs: Date())
        }) {
            var allSets = existingWorkout.sets
            allSets.append(contentsOf: validSets)
            
            let updatedWorkout = Workout(
                id: existingWorkout.id,
                exerciseId: existingWorkout.exerciseId,
                exerciseName: existingWorkout.exerciseName,
                sets: allSets,
                date: existingWorkout.date
            )
            
            workoutRepository.saveWorkout(updatedWorkout)
        } else {
            let workout = Workout(
                id: UUID().uuidString,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                sets: validSets,
                date: Date()
            )
            
            workoutRepository.saveWorkout(workout)
        }
    }
}

