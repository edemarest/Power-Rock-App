import UIKit

/**
 `SetCell` custom table view cell representing a workout set, allowing users to complete exercises and mark the set as complete.
 */
class SetCell: UITableViewCell {

    // MARK: - Properties
    private let setLabel = UILabel()
    private let completeButton = UIButton(type: .system)
    private var exerciseViews: [ExerciseCell] = []
    private var set: WorkoutSet?
    weak var delegate: SetCellDelegate?
    private var exerciseCompletion: [Bool] = []

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    func configure(with set: WorkoutSet, setIndex: Int) {
        self.set = set
        setLabel.text = "Set \(setIndex)"
        exerciseCompletion = Array(repeating: false, count: set.exercises.count)

        exerciseViews.forEach { $0.removeFromSuperview() }
        exerciseViews.removeAll()

        var lastView: UIView = setLabel
        for (index, exercise) in set.exercises.enumerated() {
            let exerciseCell = ExerciseCell()
            exerciseCell.configure(with: exercise)
            exerciseCell.checkboxAction = { [weak self] isChecked in
                guard let self = self else { return }
                self.exerciseCompletion[index] = isChecked
                self.updateCompleteButtonState()
            }
            exerciseCell.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(exerciseCell)
            exerciseViews.append(exerciseCell)

            NSLayoutConstraint.activate([
                exerciseCell.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 10),
                exerciseCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                exerciseCell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                exerciseCell.heightAnchor.constraint(equalToConstant: 44)
            ])
            lastView = exerciseCell
        }

        NSLayoutConstraint.activate([
            completeButton.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 10),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        completeButton.isEnabled = false
        updateCompleteButtonState()
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        setLabel.font = UIFont.boldSystemFont(ofSize: 18)
        setLabel.textColor = .white
        setLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(setLabel)

        completeButton.setTitle("Complete", for: .normal)
        completeButton.setTitleColor(UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1.0), for: .normal)
        completeButton.backgroundColor = .clear
        completeButton.addTarget(self, action: #selector(completeSet), for: .touchUpInside)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(completeButton)

        NSLayoutConstraint.activate([
            setLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            setLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            setLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    // MARK: - Button State
    private func updateCompleteButtonState() {
        completeButton.isEnabled = exerciseCompletion.allSatisfy { $0 }
        completeButton.setTitleColor(
            completeButton.isEnabled ? UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1.0) : .white,
            for: .normal
        )
    }

    // MARK: - Actions
    @objc private func completeSet() {
        guard let set = set else { return }
        delegate?.didCompleteSet(set)
    }
}
