import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - FanHomeViewDelegate Protocol
// Protocol to handle the tap on a workout cell
protocol FanHomeViewDelegate: AnyObject {
    func didTapWorkoutCell(with workout: Workout)
}

// MARK: - FanHomeViewController
class FanHomeViewController: UIViewController, FanHomeViewDelegate, SearchWorkoutViewDelegate {

    // MARK: - Properties
    var totalPower: Int = 0
    var fanGenres: [String] = []
    var workouts: [Workout] = []

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Workouts"
        setupNavigationBar()
        setupFanHomeView()
        fetchUserGenres()
        fetchWorkouts()
    }

    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTapLogout))
        logoutButton.tintColor = .white
        navigationItem.leftBarButtonItem = logoutButton

        let browseButton = UIBarButtonItem(title: "Browse", style: .plain, target: self, action: #selector(didTapBrowse))
        browseButton.tintColor = .white
        navigationItem.rightBarButtonItem = browseButton
    }

    // MARK: - FanHomeViewDelegate Methods
    func didTapWorkoutCell(with workout: Workout) {
        let workoutDetailsVC = WorkoutDetailsView()
        workoutDetailsVC.workout = workout
        navigationController?.pushViewController(workoutDetailsVC, animated: true)
    }

    // MARK: - SearchWorkoutViewDelegate Methods
    func updateFilteredWorkouts(with workouts: [Workout]) {
        self.workouts = workouts
        setupFanHomeView()
    }

    // MARK: - Actions
    @objc private func didTapLogout() {
        try? Auth.auth().signOut()
        navigateToWelcomeView()
    }

    @objc private func didTapBrowse() {
        let searchWorkoutVC = SearchWorkoutView()
        searchWorkoutVC.workouts = workouts
        searchWorkoutVC.delegate = self
        navigationController?.pushViewController(searchWorkoutVC, animated: true)
    }

    private func navigateToWelcomeView() {
        let welcomeVC = WelcomeViewController()
        navigationController?.pushViewController(welcomeVC, animated: true)
    }

    // MARK: - Fetching Data
    private func fetchUserGenres() {
        guard let user = Auth.auth().currentUser else { return }

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }

            if let data = snapshot?.data(),
               let genres = data["genres"] as? [String] {
                self.fanGenres = genres
                self.fetchWorkouts()
            }
        }
    }

    private func fetchWorkouts() {
        let db = Firestore.firestore()
        db.collection("workouts").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching workouts: \(error.localizedDescription)")
                return
            }

            var allWorkouts: [Workout] = []
            for document in snapshot!.documents {
                let data = document.data()

                if let bandName = data["bandName"] as? String,
                   let genres = data["genres"] as? [String],
                   let title = data["title"] as? String,
                   let difficulty = data["difficulty"] as? Int,
                   let setsData = data["sets"] as? [[String: Any]] {

                    var sets: [WorkoutSet] = []
                    for setData in setsData {
                        if let exercisesData = setData["exercises"] as? [[String: Any]] {
                            var exercises: [(name: String, reps: Int)] = []
                            for exerciseData in exercisesData {
                                if let name = exerciseData["name"] as? String,
                                   let reps = exerciseData["reps"] as? Int {
                                    exercises.append((name: name, reps: reps))
                                }
                            }
                            let workoutSet = WorkoutSet(exercises: exercises)
                            sets.append(workoutSet)
                        }
                    }

                    let workout = Workout(bandName: bandName, genres: genres, title: title, difficulty: difficulty, sets: sets)
                    allWorkouts.append(workout)
                }
            }

            self.workouts = allWorkouts
            self.setupFanHomeView()
        }
    }

    // MARK: - Setup Fan Home View
    private func setupFanHomeView() {
        let fanHomeView = FanHomeView()
        fanHomeView.delegate = self
        fanHomeView.totalPower = totalPower
        fanHomeView.workoutObjects = workouts
        fanHomeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fanHomeView)

        NSLayoutConstraint.activate([
            fanHomeView.topAnchor.constraint(equalTo: view.topAnchor),
            fanHomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fanHomeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fanHomeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - FanHomeView
// Custom view for displaying fan home UI elements including the workouts and user details
class FanHomeView: UIView, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: FanHomeViewDelegate?

    private let tableView = UITableView()
    private let totalPowerBox = UIView()
    private let totalPowerLabel = UILabel()
    private let backgroundImageView = UIImageView()

    var totalPower: Int = 0
    var workoutObjects: [Workout] = []

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .black // Darker background color

        // Add background image
        backgroundImageView.image = UIImage(named: "Background_2")
        backgroundImageView.alpha = 0.6 // Increased opacity
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundImageView)
        sendSubviewToBack(backgroundImageView)

        // Configure total power box
        totalPowerBox.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        totalPowerBox.layer.cornerRadius = 10
        totalPowerBox.clipsToBounds = true
        addSubview(totalPowerBox)

        // Configure total power label
        UIHelper.configureLabel(
            totalPowerLabel,
            text: "Total Power 🔥: \(totalPower)",
            font: UIFont.boldSystemFont(ofSize: 18),
            textColor: .white
        )
        totalPowerLabel.textAlignment = .center
        totalPowerBox.addSubview(totalPowerLabel)

        // Configure table view
        tableView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: "workoutCell")
        tableView.dataSource = self
        tableView.delegate = self
        UIHelper.configureTableView(tableView)
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        tableView.layer.cornerRadius = 12
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.layer.borderWidth = 1.5
        tableView.separatorStyle = .none
        addSubview(tableView)
    }

    // MARK: - Constraints Setup
    private func setupConstraints() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        totalPowerBox.translatesAutoresizingMaskIntoConstraints = false
        totalPowerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Background image
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Table view
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: totalPowerBox.topAnchor, constant: -16),

            // Total power box
            totalPowerBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            totalPowerBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            totalPowerBox.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            totalPowerBox.heightAnchor.constraint(equalToConstant: 60),

            // Total power label
            totalPowerLabel.centerXAnchor.constraint(equalTo: totalPowerBox.centerXAnchor),
            totalPowerLabel.centerYAnchor.constraint(equalTo: totalPowerBox.centerYAnchor)
        ])
    }

    // MARK: - UITableViewDataSource, UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutObjects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workout = workoutObjects[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath) as! WorkoutTableViewCell
        cell.configure(with: workout)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedWorkout = workoutObjects[indexPath.row]
        delegate?.didTapWorkoutCell(with: selectedWorkout)
    }
}
