import Foundation

class WgerService {
    static let shared = WgerService()
    
    private let apiKey = "fe771ab579d9df9302b681e4e78544044d251929"
    private let baseURL = "https://wger.de/api/v2"
    
    private init() {}
    
    func fetchLanguages(completion: @escaping (Result<[WgerLanguage], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/language/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                let error = NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? -1)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WgerLanguageResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response.results))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func fetchExerciseCategories(completion: @escaping (Result<[WgerCategory], Error>) -> Void) {
        if let cached = WgerCache.shared.getCategories() {
            completion(.success(cached))
            return
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/exercisecategory/")
        urlComponents?.queryItems = [URLQueryItem(name: "language", value: "2")]
        
        guard let url = urlComponents?.url else {
            if let cached = WgerCache.shared.getCategories() {
                completion(.success(cached))
            } else {
                completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Request URL: \(url.absoluteString)")
        print("Authorization: Token \(apiKey.prefix(10))...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                if let cached = WgerCache.shared.getCategories() {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                if let cached = WgerCache.shared.getCategories() {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    let error = NSError(domain: "HTTP Error", code: -1)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return
            }
            
            print("HTTP Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                print("HTTP Error: Status code \(httpResponse.statusCode)")
                if let cached = WgerCache.shared.getCategories() {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    let error = NSError(domain: "HTTP Error", code: httpResponse.statusCode)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                if let cached = WgerCache.shared.getCategories() {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    let error = NSError(domain: "No data", code: -1)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return
            }
            
            print("Received \(data.count) bytes of data")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON preview (first 500 chars): \(String(jsonString.prefix(500)))")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WgerCategoryResponse.self, from: data)
                print("Successfully decoded \(response.results.count) categories")
                WgerCache.shared.saveCategories(response.results)
                DispatchQueue.main.async {
                    completion(.success(response.results))
                }
            } catch let decodingError as DecodingError {
                print("Decoding error details:")
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .valueNotFound(let value, let context):
                    print("Value '\(value)' not found: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for '\(type)': \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                @unknown default:
                    print("Unknown decoding error: \(decodingError)")
                }
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Full JSON response: \(jsonString)")
                }
                if let cached = WgerCache.shared.getCategories() {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(decodingError))
                    }
                }
            } catch {
                print("General error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Full JSON response: \(jsonString)")
                }
                if let cached = WgerCache.shared.getCategories() {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
    
    func fetchExercises(categoryId: Int? = nil, completion: @escaping (Result<[WgerExercise], Error>) -> Void) {
        if let categoryId = categoryId, let cached = WgerCache.shared.getExercises(categoryId: categoryId) {
            completion(.success(cached))
            return
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/exercise/")
        var queryItems = [URLQueryItem(name: "language", value: "2")]
        if let categoryId = categoryId {
            queryItems.append(URLQueryItem(name: "category", value: "\(categoryId)"))
        }
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            if let categoryId = categoryId, let cached = WgerCache.shared.getExercises(categoryId: categoryId) {
                completion(.success(cached))
            } else {
                completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                if let categoryId = categoryId, let cached = WgerCache.shared.getExercises(categoryId: categoryId) {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                if let categoryId = categoryId, let cached = WgerCache.shared.getExercises(categoryId: categoryId) {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    let error = NSError(domain: "HTTP Error", code: -1)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return
            }
            
            if httpResponse.statusCode != 200 {
                if let categoryId = categoryId, let cached = WgerCache.shared.getExercises(categoryId: categoryId) {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    let error = NSError(domain: "HTTP Error", code: httpResponse.statusCode)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return
            }
            
            guard let data = data else {
                if let categoryId = categoryId, let cached = WgerCache.shared.getExercises(categoryId: categoryId) {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    let error = NSError(domain: "No data", code: -1)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return
            }
            
            print("Received \(data.count) bytes of data (exercises)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON preview (first 500 chars): \(String(jsonString.prefix(500)))")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WgerExerciseResponse.self, from: data)
                print("Successfully decoded \(response.results.count) exercises")
                
                let exercisesWithoutNames = response.results
                
                DispatchQueue.main.async {
                    if let categoryId = categoryId {
                        WgerCache.shared.saveExercises(exercisesWithoutNames, categoryId: categoryId)
                    }
                    completion(.success(exercisesWithoutNames))
                }
                
                let group = DispatchGroup()
                var exercisesWithNames: [WgerExercise] = []
                let lock = NSLock()
                
                for exercise in exercisesWithoutNames {
                    group.enter()
                    self.fetchExerciseDetails(exerciseId: exercise.id) { result in
                        switch result {
                        case .success(let detailedExercise):
                            lock.lock()
                            exercisesWithNames.append(detailedExercise)
                            lock.unlock()
                        case .failure:
                            lock.lock()
                            exercisesWithNames.append(exercise)
                            lock.unlock()
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    exercisesWithNames.sort { $0.id < $1.id }
                    if let categoryId = categoryId {
                        WgerCache.shared.saveExercises(exercisesWithNames, categoryId: categoryId)
                    }
                    if !exercisesWithNames.isEmpty {
                        completion(.success(exercisesWithNames))
                    }
                }
            } catch let decodingError as DecodingError {
                print("Decoding error details (exercises):")
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .valueNotFound(let value, let context):
                    print("Value '\(value)' not found: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for '\(type)': \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                @unknown default:
                    print("Unknown decoding error: \(decodingError)")
                }
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Full JSON response: \(jsonString)")
                }
                if let categoryId = categoryId, let cached = WgerCache.shared.getExercises(categoryId: categoryId) {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(decodingError))
                    }
                }
            } catch {
                print("General error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Full JSON response: \(jsonString)")
                }
                if let categoryId = categoryId, let cached = WgerCache.shared.getExercises(categoryId: categoryId) {
                    DispatchQueue.main.async {
                        completion(.success(cached))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
    
    func fetchExerciseDetails(exerciseId: Int, completion: @escaping (Result<WgerExercise, Error>) -> Void) {
        fetchExerciseInfo(exerciseId: exerciseId) { result in
            switch result {
            case .success(let info):
                let exercise = WgerExercise(from: info)
                WgerCache.shared.saveExerciseDetails(exercise, exerciseId: exerciseId)
                completion(.success(exercise))
            case .failure(let error):
                if let cached = WgerCache.shared.getExerciseDetails(exerciseId: exerciseId) {
                    completion(.success(cached))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchExerciseInfo(exerciseId: Int, completion: @escaping (Result<WgerExerciseInfo, Error>) -> Void) {
        var urlComponents = URLComponents(string: "\(baseURL)/exerciseinfo/")
        urlComponents?.queryItems = [
            URLQueryItem(name: "id", value: "\(exerciseId)")
        ]
        
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("Request URL (exerciseinfo): \(url.absoluteString)")
        print("Authorization: Token \(apiKey.prefix(10))...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error (exerciseinfo): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response (exerciseinfo)")
                let error = NSError(domain: "HTTP Error", code: -1)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            print("📡 HTTP Status (exerciseinfo): \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                print("HTTP Error (exerciseinfo): Status code \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
                let error = NSError(domain: "HTTP Error", code: httpResponse.statusCode)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                print("No data received (exerciseinfo)")
                let error = NSError(domain: "No data", code: -1)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            print("Received \(data.count) bytes of data (exerciseinfo)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 JSON preview (first 500 chars): \(String(jsonString.prefix(500)))")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(WgerExerciseInfoResponse.self, from: data)
                if let exerciseInfo = response.results.first {
                    print("Successfully decoded exerciseinfo for exercise \(exerciseId)")
                    DispatchQueue.main.async {
                        completion(.success(exerciseInfo))
                    }
                } else {
                    print("No exercise found with id \(exerciseId)")
                    let error = NSError(domain: "Exercise not found", code: 404)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } catch let decodingError {
                print("Decoding error (exerciseinfo): \(decodingError)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Failed to decode JSON: \(String(jsonString.prefix(1000)))")
                }
                DispatchQueue.main.async {
                    completion(.failure(decodingError))
                }
            }
        }.resume()
    }
    
    func fetchExerciseImage(imageURL: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: imageURL) else {
            completion(.failure(NSError(domain: "Invalid image URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let error = NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? -1)
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No image data", code: -1)))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}
