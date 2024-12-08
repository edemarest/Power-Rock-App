import UIKit
import FirebaseFirestore
import FirebaseAuth

/**
 `CreateWorkoutViewController` For creating and publishing a workout. Users can configure workout details, add sets, and publish the workout to Firestore.
 */
class CreateWorkoutViewController: UIViewController, CreateSetViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    weak var delegate: CreateWorkoutViewControllerDelegate?
    var workoutTitle: String = ""
    var difficulty: Int = 1
    var sets: [WorkoutSet] = []
    var bandName: String = ""
    var genres: [String] = []
    var bandLogoUrl: String = ""

    // MARK: - UI Elements
    private let publishButton: UIButton = {
        let button = UIButton(type: .system)
        UIHelper.configureButton(
            button,
            title: "Publish",
            font: UIFont.boldSystemFont(ofSize: 16),
            backgroundColor: .clear,
            textColor: UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0),
            cornerRadius: 5
        )
        button.addTarget(self, action: #selector(publishWorkout), for: .touchUpInside)
        return button
    }()

    private let workoutNameLabel: UILabel = {
        let label = UILabel()
        UIHelper.configureLabel(
            label,
            text: "Choose a workout name",
            font: UIFont.systemFont(ofSize: 16),
            textColor: .white
        )
        return label
    }()

    private let workoutTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Workout Title"
        textField.borderStyle = .roundedRect
        textField.textColor = .white
        textField.backgroundColor = .darkGray
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.layer.cornerRadius = 5
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter Workout Title",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        return textField
    }()

    private let difficultyLabel: UILabel = {
        let label = UILabel()
        UIHelper.configureLabel(
            label,
            text: "Set workout difficulty",
            font: UIFont.systemFont(ofSize: 16),
            textColor: .white
        )
        return label
    }()

    private let difficultyPicker: UISegmentedControl = {
        let control = UISegmentedControl(items: ["1", "2", "3", "4", "5"])
        control.selectedSegmentIndex = 0
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.backgroundColor = .darkGray
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        control.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
        return control
    }()

    private let addSetButton: UIButton = {
        let button = UIButton(type: .system)
        UIHelper.configureButton(
            button,
            title: "Add Set",
            font: UIFont.boldSystemFont(ofSize: 16),
            backgroundColor: .clear,
            textColor: UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0),
            cornerRadius: 5
        )
        button.addTarget(self, action: #selector(addSet), for: .touchUpInside)
        return button
    }()

    private let setsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "setCell")
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        tableView.layer.cornerRadius = 10
        tableView.separatorStyle = .none
        return tableView
    }()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Welcome_Background"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLayout()
        fetchUserDetails()
    }

    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationItem.title = "Create Workout"
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: publishButton)
    }

    // MARK: - Setup Layout
    private func setupLayout() {
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)

        [workoutNameLabel, workoutTitleTextField, difficultyLabel, difficultyPicker, addSetButton, setsTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            workoutNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            workoutNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            workoutNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            workoutTitleTextField.topAnchor.constraint(equalTo: workoutNameLabel.bottomAnchor, constant: 5),
            workoutTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            workoutTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            difficultyLabel.topAnchor.constraint(equalTo: workoutTitleTextField.bottomAnchor, constant: 20),
            difficultyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            difficultyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            difficultyPicker.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 5),
            difficultyPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            difficultyPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            addSetButton.topAnchor.constraint(equalTo: difficultyPicker.bottomAnchor, constant: 20),
            addSetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            setsTableView.topAnchor.constraint(equalTo: addSetButton.bottomAnchor, constant: 20),
            setsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            setsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            setsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])

        setsTableView.dataSource = self
        setsTableView.delegate = self
    }

    // MARK: - Handle Back Action
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Publish Workout
    @objc private func publishWorkout() {
        guard let workoutTitle = workoutTitleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !workoutTitle.isEmpty else {
            showAlert(title: "No Workout Name", message: "Please enter a name for your workout before publishing.")
            return
        }

        if sets.isEmpty {
            showAlert(title: "No Sets Added", message: "Please add at least one set to your workout before publishing.")
            return
        }

        self.workoutTitle = workoutTitle
        difficulty = difficultyPicker.selectedSegmentIndex + 1

        let workout = Workout(
            bandName: bandName,
            genres: genres,
            title: workoutTitle,
            difficulty: difficulty,
            sets: sets,
            bandLogoUrl: bandLogoUrl
        )

        DataFetcher.addWorkoutToGlobal(workout: workout) { error in
            if let error = error {
                print("Error publishing workout: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.delegate?.didPublishWorkout()
                    self.navigateToStarHomeScreen()
                }
            }
        }
    }


    // MARK: - Navigate to Home
    private func navigateToStarHomeScreen() {
        if let navigationController = navigationController {
            for controller in navigationController.viewControllers {
                if controller is StarHomeViewController {
                    navigationController.popToViewController(controller, animated: true)
                    return
                }
            }
        }
    }

    // MARK: - Add New Set
    @objc private func addSet() {
        let createSetVC = CreateSetViewController()
        createSetVC.delegate = self
        navigationController?.pushViewController(createSetVC, animated: true)
    }

    // MARK: - Change Difficulty
    @objc private func difficultyChanged() {
        difficulty = difficultyPicker.selectedSegmentIndex + 1
    }

    // MARK: - Fetch User Details
    private func fetchUserDetails() {
        DataFetcher.fetchUserDetails { [weak self] bandName, genres, bandLogoUrl, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }
            self.bandName = bandName ?? ""
            self.genres = genres ?? []
            self.bandLogoUrl = bandLogoUrl ?? "Default_Workout_Image"
        }
    }

    // MARK: - Delegate Method for Adding Set
    func didAddSet(_ set: WorkoutSet) {
        sets.append(set)
        setsTableView.reloadData()
    }

    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let set = sets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath)
        cell.textLabel?.text = "Set \(indexPath.row + 1) - \(set.exercises.count) \(set.exercises.count == 1 ? "exercise" : "exercises")"
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .darkGray
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        return cell
    }

    // MARK: - Show Alert
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
