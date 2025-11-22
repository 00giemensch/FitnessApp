//
//  WgerService.swift
//  FitnessApp
//
//  Created by Ilnur on 15.11.2025.
//

import Foundation

protocol WgerServiceProtocol {
    func fetchExerciseCategories(completion: @escaping (Result<[WgerCategory], Error>) -> Void)
    func fetchExercises(categoryId: Int?, completion: @escaping (Result<[WgerExercise], Error>) -> Void)
    func fetchExerciseDetails(exerciseId: Int, completion: @escaping (Result<WgerExercise, Error>) -> Void)
    func fetchExerciseDetail(exerciseId: Int, completion: @escaping (Result<WgerExercise, Error>) -> Void)
    func fetchExerciseImage(imageURL: String, completion: @escaping (Result<Data, Error>) -> Void)
}

final class WgerService: WgerServiceProtocol {
    private let apiKey = "fe771ab579d9df9302b681e4e78544044d251929"
    private let baseURL = "https://wger.de/api/v2"
    private let cache: WgerCacheProtocol

    init(cache: WgerCacheProtocol = WgerCache()) {
        self.cache = cache
    }

    // MARK: - Helpers
    private func performRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Token \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    completion(.failure(NSError(domain: "HTTP Error", code: statusCode)))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: -1)))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Public API
    func fetchExerciseCategories(completion: @escaping (Result<[WgerCategory], Error>) -> Void) {
        if let cached = cache.getCategories() {
            completion(.success(cached))
            return
        }

        var urlComponents = URLComponents(string: "\(baseURL)/exercisecategory/")
        urlComponents?.queryItems = [URLQueryItem(name: "language", value: "2")]

        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        performRequest(url: url) { (result: Result<WgerCategoryResponse, Error>) in
            switch result {
            case .success(let response):
                self.cache.saveCategories(response.results)
                completion(.success(response.results))
            case .failure(let error):
                if let cached = self.cache.getCategories() {
                    completion(.success(cached))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    func fetchExercises(categoryId: Int? = nil, completion: @escaping (Result<[WgerExercise], Error>) -> Void) {
        if let categoryId = categoryId, let cached = cache.getExercises(categoryId: categoryId) {
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
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        performRequest(url: url) { (result: Result<WgerExerciseResponse, Error>) in
            switch result {
            case .success(let response):
                if let categoryId = categoryId {
                    self.cache.saveExercises(response.results, categoryId: categoryId)
                }
                completion(.success(response.results))
            case .failure(let error):
                if let categoryId = categoryId, let cached = self.cache.getExercises(categoryId: categoryId) {
                    completion(.success(cached))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    func fetchExerciseDetails(exerciseId: Int, completion: @escaping (Result<WgerExercise, Error>) -> Void) {
        fetchExerciseInfo(exerciseId: exerciseId) { result in
            switch result {
            case .success(let info):
                let exercise = WgerExercise(from: info)
                self.cache.saveExerciseDetails(exercise, exerciseId: exerciseId)
                completion(.success(exercise))
            case .failure(let error):
                if let cached = self.cache.getExerciseDetails(exerciseId: exerciseId) {
                    completion(.success(cached))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    func fetchExerciseInfo(exerciseId: Int, completion: @escaping (Result<WgerExerciseInfo, Error>) -> Void) {
        var urlComponents = URLComponents(string: "\(baseURL)/exerciseinfo/")
        urlComponents?.queryItems = [URLQueryItem(name: "id", value: "\(exerciseId)")]

        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        performRequest(url: url) { (result: Result<WgerExerciseInfoResponse, Error>) in
            switch result {
            case .success(let response):
                if let exerciseInfo = response.results.first {
                    completion(.success(exerciseInfo))
                } else {
                    completion(.failure(NSError(domain: "Exercise not found", code: 404)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchExerciseImage(imageURL: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: imageURL) else {
            completion(.failure(NSError(domain: "Invalid image URL", code: -1)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    completion(.failure(NSError(domain: "HTTP Error", code: statusCode)))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No image data", code: -1)))
                    return
                }

                completion(.success(data))
            }
        }.resume()
    }

    func fetchExerciseDetail(exerciseId: Int, completion: @escaping (Result<WgerExercise, Error>) -> Void) {
        fetchExerciseDetails(exerciseId: exerciseId, completion: completion)
    }
}

