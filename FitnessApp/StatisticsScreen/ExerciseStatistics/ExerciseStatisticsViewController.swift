//
//  ExerciseStatisticsViewController.swift
//  FitnessApp
//
//  Created by Ilnur on 13.11.2025.
//

import UIKit

class ExerciseStatisticsViewController: UIViewController {
    
    weak var coordinator: IAppCoordinator?
    
    private let exerciseId: String
    private var workouts: [Workout] = []
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalRepetitionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let bestResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let periodSegmentedControl: UISegmentedControl = {
        let items = ChartPeriod.allCases.map { $0.title }
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = ChartPeriod.week.rawValue
        control.backgroundColor = .systemGray6
        return control
    }()
    
    private let averageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let periodLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let chartView: BestResultChartView = {
        let chart = BestResultChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: 350).isActive = true
        return chart
    }()
    
    private let addGoalButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить цель", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(red: 0.66, green: 0.19, blue: 0.77, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    init(exerciseId: String) {
        self.exerciseId = exerciseId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(totalRepetitionsLabel, bestResultLabel, periodSegmentedControl, chartView, averageLabel, periodLabel, addGoalButton)
//
//        contentView.addSubview(totalRepetitionsLabel)
//        contentView.addSubview(bestResultLabel)
//        contentView.addSubview(periodSegmentedControl)
//        contentView.addSubview(chartView)
//        contentView.addSubview(averageLabel)
//        contentView.addSubview(periodLabel)
//        contentView.addSubview(addGoalButton)
        setupConstraints()
        
        addGoalButton.addTarget(self, action: #selector(addGoalTapped), for: .touchUpInside)
        periodSegmentedControl.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
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
            
            totalRepetitionsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            totalRepetitionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            totalRepetitionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            bestResultLabel.topAnchor.constraint(equalTo: totalRepetitionsLabel.bottomAnchor, constant: 20),
            bestResultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bestResultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            periodSegmentedControl.topAnchor.constraint(equalTo: bestResultLabel.bottomAnchor, constant: 30),
            periodSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            periodSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            chartView.topAnchor.constraint(equalTo: periodSegmentedControl.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            averageLabel.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 16),
            averageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            averageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            periodLabel.topAnchor.constraint(equalTo: averageLabel.bottomAnchor, constant: 4),
            periodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            periodLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addGoalButton.topAnchor.constraint(equalTo: periodLabel.bottomAnchor, constant: 30),
            addGoalButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addGoalButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addGoalButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -80)
        ])
    }
    
    private func loadData() {
        workouts = WorkoutManager.shared.getWorkoutsForExercise(exerciseId: exerciseId)
        
        if let firstWorkout = workouts.first {
            title = firstWorkout.exerciseName
        } else {
            title = "Статистика"
        }
        
        updateUI()
    }
    
    private func updateUI() {
        let totalReps = workouts.reduce(0) { $0 + $1.totalRepetitions }
        let bestResult = workouts.map { $0.bestResult }.max() ?? 0
        
        let totalRepsGoal = GoalManager.shared.getGoal(exerciseId: exerciseId, type: .totalRepetitions)
        let bestResultGoal = GoalManager.shared.getGoal(exerciseId: exerciseId, type: .bestResult)
        
        if let totalGoal = totalRepsGoal {
            totalRepetitionsLabel.text = "Общее кол-во повторений: \(totalReps)/\(totalGoal.value)"
        } else {
            totalRepetitionsLabel.text = "Общее кол-во повторений: \(totalReps)"
        }
        
        if let bestGoal = bestResultGoal {
            bestResultLabel.text = "Лучший результат за подход: \(bestResult)/\(bestGoal.value)"
        } else {
            bestResultLabel.text = "Лучший результат за подход: \(bestResult) повторений"
        }
        
        chartView.updateData(workouts: workouts)
        updateChartLabels()
    }
    
    private func updateChartLabels() {
        let total = chartView.getTotalValue()
        let period = chartView.getPeriod()
        
        switch period {
        case .day:
            averageLabel.text = "Всего за день: \(total)"
        case .week:
            averageLabel.text = "Всего за неделю: \(total)"
        case .month:
            averageLabel.text = "Всего за месяц: \(total)"
        case .sixMonths:
            averageLabel.text = "Всего за 6 месяцев: \(total)"
        case .year:
            averageLabel.text = "Всего за год: \(total)"
        }
        
        periodLabel.text = chartView.getPeriodString()
    }
    
    @objc private func periodChanged() {
        guard let period = ChartPeriod(rawValue: periodSegmentedControl.selectedSegmentIndex) else { return }
        chartView.setPeriod(period)
        updateChartLabels()
    }
    
    @objc private func addGoalTapped() {
        let alert = UIAlertController(
            title: "Выберите цель",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Общее кол-во повторений", style: .default) { [weak self] _ in
            self?.setGoal(type: .totalRepetitions)
        })
        
        alert.addAction(UIAlertAction(title: "Лучший результат", style: .default) { [weak self] _ in
            self?.setGoal(type: .bestResult)
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = addGoalButton
            popover.sourceRect = addGoalButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func setGoal(type: GoalType) {
        let alert = UIAlertController(
            title: "Введите кол-во повторений",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "0"
        }
        
        alert.addAction(UIAlertAction(title: "Назад", style: .cancel))
        alert.addAction(UIAlertAction(title: "Принять", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let value = Int(text),
                  value > 0 else {
                return
            }
            
            let goal = WorkoutGoal(exerciseId: self.exerciseId, type: type, value: value)
            GoalManager.shared.saveGoal(goal)
            self.loadData()
        })
        
        present(alert, animated: true)
    }
}
