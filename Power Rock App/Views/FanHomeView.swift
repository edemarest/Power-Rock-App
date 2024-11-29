import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - FanHomeViewDelegate Protocol
// Protocol to handle the tap on a workout cell
protocol FanHomeViewDelegate: AnyObject {
    func didTapWorkoutCell(with workout: Workout)
}

// MARK: - FanHomeViewController
// ViewController for managing the home screen of a fan user, displaying workouts and user details
class FanHomeViewController: UIViewController, FanHomeViewDelegate {

    // MARK: - Properties
    var totalPower: Int = 0
    var fanGenres: [String] = []
    var workouts: [Workout] = []

    // MARK: - View Lifecycle
    // Setup navigation, layout, and fetch necessary data when the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        setupFanHomeView()
        navigationItem.hidesBackButton = true

        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTapLogout))
        navigationItem.leftBarButtonItem = logoutButton

        let browseButton = UIBarButtonItem(title: "Browse", style: .plain, target: self, action: #selector(didTapBrowse))
        navigationItem.rightBarButtonItem = browseButton

        fetchUserGenres()
        fetchWorkouts()
    }

    // MARK: - Setup Methods
    // Set up the FanHome view with necessary data
    private func setupFanHomeView() {
        let fanHomeView = FanHomeView()
        fanHomeView.delegate = self
        fanHomeView.totalPower = totalPower
        fanHomeView.workoutObjects = workouts
        fanHomeView.fanGenres = fanGenres
        fanHomeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fanHomeView)

        NSLayoutConstraint.activate([
            fanHomeView.topAnchor.constraint(equalTo: view.topAnchor),
            fanHomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fanHomeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fanHomeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - FanHomeViewDelegate Methods
    // Handle workout selection and navigate to the WorkoutDetails screen
    func didTapWorkoutCell(with workout: Workout) {
        let workoutDetailsVC = WorkoutDetailsView()
        workoutDetailsVC.workout = workout
        navigationController?.pushViewController(workoutDetailsVC, animated: true)
    }

    // MARK: - Actions
    @objc private func didTapLogout() {
        try? Auth.auth().signOut()
        navigateToWelcomeView()
    }

    @objc private func didTapBrowse() {
        print("Browse button tapped - Placeholder action")
    }

    private func navigateToWelcomeView() {
        let welcomeVC = WelcomeViewController()
        navigationController?.pushViewController(welcomeVC, animated: true)
    }

    // MARK: - Fetching User Genres and Workouts
    // Fetch user genres from Firestore and then fetch the corresponding workouts
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

    // Fetch workouts from Firestore and filter based on user genres
    private func fetchWorkouts() {
        let db = Firestore.firestore()
        db.collection("workouts").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching workouts: \(error.localizedDescription)")
                return
            }

            var filteredWorkouts: [Workout] = []
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
                    let fanGenresSet = Set(self.fanGenres)
                    let workoutGenresSet = Set(genres)

                    if !fanGenresSet.isDisjoint(with: workoutGenresSet) {
                        filteredWorkouts.append(workout)
                    }
                }
            }

            self.workouts = filteredWorkouts
            self.setupFanHomeView()
        }
    }
}

// MARK: - FanHomeView
// Custom view for displaying fan home UI elements including the workouts and user details
class FanHomeView: UIView, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: FanHomeViewDelegate?

    let tableView = UITableView()
    private let totalPowerBox = UIView()
    private let totalPowerLabel = UILabel()
    private let genresLabel = UILabel()

    var totalPower: Int = 0
    var workoutObjects: [Workout] = []
    var fanGenres: [String] = []

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
        backgroundColor = .white

        tableView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: "workoutCell")
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)

        totalPowerBox.backgroundColor = .lightGray
        totalPowerBox.layer.cornerRadius = 10
        totalPowerBox.clipsToBounds = true
        addSubview(totalPowerBox)

        totalPowerLabel.text = "Total Power 🔥: \(totalPower)"
        totalPowerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        totalPowerLabel.textAlignment = .center
        totalPowerBox.addSubview(totalPowerLabel)

        genresLabel.text = "Showing workouts for your favorite genres: \(fanGenres.joined(separator: ", "))"
        genresLabel.font = UIFont.systemFont(ofSize: 16)
        genresLabel.textAlignment = .center
        genresLabel.numberOfLines = 0
        genresLabel.textColor = .darkGray
        addSubview(genresLabel)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        totalPowerBox.translatesAutoresizingMaskIntoConstraints = false
        totalPowerLabel.translatesAutoresizingMaskIntoConstraints = false
        genresLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            genresLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            genresLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            genresLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: totalPowerBox.topAnchor, constant: -20),

            totalPowerBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            totalPowerBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            totalPowerBox.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            totalPowerBox.heightAnchor.constraint(equalToConstant: 60),

            totalPowerLabel.centerXAnchor.constraint(equalTo: totalPowerBox.centerXAnchor),
            totalPowerLabel.centerYAnchor.constraint(equalTo: totalPowerBox.centerYAnchor)
        ])
    }

    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutObjects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workout = workoutObjects[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath) as! WorkoutTableViewCell
        cell.configure(with: workout)
        return cell
    }

    // MARK: - UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedWorkout = workoutObjects[indexPath.row]
        delegate?.didTapWorkoutCell(with: selectedWorkout)
    }
}
