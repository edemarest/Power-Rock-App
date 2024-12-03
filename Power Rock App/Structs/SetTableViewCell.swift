import UIKit

// MARK: - SetTableViewCellDelegate
// Protocol to notify when a set is completed
protocol SetTableViewCellDelegate: AnyObject {
    func didCompleteSet(at index: Int)
}

class SetTableViewCell: UITableViewCell {

    // MARK: - Properties
    weak var delegate: SetTableViewCellDelegate?  // Delegate to notify completion
    var setIndex: Int = 0  // Index to identify the set

    // UI Elements
    private let setTitleLabel = UILabel()  // Label for the set title
    private let exercisesStackView = UIStackView()  // StackView for exercises and checkboxes
    private let completeButton = UIButton()  // Button to mark the set as completed

    // MARK: - Setup Methods

    /**
     Initializes the cell and sets up the UI
     */
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()  // Setup the UI when the cell is initialized
        selectionStyle = .none  // Disables cell tap behavior
    }

    /**
     Initializes the cell from a storyboard and sets up the UI
     */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()  // Setup the UI when initialized from storyboard
        selectionStyle = .none  // Disables cell tap behavior
    }

    /**
     Sets up the UI for the cell including labels, stack views, and constraints
     */
    private func setupUI() {
        backgroundColor = .white

        // Set up the set title label
        setTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        setTitleLabel.textAlignment = .left
        setTitleLabel.numberOfLines = 0
        setTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(setTitleLabel)

        // Set up the exercises stack view to arrange exercise labels and checkboxes vertically
        exercisesStackView.axis = .vertical
        exercisesStackView.spacing = 8
        exercisesStackView.alignment = .leading
        exercisesStackView.distribution = .fill
        exercisesStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(exercisesStackView)

        // Set up the complete button
        completeButton.setTitle("Complete", for: .normal)
        completeButton.backgroundColor = .gray
        completeButton.layer.cornerRadius = 10
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.isEnabled = false  // Initially disabled until all checkboxes are checked
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(completeButton)

        // Constraints for UI elements
        NSLayoutConstraint.activate([
            setTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            setTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            setTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            exercisesStackView.topAnchor.constraint(equalTo: setTitleLabel.bottomAnchor, constant: 16),
            exercisesStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            exercisesStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            completeButton.topAnchor.constraint(equalTo: exercisesStackView.bottomAnchor, constant: 16),
            completeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            completeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            completeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            completeButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Action for the complete button
        completeButton.addTarget(self, action: #selector(didCompleteSet), for: .touchUpInside)
    }

    /**
     Configures the cell with the given set and set index
     - Parameter set: The live workout set data
     - Parameter setIndex: The index of the set
     - Parameter delegate: The delegate to notify when the set is completed
     */
    func configure(with set: LiveSet, setIndex: Int, delegate: SetTableViewCellDelegate) {
        self.setIndex = setIndex
        self.delegate = delegate

        // Set the title for the set
        setTitleLabel.text = "Set \(setIndex + 1) Exercises"

        // Clear any previous exercises from the stack view
        exercisesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Create checkboxes for exercises in this set
        for exercise in set.exercises {
            let exerciseLabel = UILabel()
            exerciseLabel.text = "\(exercise.name) - \(exercise.reps) reps"
            let checkbox = UIButton()
            checkbox.setImage(UIImage(systemName: "circle"), for: .normal)  // Empty circle
            checkbox.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)  // Checked circle
            checkbox.isSelected = exercise.isChecked  // Set the initial state
            checkbox.addTarget(self, action: #selector(didToggleCheckbox(_:)), for: .touchUpInside)
            exercisesStackView.addArrangedSubview(exerciseLabel)
            exercisesStackView.addArrangedSubview(checkbox)
        }

        // Disable the complete button if the set is already completed
        completeButton.isEnabled = set.isCompleted
        completeButton.backgroundColor = set.isCompleted ? .orange : .gray
    }

    // MARK: - Actions

    /**
     Toggles the checkbox state when clicked and enables the complete button if all exercises are checked
     */
    @objc private func didToggleCheckbox(_ sender: UIButton) {
        sender.isSelected.toggle()  // Toggle the checkbox state

        // Notify the delegate that this set is completed if all exercises are checked
        let allChecked = exercisesStackView.arrangedSubviews.compactMap { $0 as? UIButton }.allSatisfy { $0.isSelected }
        completeButton.isEnabled = allChecked
    }

    /**
     Marks the set as completed and updates the UI accordingly
     */
    @objc private func didCompleteSet() {
        // Notify the delegate that this set is completed
        delegate?.didCompleteSet(at: setIndex)
        
        // Disable the complete button and grey out the cell
        completeButton.isEnabled = false
        contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)  // Grey out
    }
}

