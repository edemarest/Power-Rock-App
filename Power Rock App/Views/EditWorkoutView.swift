//
//  EditWorkoutViewController.swift
//  Power Rock App
//
//  Created by MaiAnh Tran on 12/3/24.
//
//- **Role**: This screen allows **Star** users to edit the details of a workout.
//- **Connections**:
//  - Accessible from **WorkoutDetails** for **Star** users to modify their created workouts.

import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - EditWorkoutViewController
class EditWorkoutViewController: UIViewController {

    // MARK: - Properties
    var workout: Workout? // The workout to be edited
    var onWorkoutUpdated: ((Workout) -> Void)? // Callback to pass updated workout back

    // MARK: - UI Elements
    private let titleTextField = UITextField()
    private let setsTableView = UITableView()
    private var sets: [WorkoutSet] = []
    
    private let saveButton = UIButton()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupUI()
        populateFields()
    }

    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.title = "Edit Workout"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveWorkout))
    }

    private func setupUI() {
        // Title TextField
        titleTextField.placeholder = "Workout Title"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false

        // Sets TableView
        setsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "setCell")
        setsTableView.dataSource = self
        setsTableView.delegate = self
        setsTableView.translatesAutoresizingMaskIntoConstraints = false

        // Add subviews
        view.addSubview(titleTextField)
        view.addSubview(setsTableView)

        // Constraints
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            setsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            setsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            setsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // Populate fields with existing workout data
    private func populateFields() {
        guard let workout = workout else { return }
        titleTextField.text = workout.title
        sets = workout.sets
        setsTableView.reloadData()
    }

    // MARK: - Save Workout
    @objc private func saveWorkout() {
        guard let workout = workout else { return }
        
        // Update workout object
        let updatedWorkout = Workout(
            bandName: workout.bandName,
            genres: workout.genres,
            title: titleTextField.text ?? workout.title,
            difficulty: workout.difficulty,
            sets: sets,
            timesCompleted: workout.timesCompleted
        )

        // Save updated workout to Firestore
        let db = Firestore.firestore()
        db.collection("workouts").document(updatedWorkout.title).setData([
            "bandName": updatedWorkout.bandName,
            "genres": updatedWorkout.genres,
            "title": updatedWorkout.title,
            "difficulty": updatedWorkout.difficulty,
            "sets": updatedWorkout.sets.map { $0.toDict() },
            "timesCompleted": updatedWorkout.timesCompleted
        ]) { [weak self] error in
            if let error = error {
                print("Error saving workout: \(error.localizedDescription)")
                return
            }
            // Notify the previous screen about the update
            self?.onWorkoutUpdated?(updatedWorkout)
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension EditWorkoutViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let set = sets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath)
        
        var setDetails = "Set \(indexPath.row + 1) - \(set.exercises.count) exercises\n"
        for exercise in set.exercises {
            setDetails += "• \(exercise.name) - x\(exercise.reps)\n"
        }
        cell.textLabel?.text = setDetails
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
