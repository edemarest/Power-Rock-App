import UIKit

class DoWorkoutViewController: UIViewController {
    
    // MARK: - Properties
    var workout: Workout? // The workout passed from WorkoutDetailsView
    private var remainingSets: [WorkoutSet] = [] // Temporary sets for this session
    private var completedSets = 0 // Number of completed sets
    
    // MARK: - UI Elements
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let tableView = UITableView()
    private let finishButton = UIBarButtonItem(title: "Finish", style: .plain, target: nil, action: nil)
    private let congratulatoryLabel = UILabel()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupProgressBar()
        setupTableView()
        setupCongratulatoryLabel()
        setupData()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.title = workout?.title ?? "Workout"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissView))
        finishButton.isEnabled = false
        navigationItem.rightBarButtonItem = finishButton
    }
    
    private func setupProgressBar() {
        progressBar.progress = 0
        progressBar.trackTintColor = .black
        progressBar.progressTintColor = .orange
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressBar.heightAnchor.constraint(equalToConstant: 10)
        ])
    }
    
    private func setupTableView() {
        tableView.register(SetCell.self, forCellReuseIdentifier: "SetCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCongratulatoryLabel() {
        congratulatoryLabel.text = "You finished all the sets in \(workout?.title ?? "this workout")! Hit the finish button in the top right to complete it and gain power!"
        congratulatoryLabel.font = UIFont.boldSystemFont(ofSize: 18)
        congratulatoryLabel.textColor = .systemGreen
        congratulatoryLabel.textAlignment = .center
        congratulatoryLabel.numberOfLines = 0
        congratulatoryLabel.isHidden = true // Initially hidden
        congratulatoryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(congratulatoryLabel)
        
        NSLayoutConstraint.activate([
            congratulatoryLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            congratulatoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            congratulatoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupData() {
        guard let workout = workout else { return }
        // Create a temporary array of WorkoutSet objects for this session
        remainingSets = workout.sets.map { WorkoutSet(exercises: $0.exercises) }
        updateProgressBar()
    }
    
    private func updateProgressBar() {
        let totalSets = workout?.sets.count ?? 1
        progressBar.progress = Float(completedSets) / Float(totalSets)
        finishButton.isEnabled = completedSets == totalSets
        
        if finishButton.isEnabled {
            showCongratulatoryLabel()
        }
    }
    
    private func showCongratulatoryLabel() {
        tableView.isHidden = true
        congratulatoryLabel.isHidden = false
    }
    
    // MARK: - Actions
    @objc private func dismissView() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate
extension DoWorkoutViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remainingSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetCell", for: indexPath) as? SetCell else {
            return UITableViewCell()
        }
        let set = remainingSets[indexPath.row]
        cell.configure(with: set, setIndex: indexPath.row + 1)
        cell.delegate = self
        return cell
    }
}

// MARK: - SetCellDelegate
extension DoWorkoutViewController: SetCellDelegate {
    func didCompleteSet(_ set: WorkoutSet) {
        // Remove the completed set and update progress
        if let index = remainingSets.firstIndex(where: { $0 === set }) { // Compare by object reference
            remainingSets.remove(at: index)
            completedSets += 1
            tableView.reloadData()
            updateProgressBar()
        }
    }
}


// MARK: - SetCell
protocol SetCellDelegate: AnyObject {
    func didCompleteSet(_ set: WorkoutSet)
}

class SetCell: UITableViewCell {
    
    // MARK: - Properties
    private let setLabel = UILabel()
    private let completeButton = UIButton(type: .system)
    private var exerciseViews: [ExerciseCell] = [] // Holds all exercise views
    private var set: WorkoutSet?

    weak var delegate: SetCellDelegate?
    private var exerciseCompletion: [Bool] = [] // Tracks completion of each exercise
    
    // MARK: - Setup Methods
    func configure(with set: WorkoutSet, setIndex: Int) {
        self.set = set
        setLabel.text = "Set \(setIndex)"
        exerciseCompletion = Array(repeating: false, count: set.exercises.count)
        
        // Clear any existing exercise views
        exerciseViews.forEach { $0.removeFromSuperview() }
        exerciseViews.removeAll()
        
        // Add exercise views
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
            
            // Add constraints
            NSLayoutConstraint.activate([
                exerciseCell.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 10),
                exerciseCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                exerciseCell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                exerciseCell.heightAnchor.constraint(equalToConstant: 44) // Fixed height for exercise cells
            ])
            lastView = exerciseCell
        }
        
        // Adjust the position of the complete button
        NSLayoutConstraint.activate([
            completeButton.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 10),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        // Enable or disable the complete button
        completeButton.isEnabled = false
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none // Disable cell selection
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Configure set label
        setLabel.font = UIFont.boldSystemFont(ofSize: 18)
        setLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(setLabel)

        // Configure complete button
        completeButton.setTitle("Complete", for: .normal)
        completeButton.addTarget(self, action: #selector(completeSet), for: .touchUpInside)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(completeButton)

        // Add constraints for the set label
        NSLayoutConstraint.activate([
            setLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            setLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            setLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    private func updateCompleteButtonState() {
        completeButton.isEnabled = exerciseCompletion.allSatisfy { $0 }
    }

    @objc private func completeSet() {
        guard let set = set else { return }
        delegate?.didCompleteSet(set)
    }
}

class ExerciseCell: UIView {
    
    private let nameLabel = UILabel()
    private let repsLabel = UILabel()
    private let checkbox = UIButton(type: .system)
    private var isChecked = false {
        didSet {
            let imageName = isChecked ? "checkmark.square" : "square"
            checkbox.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }

    var checkboxAction: ((Bool) -> Void)?

    func configure(with exercise: (name: String, reps: Int)) {
        nameLabel.text = exercise.name
        repsLabel.text = "x\(exercise.reps)"
        isChecked = false
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        repsLabel.translatesAutoresizingMaskIntoConstraints = false
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(nameLabel)
        addSubview(repsLabel)
        addSubview(checkbox)

        checkbox.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)

        NSLayoutConstraint.activate([
            checkbox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            checkbox.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            repsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            repsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    @objc private func toggleCheckbox() {
        isChecked.toggle()
        checkboxAction?(isChecked)
    }
}
