import UIKit

class WgerExercisesViewController: UIViewController {
    
    private var categories: [WgerCategory] = []
    private var exercises: [WgerExercise] = []
    private var selectedCategoryId: Int?
    private var isLoading = false
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Выберите категорию"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(WgerExerciseTableViewCell.self, forCellReuseIdentifier: "ExerciseCell")
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
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
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBar()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Инструкции"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        tableView.isHidden = true
        
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        setupConstraints()
        setupCollectionView()
        setupTableView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WgerCategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCell")
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func updateNavigationBar() {
        if selectedCategoryId != nil {
            title = "Упражнения"
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Назад",
                style: .plain,
                target: self,
                action: #selector(backToCategories)
            )
        } else {
            title = "Инструкции"
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc private func backToCategories() {
        selectedCategoryId = nil
        exercises = []
        tableView.isHidden = true
        collectionView.isHidden = false
        titleLabel.isHidden = false
        updateNavigationBar()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
                    self?.collectionView.reloadData()
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
                    self?.collectionView.isHidden = true
                    self?.titleLabel.isHidden = true
                    self?.tableView.isHidden = false
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
                if case .success(let detailedExercise) = result {
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
            if let categoryId = self?.selectedCategoryId {
                self?.loadExercises(categoryId: categoryId)
            } else {
                self?.loadCategories()
            }
        })
        present(alert, animated: true)
    }
}

extension WgerExercisesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! WgerCategoryCollectionViewCell
        
        guard indexPath.item < categories.count else {
            cell.configure(with: "Загрузка...")
            return cell
        }
        
        let category = categories[indexPath.item]
        cell.configure(with: category.name)
        return cell
    }
}

extension WgerExercisesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let spacing: CGFloat = 2
        let availableWidth = collectionView.bounds.width - padding * 2 - spacing
        let cellWidth = availableWidth / 2
        let cellHeight: CGFloat = 80
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < categories.count else { return }
        let category = categories[indexPath.item]
        loadExercises(categoryId: category.id)
    }
}

extension WgerExercisesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath) as! WgerExerciseTableViewCell
        
        guard indexPath.row < exercises.count else {
            cell.configure(with: "Загрузка...")
            return cell
        }
        
        let exercise = exercises[indexPath.row]
        let exerciseName = exercise.name ?? "Упражнение #\(exercise.id)"
        var description = exercise.description
        if let desc = description, !desc.isEmpty {
            description = desc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "&nbsp;", with: " ")
        }
        cell.configure(with: exerciseName, description: description, exercise: exercise)
        
        return cell
    }
}

extension WgerExercisesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row < exercises.count else { return }
        let exercise = exercises[indexPath.row]
        let detailVC = WgerExerciseDetailViewController(exerciseId: exercise.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

