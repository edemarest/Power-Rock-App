import UIKit

// MARK: - SearchWorkoutViewDelegate Protocol
protocol SearchWorkoutViewDelegate: AnyObject {
    func updateFilteredWorkouts(with workouts: [Workout])
}

// MARK: - SearchWorkoutView
class SearchWorkoutView: UIViewController {

    // MARK: - Properties
    var workouts: [Workout] = []
    var filteredWorkouts: [Workout] = []
    weak var delegate: SearchWorkoutViewDelegate?

    private let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "Pick a filter for the Power Rock workout library"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let segmentedControl = UISegmentedControl(items: ["Band", "Genre", "Name"])
    private let searchBar = UISearchBar()

    private let difficultySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 5
        slider.value = 1 // Default value
        slider.isContinuous = true
        return slider
    }()

    private let sliderLabel: UILabel = {
        let label = UILabel()
        label.text = "Difficulty: All"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 5
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()

    private let tableView = UITableView()

    private var selectedDifficulty: Int? = nil // Nil indicates all difficulties
    private var selectedFilter: String {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return "Band"
        case 1: return "Genre"
        case 2: return "Name"
        default: return "Name"
        }
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search Workouts"
        setupUI()
        setupConstraints()
        setupActions()
        updateSearchPlaceholder()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white

        // Add filter label
        view.addSubview(filterLabel)

        // Add segmented control for filter options
        segmentedControl.selectedSegmentIndex = 0
        view.addSubview(segmentedControl)

        // Add search bar
        searchBar.delegate = self
        view.addSubview(searchBar)

        // Add difficulty slider and label
        view.addSubview(difficultySlider)
        view.addSubview(sliderLabel)

        // Add reset button
        view.addSubview(resetButton)

        // Add table view for displaying results
        tableView.register(WorkoutTableViewCell.self, forCellReuseIdentifier: "workoutCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        difficultySlider.translatesAutoresizingMaskIntoConstraints = false
        sliderLabel.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Filter label
            filterLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            filterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            filterLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            // Segmented control
            segmentedControl.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),

            // Search bar
            searchBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            // Difficulty slider
            difficultySlider.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            difficultySlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            difficultySlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),

            // Slider label
            sliderLabel.centerYAnchor.constraint(equalTo: difficultySlider.centerYAnchor),
            sliderLabel.leadingAnchor.constraint(equalTo: difficultySlider.trailingAnchor, constant: 10),

            // Reset button
            resetButton.topAnchor.constraint(equalTo: difficultySlider.bottomAnchor, constant: 10),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            resetButton.widthAnchor.constraint(equalToConstant: 70),
            resetButton.heightAnchor.constraint(equalToConstant: 30),

            // Table view
            tableView.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        difficultySlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        resetButton.addTarget(self, action: #selector(resetFilters), for: .touchUpInside)
    }

    @objc private func segmentedControlChanged() {
        updateSearchPlaceholder()
        filterWorkouts()
    }

    @objc private func sliderValueChanged() {
        selectedDifficulty = Int(difficultySlider.value.rounded())
        sliderLabel.text = "Difficulty: \(selectedDifficulty ?? 1)"
        filterWorkouts()
    }

    @objc private func resetFilters() {
        selectedDifficulty = nil
        difficultySlider.value = 1
        sliderLabel.text = "Difficulty: All"
        filterWorkouts()
    }

    private func updateSearchPlaceholder() {
        searchBar.placeholder = "Enter \(selectedFilter)"
    }

    private func filterWorkouts() {
        guard let searchText = searchBar.text?.lowercased(), !searchText.isEmpty else {
            filteredWorkouts = applyDifficultyFilter(to: workouts)
            tableView.reloadData()
            return
        }

        var tempFilteredWorkouts: [Workout]

        switch segmentedControl.selectedSegmentIndex {
        case 0: // Band
            tempFilteredWorkouts = workouts.filter { $0.bandName.lowercased().contains(searchText) }
        case 1: // Genre
            tempFilteredWorkouts = workouts.filter { $0.genres.contains(where: { $0.lowercased().contains(searchText) }) }
        case 2: // Name
            tempFilteredWorkouts = workouts.filter { $0.title.lowercased().contains(searchText) }
        default:
            tempFilteredWorkouts = workouts
        }

        filteredWorkouts = applyDifficultyFilter(to: tempFilteredWorkouts)
        tableView.reloadData()
    }

    private func applyDifficultyFilter(to workouts: [Workout]) -> [Workout] {
        guard let difficulty = selectedDifficulty else {
            return workouts // Return all workouts if no difficulty is selected
        }
        return workouts.filter { $0.difficulty == difficulty }
    }
}

// MARK: - UISearchBarDelegate
extension SearchWorkoutView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterWorkouts()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchWorkoutView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWorkouts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workout = filteredWorkouts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath) as! WorkoutTableViewCell
        cell.configure(with: workout)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.updateFilteredWorkouts(with: filteredWorkouts)
    }
}
