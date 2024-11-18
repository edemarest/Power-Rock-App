import UIKit

protocol WelcomeViewDelegate: AnyObject {
    func didTapFanButton()
    func didTapStarButton()
    func didTapLoginButtonFromWelcome()
}

class WelcomeView: UIView {

    // UI Elements
    let welcomeLabel = UILabel()
    let iconImageView = UIImageView()
    let getStartedLabel = UILabel()
    let fanButton = UIButton(type: .system)
    let starButton = UIButton(type: .system)
    let loginButton = UIButton(type: .system)

    weak var delegate: WelcomeViewDelegate?

    /*
     Function name: init(frame: CGRect)
     Parameter 1 (CGRect): frame - The initial frame for the WelcomeView.
     Return (WelcomeView): Initializes and returns a new WelcomeView instance.
     Brief explanation: Sets up the WelcomeView, including UI elements, constraints, and actions for buttons.
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
        setupConstraints()
        setupActions()
    }

    /*
     Function name: init?(coder: NSCoder)
     Parameter 1 (NSCoder): coder - A decoder object.
     Return (WelcomeView?): Returns an optional initialized WelcomeView.
     Brief explanation: Decodes and initializes the WelcomeView from a storyboard or xib.
    */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUIElements()
        setupConstraints()
        setupActions()
    }

    /*
     Function name: setupUIElements
     Purpose: Configures UI elements within the WelcomeView.
     - Return (Void): Sets text, images, and styles for labels and buttons.
     - Brief explanation: Customizes appearance for welcome and get started text, icon, and buttons.
    */
    private func setupUIElements() {
        // Welcome Label
        welcomeLabel.text = "Welcome to"
        welcomeLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        welcomeLabel.textAlignment = .center
        addSubview(welcomeLabel)

        // Icon Image
        iconImageView.image = UIImage(named: "dumbbellIcon") // replace with your image name
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)

        // Get Started Label
        getStartedLabel.text = "Let’s get started!"
        getStartedLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        getStartedLabel.textAlignment = .center
        addSubview(getStartedLabel)

        // Fan Button
        fanButton.setTitle("FAN", for: .normal)
        fanButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        addSubview(fanButton)

        // Star Button
        starButton.setTitle("STAR", for: .normal)
        starButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        addSubview(starButton)

        // Login Button
        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        addSubview(loginButton)
    }

    /*
     Function name: setupConstraints
     Purpose: Sets layout constraints for the WelcomeView UI elements.
     - Return (Void): Positions elements on the view.
     - Brief explanation: Uses Auto Layout to place labels, icon, and buttons appropriately.
    */
    private func setupConstraints() {
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        getStartedLabel.translatesAutoresizingMaskIntoConstraints = false
        fanButton.translatesAutoresizingMaskIntoConstraints = false
        starButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            iconImageView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 100),
            iconImageView.heightAnchor.constraint(equalToConstant: 100),

            getStartedLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            getStartedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            fanButton.bottomAnchor.constraint(equalTo: centerYAnchor, constant: 100),
            fanButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            fanButton.widthAnchor.constraint(equalToConstant: 100),
            fanButton.heightAnchor.constraint(equalToConstant: 50),

            starButton.bottomAnchor.constraint(equalTo: centerYAnchor, constant: 100),
            starButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            starButton.widthAnchor.constraint(equalToConstant: 100),
            starButton.heightAnchor.constraint(equalToConstant: 50),

            loginButton.topAnchor.constraint(equalTo: fanButton.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    /*
     Function name: setupActions
     Purpose: Sets up actions for fan, star, and login buttons.
     - Return (Void): Links buttons to their respective action methods.
     - Brief explanation: Adds target-action mechanism for button taps.
    */
    private func setupActions() {
        fanButton.addTarget(self, action: #selector(didTapFan), for: .touchUpInside)
        starButton.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLoginButtonFromWelcome), for: .touchUpInside)
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
