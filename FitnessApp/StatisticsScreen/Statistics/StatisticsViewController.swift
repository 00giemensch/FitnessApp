//
//  StatisticsViewController.swift
//  FitnessApp
//
//  Created by Ilnur on 13.11.2025.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    weak var coordinator: IAppCoordinator?
    
    private let viewModel = StatisticsViewModel()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Выберите упражнение"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Статистики еще нет"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        viewModel.loadWorkouts()
        subscribeViewModel()
        
        viewModel.coordinator = coordinator
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.loadWorkouts()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubviews(titleLabel, tableView, emptyStateLabel)
        
        setupConstraints()
    }
    
    private func subscribeViewModel() {
        viewModel.onEmpty = { [weak self] isEmpty in
            self?.toogleEmptyState(isEmpty: isEmpty)
        }
        viewModel.onReloadData = { [weak self] in
            self?.reloadData()
        }
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StatisticsExerciseCell.self, forCellReuseIdentifier: "ExerciseCell")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func toogleEmptyState(isEmpty: Bool) {
        emptyStateLabel.isHidden = isEmpty
        tableView.isHidden = !isEmpty
    }
    
    private func reloadData() {
        tableView.reloadData()
    }
    
}

extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.countOfExercises()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath) as! StatisticsExerciseCell
        let exercise = viewModel.getModel()[indexPath.row]
        cell.configure(with: exercise.exerciseName)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let exercise = viewModel.getModel()[indexPath.row]
        //let detailVC = ExerciseStatisticsViewController(exerciseId: exercise.exerciseId)
        //navigationController?.pushViewController(detailVC, animated: true)
        viewModel.exerciseSelected(exerciseId: exercise.exerciseId)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let exercise = viewModel.getModel()[indexPath.row]
            
            let alert = UIAlertController(
                title: "Удалить статистику",
                message: "Вы уверены, что хотите удалить всю статистику по упражнению \"\(exercise.exerciseName)\"?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { [weak self] _ in
                self?.tableView.setEditing(false, animated: true)
            })
            alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                viewModel.deleteWorkoutsForExercise(exerciseId: exercise.exerciseId)
                viewModel.deleteGoals(exerciseId: exercise.exerciseId)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                viewModel.removeItem(index: indexPath.row)

                
//                if self.exercises.isEmpty {
//                    self.tableView.isHidden = true
//                    self.emptyStateLabel.isHidden = false
//                }
            })
            
            present(alert, animated: true)
        }
    }
}

