import UIKit

// MARK: - WelcomeViewDelegate
// Protocol defining methods for WelcomeView button interactions
protocol WelcomeViewDelegate: AnyObject {
    func didTapFanButton()
    func didTapStarButton()
    func didTapLoginButtonFromWelcome()
}

// MARK: - WelcomeViewController
// ViewController for managing the welcome screen and button actions
class WelcomeViewController: UIViewController, WelcomeViewDelegate {

    // MARK: - UI Properties
    private let welcomeView = WelcomeView()

    // MARK: - Lifecycle
    // Set up the view when the controller is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWelcomeView()
        self.navigationItem.hidesBackButton = true
    }

    // Set up the welcome view and add it to the view hierarchy
    private func setupWelcomeView() {
        welcomeView.delegate = self
        welcomeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeView)
        NSLayoutConstraint.activate([
            welcomeView.topAnchor.constraint(equalTo: view.topAnchor),
            welcomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            welcomeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            welcomeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - WelcomeViewDelegate
    // Navigate to Fan Registration screen
    func didTapFanButton() {
        let fanRegisterVC = FanRegisterViewController()
        navigationController?.pushViewController(fanRegisterVC, animated: true)
    }

    // Navigate to Star Registration screen
    func didTapStarButton() {
        let starRegisterVC = StarRegisterViewController()
        navigationController?.pushViewController(starRegisterVC, animated: true)
    }

    // Navigate to Login screen
    func didTapLoginButtonFromWelcome() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
}

// MARK: - WelcomeView
// Custom view for displaying the welcome screen UI elements
class WelcomeView: UIView {

    // MARK: - UI Elements
    let welcomeLabel = UILabel()
    let powerRockLabel = UILabel()
    let iconImageView = UIImageView()
    let getStartedLabel = UILabel()
    let areYouLabel = UILabel()
    let fanButton = UIButton(type: .system)
    let starButton = UIButton(type: .system)
    let alreadyHaveAccountLabel = UILabel()
    let loginButton = UIButton(type: .system)

    weak var delegate: WelcomeViewDelegate?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
        setupConstraints()
        setupActions()
        backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUIElements()
        setupConstraints()
        setupActions()
    }

    // MARK: - UI Setup
    // Initialize and set up UI elements
    private func setupUIElements() {
        // Welcome Label
        welcomeLabel.text = "Welcome to"
        welcomeLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        welcomeLabel.textAlignment = .center
        welcomeLabel.textColor = .white
        addSubview(welcomeLabel)

        // POWER ROCK Label
        powerRockLabel.text = "POWER ROCK"
        powerRockLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        powerRockLabel.textAlignment = .center
        powerRockLabel.textColor = .white
        addSubview(powerRockLabel)

        // Icon Image (Logo)
        iconImageView.image = UIImage(named: "Logo")
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)

        // Get Started Label
        getStartedLabel.text = "Let’s get started!"
        getStartedLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        getStartedLabel.textAlignment = .center
        getStartedLabel.textColor = .white
        addSubview(getStartedLabel)

        // Are you a...? Label
        areYouLabel.text = "Are you a..."
        areYouLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        areYouLabel.textAlignment = .center
        areYouLabel.textColor = .white
        addSubview(areYouLabel)

        // Fan Button
        fanButton.setTitle("FAN", for: .normal)
        fanButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        fanButton.setTitleColor(.black, for: .normal)
        fanButton.backgroundColor = .white
        fanButton.layer.cornerRadius = 10
        fanButton.layer.masksToBounds = true
        addSubview(fanButton)

        // Star Button
        starButton.setTitle("STAR", for: .normal)
        starButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        starButton.setTitleColor(.black, for: .normal)
        starButton.backgroundColor = .white
        starButton.layer.cornerRadius = 10
        starButton.layer.masksToBounds = true
        addSubview(starButton)

        // Already have an account? Label
        alreadyHaveAccountLabel.text = "Already have an account?"
        alreadyHaveAccountLabel.font = UIFont.systemFont(ofSize: 16)
        alreadyHaveAccountLabel.textAlignment = .center
        alreadyHaveAccountLabel.textColor = .white
        addSubview(alreadyHaveAccountLabel)

        // Login Button
        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.cornerRadius = 10
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        addSubview(loginButton)
    }

    // MARK: - Constraints
    // Set up Auto Layout constraints for UI elements
    private func setupConstraints() {
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        powerRockLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        getStartedLabel.translatesAutoresizingMaskIntoConstraints = false
        areYouLabel.translatesAutoresizingMaskIntoConstraints = false
        fanButton.translatesAutoresizingMaskIntoConstraints = false
        starButton.translatesAutoresizingMaskIntoConstraints = false
        alreadyHaveAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            powerRockLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 10),
            powerRockLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            iconImageView.topAnchor.constraint(equalTo: powerRockLabel.bottomAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 150),
            iconImageView.heightAnchor.constraint(equalToConstant: 150),

            getStartedLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            getStartedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            areYouLabel.topAnchor.constraint(equalTo: getStartedLabel.bottomAnchor, constant: 30),
            areYouLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            fanButton.topAnchor.constraint(equalTo: areYouLabel.bottomAnchor, constant: 20),
            fanButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            fanButton.widthAnchor.constraint(equalToConstant: 120),
            fanButton.heightAnchor.constraint(equalToConstant: 50),

            starButton.topAnchor.constraint(equalTo: areYouLabel.bottomAnchor, constant: 20),
            starButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            starButton.widthAnchor.constraint(equalToConstant: 120),
            starButton.heightAnchor.constraint(equalToConstant: 50),

            alreadyHaveAccountLabel.topAnchor.constraint(equalTo: fanButton.bottomAnchor, constant: 30),
            alreadyHaveAccountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            loginButton.topAnchor.constraint(equalTo: alreadyHaveAccountLabel.bottomAnchor, constant: 10),
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    // MARK: - Actions
    // Set up actions for button taps
    private func setupActions() {
        fanButton.addTarget(self, action: #selector(didTapFan), for: .touchUpInside)
        starButton.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLoginButtonFromWelcome), for: .touchUpInside)
    }

    // MARK: - Button Actions
    // Action for tapping the Fan button
    @objc private func didTapFan() {
        delegate?.didTapFanButton()
    }

    // Action for tapping the Star button
    @objc private func didTapStar() {
        delegate?.didTapStarButton()
    }

    // Action for tapping the Login button
    @objc private func didTapLoginButtonFromWelcome() {
        delegate?.didTapLoginButtonFromWelcome()
    }
}
