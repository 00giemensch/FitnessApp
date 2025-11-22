//
//  WgerExercisesViewController.swift
//  FitnessApp
//
//  Created by Ilnur on 15.11.2025.
//

import UIKit

class WgerExercisesViewController: UIViewController {
    
    private let viewModel: WgerExercisesViewModel

    private var isLoading = false
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Выберите категорию"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .label
        button.isHidden = true
        return button
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
    
    init(viewModel: WgerExercisesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadCategories()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if selectedCategoryId == nil {
//            navigationController?.setNavigationBarHidden(true, animated: animated)
//        } else {
//            navigationController?.setNavigationBarHidden(false, animated: animated)
//        }
//        updateNavigationBar()
//    }
    
    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.collectionView.reloadData()
        }
        viewModel.onExercisesChanged = { [weak self] in
            guard let self = self else { return }
            self.collectionView.isHidden = self.viewModel.shouldShowExercises
            self.titleLabel.isHidden = self.viewModel.shouldShowExercises
            self.tableView.isHidden = !self.viewModel.shouldShowExercises
            self.tableView.reloadData()
            self.updateNavigationBar()
        }
        viewModel.onLoadingChanged = { [weak self] loading in
            if loading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
            self?.isLoading = loading
        }
        viewModel.onError = { [weak self] message in
            self?.showError(message: message)
        }
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Инструкции"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tableView.isHidden = true
        
        view.addSubviews(titleLabel, backButton, collectionView, tableView, activityIndicator)
//        view.addSubview(titleLabel)
//        view.addSubview(backButton)
//        view.addSubview(collectionView)
//        view.addSubview(tableView)
//        view.addSubview(activityIndicator)
        
        backButton.addTarget(self, action: #selector(backToCategories), for: .touchUpInside)
        
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
        navigationController?.setNavigationBarHidden(true, animated: true)
        if viewModel.shouldShowExercises {
            titleLabel.text = "Упражнения"
            backButton.isHidden = false
        } else {
            titleLabel.text = "Выберите категорию"
            backButton.isHidden = true
        }
        titleLabel.isHidden = false
    }

    @objc private func backToCategories() {
        viewModel.resetSelection()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.viewModel.refreshCurrentState()
        })
        present(alert, animated: true)
    }
}

extension WgerExercisesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! WgerCategoryCollectionViewCell
        
        guard indexPath.item < viewModel.categories.count else {
            cell.configure(with: "Загрузка...")
            return cell
        }
        
        let category = viewModel.categories[indexPath.item]
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
        guard indexPath.item < viewModel.categories.count else { return }
        let category = viewModel.categories[indexPath.item]
        viewModel.selectCategory(category)
    }
}

extension WgerExercisesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath) as! WgerExerciseTableViewCell
        
        guard indexPath.row < viewModel.exercises.count else {
            cell.configure(with: "Загрузка...")
            return cell
        }
        
        let exercise = viewModel.exercises[indexPath.row]
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
        
        guard indexPath.row < viewModel.exercises.count else { return }
        let exercise = viewModel.exercises[indexPath.row]
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

