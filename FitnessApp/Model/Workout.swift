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

enum GoalType: String, Codable {
    case totalRepetitions = "total_repetitions"
    case bestResult = "best_result"
}

struct WorkoutGoal: Codable {
    let exerciseId: String
    let type: GoalType
    let value: Int
}
