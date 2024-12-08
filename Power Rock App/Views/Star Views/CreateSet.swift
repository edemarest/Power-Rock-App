import UIKit

/**
 `CreateSetViewController` allows users to create a workout set by adding exercises with their respective repetitions. Users can view, edit, and delete exercises before saving the set.
 */
class CreateSetViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    var exercises: [(name: String, reps: Int)] = []
    weak var delegate: CreateSetViewControllerDelegate?

    // MARK: - UI Elements
    private let exerciseLabel: UILabel = {
        let label = UILabel()
        UIHelper.configureLabel(label, text: "Exercise", font: UIFont.boldSystemFont(ofSize: 18), textColor: .white)
        return label
    }()

    private lazy var exerciseNameTextField: UITextField = {
        UIHelper.createStyledTextField(placeholder: "Enter Exercise Name")
    }()

    private let repsLabel: UILabel = {
        let label = UILabel()
        UIHelper.configureLabel(label, text: "Rep Count", font: UIFont.boldSystemFont(ofSize: 18), textColor: .white)
        return label
    }()

    private lazy var repsTextField: UITextField = {
        let textField = UIHelper.createStyledTextField(placeholder: "0")
        textField.keyboardType = .numberPad
        textField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return textField
    }()

    private let addExerciseButton: UIButton = {
        let button = UIButton(type: .system)
        UIHelper.configureButton(
            button,
            title: "Add Exercise",
            font: UIFont.boldSystemFont(ofSize: 16),
            backgroundColor: .clear,
            textColor: UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0)
        )
        return button
    }()

    private let saveSetButton: UIButton = {
        let button = UIButton(type: .system)
        UIHelper.configureButton(
            button,
            title: "Save Set",
            font: UIFont.boldSystemFont(ofSize: 16),
            backgroundColor: .clear,
            textColor: UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0)
        )
        return button
    }()

    private let exercisesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "exerciseCell")
        UIHelper.configureTableView(tableView)
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return tableView
    }()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Welcome_Background"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0.4
        return imageView
    }()

    private let blackOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIElements()
    }

    // MARK: - UI Setup
    private func setupUIElements() {
        view.addSubview(blackOverlayView)
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        view.sendSubviewToBack(blackOverlayView)

        [exerciseLabel, exerciseNameTextField, repsLabel, repsTextField, addExerciseButton, exercisesTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        addExerciseButton.addTarget(self, action: #selector(addExercise), for: .touchUpInside)
        saveSetButton.addTarget(self, action: #selector(saveSet), for: .touchUpInside)

        exercisesTableView.dataSource = self
        exercisesTableView.delegate = self
        repsTextField.delegate = self

        navigationItem.title = "Create Set"
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveSetButton)

        NSLayoutConstraint.activate([
            blackOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            blackOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blackOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blackOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            exerciseLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            exerciseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            exerciseNameTextField.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor, constant: 5),
            exerciseNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exerciseNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            repsLabel.topAnchor.constraint(equalTo: exerciseNameTextField.bottomAnchor, constant: 20),
            repsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            repsTextField.topAnchor.constraint(equalTo: repsLabel.bottomAnchor, constant: 5),
            repsTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            addExerciseButton.topAnchor.constraint(equalTo: repsTextField.bottomAnchor, constant: 20),
            addExerciseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            exercisesTableView.topAnchor.constraint(equalTo: addExerciseButton.bottomAnchor, constant: 20),
            exercisesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            exercisesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exercisesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func addExercise() {
        guard let name = exerciseNameTextField.text, !name.isEmpty,
              let repsText = repsTextField.text, let reps = Int(repsText) else { return }

        exercises.append((name: name, reps: reps))
        exercisesTableView.reloadData()

        exerciseNameTextField.text = ""
        repsTextField.text = ""
    }

    @objc private func saveSet() {
        if exercises.isEmpty {
            let alert = UIAlertController(
                title: "No Exercises Added",
                message: "Please add at least one exercise to the set before saving.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }

        let newSet = WorkoutSet(exercises: exercises)
        delegate?.didAddSet(newSet)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = exercises[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath)
        UIHelper.configureLabel(
            cell.textLabel!,
            text: "\(exercise.name) - Reps: \(exercise.reps)",
            font: UIFont.systemFont(ofSize: 16),
            textColor: .white
        )
        cell.backgroundColor = .darkGray
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        exercises.remove(at: indexPath.row)
        exercisesTableView.reloadData()
    }
}
