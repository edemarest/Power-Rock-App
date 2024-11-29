import UIKit

// MARK: - CreateSetViewControllerDelegate Protocol
// Protocol defining method for adding a WorkoutSet
protocol CreateSetViewControllerDelegate: AnyObject {
    func didAddSet(_ set: WorkoutSet)
}

// MARK: - CreateSetViewController
// ViewController for creating a workout set by adding exercises
class CreateSetViewController: UIViewController {

    // MARK: - Properties
    var exercises: [(name: String, reps: Int)] = []  // Array of exercises in the set
    weak var delegate: CreateSetViewControllerDelegate?

    // MARK: - UI Elements
    private let exerciseNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Exercise Name"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let repsTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Reps"
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let addExerciseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Exercise", for: .normal)
        button.addTarget(self, action: #selector(addExercise), for: .touchUpInside)
        return button
    }()

    private let saveSetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Set", for: .normal)
        button.addTarget(self, action: #selector(saveSet), for: .touchUpInside)
        return button
    }()

    private let exercisesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "exerciseCell")
        return tableView
    }()

    // MARK: - View Lifecycle
    // Set up view elements when the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLayout()
    }

    // MARK: - Setup Methods
    // Configure navigation bar with Back button and Save button
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationItem.title = "Create Set"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveSetButton)
    }

    // Set up layout and constraints for the UI elements
    private func setupLayout() {
        view.backgroundColor = .white

        // Layout constraints for UI elements
        view.addSubview(exerciseNameTextField)
        view.addSubview(repsTextField)
        view.addSubview(addExerciseButton)
        view.addSubview(exercisesTableView)

        exerciseNameTextField.translatesAutoresizingMaskIntoConstraints = false
        repsTextField.translatesAutoresizingMaskIntoConstraints = false
        addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        exercisesTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exerciseNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            exerciseNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exerciseNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            repsTextField.topAnchor.constraint(equalTo: exerciseNameTextField.bottomAnchor, constant: 10),
            repsTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            repsTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            addExerciseButton.topAnchor.constraint(equalTo: repsTextField.bottomAnchor, constant: 10),
            addExerciseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            exercisesTableView.topAnchor.constraint(equalTo: addExerciseButton.bottomAnchor, constant: 20),
            exercisesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            exercisesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            exercisesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        exercisesTableView.dataSource = self
        exercisesTableView.delegate = self
    }

    // MARK: - Actions
    // Navigate back to the previous screen
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // Add an exercise to the list and reload table view
    @objc private func addExercise() {
        guard let name = exerciseNameTextField.text, !name.isEmpty,
              let repsText = repsTextField.text, let reps = Int(repsText) else { return }

        exercises.append((name: name, reps: reps))
        exercisesTableView.reloadData()

        exerciseNameTextField.text = ""
        repsTextField.text = ""
    }

    // Save the created workout set and inform delegate
    @objc private func saveSet() {
        let newSet = WorkoutSet(exercises: exercises)
        delegate?.didAddSet(newSet)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
// Methods for populating and interacting with the exercises table view
extension CreateSetViewController: UITableViewDataSource, UITableViewDelegate {

    // Return number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }

    // Configure each cell to display exercise name and reps
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = exercises[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath)
        cell.textLabel?.text = "\(exercise.name) - Reps: \(exercise.reps)"
        return cell
    }

    // Remove the selected exercise from the list
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        exercises.remove(at: indexPath.row)
        exercisesTableView.reloadData()
    }
}
