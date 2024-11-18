import UIKit

protocol FanHomeViewDelegate: AnyObject {
    func didTapFanLogout()
}

class FanHomeView: UIViewController {
    // MARK: - Delegate
    weak var delegate: FanHomeViewDelegate?

    // MARK: - UI Elements
    private let welcomeLabel = UILabel()

    var firstName: String?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupConstraints()
    }

    // MARK: - Navigation Bar Setup
    private func setupNavBar() {
        navigationItem.title = "Fan Home"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTapFanLogout))
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white

        // Welcome Label
        welcomeLabel.text = "Welcome, \(firstName ?? "Fan")!" // Use firstName
        welcomeLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        welcomeLabel.textAlignment = .center
        view.addSubview(welcomeLabel)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func didTapFanLogout() {
        delegate?.didTapFanLogout() // Notify the delegate about logout
    }
}
