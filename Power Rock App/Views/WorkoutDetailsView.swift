import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - WorkoutDetails
// ViewController to display detailed information about a specific workout
class WorkoutDetailsView: UIViewController {
    
    // MARK: - Properties
    var workout: Workout? // The workout object passed from StarHomeView
    var currentUserType: String = "" // This will be either "Star" or "Fan"
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let bandNameLabel = UILabel()
    private let genresLabel = UILabel()
    private let setsTableView = UITableView()
    private var sets: [WorkoutSet] = []

    // MARK: - View Lifecycle
    // Set up the UI, navigation bar and fetch current user info
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI() // Set up the user interface
        setupNavigationBar() // Set up the navigation bar with buttons
        
        fetchCurrentUserData() // Fetch current user info (Star/Fan)
        
        if let workout = workout {
            populateWorkoutDetails(workout) // Populate the workout details
        }
    }
    
    // MARK: - Setup Methods
    // Set up UI elements like labels, table view, and constraints
    private func setupUI() {
        view.backgroundColor = .white
        
        // Title Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        // Band Name Label
        bandNameLabel.font = UIFont.systemFont(ofSize: 18)
        bandNameLabel.textColor = .gray
        bandNameLabel.textAlignment = .center
        
        // Genres Label
        genresLabel.font = UIFont.italicSystemFont(ofSize: 16)
        genresLabel.textColor = .darkGray
        genresLabel.textAlignment = .center
        
        // Set up Table View for Sets
        setsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "setCell")
        setsTableView.dataSource = self
        setsTableView.delegate = self
        setsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews to the main view
        view.addSubview(titleLabel)
        view.addSubview(bandNameLabel)
        view.addSubview(genresLabel)
        view.addSubview(setsTableView)
        
        // Set up Auto Layout constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bandNameLabel.translatesAutoresizingMaskIntoConstraints = false
        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            setsTableView.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 20),
            setsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            setsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            setsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Navigation Bar Setup
    // Set up navigation bar with title and actions based on user type
    private func setupNavigationBar() {
        navigationItem.title = "Workout Details"
        
        // Set up navigation bar button depending on user type
        if currentUserType == "Star" {
            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editWorkout))
            navigationItem.rightBarButtonItem = editButton
        } else {
            let goButton = UIBarButtonItem(title: "Go", style: .plain, target: self, action: #selector(goToDoWorkoutPage))
            navigationItem.rightBarButtonItem = goButton
        }
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    // MARK: - Fetch Current User Data
    // Fetch current user type from Firestore (Star or Fan)
    private func fetchCurrentUserData() {
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("users").document(currentUser.uid).getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    return
                }
                
                if let data = snapshot?.data(), let userType = data["userType"] as? String {
                    self.currentUserType = userType
                }
            }
        }
    }
    
    // MARK: - Populate Workout Details
    // Populate the workout details into the UI labels
    private func populateWorkoutDetails(_ workout: Workout) {
        titleLabel.text = workout.title
        bandNameLabel.text = "Band: \(workout.bandName)"
        genresLabel.text = "Genres: \(workout.genres.joined(separator: ", "))"
        
        sets = workout.sets
        setsTableView.reloadData() // Reload the table view with workout sets
    }
    
    // MARK: - Actions
    // Navigate back to the previous screen
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // Navigate to the workout edit screen (for Star users)
    @objc private func editWorkout() {
        print("Go to edit workout page")
    }
    
    // Navigate to the Fan page (for Fan users)
    @objc private func goToDoWorkoutPage() {
        print("Go to do workout page")
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
// Table view delegate and data source for displaying workout sets and exercises
extension WorkoutDetailsView: UITableViewDataSource, UITableViewDelegate {
    
    // Return the number of rows (sets) in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count
    }
    
    // Configure each cell with the set details and exercises
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let set = sets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath)
        
        var setDetails = "Set \(indexPath.row + 1) - \(set.exercises.count) exercises\n"
        
        // Loop through the exercises for the set and format them
        for exercise in set.exercises {
            setDetails += "• \(exercise.name) - x\(exercise.reps)\n"
        }
        
        // Set the formatted text to the cell
        cell.textLabel?.text = setDetails
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = .black
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    // Handle selection of a set cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let set = sets[indexPath.row]
        print("Selected Set \(indexPath.row + 1) - \(set.exercises.count) exercises")
    }
}
