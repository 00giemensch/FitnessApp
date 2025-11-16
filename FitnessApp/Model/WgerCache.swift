import Foundation

class WgerCache {
    static let shared = WgerCache()
    
    private let categoriesKey = "wger_cached_categories"
    private let exercisesKeyPrefix = "wger_cached_exercises_"
    private let exerciseDetailsKeyPrefix = "wger_cached_exercise_details_"
    private let cacheTimestampKey = "wger_cache_timestamp"
    private let cacheExpirationHours: TimeInterval = 24 * 7
    
    private init() {}
    
    func saveCategories(_ categories: [WgerCategory]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: categoriesKey)
            UserDefaults.standard.set(Date(), forKey: cacheTimestampKey)
        }
    }
    
    func getCategories() -> [WgerCategory]? {
        guard let data = UserDefaults.standard.data(forKey: categoriesKey),
              let categories = try? JSONDecoder().decode([WgerCategory].self, from: data),
              isCacheValid() else {
            return nil
        }
        return categories
    }
    
    func saveExercises(_ exercises: [WgerExercise], categoryId: Int) {
        let key = "\(exercisesKeyPrefix)\(categoryId)"
        if let encoded = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func getExercises(categoryId: Int) -> [WgerExercise]? {
        let key = "\(exercisesKeyPrefix)\(categoryId)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let exercises = try? JSONDecoder().decode([WgerExercise].self, from: data),
              isCacheValid() else {
            return nil
        }
        return exercises
    }
    
    func saveExerciseDetails(_ exercise: WgerExercise, exerciseId: Int) {
        let key = "\(exerciseDetailsKeyPrefix)\(exerciseId)"
        if let encoded = try? JSONEncoder().encode(exercise) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func getExerciseDetails(exerciseId: Int) -> WgerExercise? {
        let key = "\(exerciseDetailsKeyPrefix)\(exerciseId)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let exercise = try? JSONDecoder().decode(WgerExercise.self, from: data),
              isCacheValid() else {
            return nil
        }
        return exercise
    }
    
    private func isCacheValid() -> Bool {
        guard let timestamp = UserDefaults.standard.object(forKey: cacheTimestampKey) as? Date else {
            return false
        }
        return Date().timeIntervalSince(timestamp) < cacheExpirationHours * 3600
    }
    
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: categoriesKey)
        UserDefaults.standard.removeObject(forKey: cacheTimestampKey)
        
        let keys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in keys {
            if key.hasPrefix(exercisesKeyPrefix) || key.hasPrefix(exerciseDetailsKeyPrefix) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}

