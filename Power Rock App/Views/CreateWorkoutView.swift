import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - CreateWorkoutViewController
// ViewController for creating a workout, including adding sets and publishing to Firestore
class CreateWorkoutViewController: UIViewController {

    // MARK: - Properties
    var workoutTitle: String = ""
    var difficulty: Int = 1
    // List of sets in the workout
    var sets: [WorkoutSet] = []
    // To hold band name fetched from Firestore
    var bandName: String = ""
    // To hold band genres fetched from Firestore
    var genres: [String] = []

    // MARK: - UI Elements
    private let publishButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Publish", for: .normal)
        button.addTarget(self, action: #selector(publishWorkout), for: .touchUpInside)
        return button
    }()

    private let workoutTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Workout Title"
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 18)
        return textField
    }()

    private let difficultyPicker: UISegmentedControl = {
        let control = UISegmentedControl(items: ["1", "2", "3", "4", "5"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
        return control
    }()

    private let addSetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Set", for: .normal)
        button.addTarget(self, action: #selector(addSet), for: .touchUpInside)
        return button
    }()

    private let setsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "setCell")
        return tableView
    }()

    // MARK: - View Lifecycle
    // Set up view elements when the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLayout()
        fetchUserDetails()  // Fetch band name and genres here
    }

    // MARK: - Setup Methods
    // Configure navigation bar with Back button and Save button
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationItem.title = "Create Workout"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: publishButton)
    }

    // Set up layout and constraints for the UI elements
    private func setupLayout() {
        view.backgroundColor = .white
        setsTableView.translatesAutoresizingMaskIntoConstraints = false
        workoutTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        difficultyPicker.translatesAutoresizingMaskIntoConstraints = false
        addSetButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(workoutTitleTextField)
        view.addSubview(difficultyPicker)
        view.addSubview(addSetButton)
        view.addSubview(setsTableView)

        NSLayoutConstraint.activate([
            workoutTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            workoutTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            workoutTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            difficultyPicker.topAnchor.constraint(equalTo: workoutTitleTextField.bottomAnchor, constant: 20),
            difficultyPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            difficultyPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            addSetButton.topAnchor.constraint(equalTo: difficultyPicker.bottomAnchor, constant: 20),
            addSetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            setsTableView.topAnchor.constraint(equalTo: addSetButton.bottomAnchor, constant: 20),
            setsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            setsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            setsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        setsTableView.dataSource = self
        setsTableView.delegate = self
    }

    // MARK: - Actions
    // Navigate back to the previous screen
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // Publish the workout and save it to Firestore
    @objc private func publishWorkout() {
        workoutTitle = workoutTitleTextField.text ?? ""
        difficulty = difficultyPicker.selectedSegmentIndex + 1

        print("Workout Title: \(workoutTitle)")
        print("Difficulty: \(difficulty)")
        print("Sets: \(sets)")

        // Fetch the band name and genres and then create the workout
        let workout = Workout(bandName: bandName, genres: genres, title: workoutTitle, difficulty: difficulty, sets: sets)
        
        // Here, you can save the workout to Firestore
        saveWorkoutToFirestore(workout)

        // Navigate back to the StarHomeViewController after publishing the workout
        if let navigationController = navigationController {
            for controller in navigationController.viewControllers {
                if let starHomeVC = controller as? StarHomeViewController {
                    navigationController.popToViewController(starHomeVC, animated: true)  // Pop back to StarHomeViewController
                    return
                }
            }
        }
    }

    // Add a new set to the workout
    @objc private func addSet() {
        let createSetVC = CreateSetViewController()
        createSetVC.delegate = self
        navigationController?.pushViewController(createSetVC, animated: true)
    }

    // Update the difficulty based on the segmented control selection
    @objc private func difficultyChanged() {
        difficulty = difficultyPicker.selectedSegmentIndex + 1
    }

    // Fetch user details to get band name and genres
    private func fetchUserDetails() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data(),
                  let userType = data["userType"] as? String else {
                print("Invalid user data.")
                return
            }

            self.bandName = userType == "Star" ? data["bandName"] as? String ?? "" : ""
            self.genres = data["genres"] as? [String] ?? []
            print("Fetched Band Details - Band Name: \(self.bandName), Genres: \(self.genres)")
        }
    }

    // Save workout to Firestore
    private func saveWorkoutToFirestore(_ workout: Workout) {
        let db = Firestore.firestore()
        db.collection("workouts").addDocument(data: [
            "bandName": workout.bandName,
            "genres": workout.genres,
            "title": workout.title,
            "difficulty": workout.difficulty,
            "sets": workout.sets.map { $0.toDict() }
        ]) { error in
            if let error = error {
                print("Error adding workout: \(error.localizedDescription)")
            } else {
                print("Workout successfully added!")
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
// Methods for populating and interacting with the sets table view
extension CreateWorkoutViewController: UITableViewDataSource, UITableViewDelegate {

    // Return number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count
    }

    // Configure each cell to display set information
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let set = sets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath)
        cell.textLabel?.text = "Set \(indexPath.row + 1) - \(set.exercises.count) exercises"
        return cell
    }

    // Handle cell selection if needed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle cell selection if needed
    }
}

// MARK: - CreateSetViewControllerDelegate
// Methods for receiving data from CreateSetViewController
extension CreateWorkoutViewController: CreateSetViewControllerDelegate {
    // Add a set to the workout and reload the table view
    func didAddSet(_ set: WorkoutSet) {
        sets.append(set)
        setsTableView.reloadData()
    }
}
