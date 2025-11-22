//
//  WorkoutViewController.swift
//  FitnessApp
//
//  Created by Ilnur on 13.11.2025.
//

import UIKit

struct WorkoutSetData {
    var repetitions: Int?
}

class WorkoutViewController: UIViewController {
    
    private let exerciseId: String
    private let exerciseName: String
    private let workoutManager: WorkoutManagerProtocol
    private var sets: [WorkoutSetData] = []
    private var setsStackView: UIStackView!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let exerciseNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let addSetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("добавить подход", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.66, green: 0.19, blue: 0.77, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private let completeWorkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Завершить тренировку", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.66, green: 0.19, blue: 0.77, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    init(exerciseId: String, exerciseName: String, workoutManager: WorkoutManagerProtocol) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.workoutManager = workoutManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        exerciseNameLabel.text = exerciseName
        
        setsStackView = UIStackView()
        setsStackView.translatesAutoresizingMaskIntoConstraints = false
        setsStackView.axis = .vertical
        setsStackView.spacing = 16
        setsStackView.distribution = .fill
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(backButton, exerciseNameLabel, setsStackView, addSetButton, completeWorkoutButton)
        
        setupConstraints()
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            exerciseNameLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            exerciseNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            exerciseNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            exerciseNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            setsStackView.topAnchor.constraint(equalTo: exerciseNameLabel.bottomAnchor, constant: 30),
            setsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            setsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addSetButton.topAnchor.constraint(equalTo: setsStackView.bottomAnchor, constant: 20),
            addSetButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addSetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            completeWorkoutButton.topAnchor.constraint(equalTo: addSetButton.bottomAnchor, constant: 20),
            completeWorkoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            completeWorkoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            completeWorkoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        addSetButton.addTarget(self, action: #selector(addSetTapped), for: .touchUpInside)
        completeWorkoutButton.addTarget(self, action: #selector(completeWorkoutTapped), for: .touchUpInside)
    }
    
    @objc private func addSetTapped() {
        if let lastSet = sets.last, lastSet.repetitions == nil {
            showError(message: "Введите хотя бы одно повторение для прошлого подхода")
            return
        }
        
        sets.append(WorkoutSetData(repetitions: nil))
        updateSetsUI()
    }
    
    @objc private func completeWorkoutTapped() {
        let validSets = sets.filter { $0.repetitions != nil && $0.repetitions! > 0 }
        
        if validSets.isEmpty {
            navigationController?.popToRootViewController(animated: true)
            return
        }
        
        let alert = UIAlertController(
            title: "Завершить тренировку",
            message: "Добавить результаты тренировки в статистику?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.saveWorkout()
        })
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func saveWorkout() {
        let validSets = sets.compactMap { set -> WorkoutSet? in
            guard let reps = set.repetitions, reps > 0 else { return nil }
            return WorkoutSet(repetitions: reps, date: Date())
        }
        
        guard !validSets.isEmpty else {
            navigationController?.popToRootViewController(animated: true)
            return
        }
        
        let allWorkouts = workoutManager.getAllWorkouts()
        
        if let existingWorkout = allWorkouts.first(where: { workout in
            workout.exerciseId == exerciseId &&
            Calendar.current.isDate(workout.date, inSameDayAs: Date())
        }) {
            var allSets = existingWorkout.sets
            allSets.append(contentsOf: validSets)
            
            let updatedWorkout = Workout(
                id: existingWorkout.id,
                exerciseId: existingWorkout.exerciseId,
                exerciseName: existingWorkout.exerciseName,
                sets: allSets,
                date: existingWorkout.date
            )
            
            workoutManager.saveWorkout(updatedWorkout)
        } else {
            let workout = Workout(
                id: UUID().uuidString,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                sets: validSets,
                date: Date()
            )
            
            workoutManager.saveWorkout(workout)
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func updateSetsUI() {
        setsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, set) in sets.enumerated() {
            let setView = createSetView(setNumber: index + 1, set: set)
            setsStackView.addArrangedSubview(setView)
        }
    }
    
    private func createSetView(setNumber: Int, set: WorkoutSetData) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 12
        containerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let setNumberLabel = UILabel()
        setNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        setNumberLabel.text = "\(setNumber)-й подход:"
        setNumberLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        setNumberLabel.isHidden = false
        
        let contentStackView = UIStackView()
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 8
        
        if let repetitions = set.repetitions {
            let repetitionsLabel = UILabel()
            repetitionsLabel.text = "Повторений: \(repetitions)"
            repetitionsLabel.font = .systemFont(ofSize: 16)
            
            let changeButton = UIButton(type: .system)
            changeButton.setTitle("Изменить значение", for: .normal)
            changeButton.titleLabel?.font = .systemFont(ofSize: 14)
            changeButton.setTitleColor(UIColor(red: 0.66, green: 0.19, blue: 0.77, alpha: 1.0), for: .normal)
            changeButton.addTarget(self, action: #selector(changeRepetitionsTapped(_:)), for: .touchUpInside)
            changeButton.tag = setNumber - 1
            
            contentStackView.addArrangedSubview(repetitionsLabel)
            contentStackView.addArrangedSubview(changeButton)
        } else {
            let addButton = UIButton(type: .system)
            addButton.setTitle("Добавить повторения", for: .normal)
            addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            addButton.setTitleColor(UIColor(red: 0.66, green: 0.19, blue: 0.77, alpha: 1.0), for: .normal)
            addButton.addTarget(self, action: #selector(addRepetitionsTapped(_:)), for: .touchUpInside)
            addButton.tag = setNumber - 1
            
            contentStackView.addArrangedSubview(addButton)
        }
        
        containerView.addSubview(setNumberLabel)
        containerView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            setNumberLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            setNumberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            setNumberLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            contentStackView.topAnchor.constraint(equalTo: setNumberLabel.bottomAnchor, constant: 8),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
    
    @objc private func addRepetitionsTapped(_ sender: UIButton) {
        let setIndex = sender.tag
        showNumberInputAlert(for: setIndex)
    }
    
    @objc private func changeRepetitionsTapped(_ sender: UIButton) {
        let setIndex = sender.tag
        showNumberInputAlert(for: setIndex)
    }
    
    private func showNumberInputAlert(for setIndex: Int) {
        let alert = UIAlertController(title: "Введите количество повторений", message: nil, preferredStyle: .alert)
        
        alert.addTextField { [weak self] textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "0"
            if let currentReps = self?.sets[setIndex].repetitions {
                textField.text = "\(currentReps)"
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let okAction = UIAlertAction(title: "Ввод", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let value = Int(text),
                  value > 0 else {
                return
            }
            
            if setIndex < self.sets.count {
                self.sets[setIndex].repetitions = value
                self.updateSetsUI()
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
