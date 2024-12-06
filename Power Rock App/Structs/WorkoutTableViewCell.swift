import UIKit

// MARK: - WorkoutTableViewCell
// Custom table view cell to display workout details
class WorkoutTableViewCell: UITableViewCell {

    // MARK: - UI Elements
    private let workoutTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bandNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let difficultyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let gradientLayer = CAGradientLayer()
    private let outlineMaskLayer = CAShapeLayer()

    private var currentDifficulty: Int = 1 // Default value

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear // Ensure no default white background
        selectionStyle = .none   // Remove selection highlight

        // Add container view to content view
        contentView.addSubview(containerView)

        // Add labels to container view
        containerView.addSubview(workoutTitleLabel)
        containerView.addSubview(bandNameLabel)
        containerView.addSubview(difficultyLabel)
    }

    // MARK: - Constraints Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            // Title label
            workoutTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            workoutTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            workoutTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),

            // Band name label
            bandNameLabel.topAnchor.constraint(equalTo: workoutTitleLabel.bottomAnchor, constant: 5),
            bandNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            bandNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),

            // Difficulty label
            difficultyLabel.topAnchor.constraint(equalTo: bandNameLabel.bottomAnchor, constant: 5),
            difficultyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            difficultyLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            difficultyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15)
        ])
    }

    // MARK: - Configure Cell
    func configure(with workout: Workout) {
        workoutTitleLabel.text = workout.title
        bandNameLabel.text = "Created by \(workout.bandName)"
        difficultyLabel.text = "Difficulty: \(workout.difficulty)"
        currentDifficulty = workout.difficulty // Save the difficulty
        setNeedsLayout() // Trigger layoutSubviews to update the gradient
    }

    // MARK: - Gradient Outline
    private func applyGradientOutline(difficulty: Int) {
        // Ensure containerView.bounds has a valid frame
        guard containerView.bounds.width > 0, containerView.bounds.height > 0 else {
            print("Invalid containerView.bounds: \(containerView.bounds)")
            return
        }

        // Get the gradient for the difficulty
        guard let gradient = UIHelper.gradientForDifficulty(difficulty: difficulty) else { return }
        gradientLayer.colors = gradient.colors
        gradientLayer.startPoint = gradient.startPoint
        gradientLayer.endPoint = gradient.endPoint
        gradientLayer.frame = containerView.bounds

        // Define mask layer for the gradient
        outlineMaskLayer.path = UIBezierPath(roundedRect: containerView.bounds.insetBy(dx: 2, dy: 2), cornerRadius: 10).cgPath
        outlineMaskLayer.lineWidth = 3
        outlineMaskLayer.fillColor = UIColor.clear.cgColor
        outlineMaskLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = outlineMaskLayer

        // Remove previous gradient layers
        containerView.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

        // Add the gradient layer
        containerView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Ensure the gradient is applied after layout is finalized
        DispatchQueue.main.async {
            self.applyGradientOutline(difficulty: self.currentDifficulty)
        }
    }

}
