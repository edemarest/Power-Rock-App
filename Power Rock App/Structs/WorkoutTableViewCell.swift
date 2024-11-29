import UIKit

// MARK: - WorkoutTableViewCell
// Custom table view cell to display workout details
class WorkoutTableViewCell: UITableViewCell {

    // MARK: - UI Elements
    // Label to display the workout title
    let workoutTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Label to display the band name that created the workout
    let bandNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Label to display the difficulty level of the workout
    let difficultyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Methods
    // Configure the cell with a workout object
    func configure(with workout: Workout) {
        workoutTitleLabel.text = workout.title
        bandNameLabel.text = "Created by \(workout.bandName)"
        difficultyLabel.text = "Difficulty: \(workout.difficulty)"
    }
    
    // MARK: - Layout Setup
    // Initialize the cell and set up constraints for the labels
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add subviews to the cell's content view
        contentView.addSubview(workoutTitleLabel)
        contentView.addSubview(bandNameLabel)
        contentView.addSubview(difficultyLabel)
        
        // Set up the constraints for the labels
        NSLayoutConstraint.activate([
            workoutTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            workoutTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            workoutTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            bandNameLabel.topAnchor.constraint(equalTo: workoutTitleLabel.bottomAnchor, constant: 5),
            bandNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            bandNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            difficultyLabel.topAnchor.constraint(equalTo: bandNameLabel.bottomAnchor, constant: 5),
            difficultyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            difficultyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    // Required initializer (not used in this case)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
