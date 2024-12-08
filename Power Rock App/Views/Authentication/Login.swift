import UIKit
import FirebaseAuth
import FirebaseFirestore

/**
 `LoginViewController` handles user authentication. It provides a login form where users can enter their email and password. Upon successful login, the app navigates the user to either the Fan Home or Star Home view based on their user type.
 */
class LoginViewController: UIViewController, LoginViewDelegate {

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        setupLoginView()
        setupBackground()

        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(didTapLoginBackButton))
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupLoginView() {
        let loginView = LoginView()
        loginView.delegate = self
        loginView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginView)

        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalTo: view.topAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupBackground() {
        let backgroundImageView = UIImageView(image: UIImage(named: "Welcome_Background"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.6
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundImageView, at: 0)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc func didTapLoginBackButton() {
        if let navigationController = navigationController {
            if let rootVC = navigationController.viewControllers.first as? WelcomeViewController {
                navigationController.popToRootViewController(animated: true)
            } else {
                let welcomeVC = WelcomeViewController()
                navigationController.setViewControllers([welcomeVC], animated: false)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    func didTapLoginButton(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            showAlert(message: "Please fill in both fields.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(message: "Login failed. Please check your credentials.")
                return
            }

            guard let uid = authResult?.user.uid else {
                self.showAlert(message: "Unexpected error occurred. Please try again.")
                return
            }

            DataFetcher.fetchUserType(for: uid) { [weak self] userType, error in
                guard let self = self else { return }

                if let error = error {
                    self.showAlert(message: "Failed to fetch user details. Please try again.")
                    return
                }

                guard let userType = userType else {
                    self.showAlert(message: "Failed to identify user type. Please contact support.")
                    return
                }

                self.dismiss(animated: true) {
                    if userType == "Fan" {
                        self.navigateToFanHome()
                    } else if userType == "Star" {
                        self.navigateToStarHome()
                    } else {
                        self.showAlert(message: "Unknown user type.")
                    }
                }
            }
        }
    }

    private func navigateToFanHome() {
        let fanVC = FanHomeViewController()
        navigationController?.pushViewController(fanVC, animated: true)
    }

    private func navigateToStarHome() {
        let starHomeVC = StarHomeViewController()
        navigationController?.pushViewController(starHomeVC, animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

/**
 `LoginView` is a custom view for the login form, allowing users to input their email and password.
 */
class LoginView: UIView {

    weak var delegate: LoginViewDelegate?

    private let emailLabel = UILabel()
    private var emailTextField = UITextField()
    private let passwordLabel = UILabel()
    private var passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let noteLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupActions()
    }

    private func setupUI() {
        backgroundColor = .clear

        let defaultFont = UIFont.systemFont(ofSize: 16)

        UIHelper.configureLabel(
            emailLabel,
            text: "Enter your email:",
            font: defaultFont,
            textColor: .white
        )
        addSubview(emailLabel)

        emailTextField = UIHelper.createStyledTextField(
            placeholder: "Email",
            font: defaultFont
        )
        addSubview(emailTextField)

        UIHelper.configureLabel(
            passwordLabel,
            text: "Enter your password:",
            font: defaultFont,
            textColor: .white
        )
        addSubview(passwordLabel)

        passwordTextField = UIHelper.createStyledTextField(
            placeholder: "Password",
            font: defaultFont
        )
        passwordTextField.isSecureTextEntry = true
        addSubview(passwordTextField)

        UIHelper.configureButton(
            loginButton,
            title: "Login",
            font: defaultFont,
            backgroundColor: .white,
            textColor: .black
        )
        addSubview(loginButton)

        UIHelper.configureLabel(
            noteLabel,
            text: "Authentication for both user types Fan and Star only requires your email address and password, nothing else.",
            font: UIFont.systemFont(ofSize: 12),
            textColor: .white
        )
        noteLabel.numberOfLines = 0
        noteLabel.textAlignment = .center
        addSubview(noteLabel)
    }

    private func setupConstraints() {
        let padding: CGFloat = 16
        
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        noteLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            emailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            passwordLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 150),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            noteLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            noteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            noteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            noteLabel.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    }

    @objc private func didTapLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Error: All fields are required")
            return
        }
        delegate?.didTapLoginButton(email: email, password: password)
    }
}
