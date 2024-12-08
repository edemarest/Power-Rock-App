import UIKit

class ExerciseRowCell: UITableViewCell {

    // MARK: - UI Elements
    private let checkbox = UIButton() // Checkbox on the left
    private let exerciseLabel = UILabel() // Exercise name
    private let repsLabel = UILabel() // Rep count

    // Callback to notify about checkbox toggle
    var onCheckboxToggle: ((Bool) -> Void)?

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        // Checkbox
        checkbox.setImage(UIImage(systemName: "circle"), for: .normal)
        checkbox.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkbox.addTarget(self, action: #selector(didTapCheckbox), for: .touchUpInside)
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkbox)

        // Exercise Label
        exerciseLabel.font = UIFont.systemFont(ofSize: 16)
        exerciseLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(exerciseLabel)

        // Reps Label
        repsLabel.font = UIFont.systemFont(ofSize: 14)
        repsLabel.textColor = .gray
        repsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(repsLabel)

        // Constraints
        NSLayoutConstraint.activate([
            checkbox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: 24),
            checkbox.heightAnchor.constraint(equalToConstant: 24),

            exerciseLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 16),
            exerciseLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            repsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: exerciseLabel.trailingAnchor, constant: 8),
            repsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            repsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44) // Minimum height
        ])
    }

    // MARK: - Configuration
    func configure(exerciseName: String, reps: Int, isChecked: Bool) {
        exerciseLabel.text = exerciseName
        repsLabel.text = "x\(reps)"
        checkbox.isSelected = isChecked
    }

    // MARK: - Actions
    @objc private func didTapCheckbox() {
        checkbox.isSelected.toggle()
        onCheckboxToggle?(checkbox.isSelected)
    }
}
