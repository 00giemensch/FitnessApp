//
//  WgerExerciseDetailViewController.swift
//  FitnessApp
//
//  Created by Ilnur on 16.11.2025.
//

import UIKit

class WgerExerciseDetailViewController: UIViewController {
    
    private let exerciseId: Int
    private var exercise: WgerExercise?
    private var exerciseInfo: WgerExerciseInfo?
    private var descriptionTopConstraint: NSLayoutConstraint?
    
    private let viewModel: WgerExerciseDetailViewModel
    private let service: WgerServiceProtocol

    
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
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "figure.strengthtraining.traditional")
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(exerciseId: Int, viewModel: WgerExerciseDetailViewModel, service: WgerServiceProtocol) {
        self.exerciseId = exerciseId
        self.viewModel = viewModel
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadExerciseDetails()
    }
    
    private func bindViewModel() {
        viewModel.onDataLoaded = { [weak self] in
            guard let self = self else { return }
            self.exercise = self.viewModel.exercise
            self.title = self.viewModel.title
            self.configureContent()
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            self?.activityIndicator.isHidden = !isLoading
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.onError = { [weak self] error in
            self?.presentError(error)
        }
    }

    private func presentError(_ error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(.init(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(backButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(imageView)
        view.addSubview(activityIndicator)
        
        setupConstraints()
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupConstraints() {
        descriptionTopConstraint = descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)
        
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
            
            nameLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            descriptionTopConstraint!,
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    private func configureContent() {
        guard let exercise = exercise else { return }
        
        if let name = exercise.name, !name.isEmpty {
            nameLabel.text = name
        } else {
            nameLabel.text = "Упражнение #\(exercise.id)"
        }
        
        var descriptionText = ""
        
        if let description = exercise.description, !description.isEmpty {
            let cleanDescription = description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            descriptionText = cleanDescription
        }
        
        var additionalInfo: [String] = []
        
        if let info = exerciseInfo {
            if let category = info.category {
                additionalInfo.append("Категория: \(category.name)")
            }
            if let muscles = info.muscles, !muscles.isEmpty {
                let muscleNames = muscles.map { $0.name }.joined(separator: ", ")
                additionalInfo.append("Основные мышцы: \(muscleNames)")
            }
            if let musclesSecondary = info.musclesSecondary, !musclesSecondary.isEmpty {
                let muscleNames = musclesSecondary.map { $0.name }.joined(separator: ", ")
                additionalInfo.append("Второстепенные мышцы: \(muscleNames)")
            }
            if let equipment = info.equipment, !equipment.isEmpty {
                let equipmentNames = equipment.map { $0.name }.joined(separator: ", ")
                additionalInfo.append("Оборудование: \(equipmentNames)")
            }
        } else {
            if let category = exercise.category {
                additionalInfo.append("Категория: #\(category)")
            }
            if let muscles = exercise.muscles, !muscles.isEmpty {
                additionalInfo.append("Мышцы: \(muscles.map { String($0) }.joined(separator: ", "))")
            }
            if let equipment = exercise.equipment, !equipment.isEmpty {
                additionalInfo.append("Оборудование: \(equipment.map { String($0) }.joined(separator: ", "))")
            }
        }
        
        if !descriptionText.isEmpty {
            if !additionalInfo.isEmpty {
                descriptionText += "\n\n" + additionalInfo.joined(separator: "\n")
            }
            descriptionLabel.text = descriptionText
        } else if !additionalInfo.isEmpty {
            descriptionLabel.text = additionalInfo.joined(separator: "\n")
        } else {
            descriptionLabel.text = "Информация об упражнении отсутствует"
        }
        
        descriptionLabel.isHidden = false
        
        if let images = exercise.images, !images.isEmpty {
            let mainImage = images.first(where: { $0.isMain == true }) ?? images.first
            if let mainImage = mainImage {
                let imageURLString = mainImage.image.hasPrefix("http") ? mainImage.image : "https://wger.de\(mainImage.image)"
                if let imageURL = URL(string: imageURLString) {
                    imageView.isHidden = false
                    loadImage(from: imageURL)
                } else {
                    showPlaceholderImage()
                }
            } else {
                showPlaceholderImage()
            }
        } else {
            showPlaceholderImage()
        }
    }
    
    private func loadImage(from url: URL) {
        service.fetchExerciseImage(imageURL: url.absoluteString) { [weak self] (result: Result<Data, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageData):
                    if let image = UIImage(data: imageData) {
                        self?.imageView.image = image
                        self?.imageView.tintColor = nil
                        self?.imageView.contentMode = .scaleAspectFit
                    } else {
                        self?.showPlaceholderImage()
                    }
                case .failure:
                    self?.showPlaceholderImage()
                }
            }
        }
    }
    
    private func showPlaceholderImage() {
        imageView.isHidden = false
        imageView.image = UIImage(systemName: "figure.strengthtraining.traditional")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .center
        imageView.backgroundColor = .systemGray6
        if descriptionTopConstraint?.isActive == true {
            descriptionTopConstraint?.isActive = false
        }
        descriptionTopConstraint = descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)
        descriptionTopConstraint?.isActive = true
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

