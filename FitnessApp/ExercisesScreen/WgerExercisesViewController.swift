import UIKit

class WgerExercisesViewController: UIViewController {
    
    private var categories: [WgerCategory] = []
    private var exercises: [WgerExercise] = []
    private var selectedCategoryId: Int?
    private var isLoading = false
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(WgerExerciseTableViewCell.self, forCellReuseIdentifier: "ExerciseCell")
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBar()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Инструкции"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        setupConstraints()
    }
    
    private func updateNavigationBar() {
        if selectedCategoryId != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Назад",
                style: .plain,
                target: self,
                action: #selector(backToCategories)
            )
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc private func backToCategories() {
        selectedCategoryId = nil
        exercises = []
        tableView.reloadData()
        updateNavigationBar()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadCategories() {
        activityIndicator.startAnimating()
        isLoading = true
        
        WgerService.shared.fetchExerciseCategories { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.isLoading = false
                
                switch result {
                case .success(let categories):
                    self?.categories = categories
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showError(message: "Не удалось загрузить категории: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadExercises(categoryId: Int? = nil) {
        activityIndicator.startAnimating()
        isLoading = true
        selectedCategoryId = categoryId
        
        WgerService.shared.fetchExercises(categoryId: categoryId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.isLoading = false
                
                switch result {
                case .success(let exercises):
                    self?.exercises = exercises
                    self?.tableView.reloadData()
                    self?.updateNavigationBar()
                    
                    if exercises.first(where: { $0.name == nil }) != nil {
                        self?.loadExerciseNames()
                    }
                case .failure(let error):
                    self?.showError(message: "Не удалось загрузить упражнения: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadExerciseNames() {
        let group = DispatchGroup()
        var updatedExercises = exercises
        
        for (index, exercise) in exercises.enumerated() where exercise.name == nil {
            group.enter()
            WgerService.shared.fetchExerciseDetails(exerciseId: exercise.id) { result in
                if case .success(let detailedExercise) = result, let name = detailedExercise.name {
                    updatedExercises[index] = detailedExercise
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.exercises = updatedExercises
            self.tableView.reloadData()
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            if self?.selectedCategoryId == nil {
                self?.loadCategories()
            } else {
                self?.loadExercises(categoryId: self?.selectedCategoryId)
            }
        })
        present(alert, animated: true)
    }
}

extension WgerExercisesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedCategoryId == nil {
            return categories.count
        }
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath) as! WgerExerciseTableViewCell
        
        if selectedCategoryId == nil {
            guard indexPath.row < categories.count else {
                cell.configure(with: "Загрузка...")
                return cell
            }
            let category = categories[indexPath.row]
            cell.configure(with: category.name)
        } else {
            guard indexPath.row < exercises.count else {
                cell.configure(with: "Загрузка...")
                return cell
            }
            let exercise = exercises[indexPath.row]
            let exerciseName = exercise.name ?? "Упражнение #\(exercise.id)"
            var description = exercise.description
            if let desc = description, !desc.isEmpty {
                description = desc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            }
            cell.configure(with: exerciseName, description: description)
        }
        
        return cell
    }
}

extension WgerExercisesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedCategoryId == nil {
            guard indexPath.row < categories.count else { return }
            let category = categories[indexPath.row]
            loadExercises(categoryId: category.id)
        } else {
            guard indexPath.row < exercises.count else { return }
            let exercise = exercises[indexPath.row]
            let detailVC = WgerExerciseDetailViewController(exerciseId: exercise.id)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

