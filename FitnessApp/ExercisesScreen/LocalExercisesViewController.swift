import UIKit

class LocalExercisesViewController: UIViewController {
    
    private let exercises = LocalExercise.allExercises
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupExercises()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Упражнения"
        
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupExercises() {
        for exercise in exercises {
            let button = createExerciseButton(exercise: exercise)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func createExerciseButton(exercise: LocalExercise) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(exercise.name, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        if exercise.isAvailable {
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(exerciseTapped(_:)), for: .touchUpInside)
        } else {
            button.backgroundColor = .systemGray4
            button.setTitleColor(.secondaryLabel, for: .normal)
            button.setTitle("\(exercise.name) (в разработке)", for: .normal)
            button.isEnabled = false
        }
        
        button.tag = exercises.firstIndex(where: { $0.id == exercise.id }) ?? 0
        return button
    }
    
    @objc private func exerciseTapped(_ sender: UIButton) {
        let exercise = exercises[sender.tag]
        if exercise.isAvailable {
            startWorkout(exercise: exercise)
        }
    }
    
    private func startWorkout(exercise: LocalExercise) {
        let workoutVC = WorkoutViewController(exerciseId: exercise.id, exerciseName: exercise.name)
        navigationController?.pushViewController(workoutVC, animated: true)
    }
}
