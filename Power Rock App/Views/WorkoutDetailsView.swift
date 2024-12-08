import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - WorkoutDetailsDelegate Protocol
protocol WorkoutDetailsDelegate: AnyObject {
    func didUpdateWorkouts()
}

// MARK: - WorkoutDetailsView
class WorkoutDetailsView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    var workout: Workout? // The workout object passed from FanHomeView or other screens
    var currentUserType: String = "" // This will be either "Star" or "Fan"
    weak var delegate: WorkoutDetailsDelegate?

    // MARK: - UI Elements
    private let workoutNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 36) // Super large bold font
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let difficultyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bandNameLabel = UILabel()
    private let genresLabel = UILabel()
    private let setsTableView = UITableView()
    private let doWorkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Do Workout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Hidden until confirmed user is a Fan
        return button
    }()
    private let addToMyWorkoutsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Hidden until confirmed user is a Fan
        return button
    }()
    private let deleteWorkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Workout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Welcome_Background"))
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private var sets: [WorkoutSet] = []

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Workout Details" // Set the navigation bar title
        setupUI()
        setupNavigationBar()
        fetchCurrentUserData()
        if let workout = workout {
            populateWorkoutDetails(workout)
        }
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        navigationController?.navigationBar.tintColor = .white
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        UIHelper.configureLabel(
            bandNameLabel,
            text: "",
            font: UIFont.systemFont(ofSize: 20),
            textColor: .white
        )
        bandNameLabel.textAlignment = .center
        bandNameLabel.translatesAutoresizingMaskIntoConstraints = false

        UIHelper.configureLabel(
            genresLabel,
            text: "",
            font: UIFont.italicSystemFont(ofSize: 18),
            textColor: .white
        )
        genresLabel.textAlignment = .center
        genresLabel.translatesAutoresizingMaskIntoConstraints = false

        UIHelper.configureTableView(setsTableView)
        setsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "setCell")
        setsTableView.dataSource = self
        setsTableView.delegate = self
        setsTableView.backgroundColor = .clear
        setsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add target actions for buttons
        doWorkoutButton.addTarget(self, action: #selector(handleDoWorkout), for: .touchUpInside)
        addToMyWorkoutsButton.addTarget(self, action: #selector(handleAddOrRemoveWorkout), for: .touchUpInside)
        deleteWorkoutButton.addTarget(self, action: #selector(deleteWorkout), for: .touchUpInside)

        view.addSubview(workoutNameLabel)
        view.addSubview(difficultyLabel)
        view.addSubview(bandNameLabel)
        view.addSubview(genresLabel)
        view.addSubview(setsTableView)
        view.addSubview(doWorkoutButton)
        view.addSubview(addToMyWorkoutsButton)
        view.addSubview(deleteWorkoutButton)

        NSLayoutConstraint.activate([
            workoutNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            workoutNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            workoutNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            difficultyLabel.topAnchor.constraint(equalTo: workoutNameLabel.bottomAnchor, constant: 10),
            difficultyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            difficultyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            bandNameLabel.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 20),
            bandNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bandNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            genresLabel.topAnchor.constraint(equalTo: bandNameLabel.bottomAnchor, constant: 10),
            genresLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            genresLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            setsTableView.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 20),
            setsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            setsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            setsTableView.bottomAnchor.constraint(equalTo: doWorkoutButton.topAnchor, constant: -20),

            doWorkoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doWorkoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doWorkoutButton.heightAnchor.constraint(equalToConstant: 50),
            doWorkoutButton.bottomAnchor.constraint(equalTo: addToMyWorkoutsButton.topAnchor, constant: -10),

            addToMyWorkoutsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addToMyWorkoutsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addToMyWorkoutsButton.heightAnchor.constraint(equalToConstant: 50),
            addToMyWorkoutsButton.bottomAnchor.constraint(equalTo: deleteWorkoutButton.topAnchor, constant: -10),

            deleteWorkoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteWorkoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deleteWorkoutButton.heightAnchor.constraint(equalToConstant: 50),
            deleteWorkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Populate Workout Details
    private func populateWorkoutDetails(_ workout: Workout) {
        workoutNameLabel.text = workout.title
        difficultyLabel.text = "Difficulty: \(workout.difficulty)"
        bandNameLabel.text = "Band: \(workout.bandName)"
        genresLabel.text = "Genres: \(workout.genres.joined(separator: ", "))"
        sets = workout.sets
        setsTableView.reloadData()
        updateAddToMyWorkoutsButton()
    }
    
    // MARK: - Fetch User Data
    private func fetchCurrentUserData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            if let data = snapshot?.data(), let userType = data["userType"] as? String {
                self.currentUserType = userType
                DispatchQueue.main.async {
                    self.doWorkoutButton.isHidden = (userType != "Fan")
                    self.addToMyWorkoutsButton.isHidden = (userType != "Fan")
                    self.deleteWorkoutButton.isHidden = (userType != "Star")
                }
            }
        }
    }

    // MARK: - Delete Workout
    @objc private func deleteWorkout() {
        guard let workout = workout else { return }
        DataFetcher.deleteWorkout(workoutTitle: workout.title) { [weak self] error in
            if let error = error {
                print("Error deleting workout: \(error.localizedDescription)")
                return
            }
            self?.delegate?.didUpdateWorkouts()
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Update Button State
    private func updateAddToMyWorkoutsButton() {
        guard let workoutTitle = workout?.title else { return }
        DataFetcher.isWorkoutInMyWorkouts(workoutTitle: workoutTitle) { [weak self] isAdded, error in
            guard let self = self else { return }
            if let error = error {
                print("Error checking workout: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                if isAdded {
                    self.addToMyWorkoutsButton.setTitle("Remove from My Workouts", for: .normal)
                    self.addToMyWorkoutsButton.backgroundColor = UIColor.darkGray
                } else {
                    self.addToMyWorkoutsButton.setTitle("Add to My Workouts", for: .normal)
                    self.addToMyWorkoutsButton.backgroundColor = UIColor.systemGreen
                }
            }
        }
    }

    // MARK: - Handle Add/Remove Workout
    @objc private func handleAddOrRemoveWorkout() {
        guard let workout = workout else { return }
        DataFetcher.isWorkoutInMyWorkouts(workoutTitle: workout.title) { [weak self] isAdded, error in
            guard let self = self else { return }
            if let error = error {
                print("Error checking workout: \(error.localizedDescription)")
                return
            }
            if isAdded {
                DataFetcher.removeWorkoutFromMyWorkouts(workoutTitle: workout.title) { error in
                    if let error = error {
                        print("Error removing workout: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.delegate?.didUpdateWorkouts()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                DataFetcher.addWorkoutToMyWorkouts(workout: workout) { error in
                    if let error = error {
                        print("Error adding workout: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.delegate?.didUpdateWorkouts()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Handle Edit Workout
    @objc private func editWorkout() {
        guard let workout = workout else { return }
        let editVC = EditWorkoutViewController()
        editVC.workout = workout
        editVC.onWorkoutUpdated = { [weak self] updatedWorkout in
            self?.workout = updatedWorkout
            self?.populateWorkoutDetails(updatedWorkout)
        }
        navigationController?.pushViewController(editVC, animated: true)
    }

    // MARK: - Handle Do Workout
    @objc private func handleDoWorkout() {
        guard let workout = workout else { return }
        let doWorkoutVC = DoWorkoutViewController()
        doWorkoutVC.workout = workout
        navigationController?.pushViewController(doWorkoutVC, animated: true)
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath)
        let set = sets[indexPath.row]

        // Configure the cell for multiple lines
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = formatSetDetails(set, index: indexPath.row + 1)

        // Style the cell
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.selectionStyle = .none // Disable tap functionality
        return cell
    }

    private func formatSetDetails(_ set: WorkoutSet, index: Int) -> String {
        var details = "Set \(index): \(set.exercises.count) Exercises\n"
        for exercise in set.exercises {
            details += "• \(exercise.name) (x\(exercise.reps))\n"
        }
        return details.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
