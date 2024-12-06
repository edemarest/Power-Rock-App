import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - FanHomeViewDelegate Protocol
protocol FanHomeViewDelegate: AnyObject {
    func didTapWorkoutCell(with workout: Workout)
}

// MARK: - FanHomeViewController
class FanHomeViewController: UIViewController, FanHomeViewDelegate, SearchWorkoutViewDelegate, WorkoutDetailsDelegate {

    // MARK: - Properties
    var totalPower: Int = 0
    var fanGenres: [String] = []
    var workouts: [Workout] = []

    private var fanHomeView: FanHomeView? // Reference to the FanHomeView

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Workouts"
        setupNavigationBar()
        setupFanHomeView()
        fetchUserGenres()
        fetchUserWorkouts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
    }

    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        // Set background color and text attributes
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        // Configure Logout Button
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTapLogout))
        logoutButton.tintColor = .white
        navigationItem.leftBarButtonItem = logoutButton

        // Configure Browse Button
        let browseButton = UIBarButtonItem(title: "Browse", style: .plain, target: self, action: #selector(didTapBrowse))
        browseButton.tintColor = .white
        navigationItem.rightBarButtonItem = browseButton
    }

    // MARK: - FanHomeViewDelegate Methods
    func didTapWorkoutCell(with workout: Workout) {
        let workoutDetailsVC = WorkoutDetailsView()
        workoutDetailsVC.workout = workout
        workoutDetailsVC.delegate = self // Set delegate
        navigationController?.pushViewController(workoutDetailsVC, animated: true)
    }

    // MARK: - WorkoutDetailsDelegate Method
    func didUpdateWorkouts() {
        print("Workout list updated in WorkoutDetails. Refreshing home view...")
        fetchUserWorkouts() // Refresh workouts after changes
    }

    // MARK: - SearchWorkoutViewDelegate Methods
    func updateFilteredWorkouts(with workouts: [Workout]) {
        print("Updated workouts from SearchWorkoutView. Refreshing MyWorkouts...")
        fetchUserWorkouts() // Fetch updated MyWorkouts list
    }

    // MARK: - Actions
    @objc private func didTapLogout() {
        try? Auth.auth().signOut()
        navigateToWelcomeView()
    }

    @objc private func didTapBrowse() {
        let searchWorkoutVC = SearchWorkoutView()
        searchWorkoutVC.workouts = workouts
        searchWorkoutVC.delegate = self // Set delegate for updates
        navigationController?.pushViewController(searchWorkoutVC, animated: true)
    }

    private func navigateToWelcomeView() {
        let welcomeVC = WelcomeViewController()
        navigationController?.pushViewController(welcomeVC, animated: true)
    }

    // MARK: - Fetching Data
    private func fetchUserGenres() {
        DataFetcher.fetchUserGenres { [weak self] genres, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user genres: \(error.localizedDescription)")
                return
            }
            self.fanGenres = genres ?? []
        }
    }

    private func fetchUserWorkouts() {
        print("Fetching updated MyWorkouts...")
        
        DataFetcher.fetchMyWorkouts { [weak self] workouts, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching MyWorkouts: \(error.localizedDescription)")
                return
            }
            
            self.workouts = workouts ?? []
            print("Fetched MyWorkouts:")
            for workout in self.workouts {
                print("- \(workout.title)")
            }
            
            DispatchQueue.main.async {
                self.refreshFanHomeView()
            }
        }
    }

    // MARK: - Setup Fan Home View
    private func setupFanHomeView() {
        let fanHomeView = FanHomeView()
        self.fanHomeView = fanHomeView // Keep a reference to update dynamically
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

    private func refreshFanHomeView() {
        guard let fanHomeView = fanHomeView else { return }
        print("Refreshing FanHomeView with updated workouts...")
        fanHomeView.updateWorkouts(workouts)
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
    private let workoutsDescriptionLabel = UILabel() // New label for description

    var totalPower: Int = 0
    var workoutObjects: [Workout] = []

    // Expose tableView as a computed property
    public var workoutTableView: UITableView {
        return tableView
    }

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
    
    func updateWorkouts(_ workouts: [Workout]) {
        self.workoutObjects = workouts
        tableView.reloadData()
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .black // Darker background color

        // Add background image
        backgroundImageView.image = UIImage(named: "Background_2")
        backgroundImageView.alpha = 0.4 // Increased opacity
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundImageView)
        sendSubviewToBack(backgroundImageView)

        // Configure description label
        UIHelper.configureLabel(
            workoutsDescriptionLabel,
            text: "Your workouts home is a collection of workouts of your favorite genre! Feel free to remove any or browse and add more!",
            font: UIFont.systemFont(ofSize: 14),
            textColor: .white
        )
        workoutsDescriptionLabel.numberOfLines = 0
        workoutsDescriptionLabel.textAlignment = .center
        addSubview(workoutsDescriptionLabel)

        // Configure total power box
        totalPowerBox.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        totalPowerBox.layer.cornerRadius = 10
        totalPowerBox.clipsToBounds = true
        addSubview(totalPowerBox)

        // Configure total power label
        totalPowerBox.backgroundColor = UIColor.orange
        // Update total power label styling
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
        workoutsDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        totalPowerBox.translatesAutoresizingMaskIntoConstraints = false
        totalPowerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Background image
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Workouts description label
            workoutsDescriptionLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            workoutsDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            workoutsDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Table view
            tableView.topAnchor.constraint(equalTo: workoutsDescriptionLabel.bottomAnchor, constant: 8),
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
