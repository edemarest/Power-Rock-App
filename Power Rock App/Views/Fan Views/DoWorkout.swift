import UIKit

/**
 `DoWorkoutViewController` Handles the user's workout session, tracking progress, updating power points, and managing UI interactions.
 */
class DoWorkoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SetCellDelegate {

    // MARK: - Properties
    var workout: Workout?
    private var remainingSets: [WorkoutSet] = []
    private var completedSets = 0
    private var powerPointsEarned = 0
    private var originalSetIndices: [Int] = []

    // MARK: - UI Elements
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let tableView = UITableView()
    private let finishButton = UIBarButtonItem(title: "Finish", style: .plain, target: nil, action: nil)
    private let congratulatoryLabel = UILabel()
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Welcome_Background"))
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let blackOverlayView: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = .black
        overlay.translatesAutoresizingMaskIntoConstraints = false
        return overlay
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackgroundWithOverlay()
        view.backgroundColor = .black
        setupNavigationBar()
        setupUI()
        setupData()
        ensurePowerPointsInitialized()
    }

    // MARK: - Setup UI
    private func addBackgroundWithOverlay() {
        view.addSubview(backgroundImageView)
        view.addSubview(blackOverlayView)
        view.sendSubviewToBack(backgroundImageView)
        view.sendSubviewToBack(blackOverlayView)

        NSLayoutConstraint.activate([
            blackOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            blackOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blackOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blackOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.title = workout?.title ?? "Workout"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismissView))
        finishButton.target = self
        finishButton.action = #selector(finishWorkout)
        finishButton.isEnabled = false
        navigationItem.rightBarButtonItem = finishButton
    }

    private func setupUI() {
        progressBar.progress = 0
        progressBar.trackTintColor = .darkGray
        progressBar.progressTintColor = UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1.0)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressBar.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        tableView.register(SetCell.self, forCellReuseIdentifier: "SetCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        congratulatoryLabel.text = "You finished all the sets in \(workout?.title ?? "this workout")! Hit the finish button in the top right to complete it and gain power!"
        congratulatoryLabel.font = UIFont.boldSystemFont(ofSize: 18)
        congratulatoryLabel.textColor = .white
        congratulatoryLabel.textAlignment = .center
        congratulatoryLabel.numberOfLines = 0
        congratulatoryLabel.isHidden = true
        congratulatoryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(congratulatoryLabel)
        
        NSLayoutConstraint.activate([
            congratulatoryLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            congratulatoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            congratulatoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupData() {
        guard let workout = workout else { return }
        remainingSets = workout.sets.map { WorkoutSet(exercises: $0.exercises) }
        originalSetIndices = Array(1...remainingSets.count)
        powerPointsEarned = (workout.difficulty ?? 1) * 100
        updateProgressBar()
    }

    private func updateProgressBar() {
        let totalSets = workout?.sets.count ?? 1
        progressBar.progress = Float(completedSets) / Float(totalSets)
        finishButton.isEnabled = completedSets == totalSets
        
        if finishButton.isEnabled {
            showCongratulatoryLabel()
        }
    }

    private func showCongratulatoryLabel() {
        tableView.isHidden = true
        congratulatoryLabel.isHidden = false
    }

    private func ensurePowerPointsInitialized() {
        DataFetcher.ensurePowerPointsForFan { error in
            if let error = error {
                print("Error initializing power points: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Actions
    @objc private func dismissView() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func finishWorkout() {
        DataFetcher.updateUserPowerPoints(by: powerPointsEarned) { [weak self] error in
            if let error = error {
                print("Error updating power points: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self?.navigateBackToHome()
            }
        }
    }

    private func navigateBackToHome() {
        guard let navigationController = navigationController else { return }
        
        for viewController in navigationController.viewControllers {
            if let fanHomeVC = viewController as? FanHomeViewController {
                fanHomeVC.refreshPowerPoints()
                navigationController.popToViewController(fanHomeVC, animated: true)
                return
            }
        }
        
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remainingSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetCell", for: indexPath) as? SetCell else {
            return UITableViewCell()
        }
        let set = remainingSets[indexPath.row]
        let originalIndex = originalSetIndices[indexPath.row]
        cell.configure(with: set, setIndex: originalIndex)
        cell.delegate = self
        return cell
    }
    
    func didCompleteSet(_ set: WorkoutSet) {
        if let index = remainingSets.firstIndex(where: { $0 === set }) {
            remainingSets.remove(at: index)
            originalSetIndices.remove(at: index)
            completedSets += 1

            tableView.reloadData()
            updateProgressBar()
        }
    }
}
