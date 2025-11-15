import UIKit

class ExerciseStatisticsViewController: UIViewController {
    
    private let exerciseId: String
    private var workouts: [Workout] = []
    
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
    
    private let totalRepetitionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let bestResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let weeklyAverageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let addGoalButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить цель", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
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
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Статистика"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(totalRepetitionsLabel)
        contentView.addSubview(bestResultLabel)
        contentView.addSubview(weeklyAverageLabel)
        contentView.addSubview(addGoalButton)
        
        setupConstraints()
        
        addGoalButton.addTarget(self, action: #selector(addGoalTapped), for: .touchUpInside)
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
            
            weeklyAverageLabel.topAnchor.constraint(equalTo: bestResultLabel.bottomAnchor, constant: 20),
            weeklyAverageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weeklyAverageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addGoalButton.topAnchor.constraint(equalTo: weeklyAverageLabel.bottomAnchor, constant: 30),
            addGoalButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addGoalButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addGoalButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
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
        
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentWorkouts = workouts.filter { $0.date >= weekAgo }
        let weeklyTotal = recentWorkouts.reduce(0) { $0 + $1.totalRepetitions }
        let weeklyAverage = recentWorkouts.isEmpty ? 0 : weeklyTotal / recentWorkouts.count
        
        let totalRepsGoal = GoalManager.shared.getGoal(exerciseId: exerciseId, type: .totalRepetitions)
        let bestResultGoal = GoalManager.shared.getGoal(exerciseId: exerciseId, type: .bestResult)
        
        if let totalGoal = totalRepsGoal {
            totalRepetitionsLabel.text = "Общее кол-во повторений: \(totalReps)/\(totalGoal.value)"
        } else {
            totalRepetitionsLabel.text = "Общее кол-во повторений: \(totalReps)"
        }
        
        if let bestGoal = bestResultGoal {
            bestResultLabel.text = "Лучший результат: \(bestResult)/\(bestGoal.value)"
        } else {
            bestResultLabel.text = "Лучший результат: \(bestResult) повторений"
        }
        
        weeklyAverageLabel.text = "Среднее за неделю: \(weeklyAverage)"
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
