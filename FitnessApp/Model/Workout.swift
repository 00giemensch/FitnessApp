//
//  Workout.swift
//  FitnessApp
//
//  Created by Ilnur on 13.11.2025.
//

import Foundation
import CoreData

struct WorkoutSet: Codable {
    let repetitions: Int
    let date: Date
    
    init(repetitions: Int, date: Date = Date()) {
        self.repetitions = repetitions
        self.date = date
    }
}

struct Workout: Codable {
    let id: String
    let exerciseId: String
    let exerciseName: String
    var sets: [WorkoutSet]
    let date: Date
    
    init(id: String = UUID().uuidString, exerciseId: String, exerciseName: String, sets: [WorkoutSet] = [], date: Date = Date()) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.sets = sets
        self.date = date
    }
    
    var totalRepetitions: Int {
        return sets.reduce(0) { $0 + $1.repetitions }
    }
    
    var setsCount: Int {
        return sets.count
    }
    
    var bestResult: Int {
        return sets.map { $0.repetitions }.max() ?? 0
    }
}

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
    
    // Теперь принимает CoreDataManager вместо прямого доступа к context
    func update(from workout: Workout, coreDataManager: CoreDataManagerProtocol) {
        self.id = workout.id
        self.exerciseId = workout.exerciseId
        self.exerciseName = workout.exerciseName
        self.date = workout.date
        
        // Удаляем старые подходы через менеджер
        if let oldSets = self.sets as? Set<WorkoutSetEntity> {
            oldSets.forEach { coreDataManager.delete($0) }
        }
        
        // Создаём новые через менеджер
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

protocol WorkoutManagerProtocol {
    func saveWorkout(_ workout: Workout)
    func getAllWorkouts() -> [Workout]
    func getWorkoutsForExercise(exerciseId: String) -> [Workout]
    func deleteWorkoutsForExercise(exerciseId: String)
}

final class WorkoutManager: WorkoutManagerProtocol {
    private let coreDataManager: CoreDataManagerProtocol
    
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
    }
    
    func saveWorkout(_ workout: Workout) {
        let fetchRequest: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", workout.id)
        
        do {
            let results = try coreDataManager.fetch(fetchRequest)
            let workoutEntity: WorkoutEntity
            
            if let existing = results.first {
                workoutEntity = existing
            } else {
                workoutEntity = coreDataManager.create(WorkoutEntity.self)
            }
            
            workoutEntity.update(from: workout, coreDataManager: coreDataManager)
            coreDataManager.save()
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    func getAllWorkouts() -> [Workout] {
        let fetchRequest: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let entities = try coreDataManager.fetch(fetchRequest)
            return entities.compactMap { $0.toWorkout() }
        } catch {
            print("Error fetching workouts: \(error)")
            return []
        }
    }
    
    func getWorkoutsForExercise(exerciseId: String) -> [Workout] {
        let fetchRequest: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseId == %@", exerciseId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let entities = try coreDataManager.fetch(fetchRequest)
            return entities.compactMap { $0.toWorkout() }
        } catch {
            print("Error fetching workouts for exercise: \(error)")
            return []
        }
    }
    
    func deleteWorkoutsForExercise(exerciseId: String) {
        let fetchRequest: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseId == %@", exerciseId)
        
        do {
            let entities = try coreDataManager.fetch(fetchRequest)
            for entity in entities {
                coreDataManager.delete(entity)
            }
            coreDataManager.save()
        } catch {
            print("Error deleting workouts for exercise: \(error)")
        }
    }
}

enum GoalType: String, Codable {
    case totalRepetitions = "total_repetitions"
    case bestResult = "best_result"
}

struct WorkoutGoal: Codable {
    let exerciseId: String
    let type: GoalType
    let value: Int
}

// Workout.swift
protocol GoalManagerProtocol {
    func saveGoal(_ goal: WorkoutGoal)
    func getGoal(exerciseId: String, type: GoalType) -> WorkoutGoal?
    func getAllGoals(exerciseId: String) -> [WorkoutGoal]
    func deleteGoalsForExercise(exerciseId: String)
}

final class GoalManager: GoalManagerProtocol {
    private let coreDataManager: CoreDataManagerProtocol
    
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
    }
    
    func saveGoal(_ goal: WorkoutGoal) {
        let fetchRequest: NSFetchRequest<WorkoutGoalEntity> = WorkoutGoalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseId == %@ AND type == %@", goal.exerciseId, goal.type.rawValue)
        
        do {
            let results = try coreDataManager.fetch(fetchRequest)
            let goalEntity: WorkoutGoalEntity
            
            if let existing = results.first {
                goalEntity = existing
            } else {
                goalEntity = coreDataManager.create(WorkoutGoalEntity.self)
            }
            
            goalEntity.update(from: goal)
            coreDataManager.save()
        } catch {
            print("Error saving goal: \(error)")
        }
    }
    
    func getGoal(exerciseId: String, type: GoalType) -> WorkoutGoal? {
        let fetchRequest: NSFetchRequest<WorkoutGoalEntity> = WorkoutGoalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseId == %@ AND type == %@", exerciseId, type.rawValue)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try coreDataManager.fetch(fetchRequest)
            return results.first?.toWorkoutGoal()
        } catch {
            print("Error fetching goal: \(error)")
            return nil
        }
    }
    
    func getAllGoals(exerciseId: String) -> [WorkoutGoal] {
        let fetchRequest: NSFetchRequest<WorkoutGoalEntity> = WorkoutGoalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseId == %@", exerciseId)
        
        do {
            let entities = try coreDataManager.fetch(fetchRequest)
            return entities.compactMap { $0.toWorkoutGoal() }
        } catch {
            print("Error fetching goals: \(error)")
            return []
        }
    }
    
    func deleteGoalsForExercise(exerciseId: String) {
        let fetchRequest: NSFetchRequest<WorkoutGoalEntity> = WorkoutGoalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseId == %@", exerciseId)
        
        do {
            let entities = try coreDataManager.fetch(fetchRequest)
            for entity in entities {
                coreDataManager.delete(entity)
            }
            coreDataManager.save()
        } catch {
            print("Error deleting goals for exercise: \(error)")
        }
    }
}
