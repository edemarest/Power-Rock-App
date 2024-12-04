import UIKit

class DoWorkoutViewController: UIViewController {

    // MARK: - Properties
    var workout: Workout?  // The workout data
    var liveSets: [LiveSet] = []  // List of live sets to be displayed
    private var completedSets: Set<Int> = []  // Set of indices of completed sets

    // UI Elements
    private let tableView = UITableView()  // Table view for sets
    private let progressLabel = UILabel()  // Progress label

    // Constants
    private let backButtonTitle = "Back"
    private let finishButtonTitle = "Finish"
    private let progressFormat = "%d/%d 🔥"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupLiveSets()
        updateProgressLabel()
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Setup Methods
    private func setupNavBar() {
        navigationItem.title = workout?.title ?? "Unknown Workout"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: .plain, target: self, action: #selector(backTapped))
        let finishButton = UIBarButtonItem(title: finishButtonTitle, style: .done, target: self, action: #selector(finishTapped))
        finishButton.isEnabled = false
        finishButton.tintColor = .gray
        navigationItem.rightBarButtonItem = finishButton
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        // Progress Label
        progressLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)

        // Table View
        tableView.register(SetTableViewCell.self, forCellReuseIdentifier: "setCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        view.addSubview(tableView)

        // Constraints
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupLiveSets() {
        guard let workout = workout else { return }
        liveSets = workout.sets.compactMap { set in
            guard !set.exercises.isEmpty else { return nil }
            let liveExercises = set.exercises.map { (name: $0.name, reps: $0.reps, isChecked: false) }
            return LiveSet(exercises: liveExercises)
        }
    }

    private func updateFinishButton() {
        if let finishButton = navigationItem.rightBarButtonItem {
            finishButton.isEnabled = completedSets.count == liveSets.count
            finishButton.tintColor = finishButton.isEnabled ? .orange : .gray
        }
    }

    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func finishTapped() {
        print("Workout Finished!")
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension DoWorkoutViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liveSets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let set = liveSets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath) as! SetTableViewCell

        let isCompleted = completedSets.contains(indexPath.row)
        cell.configure(with: set, delegate: self, index: indexPath.row, isCompleted: isCompleted)

        return cell
    }
}

// MARK: - SetTableViewCellDelegate
extension DoWorkoutViewController: SetTableViewCellDelegate {
    func didCompleteSet(at index: Int) {
        print("Set \(index + 1) completed.")

        // Remove the completed set and move it to the bottom
        let completedSet = liveSets.remove(at: index)
        liveSets.append(completedSet)

        // Update completed sets
        completedSets.insert(index)

        // Refresh the table view
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            tableView.insertRows(at: [IndexPath(row: liveSets.count - 1, section: 0)], with: .fade)
        }, completion: { _ in
            self.updateProgressLabel()
        })
    }

    private func updateProgressLabel() {
        let completedCount = completedSets.count
        let totalCount = liveSets.count
        progressLabel.text = String(format: progressFormat, completedCount, totalCount)
    }
}
