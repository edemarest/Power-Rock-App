import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - CreateWorkoutViewController
class CreateWorkoutViewController: UIViewController {

    // MARK: - Properties
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
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        return textField
    }()

    private let difficultyPicker: UISegmentedControl = {
        let control = UISegmentedControl(items: ["1", "2", "3", "4", "5"])
        control.selectedSegmentIndex = 0
        
        // Set default (unselected) segment appearance
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.backgroundColor = .darkGray
        
        // Set selected segment appearance: black text and white background
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        let selectedImage = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 30)).image { _ in
            UIColor.white.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 30)).fill()
        }
        control.setBackgroundImage(selectedImage, for: .selected, barMetrics: .default)

        control.layer.cornerRadius = 5
        control.clipsToBounds = true

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
        let imageView = UIImageView(image: UIImage(named: "Background_1"))
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

    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.title = "Create Workout"
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: publishButton)
    }

    private func setupLayout() {
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)

        [workoutTitleTextField, difficultyPicker, addSetButton, setsTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            workoutTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            workoutTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            workoutTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            difficultyPicker.topAnchor.constraint(equalTo: workoutTitleTextField.bottomAnchor, constant: 20),
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

    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func publishWorkout() {
        workoutTitle = workoutTitleTextField.text ?? ""
        difficulty = difficultyPicker.selectedSegmentIndex + 1

        let workout = Workout(
            bandName: bandName,
            genres: genres,
            title: workoutTitle,
            difficulty: difficulty,
            sets: sets,
            bandLogoUrl: bandLogoUrl
        )

        saveWorkoutToFirestore(workout)
        navigationController?.popToRootViewController(animated: true)
    }

    private func saveWorkoutToFirestore(_ workout: Workout) {
        let db = Firestore.firestore()
        db.collection("workouts").addDocument(data: workout.toDict()) { error in
            if let error = error {
                print("Error adding workout: \(error.localizedDescription)")
            } else {
                print("Workout successfully added!")
            }
        }
    }

    @objc private func addSet() {
        let createSetVC = CreateSetViewController()
        createSetVC.delegate = self
        navigationController?.pushViewController(createSetVC, animated: true)
    }

    @objc private func difficultyChanged() {
        difficulty = difficultyPicker.selectedSegmentIndex + 1
    }

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
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension CreateWorkoutViewController: UITableViewDataSource, UITableViewDelegate {
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
}

// MARK: - CreateSetViewControllerDelegate
extension CreateWorkoutViewController: CreateSetViewControllerDelegate {
    func didAddSet(_ set: WorkoutSet) {
        sets.append(set)
        setsTableView.reloadData()
    }
}
