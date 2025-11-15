//
//  WorkoutSetTableViewCell.swift
//  FitnessApp
//
//  Created by Ilnur on 13.11.2025.
//

import UIKit

class WorkoutSetTableViewCell: UITableViewCell {
    
    private let setNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let repetitionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(setNumberLabel)
        contentView.addSubview(repetitionsLabel)
        
        NSLayoutConstraint.activate([
            setNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            setNumberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            repetitionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            repetitionsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(setNumber: Int, repetitions: Int) {
        setNumberLabel.text = "\(setNumber)-й подход: "
        repetitionsLabel.text = "\(repetitions) повторений"
    }
}

