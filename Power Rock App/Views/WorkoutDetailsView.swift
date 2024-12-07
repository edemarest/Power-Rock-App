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
    private let editWorkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Workout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemOrange
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Hidden until confirmed user is a Star
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
        self.title = "Workout Details" // Set the navigation bar title
        setupUI()
        setupNavigationBar()
        fetchCurrentUserData()
        if let workout = workout {
            populateWorkoutDetails(workout)
        }
    }
    
    private func setupNavigationBar() {
        // Set the navigation bar background color to clear or black
        navigationController?.navigationBar.barTintColor = .black

        // Set the title text color to white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]

        // Set the navigation bar items' tint color to white (affects back button and other bar buttons)
        navigationController?.navigationBar.tintColor = .white
    }


    // MARK: - Setup UI
    private func setupUI() {
        // Set background color and add background image
        view.backgroundColor = .black
        backgroundImageView.image = UIImage(named: "Welcome_Background")
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Configure labels for band and genres
        UIHelper.configureLabel(
            bandNameLabel,
            text: "Band: \(workout?.bandName ?? "Unknown")",
            font: UIFont.systemFont(ofSize: 20),
            textColor: .white
        )
        bandNameLabel.textAlignment = .center // Center align text
        bandNameLabel.translatesAutoresizingMaskIntoConstraints = false

        UIHelper.configureLabel(
            genresLabel,
            text: "Genres: \(workout?.genres.joined(separator: ", ") ?? "None")",
            font: UIFont.italicSystemFont(ofSize: 18),
            textColor: .white
        )
        genresLabel.textAlignment = .center // Center align text
        genresLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure table view
        UIHelper.configureTableView(setsTableView)
        setsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "setCell")
        setsTableView.dataSource = self
        setsTableView.delegate = self
        setsTableView.backgroundColor = .clear // Transparent background
        setsTableView.translatesAutoresizingMaskIntoConstraints = false

        // Configure buttons using UIHelper
        UIHelper.configureButton(
            doWorkoutButton,
            title: "Do Workout",
            font: UIFont.systemFont(ofSize: 18, weight: .bold),
            backgroundColor: UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1.0), // Solid reddish-orange
            textColor: .white
        )
        doWorkoutButton.addTarget(self, action: #selector(handleDoWorkout), for: .touchUpInside)
        doWorkoutButton.translatesAutoresizingMaskIntoConstraints = false

        UIHelper.configureButton(
            addToMyWorkoutsButton,
            title: "Remove Workout",
            font: UIFont.systemFont(ofSize: 18, weight: .bold),
            backgroundColor: UIColor.darkGray, // Dark gray background
            textColor: .white
        )
        addToMyWorkoutsButton.addTarget(self, action: #selector(handleAddOrRemoveWorkout), for: .touchUpInside)
        addToMyWorkoutsButton.translatesAutoresizingMaskIntoConstraints = false

        UIHelper.configureButton(
            editWorkoutButton,
            title: "Edit Workout",
            font: UIFont.systemFont(ofSize: 18, weight: .bold),
            backgroundColor: .white,
            textColor: .black
        )
        editWorkoutButton.addTarget(self, action: #selector(editWorkout), for: .touchUpInside)
        editWorkoutButton.translatesAutoresizingMaskIntoConstraints = false

        // Add subviews
        view.addSubview(bandNameLabel)
        view.addSubview(genresLabel)
        view.addSubview(setsTableView)
        view.addSubview(doWorkoutButton)
        view.addSubview(addToMyWorkoutsButton)
        view.addSubview(editWorkoutButton)

        // Set constraints
        NSLayoutConstraint.activate([
            // Band name label
            bandNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            bandNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bandNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Genres label
            genresLabel.topAnchor.constraint(equalTo: bandNameLabel.bottomAnchor, constant: 10),
            genresLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            genresLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Table view
            setsTableView.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 20),
            setsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            setsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            setsTableView.bottomAnchor.constraint(equalTo: doWorkoutButton.topAnchor, constant: -20),

            // Do Workout button
            doWorkoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doWorkoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doWorkoutButton.heightAnchor.constraint(equalToConstant: 50),
            doWorkoutButton.bottomAnchor.constraint(equalTo: addToMyWorkoutsButton.topAnchor, constant: -10),

            // Remove Workout button
            addToMyWorkoutsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addToMyWorkoutsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addToMyWorkoutsButton.heightAnchor.constraint(equalToConstant: 50),
            addToMyWorkoutsButton.bottomAnchor.constraint(equalTo: editWorkoutButton.topAnchor, constant: -10),

            // Edit Workout button
            editWorkoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            editWorkoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            editWorkoutButton.heightAnchor.constraint(equalToConstant: 50),
            editWorkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let set = sets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath)
        
        // Prepare set details with exercises
        var setDetails = "Set \(indexPath.row + 1) - \(set.exercises.count) exercises\n"
        for exercise in set.exercises {
            setDetails += "• \(exercise.name) - \(exercise.reps) reps\n"
        }
        
        // Configure cell appearance
        cell.textLabel?.text = setDetails
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = .white // White text
        cell.backgroundColor = .clear // Transparent background
        cell.selectionStyle = .none
        
        return cell
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
                self.editWorkoutButton.isHidden = (userType != "Star")
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
}
