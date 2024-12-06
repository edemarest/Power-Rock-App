import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - Protocol
// Protocol to handle actions like logout, adding workout, and selecting workout cell
protocol StarHomeViewDelegate: AnyObject {
    func didTapLogout()
    func didTapAddWorkout()
    func didTapWorkoutCell(with workout: Workout)
}

// MARK: - StarHomeViewController
// ViewController to manage the home screen for "Star" users, displaying their workouts
class StarHomeViewController: UIViewController, StarHomeViewDelegate {

    // MARK: - Properties
    private let starHomeView = StarHomeView()
    var workouts: [Workout] = [] // Workouts to be displayed

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchWorkouts()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.addSubview(starHomeView)
        starHomeView.delegate = self
        starHomeView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            starHomeView.topAnchor.constraint(equalTo: view.topAnchor),
            starHomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            starHomeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starHomeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        navigationItem.title = "Home"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTapLogoutButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddWorkoutButton))
    }

    // MARK: - Fetch Workouts
    private func fetchWorkouts() {
        DataFetcher.fetchWorkouts { [weak self] workouts, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching workouts: \(error.localizedDescription)")
                return
            }

            self.workouts = workouts ?? []
            self.starHomeView.workouts = self.workouts
            self.starHomeView.tableView.reloadData()
        }
    }

    // MARK: - Actions
    @objc private func didTapLogoutButton() {
        do {
            try Auth.auth().signOut()
            navigateToWelcomeScreen()
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    @objc private func didTapAddWorkoutButton() {
        let createWorkoutVC = CreateWorkoutViewController()
        navigationController?.pushViewController(createWorkoutVC, animated: true)
    }

    // MARK: - StarHomeViewDelegate Methods
    func didTapLogout() {
        print("Logout tapped from StarHomeView")
    }

    func didTapAddWorkout() {
        print("Add Workout tapped from StarHomeView")
    }

    func didTapWorkoutCell(with workout: Workout) {
        let workoutDetailsVC = WorkoutDetailsView()
        workoutDetailsVC.workout = workout
        navigationController?.pushViewController(workoutDetailsVC, animated: true)
    }

    // MARK: - Navigation Methods
    private func navigateToWelcomeScreen() {
        let welcomeVC = WelcomeViewController()
        if let navigationController = navigationController {
            navigationController.setViewControllers([welcomeVC], animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: welcomeVC)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }
}


// MARK: - StarHomeView
// Custom view for displaying the workouts and user details on the StarHome screen
class StarHomeView: UIView, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: StarHomeViewDelegate?
    let tableView = UITableView()
    var workouts: [Workout] = []

    // MARK: - Initialization
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
        tableView.tableFooterView = UIView()
        addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Constraints
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workout = workouts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath) as! WorkoutTableViewCell
        cell.configure(with: workout)
        return cell
    }

    // MARK: - UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedWorkout = workouts[indexPath.row]
        delegate?.didTapWorkoutCell(with: selectedWorkout)
    }
}
