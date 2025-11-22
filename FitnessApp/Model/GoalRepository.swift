//
//  GoalRepository.swift
//  FitnessApp
//
//  Created by Ilnur on 22.11.2025.
//

import Foundation
import CoreData

protocol GoalRepositoryProtocol {
    func saveGoal(_ goal: WorkoutGoal)
    func getGoal(exerciseId: String, type: GoalType) -> WorkoutGoal?
    func getAllGoals(exerciseId: String) -> [WorkoutGoal]
    func deleteGoalsForExercise(exerciseId: String)
}

final class GoalLocalRepository: GoalRepositoryProtocol {
    private let coreDataManager: CoreDataManagerProtocol
    
    init() {
        self.coreDataManager = CoreDataManager.shared
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

