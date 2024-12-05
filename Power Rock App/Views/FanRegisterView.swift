import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - FanRegisterViewDelegate Protocol
// Protocol defining methods for Fan registration screen interactions
protocol FanRegisterViewDelegate: AnyObject {
    func didTapFanBackButton()
    func didTapFanRegisterButton(firstName: String, email: String, password: String, genres: [String])
}

// MARK: - FanRegisterViewController
// ViewController for managing Fan registration and interacting with Firebase
class FanRegisterViewController: UIViewController, FanRegisterViewDelegate {
    
    // Set up the view when the controller is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register as a Fan"
        setupFanRegisterView()
    }

    // Set up the Fan registration view and add it to the view hierarchy
    private func setupFanRegisterView() {
        let fanRegisterView = FanRegisterView()
        fanRegisterView.delegate = self
        fanRegisterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fanRegisterView)

        NSLayoutConstraint.activate([
            fanRegisterView.topAnchor.constraint(equalTo: view.topAnchor),
            fanRegisterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fanRegisterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fanRegisterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - FanRegisterViewDelegate Methods
    // Navigate back to the previous screen
    func didTapFanBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // Handle Fan registration with Firebase
    func didTapFanRegisterButton(firstName: String, email: String, password: String, genres: [String]) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                print("Error registering: \(error.localizedDescription)")
                self.showAlert(message: "Registration failed. Please try again.")
                return
            }

            guard let uid = authResult?.user.uid else {
                print("Error: User ID not found after registration.")
                self.showAlert(message: "Unexpected error occurred. Please try again.")
                return
            }

            // Save user data to Firestore
            self.saveUserData(uid: uid, firstName: firstName, genres: genres)
        }
    }

    // Save user data to Firestore
    private func saveUserData(uid: String, firstName: String, genres: [String]) {
        let userData: [String: Any] = [
            "userType": "Fan",
            "firstName": firstName,
            "genres": genres
        ]

        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
                self.showAlert(message: "Failed to save user data. Please try again.")
                return
            }

            print("Fan registration successful!")
            self.navigateToFanHome()
        }
    }

    // Show alert with a message
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Navigate to Fan home screen after successful registration
    private func navigateToFanHome() {
        let fanHomeVC = FanHomeViewController()
        navigationController?.pushViewController(fanHomeVC, animated: true)
    }
}

// MARK: - FanRegisterView
// Custom view for displaying the Fan registration form
// MARK: - Updated FanRegisterView
class FanRegisterView: UIView {

    // MARK: - UI Elements
    let nameLabel = UILabel()
    let nameTextField = UITextField()

    let genresLabel = UILabel()
    let genresTextField = UITextField()
    let addGenreButton = UIButton(type: .system)
    let genresContainer = UIStackView()

    let emailLabel = UILabel()
    let emailTextField = UITextField()

    let passwordLabel = UILabel()
    let passwordTextField = UITextField()

    let registerButton = UIButton(type: .system)

    private var genresArray: [String] = []

    weak var delegate: FanRegisterViewDelegate?

    // MARK: - Initializers
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

