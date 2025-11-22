//
//  WgerExerciseDetailViewModel.swift
//  FitnessApp
//
//  Created by Ilnur on 21.11.2025.
//

import Foundation

final class WgerExerciseDetailViewModel {
    
    var onDataLoaded: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?
    
    private let exerciseId: Int
    private let service: WgerServiceProtocol
    
    private(set) var exercise: WgerExercise?
    
    init(exerciseId: Int, service: WgerServiceProtocol) {
        self.exerciseId = exerciseId
        self.service = service
    }
    
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

