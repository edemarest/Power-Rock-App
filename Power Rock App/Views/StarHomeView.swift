import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - Protocol
protocol StarHomeViewDelegate: AnyObject {
    func didTapLogout()
    func didTapAddWorkout()
    func didTapWorkoutCell(with workout: Workout)
}

// MARK: - StarHomeViewController
class StarHomeViewController: UIViewController, StarHomeViewDelegate {

    // MARK: - Properties
    private let starHomeView = StarHomeView()
    var workouts: [Workout] = [] // Workouts to be displayed

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        fetchWorkouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchWorkouts()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(starHomeView)
        starHomeView.delegate = self
        starHomeView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            starHomeView.topAnchor.constraint(equalTo: view.topAnchor),
            starHomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            starHomeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starHomeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupNavigationBar() {
        // Set the navigation bar color
        navigationController?.navigationBar.barTintColor = .black

        // Set the title text color
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        // Set the buttons' tint color
        navigationController?.navigationBar.tintColor = .white

        // Set up left and right bar button items
        navigationItem.title = "Created Workouts"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTapLogoutButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddWorkoutButton))
    }

    // MARK: - Fetch Workouts
    private func fetchWorkouts() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is logged in.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)

        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data(),
                  let userBandName = data["bandName"] as? String else {
                print("Error: Missing or invalid band name in user data.")
                return
            }

            DataFetcher.fetchWorkouts { workouts, error in
                if let error = error {
                    print("Error fetching workouts: \(error.localizedDescription)")
                    return
                }

                // Filter workouts by band name
                self.workouts = (workouts ?? []).filter { $0.bandName == userBandName }

                // Update the view
                self.starHomeView.workouts = self.workouts
                DispatchQueue.main.async {
                    self.starHomeView.tableView.reloadData()
                }
            }
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
class StarHomeView: UIView, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    weak var delegate: StarHomeViewDelegate?
    let tableView = UITableView()
    var workouts: [Workout] = []

    private let backgroundImageView = UIImageView()

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
        backgroundColor = .black

        // Background Image
        backgroundImageView.image = UIImage(named: "Background_2")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.4
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundImageView)
        sendSubviewToBack(backgroundImageView)

        // Table View
        tableView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: "workoutCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        tableView.layer.cornerRadius = 12
        tableView.layer.borderWidth = 1.5
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.separatorStyle = .none
        addSubview(tableView)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
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
