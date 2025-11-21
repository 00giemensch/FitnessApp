//
//  WgerExerciseTableViewCell.swift
//  FitnessApp
//
//  Created by Ilnur on 15.11.2025.
//

import UIKit

class WgerExerciseTableViewCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let exerciseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "figure.strengthtraining.traditional")
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        return label
    }()
    
    private var descriptionBottomConstraint: NSLayoutConstraint?
    private var imageLoadTask: URLSessionDataTask?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(containerView)

        containerView.addSubviews(exerciseImageView, nameLabel, descriptionLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            exerciseImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            exerciseImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            exerciseImageView.widthAnchor.constraint(equalToConstant: 80),
            exerciseImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: exerciseImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: exerciseImageView.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
        
        let bottomConstraint = descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        bottomConstraint.isActive = true
        descriptionBottomConstraint = bottomConstraint
    }
    
    func configure(with name: String, description: String? = nil, exercise: WgerExercise? = nil) {
        nameLabel.text = name
        if let description = description, !description.isEmpty {
            let cleanDescription = description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "&nbsp;", with: " ")
            descriptionLabel.text = cleanDescription
            descriptionLabel.isHidden = false
            descriptionBottomConstraint?.isActive = true
        } else {
            descriptionLabel.isHidden = true
            descriptionBottomConstraint?.isActive = false
        }
        
        imageLoadTask?.cancel()
        imageLoadTask = nil
        
        if let exercise = exercise, let images = exercise.images, !images.isEmpty {
            let mainImage = images.first(where: { $0.isMain == true }) ?? images.first
            if let mainImage = mainImage {
                let imageURLString = mainImage.image.hasPrefix("http") ? mainImage.image : "https://wger.de\(mainImage.image)"
                if let imageURL = URL(string: imageURLString) {
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
        imageLoadTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self, let data = data, let image = UIImage(data: data), error == nil else {
                    self?.showPlaceholderImage()
                    return
                }
                self.exerciseImageView.image = image
                self.exerciseImageView.tintColor = nil
                self.exerciseImageView.contentMode = .scaleAspectFill
            }
        }
        imageLoadTask?.resume()
    }
    
    private func showPlaceholderImage() {
        exerciseImageView.image = UIImage(systemName: "figure.strengthtraining.traditional")
        exerciseImageView.tintColor = .systemGray3
        exerciseImageView.contentMode = .center
        exerciseImageView.backgroundColor = .systemGray6
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        exerciseImageView.image = UIImage(systemName: "figure.strengthtraining.traditional")
        exerciseImageView.tintColor = .systemGray3
        exerciseImageView.contentMode = .center
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.containerView.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}

