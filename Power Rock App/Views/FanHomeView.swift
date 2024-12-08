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
    var totalPower: Int = 0 {
        didSet {
            fanHomeView?.updateTotalPowerLabel(to: totalPower)
        }
    }
    var fanGenres: [String] = [] // User's selected genres
    var workouts: [Workout] = [] // Workouts in MyWorkouts
    private var fanHomeView: FanHomeView?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Workouts"
        setupNavigationBar()
        setupFanHomeView()

        fetchUserGenres() // Fetch genres
        fetchUserWorkouts() // Fetch MyWorkouts
        fetchPowerPoints() // Fetch power points
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
        refreshPowerPoints() // Ensure the power points are updated every time the view appears
    }

    // MARK: - Navigation Bar Setup
    @objc private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTapLogout))
        logoutButton.tintColor = .white
        navigationItem.leftBarButtonItem = logoutButton

        let browseButton = UIButton(type: .system)
        browseButton.setTitle("Browse", for: .normal)
        browseButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        browseButton.setTitleColor(UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0), for: .normal)
        browseButton.addTarget(self, action: #selector(didTapBrowse), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: browseButton)
    }

    // MARK: - Delegate Methods
    func didTapWorkoutCell(with workout: Workout) {
        let workoutDetailsVC = WorkoutDetailsView()
        workoutDetailsVC.workout = workout
        workoutDetailsVC.delegate = self
        navigationController?.pushViewController(workoutDetailsVC, animated: true)
    }

    func didUpdateWorkouts() {
        fetchUserWorkouts()
    }

    func updateFilteredWorkouts(with workouts: [Workout]) {
        fetchUserWorkouts()
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
        DataFetcher.fetchUserGenres { [weak self] genres, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user genres: \(error.localizedDescription)")
                return
            }

            self.fanGenres = genres?.map { $0.lowercased() } ?? [] // Normalize genres to lowercase
            print("Fetched user genres: \(self.fanGenres)")
        }
    }

    private func fetchUserWorkouts() {
        DataFetcher.fetchMyWorkouts { [weak self] workouts, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching MyWorkouts: \(error.localizedDescription)")
                return
            }

            self.workouts = workouts ?? []
            print("Fetched MyWorkouts (\(self.workouts.count)):")
            self.workouts.forEach { workout in
                print("- \(workout.title) [Genres: \(workout.genres)]")
            }

            DispatchQueue.main.async {
                self.fanHomeView?.updateWorkouts(self.workouts)
            }
        }
    }

    private func fetchPowerPoints() {
        DataFetcher.fetchUserPowerPoints { [weak self] points, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching power points: \(error.localizedDescription)")
                return
            }
            self.totalPower = points ?? 0
        }
    }

    func refreshPowerPoints() {
        DataFetcher.fetchUserPowerPoints { [weak self] points, error in
            guard let self = self else { return }
            if let error = error {
                print("Error refreshing power points: \(error.localizedDescription)")
                return
            }
            self.totalPower = points ?? 0
        }
    }

    // MARK: - Setup Fan Home View
    private func setupFanHomeView() {
        let fanHomeView = FanHomeView()
        self.fanHomeView = fanHomeView
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
class FanHomeView: UIView, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    weak var delegate: FanHomeViewDelegate?

    private let tableView = UITableView()
    private let totalPowerBox = UIView()
    private let totalPowerLabel = UILabel()
    private let backgroundImageView = UIImageView()
    private let workoutsDescriptionLabel = UILabel()

    var totalPower: Int = 0 {
        didSet {
            updateTotalPowerLabel(to: totalPower)
        }
    }
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

    // MARK: - Methods
    func updateTotalPowerLabel(to power: Int) {
        totalPowerLabel.text = "Total Power 🔥: \(power)"
    }

    func updateWorkouts(_ workouts: [Workout]) {
        self.workoutObjects = workouts
        tableView.reloadData()
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .black

        backgroundImageView.image = UIImage(named: "Background_2")
        backgroundImageView.alpha = 0.4
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundImageView)
        sendSubviewToBack(backgroundImageView)

        UIHelper.configureLabel(
            workoutsDescriptionLabel,
            text: "Your workouts home is a collection of workouts of your favorite genre! Feel free to remove any or browse and add more!",
            font: UIFont.systemFont(ofSize: 14),
            textColor: .white
        )
        workoutsDescriptionLabel.numberOfLines = 0
        workoutsDescriptionLabel.textAlignment = .center
        addSubview(workoutsDescriptionLabel)

        totalPowerBox.backgroundColor = .black
        totalPowerBox.layer.cornerRadius = 10
        totalPowerBox.clipsToBounds = true
        addSubview(totalPowerBox)

        UIHelper.configureLabel(
            totalPowerLabel,
            text: "Total Power 🔥: \(totalPower)",
            font: UIFont.boldSystemFont(ofSize: 18),
            textColor: .white
        )
        totalPowerLabel.textAlignment = .center
        totalPowerBox.addSubview(totalPowerLabel)

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

    private func setupConstraints() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        workoutsDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        totalPowerBox.translatesAutoresizingMaskIntoConstraints = false
        totalPowerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            workoutsDescriptionLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            workoutsDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            workoutsDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: workoutsDescriptionLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: totalPowerBox.topAnchor, constant: -16),

            totalPowerBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            totalPowerBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            totalPowerBox.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            totalPowerBox.heightAnchor.constraint(equalToConstant: 60),

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

