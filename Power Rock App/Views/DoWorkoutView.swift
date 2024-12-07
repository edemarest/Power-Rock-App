import UIKit

class DoWorkoutViewController: UIViewController {
    
    // MARK: - Properties
    var workout: Workout? // The workout passed from WorkoutDetailsView
    private var remainingSets: [WorkoutSet] = [] // Temporary sets for this session
    private var completedSets = 0 // Number of completed sets
    private var powerPointsEarned = 0
    private var originalSetIndices: [Int] = []
    
    // MARK: - UI Elements
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let tableView = UITableView()
    private let finishButton = UIBarButtonItem(title: "Finish", style: .plain, target: nil, action: nil)
    private let congratulatoryLabel = UILabel()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupUI()
        setupData()
        ensurePowerPointsInitialized()
    }
    
    private func ensurePowerPointsInitialized() {
        DataFetcher.ensurePowerPointsForFan { error in
            if let error = error {
                print("Error initializing power points: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.title = workout?.title ?? "Workout"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissView))
        finishButton.target = self
        finishButton.action = #selector(finishWorkout)
        finishButton.isEnabled = false
        navigationItem.rightBarButtonItem = finishButton
    }
    
    private func setupUI() {
        // Progress Bar
        progressBar.progress = 0
        progressBar.trackTintColor = .darkGray
        progressBar.progressTintColor = UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1.0)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressBar.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        // TableView
        tableView.register(SetCell.self, forCellReuseIdentifier: "SetCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Congratulatory Label
        congratulatoryLabel.text = "You finished all the sets in \(workout?.title ?? "this workout")! Hit the finish button in the top right to complete it and gain power!"
        congratulatoryLabel.font = UIFont.boldSystemFont(ofSize: 18)
        congratulatoryLabel.textColor = .white
        congratulatoryLabel.textAlignment = .center
        congratulatoryLabel.numberOfLines = 0
        congratulatoryLabel.isHidden = true
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
        remainingSets = workout.sets.map { WorkoutSet(exercises: $0.exercises) }
        originalSetIndices = Array(1...remainingSets.count) // Store original indices (1-based)
        powerPointsEarned = (workout.difficulty ?? 1) * 100 // Calculate power points
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
    
    @objc private func finishWorkout() {
        DataFetcher.updateUserPowerPoints(by: powerPointsEarned) { [weak self] error in
            if let error = error {
                print("Error updating power points: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.navigateBackToHome()
            }
        }
    }
    
    private func navigateBackToHome() {
        guard let navigationController = navigationController else { return }
        
        for viewController in navigationController.viewControllers {
            if let fanHomeVC = viewController as? FanHomeViewController {
                fanHomeVC.refreshPowerPoints() // Ensure power points are updated
                navigationController.popToViewController(fanHomeVC, animated: true)
                return
            }
        }
        
        navigationController.popViewController(animated: true) // Default fallback
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
        let originalIndex = originalSetIndices[indexPath.row] // Use static index
        cell.configure(with: set, setIndex: originalIndex)
        cell.delegate = self
        return cell
    }
}

// MARK: - SetCellDelegate
extension DoWorkoutViewController: SetCellDelegate {
    func didCompleteSet(_ set: WorkoutSet) {
        if let index = remainingSets.firstIndex(where: { $0 === set }) {
            remainingSets.remove(at: index)
            originalSetIndices.remove(at: index) // Maintain alignment
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
        setLabel.text = "Set \(setIndex)" // Always reflect the original set index
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
            
            NSLayoutConstraint.activate([
                exerciseCell.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 10),
                exerciseCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                exerciseCell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                exerciseCell.heightAnchor.constraint(equalToConstant: 44)
            ])
            lastView = exerciseCell
        }
        
        // Adjust the position of the complete button
        NSLayoutConstraint.activate([
            completeButton.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 10),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        completeButton.isEnabled = false // Initially disabled
        updateCompleteButtonState() // Ensure correct appearance
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
        backgroundColor = .clear // Transparent background to avoid visible container background
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.9) // Dark grey (almost black)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        // Configure set label
        setLabel.font = UIFont.boldSystemFont(ofSize: 18)
        setLabel.textColor = .white
        setLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(setLabel)

        // Configure complete button
        completeButton.setTitle("Complete", for: .normal)
        completeButton.setTitleColor(UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1.0), for: .normal) // Reddish-orange text
        completeButton.backgroundColor = .clear // Transparent background
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
        if exerciseCompletion.allSatisfy({ $0 }) {
            completeButton.isEnabled = true
            completeButton.setTitleColor(UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1.0), for: .normal)
        } else {
            completeButton.isEnabled = false
            completeButton.setTitleColor(.white, for: .normal)
        }
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
            let imageName = isChecked ? "checkmark.square.fill" : "square"
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
        backgroundColor = UIColor.black.withAlphaComponent(0.9) // Dark grey (almost black)
        layer.cornerRadius = 5
        layer.masksToBounds = true

        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        repsLabel.textColor = .white
        repsLabel.font = UIFont.systemFont(ofSize: 16)
        repsLabel.translatesAutoresizingMaskIntoConstraints = false

        checkbox.tintColor = .white // White checkbox
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

    @objc private func toggleCheckbox() {
        isChecked.toggle()
        checkboxAction?(isChecked)
    }
}
