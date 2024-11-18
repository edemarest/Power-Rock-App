import UIKit

protocol StarHomeViewDelegate: AnyObject {
    func didTapLogout()
    func didTapAddWorkout()
}

class StarHomeView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Delegate
    weak var delegate: StarHomeViewDelegate?

    // MARK: - UI Elements
    let tableView = UITableView()
    let fanPowerLabel = UILabel()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupConstraints()
    }

    // MARK: - Navigation Bar Setup
    private func setupNavBar() {
        navigationItem.title = "Band Name" // Replace with the actual band name later
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTapLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white

        // TableView Setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)

        // Fan Power Section
        fanPowerLabel.text = "🔥 Fan Power"
        fanPowerLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        fanPowerLabel.textAlignment = .center
        fanPowerLabel.backgroundColor = .lightGray.withAlphaComponent(0.2)
        view.addSubview(fanPowerLabel)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        fanPowerLabel.translatesAutoresizingMaskIntoConstraints = false

        let fanPowerHeight: CGFloat = view.bounds.height / 6

        NSLayoutConstraint.activate([
            // TableView Constraints
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: fanPowerLabel.topAnchor),

            // Fan Power Section Constraints
            fanPowerLabel.heightAnchor.constraint(equalToConstant: fanPowerHeight),
            fanPowerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fanPowerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fanPowerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 // Empty tableView for now
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }

    // MARK: - Actions
    @objc private func didTapLogout() {
        delegate?.didTapLogout() // Notify the delegate about logout
    }

    @objc private func didTapAdd() {
        delegate?.didTapAddWorkout() // Notify the delegate to navigate to CreateWorkoutView
    }
}
