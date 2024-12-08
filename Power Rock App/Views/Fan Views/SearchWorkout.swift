import UIKit
import FirebaseFirestore

/**
 `SearchWorkoutViewController` SearchWorkoutViewController is responsible for displaying and filtering the Power Rock workout library.
 /// Users can filter workouts by Band, Genre, Name, or Difficulty, and navigate to workout details.
 */
class SearchWorkoutViewController: UIViewController, UITableViewDataSource,
                         UITableViewDelegate, UISearchBarDelegate, WorkoutDetailsViewControllerDelegate {
    // MARK: - Properties
    var workouts: [Workout] = []
    var filteredWorkouts: [Workout] = []
    weak var delegate: SearchWorkoutViewControllerDelegate?

    private let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "Pick a filter for the Power Rock workout library"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Background_3")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var selectedFilter: String {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return "Band"
        case 1: return "Genre"
        case 2: return "Name"
        default: return "Name"
        }
    }

    private let segmentedControl = UISegmentedControl(items: ["Band", "Genre", "Name"])
    private let searchBar = UISearchBar()

    private let difficultySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 5
        slider.value = 1
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
    private var selectedDifficulty: Int? = nil

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search Workouts"
        setupUI()
        setupConstraints()
        setupActions()
        updateSearchPlaceholder()
        fetchAllWorkouts()
    }

    // MARK: - Fetch Workouts
    private func fetchAllWorkouts() {
        DataFetcher.fetchWorkouts { [weak self] workouts, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching workouts: \(error.localizedDescription)")
                return
            }

            guard let fetchedWorkouts = workouts else {
                print("No workout data found")
                return
            }

            self.workouts = fetchedWorkouts
            self.filteredWorkouts = self.workouts
            self.tableView.reloadData()
        }
    }


    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        UIHelper.configureLabel(filterLabel, text: "Pick a filter for the Power Rock workout library", font: UIFont.systemFont(ofSize: 16, weight: .medium), textColor: .white)
        view.addSubview(filterLabel)

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.systemOrange], for: .selected)
        segmentedControl.backgroundColor = .darkGray
        view.addSubview(segmentedControl)

        searchBar.delegate = self
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.backgroundImage = UIImage()
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search workouts...", attributes: placeholderAttributes)
        view.addSubview(searchBar)

        difficultySlider.minimumTrackTintColor = UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0)
        difficultySlider.maximumTrackTintColor = .gray
        difficultySlider.setThumbImage(createSliderThumb(with: .darkGray), for: .normal)
        view.addSubview(difficultySlider)

        UIHelper.configureLabel(sliderLabel, text: "Difficulty: All", font: UIFont.systemFont(ofSize: 14), textColor: .white)
        view.addSubview(sliderLabel)

        UIHelper.configureButton(resetButton, title: "Reset", font: UIFont.systemFont(ofSize: 16, weight: .bold), backgroundColor: .darkGray, textColor: .white, cornerRadius: 5)
        view.addSubview(resetButton)

        UIHelper.configureTableView(tableView)
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
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            filterLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            filterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            filterLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            segmentedControl.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),

            searchBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            difficultySlider.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            difficultySlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            difficultySlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),

            sliderLabel.centerYAnchor.constraint(equalTo: difficultySlider.centerYAnchor),
            sliderLabel.leadingAnchor.constraint(equalTo: difficultySlider.trailingAnchor, constant: 10),

            resetButton.topAnchor.constraint(equalTo: difficultySlider.bottomAnchor, constant: 10),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            resetButton.widthAnchor.constraint(equalToConstant: 70),
            resetButton.heightAnchor.constraint(equalToConstant: 30),

            tableView.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func createSliderThumb(with color: UIColor) -> UIImage {
        let thumbSize = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(thumbSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: thumbSize))
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbImage ?? UIImage()
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
        searchBar.text = ""
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
        case 0:
            tempFilteredWorkouts = workouts.filter { $0.bandName.lowercased().contains(searchText) }
        case 1:
            tempFilteredWorkouts = workouts.filter { $0.genres.contains(where: { $0.lowercased().contains(searchText) }) }
        case 2:
            tempFilteredWorkouts = workouts.filter { $0.title.lowercased().contains(searchText) }
        default:
            tempFilteredWorkouts = workouts
        }

        filteredWorkouts = applyDifficultyFilter(to: tempFilteredWorkouts)
        tableView.reloadData()
    }

    private func applyDifficultyFilter(to workouts: [Workout]) -> [Workout] {
        guard let difficulty = selectedDifficulty else { return workouts }
        return workouts.filter { $0.difficulty == difficulty }
    }
    
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
        let selectedWorkout = filteredWorkouts[indexPath.row]
        let workoutDetailsVC = WorkoutDetailsViewController()
        workoutDetailsVC.workout = selectedWorkout
        workoutDetailsVC.delegate = self
        navigationController?.pushViewController(workoutDetailsVC, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterWorkouts()
    }
    
    func didUpdateWorkouts() {
        fetchAllWorkouts()
        delegate?.updateFilteredWorkouts(with: workouts)
    }
}
