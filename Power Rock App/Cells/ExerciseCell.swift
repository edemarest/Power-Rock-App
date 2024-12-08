import UIKit
/**
 `ExerciseCell` A custom view representing a single exercise with a name, reps, and a checkbox for completion.
 */
class ExerciseCell: UIView {

    // MARK: - Properties
    private let nameLabel = UILabel()
    private let repsLabel = UILabel()
    private let checkbox = UIButton(type: .system)
    private var isChecked = false {
        didSet {
            let imageName = isChecked ? "checkmark.square.fill" : "square"
            checkbox.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    var checkboxAction: ((Bool) -> Void)?

    /// Configures the cell with exercise details.
    /// - Parameter exercise: A tuple containing the exercise name and reps.
    func configure(with exercise: (name: String, reps: Int)) {
        nameLabel.text = exercise.name
        repsLabel.text = "x\(exercise.reps)"
        isChecked = false
    }

    /// Initializes the view with a frame.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    /// Required initializer.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets up the UI components and layout.
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 5
        layer.masksToBounds = true

        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        repsLabel.textColor = .white
        repsLabel.font = UIFont.systemFont(ofSize: 16)
        repsLabel.translatesAutoresizingMaskIntoConstraints = false

        checkbox.tintColor = .white
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)

        addSubview(nameLabel)
        addSubview(repsLabel)
        addSubview(checkbox)

        NSLayoutConstraint.activate([
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            checkbox.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: 24),
            checkbox.heightAnchor.constraint(equalToConstant: 24),

            nameLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            repsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            repsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    /// Toggles the checkbox state and triggers the action callback.
    @objc private func toggleCheckbox() {
        isChecked.toggle()
        checkboxAction?(isChecked)
    }
}
