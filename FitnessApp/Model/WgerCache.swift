//
//  WgerCache.swift
//  FitnessApp
//
//  Created by Ilnur on 15.11.2025.
//

import Foundation

protocol WgerCacheProtocol {
    func saveCategories(_ categories: [WgerCategory])
    func getCategories() -> [WgerCategory]?
    func saveExercises(_ exercises: [WgerExercise], categoryId: Int)
    func getExercises(categoryId: Int) -> [WgerExercise]?
    func saveExerciseDetails(_ exercise: WgerExercise, exerciseId: Int)
    func getExerciseDetails(exerciseId: Int) -> WgerExercise?
    func clearCache()
}

final class WgerCache: WgerCacheProtocol {
    private let userDefaults: UserDefaults
    private let categoriesKey = "wger_cached_categories"
    private let exercisesKeyPrefix = "wger_cached_exercises_"
    private let exerciseDetailsKeyPrefix = "wger_cached_exercise_details_"
    private let cacheTimestampKey = "wger_cache_timestamp"
    private let cacheExpirationHours: TimeInterval = 24 * 7
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveCategories(_ categories: [WgerCategory]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            userDefaults.set(encoded, forKey: categoriesKey)
            userDefaults.set(Date(), forKey: cacheTimestampKey)
        }
    }
    
    func getCategories() -> [WgerCategory]? {
        guard let data = userDefaults.data(forKey: categoriesKey),
              let categories = try? JSONDecoder().decode([WgerCategory].self, from: data),
              isCacheValid() else {
            return nil
        }
        return categories
    }
    
    func saveExercises(_ exercises: [WgerExercise], categoryId: Int) {
        let key = "\(exercisesKeyPrefix)\(categoryId)"
        if let encoded = try? JSONEncoder().encode(exercises) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    func getExercises(categoryId: Int) -> [WgerExercise]? {
        let key = "\(exercisesKeyPrefix)\(categoryId)"
        guard let data = userDefaults.data(forKey: key),
              let exercises = try? JSONDecoder().decode([WgerExercise].self, from: data),
              isCacheValid() else {
            return nil
        }
        return exercises
    }
    
    func saveExerciseDetails(_ exercise: WgerExercise, exerciseId: Int) {
        let key = "\(exerciseDetailsKeyPrefix)\(exerciseId)"
        if let encoded = try? JSONEncoder().encode(exercise) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    func getExerciseDetails(exerciseId: Int) -> WgerExercise? {
        let key = "\(exerciseDetailsKeyPrefix)\(exerciseId)"
        guard let data = userDefaults.data(forKey: key),
              let exercise = try? JSONDecoder().decode(WgerExercise.self, from: data),
              isCacheValid() else {
            return nil
        }
        return exercise
    }
    
    private func isCacheValid() -> Bool {
        guard let timestamp = userDefaults.object(forKey: cacheTimestampKey) as? Date else {
            return false
        }
        return Date().timeIntervalSince(timestamp) < cacheExpirationHours * 3600
    }
    
    func clearCache() {
        userDefaults.removeObject(forKey: categoriesKey)
        userDefaults.removeObject(forKey: cacheTimestampKey)
        
        let keys = userDefaults.dictionaryRepresentation().keys
        for key in keys {
            if key.hasPrefix(exercisesKeyPrefix) || key.hasPrefix(exerciseDetailsKeyPrefix) {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}
