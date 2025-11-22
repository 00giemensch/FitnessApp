//
//  WorkoutManager.swift
//  FitnessApp
//
//  Created by Ilnur on 22.11.2025.
//

import Foundation
import CoreData 

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
