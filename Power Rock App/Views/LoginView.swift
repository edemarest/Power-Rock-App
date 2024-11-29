import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - Protocol
// Protocol to handle login button and back button actions
protocol LoginViewDelegate: AnyObject {
    func didTapLoginBackButton()
    func didTapLoginButton(email: String, password: String)
}

// MARK: - LoginViewController
// ViewController for handling login functionality and navigating based on user type
class LoginViewController: UIViewController, LoginViewDelegate {

    let db = Firestore.firestore()

    // MARK: - Properties
    var userTitle: String?

    // MARK: - View Lifecycle
    // Set up view elements and navigation when the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        setupLoginView()
        navigationItem.hidesBackButton = true

        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(didTapLoginBackButton))
        navigationItem.leftBarButtonItem = backButton
    }

    // MARK: - Setup Methods
    // Set up the login view and add it to the view hierarchy
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

    // MARK: - LoginViewDelegate Methods
    // Handle the back button tap
    @objc func didTapLoginBackButton() {
        let welcomeVC = WelcomeViewController()
        navigationController?.pushViewController(welcomeVC, animated: true)
    }

    // Handle the login button tap, perform authentication and navigate accordingly
    func didTapLoginButton(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            showAlert(message: "Please fill in both fields.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                self.showAlert(message: "Login failed. Please check your credentials.")
                return
            }

            guard let uid = authResult?.user.uid else {
                print("Error: User ID not found after login.")
                self.showAlert(message: "Unexpected error occurred. Please try again.")
                return
            }

            self.db.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching user details: \(error.localizedDescription)")
                    self.showAlert(message: "Failed to fetch user details. Please try again.")
                    return
                }

                guard let data = snapshot?.data(), let userType = data["userType"] as? String else {
                    print("User data missing or malformed.")
                    self.showAlert(message: "Failed to identify user type. Please contact support.")
                    return
                }

                if userType == "Star", let bandName = data["bandName"] as? String {
                    self.userTitle = bandName
                } else if let firstName = data["firstName"] as? String {
                    self.userTitle = firstName
                }

                self.dismiss(animated: true) {
                    if userType == "Fan" {
                        self.navigateToFanHome()
                    } else if userType == "Star" {
                        self.navigateToStarHome()
                    } else {
                        print("Unknown userType: \(userType)")
                        self.showAlert(message: "Unknown user type.")
                    }
                }
            }
        }
    }

    // MARK: - Navigation Methods
    // Navigate to the Fan home screen
    private func navigateToFanHome() {
        let fanVC = FanHomeViewController()
        navigationController?.pushViewController(fanVC, animated: true)
    }

    // Navigate to the Star home screen
    private func navigateToStarHome() {
        let starHomeVC = StarHomeViewController()
        navigationController?.pushViewController(starHomeVC, animated: true)
    }

    // MARK: - Helper Methods
    // Display an alert with a message
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - LoginView
// Custom view for displaying the login form
class LoginView: UIView {

    // MARK: - Delegate
    weak var delegate: LoginViewDelegate?

    // MARK: - UI Elements
    private let emailLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordLabel = UILabel()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)

    // MARK: - Initialization
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

    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .white
        
        // Email Label and TextField
        emailLabel.text = "Enter your email:"
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(emailLabel)
        
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        addSubview(emailTextField)
        
        // Password Label and TextField
        passwordLabel.text = "Enter your password:"
        passwordLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(passwordLabel)
        
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        addSubview(passwordTextField)
        
        // Login Button
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.layer.cornerRadius = 10
        addSubview(loginButton)
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        let padding: CGFloat = 16
        
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Email Section
            emailLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Password Section
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 5),
            passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Login Button
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 150),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Setup Actions
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    }

    // MARK: - Actions
    // Handle the login button tap
    @objc private func didTapLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Error: All fields are required")
            return
        }
        delegate?.didTapLoginButton(email: email, password: password)
    }
}
