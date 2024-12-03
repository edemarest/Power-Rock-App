import UIKit

class DoWorkoutViewController: UIViewController {

    // MARK: - Properties
    var workout: Workout?  // This should be safely unwrapped before use
    var liveSets: [LiveSet] = []  // List of live sets to be used in the table view
    private var completedSets = 0  // Track how many sets are completed

    // UI Elements
    private let tableView = UITableView()  // Table view to display the sets
    private let progressLabel = UILabel()  // Label to show the progress
    private let finishButton = UIButton()  // Button to finish the workout

    // UI Constants
    private let backButtonTitle = "Back"  // Title for the back button
    private let finishButtonTitle = "Finish"  // Title for the finish button
    private let progressFormat = "%d/%d 🔥"  // Format for the progress label

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()  // Setup the navigation bar
        setupUI()  // Setup the UI elements
        setupLiveSets()  // Setup the live sets for the workout
        updateProgressLabel()  // Update the progress label with initial values

        // Table view delegate and data source setup
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Setup Methods

    /**
     Sets up the navigation bar with the back and finish buttons
     */
    private func setupNavBar() {
        navigationItem.title = workout?.title ?? "Unknown Workout"  // Safe unwrap
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: .plain, target: self, action: #selector(backTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: finishButtonTitle, style: .done, target: self, action: #selector(finishTapped))
    }

    /**
     Sets up the UI elements including progress label, table view, and finish button
     */
    private func setupUI() {
        view.backgroundColor = .white
        
        // Setup Progress Label
        progressLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        progressLabel.textAlignment = .center
        progressLabel.textColor = .black
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)

        // Setup TableView
        tableView.register(SetTableViewCell.self, forCellReuseIdentifier: "setCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Setup Finish Button
        finishButton.setTitle(finishButtonTitle, for: .normal)
        finishButton.backgroundColor = .gray
        finishButton.layer.cornerRadius = 10
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.isEnabled = false
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(finishButton)

        // Constraints
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: finishButton.topAnchor, constant: -20),

            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    /**
     Initializes live sets from the workout's sets
     */
    private func setupLiveSets() {
        guard let workout = workout else { return }
        
        liveSets = workout.sets.compactMap { set in
            guard !set.exercises.isEmpty else { return nil }
            let liveExercises = set.exercises.map { (name: $0.name, reps: $0.reps, isChecked: false) }
            return LiveSet(exercises: liveExercises)
        }
    }

    /**
     Updates the progress label with the current completed sets
     */
    private func updateProgressLabel() {
        progressLabel.text = String(format: progressFormat, completedSets, liveSets.count)
        finishButton.isEnabled = completedSets == liveSets.count  // Enable finish button when all sets are completed
    }

    // MARK: - Actions

    /**
     Navigates back to the previous screen
     */
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    /**
     Handles the finish button tap and completes the workout
     */
    @objc private func finishTapped() {
        print("Workout Finished!")
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension DoWorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    
    /**
     Returns the number of rows (live sets) in the table
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liveSets.count
    }

    /**
     Configures each cell with the set and passes necessary information
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let set = liveSets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath) as! SetTableViewCell
        cell.configure(with: set, setIndex: indexPath.row, delegate: self)
        return cell
    }

    /**
     Deselects the selected row after tapping
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SetTableViewCellDelegate

extension DoWorkoutViewController: SetTableViewCellDelegate {
    
    /**
     Updates the completed sets count and the progress label
     */
    func didCompleteSet(at index: Int) {
        completedSets += 1
        updateProgressLabel()
        tableView.reloadData()  // Refresh the table to show the completed set at the bottom

        if completedSets == liveSets.count {
            finishButton.setTitleColor(.orange, for: .normal)
        }
    }
}
