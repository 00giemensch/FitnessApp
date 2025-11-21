//
//  WgerExerciseDetailViewModel.swift
//  FitnessApp
//
//  Created by Ilnur on 21.11.2025.
//

import Foundation

final class WgerExerciseDetailViewModel {
    
    // MARK: - Outputs
    var onDataLoaded: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Dependencies
    private let exerciseId: Int
    private let service: WgerServiceProtocol
    
    // MARK: - State
    private(set) var exercise: WgerExercise?
    
    init(exerciseId: Int, service: WgerServiceProtocol = WgerService.shared) {
        self.exerciseId = exerciseId
        self.service = service
    }
    
    // MARK: - Inputs
    func loadExerciseDetails() {
        onLoadingStateChanged?(true)
        service.fetchExerciseDetail(exerciseId: exerciseId) { [weak self] result in
            guard let self = self else { return }
            self.onLoadingStateChanged?(false)
            
            switch result {
            case .success(let exercise):
                self.exercise = exercise
                self.onDataLoaded?()
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    // MARK: - Computed properties for UI
    var title: String {
        exercise?.name ?? "Упражнение"
    }
    
    var descriptionHTML: String {
        exercise?.description ?? ""
    }
    
    var muscles: String {
        (exercise?.muscles ?? []).map { String($0) }.joined(separator: ", ")
    }
    
    var equipment: String {
        (exercise?.equipment ?? []).map { String($0) }.joined(separator: ", ")
    }
    
    private var exerciseIdString: String {
        "\(exerciseId)"
    }
}

