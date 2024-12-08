import UIKit
import FirebaseAuth
import FirebaseFirestore

/**
 `FanRegisterViewController` Handles fan registration flow, including user validation, Firebase registration, and navigation.
 */
class FanRegisterViewController: UIViewController, FanRegisterViewDelegate {

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register as a Fan"
        setupBackground()
        setupFanRegisterView()
    }

    // MARK: - Setup Methods
    private func setupBackground() {
        let backgroundImageView = UIImageView(image: UIImage(named: "Background_1"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

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
    func didTapFanBackButton() {
        navigationController?.popViewController(animated: true)
    }

    func didTapFanRegisterButton(firstName: String, email: String, password: String, genres: [String]) {
        guard validateFields(firstName: firstName, email: email, password: password, genres: genres) else {
            return
        }

        // Firebase registration
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .emailAlreadyInUse:
                    self.showAlert(title: "Registration Failed", message: "The email address is already in use.")
                case .invalidEmail:
                    self.showAlert(title: "Registration Failed", message: "The email address is invalid.")
                default:
                    self.showAlert(title: "Registration Failed", message: "An unexpected error occurred: \(error.localizedDescription)")
                }
                return
            }

            guard let uid = authResult?.user.uid else {
                self.showAlert(title: "Error", message: "Unexpected error occurred. Please try again.")
                return
            }

            self.saveUserData(uid: uid, firstName: firstName, genres: genres)
        }
    }

    private func saveUserData(uid: String, firstName: String, genres: [String]) {
        let userData: [String: Any] = [
            "userType": "Fan",
            "firstName": firstName,
            "genres": genres
        ]

        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to save user data. Please try again.")
                return
            }

            DataFetcher.addInitialWorkoutsToMyWorkouts(uid: uid, genres: genres) { error in
                if let error = error {
                    print("Error adding initial workouts: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to initialize workouts. Please try again.")
                    return
                }

                self.navigateToFanHome()
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func navigateToFanHome() {
        let fanHomeVC = FanHomeViewController()
        navigationController?.pushViewController(fanHomeVC, animated: true)
    }

    private func validateFields(firstName: String, email: String, password: String, genres: [String]) -> Bool {
        if firstName.isEmpty {
            showAlert(title: "Missing Information", message: "Please enter your name.")
            return false
        }
        if email.isEmpty {
            showAlert(title: "Missing Information", message: "Please enter your email.")
            return false
        }
        if password.isEmpty {
            showAlert(title: "Missing Information", message: "Please enter your password.")
            return false
        }
        if genres.isEmpty {
            showAlert(title: "Missing Information", message: "Please add at least one genre.")
            return false
        }
        return true
    }
}

// MARK: - FanRegisterView
/// Handles the UI for fan registration, including name, email, password, and genres input.
class FanRegisterView: UIView {

    // MARK: - UI Elements
    private let nameLabel = UILabel()
    private lazy var nameTextField: UITextField = {
        UIHelper.createStyledTextField(placeholder: "Enter your name")
    }()
    
    private let genresLabel = UILabel()
    private lazy var genresTextField: UITextField = {
        UIHelper.createStyledTextField(placeholder: "Enter genre")
    }()
    private let addGenreButton = UIButton(type: .system)
    private let genresContainer = UIStackView()
    
    private let emailLabel = UILabel()
    private lazy var emailTextField: UITextField = {
        UIHelper.createStyledTextField(placeholder: "Enter email")
    }()
    
    private let passwordLabel = UILabel()
    private lazy var passwordTextField: UITextField = {
        let textField = UIHelper.createStyledTextField(placeholder: "Enter password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let registerButton = UIButton(type: .system)
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
        backgroundColor = .clear

        let defaultFont = UIFont.systemFont(ofSize: 16)

        // Configure labels and text fields
        UIHelper.configureLabel(nameLabel, text: "Name", font: defaultFont)
        addSubview(nameLabel)
        addSubview(nameTextField)

        UIHelper.configureLabel(genresLabel, text: "Genres", font: defaultFont)
        addSubview(genresLabel)
        addSubview(genresTextField)

        // Configure buttons
        UIHelper.configureButton(addGenreButton, title: "+", font: defaultFont)
        addSubview(addGenreButton)
        
        genresContainer.axis = .horizontal
        genresContainer.alignment = .leading
        genresContainer.distribution = .fillProportionally
        genresContainer.spacing = 8
        addSubview(genresContainer)

        UIHelper.configureLabel(emailLabel, text: "Email", font: defaultFont)
        addSubview(emailLabel)
        addSubview(emailTextField)

        UIHelper.configureLabel(passwordLabel, text: "Password", font: defaultFont)
        addSubview(passwordLabel)
        addSubview(passwordTextField)

        UIHelper.configureButton(registerButton, title: "Register", font: defaultFont)
        addSubview(registerButton)
    }

    private func setupConstraints() {
        let subviews = [
            nameLabel, nameTextField,
            genresLabel, genresTextField, addGenreButton, genresContainer,
            emailLabel, emailTextField, passwordLabel, passwordTextField, registerButton
        ]
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            genresLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            genresLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            genresTextField.topAnchor.constraint(equalTo: genresLabel.bottomAnchor, constant: 5),
            genresTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            genresTextField.trailingAnchor.constraint(equalTo: addGenreButton.leadingAnchor, constant: -10),
            genresTextField.heightAnchor.constraint(equalToConstant: 40),
            
            addGenreButton.centerYAnchor.constraint(equalTo: genresTextField.centerYAnchor),
            addGenreButton.widthAnchor.constraint(equalToConstant: 40),
            addGenreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            genresContainer.topAnchor.constraint(equalTo: genresTextField.bottomAnchor, constant: 5),
            genresContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            genresContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            genresContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            emailLabel.topAnchor.constraint(equalTo: genresContainer.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 5),
            passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            registerButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            registerButton.widthAnchor.constraint(equalToConstant: 150),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupActions() {
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        addGenreButton.addTarget(self, action: #selector(didTapAddGenre), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func didTapRegister() {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        delegate?.didTapFanRegisterButton(firstName: name, email: email, password: password, genres: genresArray)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    @objc private func didTapAddGenre() {
        guard let genre = genresTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !genre.isEmpty else {
            return
        }

        // Character limit check
        guard genre.count <= 10 else {
            showAlert(title: "Input Too Long", message: "Genres cannot exceed 10 characters.")
            return
        }

        // Limit to 3 genres
        guard genresArray.count < 3 else {
            showAlert(title: "Limit Reached", message: "You can only add up to 3 genres.")
            return
        }

        genresArray.append(genre)
        genresTextField.text = ""

        let genreTag = UIHelper.createTagLabel(
            with: genre,
            font: UIFont.systemFont(ofSize: 14),
            backgroundColor: .white,
            textColor: .black,
            cornerRadius: 10,
            target: self,
            action: #selector(didTapRemoveGenre(_:))
        )
        genresContainer.addArrangedSubview(genreTag)
        genresContainer.layoutIfNeeded()
    }

    @objc private func didTapRemoveGenre(_ sender: UIButton) {
        guard let genreContainer = sender.superview else { return }
        if let label = genreContainer.subviews.first(where: { $0 is UILabel }) as? UILabel,
           let genreText = label.text,
           let index = genresArray.firstIndex(of: genreText) {
            genresArray.remove(at: index)
        }
        genresContainer.removeArrangedSubview(genreContainer)
        genreContainer.removeFromSuperview()
        genresContainer.setNeedsLayout()
        genresContainer.layoutIfNeeded()
    }
}