    // MARK: - UI Setup
    private func setupUIElements() {
        backgroundColor = .black

        // Apply common edgy font
        let edgyFont = UIFont(name: "Chalkduster", size: 16) ?? UIFont.systemFont(ofSize: 16)

        // Name Label and TextField
        nameLabel.text = "Name"
        nameLabel.font = edgyFont
        nameLabel.textColor = .white
        addSubview(nameLabel)

        nameTextField.placeholder = "Enter your name"
        nameTextField.borderStyle = .none
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.white.cgColor
        nameTextField.textColor = .white
        nameTextField.font = edgyFont
        addSubview(nameTextField)

        // Genres Label, TextField, and Add Genre Button
        genresLabel.text = "Genres:"
        genresLabel.font = edgyFont
        genresLabel.textColor = .white
        addSubview(genresLabel)

        genresTextField.placeholder = "Enter genre"
        genresTextField.borderStyle = .none
        genresTextField.layer.borderWidth = 1
        genresTextField.layer.borderColor = UIColor.white.cgColor
        genresTextField.textColor = .white
        genresTextField.font = edgyFont
        addSubview(genresTextField)

        addGenreButton.setTitle("+", for: .normal)
        addGenreButton.backgroundColor = .white
        addGenreButton.setTitleColor(.black, for: .normal)
        addGenreButton.layer.cornerRadius = 20
        addSubview(addGenreButton)

        genresContainer.axis = .vertical
        genresContainer.spacing = 8
        addSubview(genresContainer)

        // Email Label and TextField
        emailLabel.text = "Email"
        emailLabel.font = edgyFont
        emailLabel.textColor = .white
        addSubview(emailLabel)

        emailTextField.placeholder = "Enter email"
        emailTextField.borderStyle = .none
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.white.cgColor
        emailTextField.textColor = .white
        emailTextField.font = edgyFont
        addSubview(emailTextField)

        // Password Label and TextField
        passwordLabel.text = "Password"
        passwordLabel.font = edgyFont
        passwordLabel.textColor = .white
        addSubview(passwordLabel)

        passwordTextField.placeholder = "Enter password"
        passwordTextField.borderStyle = .none
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.white.cgColor
        passwordTextField.textColor = .white
        passwordTextField.font = edgyFont
        passwordTextField.isSecureTextEntry = true
        addSubview(passwordTextField)

        // Register Button
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = edgyFont
        registerButton.backgroundColor = .white
        registerButton.setTitleColor(.black, for: .normal)
        addSubview(registerButton)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        let subviews = [
            nameLabel, nameTextField,
            genresLabel, genresTextField, addGenreButton, genresContainer,
            emailLabel, emailTextField, passwordLabel, passwordTextField, registerButton
        ]
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            // Name
            nameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),

            // Genres
            genresLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            genresLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            genresTextField.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 5),
            genresTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            genresTextField.trailingAnchor.constraint(equalTo: addGenreButton.leadingAnchor, constant: -10),
            genresTextField.heightAnchor.constraint(equalToConstant: 40),

            addGenreButton.centerYAnchor.constraint(equalTo: genresTextField.centerYAnchor),
            addGenreButton.widthAnchor.constraint(equalToConstant: 40),
            addGenreButton.heightAnchor.constraint(equalToConstant: 40),
            addGenreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            genresContainer.topAnchor.constraint(equalTo: genresTextField.bottomAnchor, constant: 10),
            genresContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            genresContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            // Email
            emailLabel.topAnchor.constraint(equalTo: genresContainer.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),

            // Password
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 5),
            passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),

            // Register Button
            registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            registerButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            registerButton.widthAnchor.constraint(equalToConstant: 150),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        addGenreButton.addTarget(self, action: #selector(didTapAddGenre), for: .touchUpInside)
    }

    // MARK: - Button Actions
    // Handle the Register button tap
    @objc private func didTapRegister() {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        delegate?.didTapFanRegisterButton(firstName: name, email: email, password: password, genres: genresArray)
    }

    // Handle adding genre to the list
    @objc private func didTapAddGenre() {
        guard let genre = genresTextField.text, !genre.isEmpty else { return }

        // Add genre to the array
        genresArray.append(genre)

        // Create a label for the genre
        let genreLabel = UILabel()
        genreLabel.text = genre
        genreLabel.font = UIFont.systemFont(ofSize: 14)
        genreLabel.textColor = .black
        genreLabel.backgroundColor = .systemGray5
        genreLabel.layer.cornerRadius = 8
        genreLabel.clipsToBounds = true
        genreLabel.textAlignment = .center
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

        // Add the label to the genresContainer
        genresContainer.addArrangedSubview(genreLabel)

        // Clear the text field
        genresTextField.text = ""
    }
}
