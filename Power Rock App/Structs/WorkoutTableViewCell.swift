import UIKit

// MARK: - WorkoutTableViewCell
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
        view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let bandCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8 // Slightly rounded corners
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

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

        // Add band cover image view to container view
        containerView.addSubview(bandCoverImageView)

        // Add labels to container view
        containerView.addSubview(workoutTitleLabel)
        containerView.addSubview(bandNameLabel)
        containerView.addSubview(difficultyLabel)

        // Configure container view border
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.orange.cgColor
    }

    // MARK: - Constraints Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            // Band cover image view
            bandCoverImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            bandCoverImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            bandCoverImageView.widthAnchor.constraint(equalToConstant: 60),
            bandCoverImageView.heightAnchor.constraint(equalToConstant: 60),

            // Title label
            workoutTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            workoutTitleLabel.leadingAnchor.constraint(equalTo: bandCoverImageView.trailingAnchor, constant: 15),
            workoutTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),

            // Band name label
            bandNameLabel.topAnchor.constraint(equalTo: workoutTitleLabel.bottomAnchor, constant: 5),
            bandNameLabel.leadingAnchor.constraint(equalTo: bandCoverImageView.trailingAnchor, constant: 15),
            bandNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),

            // Difficulty label
            difficultyLabel.topAnchor.constraint(equalTo: bandNameLabel.bottomAnchor, constant: 5),
            difficultyLabel.leadingAnchor.constraint(equalTo: bandCoverImageView.trailingAnchor, constant: 15),
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

        // Set white text for title and band name
        workoutTitleLabel.textColor = .white
        bandNameLabel.textColor = .white

        // Update difficulty text color based on solid color
        difficultyLabel.textColor = UIHelper.colorForDifficulty(difficulty: workout.difficulty)

        // Load band cover image or fallback image
        if let bandLogoUrl = workout.bandLogoUrl, let url = URL(string: bandLogoUrl) {
            fetchImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.bandCoverImageView.image = image ?? UIImage(named: "Default_Workout_Icon")
                }
            }
        } else {
            bandCoverImageView.image = UIImage(named: "Default_Workout_Icon")
        }
    }
    
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Failed to fetch image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the container view maintains its orange outline without additional layers
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.orange.cgColor
    }
}
