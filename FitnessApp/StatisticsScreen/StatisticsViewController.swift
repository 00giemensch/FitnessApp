import UIKit

class StatisticsViewController: UIViewController {
    
    private var exercisesWithStats: [String] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Выберите упражнение"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
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
        loadWorkouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWorkouts()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Статистика"
        
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        view.addSubview(emptyStateLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadWorkouts() {
        let allWorkouts = WorkoutManager.shared.getAllWorkouts()
        let exerciseIds = Set(allWorkouts.map { $0.exerciseId })
        exercisesWithStats = Array(exerciseIds)
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if exercisesWithStats.isEmpty {
            emptyStateLabel.isHidden = false
            stackView.isHidden = true
        } else {
            emptyStateLabel.isHidden = true
            stackView.isHidden = false
            
            for exerciseId in exercisesWithStats {
                if let workout = allWorkouts.first(where: { $0.exerciseId == exerciseId }) {
                    let button = createExerciseButton(exerciseName: workout.exerciseName, exerciseId: exerciseId)
                    stackView.addArrangedSubview(button)
                }
            }
        }
    }
    
    private func createExerciseButton(exerciseName: String, exerciseId: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(exerciseName, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(exerciseStatsTapped(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = exerciseId
        return button
    }
    
    @objc private func exerciseStatsTapped(_ sender: UIButton) {
        guard let exerciseId = sender.accessibilityIdentifier else { return }
        let detailVC = ExerciseStatisticsViewController(exerciseId: exerciseId)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
