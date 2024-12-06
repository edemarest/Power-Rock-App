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
    private let titleLabel = UILabel()
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
        button.backgroundColor = UIColor.systemRed
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Hidden until confirmed user is a Fan
        return button
    }()
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "WorkoutBackground"))
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var sets: [WorkoutSet] = []

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchCurrentUserData()
        if let workout = workout {
            populateWorkoutDetails(workout)
        }
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add Background
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Configure Labels
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        bandNameLabel.font = UIFont.systemFont(ofSize: 20)
        bandNameLabel.textColor = .darkGray
        bandNameLabel.textAlignment = .center
        
        genresLabel.font = UIFont.italicSystemFont(ofSize: 18)
        genresLabel.textColor = .gray
        genresLabel.textAlignment = .center
        
        // Configure Table View
        setsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "setCell")
        setsTableView.dataSource = self
        setsTableView.delegate = self
        setsTableView.translatesAutoresizingMaskIntoConstraints = false
        setsTableView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        setsTableView.layer.cornerRadius = 12
        
        // Add Subviews
        view.addSubview(titleLabel)
        view.addSubview(bandNameLabel)
        view.addSubview(genresLabel)
        view.addSubview(setsTableView)
        view.addSubview(separatorView)
        view.addSubview(doWorkoutButton)
        view.addSubview(addToMyWorkoutsButton)
        
        // Button Actions
        addToMyWorkoutsButton.addTarget(self, action: #selector(handleAddOrRemoveWorkout), for: .touchUpInside)
        doWorkoutButton.addTarget(self, action: #selector(handleDoWorkout), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bandNameLabel.translatesAutoresizingMaskIntoConstraints = false
        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        setsTableView.translatesAutoresizingMaskIntoConstraints = false
        addToMyWorkoutsButton.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        // Set Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            bandNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            bandNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bandNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            genresLabel.topAnchor.constraint(equalTo: bandNameLabel.bottomAnchor, constant: 10),
            genresLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            genresLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            separatorView.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 15),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            setsTableView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 15),
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
            addToMyWorkoutsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
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
                self.addToMyWorkoutsButton.isHidden = (userType != "Fan")
                self.doWorkoutButton.isHidden = (userType != "Fan")
                self.updateAddToMyWorkoutsButton()
            }
        }
    }

    // MARK: - Populate Workout Details
    private func populateWorkoutDetails(_ workout: Workout) {
        titleLabel.text = workout.title
        bandNameLabel.text = "Band: \(workout.bandName)"
        genresLabel.text = "Genres: \(workout.genres.joined(separator: ", "))"
        sets = workout.sets
        setsTableView.reloadData()
        updateAddToMyWorkoutsButton()
    }

    // MARK: - Update Button State
    private func updateAddToMyWorkoutsButton() {
        guard let workoutTitle = workout?.title else { return }
        print("Checking if workout '\(workoutTitle)' is in MyWorkouts...")
        
        DataFetcher.isWorkoutInMyWorkouts(workoutTitle: workoutTitle) { [weak self] isAdded, error in
            guard let self = self else { return }
            if let error = error {
                print("Error checking workout '\(workoutTitle)': \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                if isAdded {
                    print("Workout '\(workoutTitle)' is in MyWorkouts.")
                    self.addToMyWorkoutsButton.setTitle("Remove from My Workouts", for: .normal)
                    self.addToMyWorkoutsButton.backgroundColor = UIColor.systemRed
                } else {
                    print("Workout '\(workoutTitle)' is NOT in MyWorkouts.")
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
                print("Error checking workout in MyWorkouts: \(error.localizedDescription)")
                return
            }
            
            if isAdded {
                // Remove workout
                DataFetcher.removeWorkoutFromMyWorkouts(workoutTitle: workout.title) { error in
                    if let error = error {
                        print("Error removing workout: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            print("Removed workout '\(workout.title)' successfully.")
                            self.delegate?.didUpdateWorkouts() // Notify delegate
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                // Add workout
                DataFetcher.addWorkoutToMyWorkouts(workout: workout) { error in
                    if let error = error {
                        print("Error adding workout: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            print("Added workout '\(workout.title)' successfully.")
                            self.delegate?.didUpdateWorkouts() // Notify delegate
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
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
        let set = sets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath)
        var setDetails = "Set \(indexPath.row + 1) - \(set.exercises.count) exercises\n"
        for exercise in set.exercises {
            setDetails += "• \(exercise.name) - x\(exercise.reps)\n"
        }
        cell.textLabel?.text = setDetails
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        return cell
    }
}
