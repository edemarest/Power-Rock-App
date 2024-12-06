import UIKit

// MARK: - WelcomeViewDelegate
// Protocol defining methods for WelcomeView button interactions
protocol WelcomeViewDelegate: AnyObject {
    func didTapFanButton()
    func didTapStarButton()
    func didTapLoginButtonFromWelcome()
}

// MARK: - WelcomeViewController
class WelcomeViewController: UIViewController, WelcomeViewDelegate {

    private let welcomeView = WelcomeView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWelcomeView()
        setupBackground()
        navigationItem.hidesBackButton = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make the navigation bar transparent
        navigationController?.setNavigationBarHidden(false, animated: false)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset the navigation bar to black
        navigationController?.setNavigationBarHidden(false, animated: false)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black // Set the background color to black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Set the title color to white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }

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

    private func setupBackground() {
        let baseView = UIView()
        baseView.backgroundColor = .black
        baseView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(baseView, at: 0)

        let backgroundImageView = UIImageView(image: UIImage(named: "Welcome_Background"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.6
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundImageView, aboveSubview: baseView)

        NSLayoutConstraint.activate([
            baseView.topAnchor.constraint(equalTo: view.topAnchor),
            baseView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            baseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func didTapFanButton() {
        let fanRegisterVC = FanRegisterViewController()
        navigationController?.pushViewController(fanRegisterVC, animated: true)
    }

    func didTapStarButton() {
        let starRegisterVC = StarRegisterViewController()
        navigationController?.pushViewController(starRegisterVC, animated: true)
    }

    func didTapLoginButtonFromWelcome() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
}


class WelcomeView: UIView {

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUIElements()
        setupConstraints()
        setupActions()
    }
    
    private func setupUIElements() {
        backgroundColor = .clear

        // Welcome Label
        UIHelper.configureLabel(welcomeLabel, text: "Welcome to", font: UIFont.systemFont(ofSize: 24, weight: .medium))
        addSubview(welcomeLabel)

        // POWER ROCK Label
        UIHelper.configureLabel(powerRockLabel, text: "POWER ROCK", font: UIFont.systemFont(ofSize: 48, weight: .bold))
        addSubview(powerRockLabel)

        // Icon Image
        iconImageView.image = UIImage(named: "Logo")
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)

        // Get Started Label
        UIHelper.configureLabel(getStartedLabel, text: "Let’s get started!", font: UIFont.systemFont(ofSize: 18, weight: .regular))
        addSubview(getStartedLabel)

        // Are You Label
        UIHelper.configureLabel(areYouLabel, text: "Are you a...", font: UIFont.systemFont(ofSize: 22, weight: .bold))
        addSubview(areYouLabel)

        // Fan Button
        UIHelper.configureButtonWithIcon(
            fanButton,
            title: "FAN",
            font: UIFont.boldSystemFont(ofSize: 20),
            iconName: "Fan_Icon",
            backgroundColor: .white,
            textColor: .black,
            cornerRadius: 10
        )
        addSubview(fanButton) // Add fanButton to view hierarchy

        // Star Button
        UIHelper.configureButtonWithIcon(
            starButton,
            title: "STAR",
            font: UIFont.boldSystemFont(ofSize: 20),
            iconName: "Star_Icon",
            backgroundColor: .white,
            textColor: .black,
            cornerRadius: 10
        )
        addSubview(starButton) // Add starButton to view hierarchy

        // Already Have Account Label
        UIHelper.configureLabel(alreadyHaveAccountLabel, text: "Already have an account?", font: UIFont.systemFont(ofSize: 16))
        addSubview(alreadyHaveAccountLabel)

        // Login Button
        UIHelper.configureButton(
            loginButton,
            title: "Login",
            font: UIFont.systemFont(ofSize: 16),
            backgroundColor: .clear,
            textColor: .white,
            cornerRadius: 10
        )
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        addSubview(loginButton)
    }


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
            fanButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -10),
            fanButton.heightAnchor.constraint(equalToConstant: 50),

            // Star Button
            starButton.topAnchor.constraint(equalTo: areYouLabel.bottomAnchor, constant: 20),
            starButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 10),
            starButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            starButton.heightAnchor.constraint(equalToConstant: 50),

            alreadyHaveAccountLabel.topAnchor.constraint(equalTo: fanButton.bottomAnchor, constant: 30),
            alreadyHaveAccountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            loginButton.topAnchor.constraint(equalTo: alreadyHaveAccountLabel.bottomAnchor, constant: 10),
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func setupActions() {
        fanButton.addTarget(self, action: #selector(didTapFan), for: .touchUpInside)
        starButton.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLoginButtonFromWelcome), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    @objc private func didTapFan() {
        delegate?.didTapFanButton()
    }

    @objc private func didTapStar() {
        delegate?.didTapStarButton()
    }


    @objc private func didTapLoginButtonFromWelcome() {
        delegate?.didTapLoginButtonFromWelcome()
    }
}
