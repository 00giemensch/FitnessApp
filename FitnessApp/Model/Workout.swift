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
    
    func update(from workout: Workout) {
        self.id = workout.id
        self.exerciseId = workout.exerciseId
        self.exerciseName = workout.exerciseName
        self.date = workout.date
        
        if let oldSets = self.sets as? Set<WorkoutSetEntity> {
            oldSets.forEach { CoreDataManager.shared.context.delete($0) }
        }
        
        let newSets = workout.sets.map { workoutSet -> WorkoutSetEntity in
            let setEntity = WorkoutSetEntity(context: CoreDataManager.shared.context)
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

class WorkoutManager {
    static let shared = WorkoutManager()
    
    private init() {}
    
    func saveWorkout(_ workout: Workout) {
        let context = CoreDataManager.shared.context
        
        let fetchRequest: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", workout.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            let workoutEntity: WorkoutEntity
            
            if let existing = results.first {
                workoutEntity = existing
            } else {
                workoutEntity = WorkoutEntity(context: context)
            }
            
            workoutEntity.update(from: workout)
            CoreDataManager.shared.saveContext()
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    func getAllWorkouts() -> [Workout] {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.compactMap { $0.toWorkout() }
        } catch {
            print("Error fetching workouts: \(error)")
            return []
        }
    }
    
    func getWorkoutsForExercise(exerciseId: String) -> [Workout] {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseId == %@", exerciseId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.compactMap { $0.toWorkout() }
        } catch {
            print("Error fetching workouts for exercise: \(error)")
            return []
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

class GoalManager {
    static let shared = GoalManager()
    
    private init() {}
    
    func saveGoal(_ goal: WorkoutGoal) {
        let context = CoreDataManager.shared.context
        
        let fetchRequest: NSFetchRequest<WorkoutGoalEntity> = WorkoutGoalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseId == %@ AND type == %@", goal.exerciseId, goal.type.rawValue)
        
        do {
            let results = try context.fetch(fetchRequest)
            let goalEntity: WorkoutGoalEntity
            
            if let existing = results.first {
                goalEntity = existing
            } else {
                goalEntity = WorkoutGoalEntity(context: context)
            }
            
            goalEntity.update(from: goal)
            CoreDataManager.shared.saveContext()
        } catch {
            print("Error saving goal: \(error)")
        }
    }
    
    func getGoal(exerciseId: String, type: GoalType) -> WorkoutGoal? {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<WorkoutGoalEntity> = WorkoutGoalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseId == %@ AND type == %@", exerciseId, type.rawValue)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first?.toWorkoutGoal()
        } catch {
            print("Error fetching goal: \(error)")
            return nil
        }
    }
    
    func getAllGoals(exerciseId: String) -> [WorkoutGoal] {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<WorkoutGoalEntity> = WorkoutGoalEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "exerciseId == %@", exerciseId)
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.compactMap { $0.toWorkoutGoal() }
        } catch {
            print("Error fetching goals: \(error)")
            return []
        }
    }
}
