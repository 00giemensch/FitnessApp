//
//  WorkoutEntity+Mapping.swift
//  FitnessApp
//
//  Created by Ilnur on 22.11.2025.
//

import Foundation

extension WorkoutEntity {
    func toWorkout() -> Workout? {
        guard let id = id,
              let exerciseId = exerciseId,
              let exerciseName = exerciseName,
              let date = date,
              let setsData = sets as? Set<WorkoutSetEntity> else {
            return nil
        }
        
        let workoutSets = setsData.compactMap { setEntity -> WorkoutSet? in
            guard let date = setEntity.date else { return nil }
            return WorkoutSet(repetitions: Int(setEntity.repetitions), date: date)
        }
        
        return Workout(
            id: id,
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            sets: workoutSets,
            date: date
        )
    }
    
    func update(from workout: Workout, coreDataManager: CoreDataManagerProtocol) {
        self.id = workout.id
        self.exerciseId = workout.exerciseId
        self.exerciseName = workout.exerciseName
        self.date = workout.date
        
        if let oldSets = self.sets as? Set<WorkoutSetEntity> {
            oldSets.forEach { coreDataManager.delete($0) }
        }
        
        let newSets = workout.sets.map { workoutSet -> WorkoutSetEntity in
            let setEntity = coreDataManager.create(WorkoutSetEntity.self)
            setEntity.repetitions = Int32(workoutSet.repetitions)
            setEntity.date = workoutSet.date
            return setEntity
        }
        
        self.sets = NSSet(array: newSets)
    }
}

extension WorkoutGoalEntity {
    func toWorkoutGoal() -> WorkoutGoal? {
        guard let exerciseId = exerciseId,
              let typeString = type,
              let type = GoalType(rawValue: typeString) else {
            return nil
        }
        return WorkoutGoal(exerciseId: exerciseId, type: type, value: Int(value))
    }
    
    func update(from goal: WorkoutGoal) {
        self.exerciseId = goal.exerciseId
        self.type = goal.type.rawValue
        self.value = Int32(goal.value)
    }
}
