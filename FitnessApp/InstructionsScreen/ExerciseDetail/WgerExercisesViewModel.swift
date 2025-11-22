import Foundation

final class WgerExercisesViewModel {
    var onCategoriesChanged: (() -> Void)?
    var onExercisesChanged: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    private(set) var categories: [WgerCategory] = []
    private(set) var exercises: [WgerExercise] = []
    private(set) var selectedCategoryId: Int?
    private let service: WgerServiceProtocol

    private var isLoading = false {
        didSet {
            guard oldValue != isLoading else { return }
            onLoadingChanged?(isLoading)
        }
    }

    init(service: WgerServiceProtocol) {
        self.service = service
    }

    func loadCategories() {
        guard !isLoading else { return }
        isLoading = true
        service.fetchExerciseCategories { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let categories):
                self.categories = categories
                self.onCategoriesChanged?()
            case .failure(let error):
                self.onError?("Не удалось загрузить категории: \(error.localizedDescription)")
            }
        }
    }

    func selectCategory(_ category: WgerCategory) {
        guard !isLoading else { return }
        selectedCategoryId = category.id
        loadExercises(categoryId: category.id)
    }

    func resetSelection() {
        selectedCategoryId = nil
        exercises.removeAll()
        onExercisesChanged?()
    }

    func refreshCurrentState() {
        if let categoryId = selectedCategoryId,
           let category = categories.first(where: { $0.id == categoryId }) {
            selectCategory(category)
        } else {
            loadCategories()
        }
    }

    private func loadExercises(categoryId: Int) {
        isLoading = true
        service.fetchExercises(categoryId: categoryId) { [weak self] (result: Result<[WgerExercise], Error>) in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let exercises):
                self.exercises = exercises
                self.onExercisesChanged?()
                if exercises.contains(where: { $0.name == nil }) {
                    self.loadExerciseNames()
                }
            case .failure(let error):
                self.onError?("Не удалось загрузить упражнения: \(error.localizedDescription)")
            }
        }
    }

    private func loadExerciseNames() {
        let group = DispatchGroup()
        var updatedExercises = exercises

        for (index, exercise) in exercises.enumerated() where exercise.name == nil {
            group.enter()
            service.fetchExerciseDetails(exerciseId: exercise.id) { (result: Result<WgerExercise, Error>) in
                if case .success(let detailedExercise) = result {
                    updatedExercises[index] = detailedExercise
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.exercises = updatedExercises
            self.onExercisesChanged?()
        }
    }

    var shouldShowExercises: Bool {
        selectedCategoryId != nil
    }
}

