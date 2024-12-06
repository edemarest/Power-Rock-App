import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - FanRegisterViewDelegate Protocol
protocol FanRegisterViewDelegate: AnyObject {
    func didTapFanBackButton()
    func didTapFanRegisterButton(firstName: String, email: String, password: String, genres: [String])
}

// MARK: - FanRegisterViewController
class FanRegisterViewController: UIViewController, FanRegisterViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register as a Fan"
        setupNavbar()
        setupBackground()
        setupFanRegisterView()
    }

    // Set up the navigation bar
    private func setupNavbar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }

    // Set up the background
    private func setupBackground() {
        let baseView = UIView()
        baseView.backgroundColor = .black
        baseView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(baseView)

        let backgroundImageView = UIImageView(image: UIImage(named: "Background_1"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.6
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)

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

    // Set up the Fan registration view
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

    // Handle back button tap
    func didTapFanBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // Handle register button tap
    func didTapFanRegisterButton(firstName: String, email: String, password: String, genres: [String]) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(message: "Registration failed. Please try again.")
                return
            }

            guard let uid = authResult?.user.uid else {
                self.showAlert(message: "Unexpected error occurred. Please try again.")
                return
            }

            self.saveUserData(uid: uid, firstName: firstName, genres: genres)
        }
    }

    // Save user data
    private func saveUserData(uid: String, firstName: String, genres: [String]) {
        let userData: [String: Any] = [
            "userType": "Fan",
            "firstName": firstName,
            "genres": genres
        ]

        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            if let error = error {
                self.showAlert(message: "Failed to save user data. Please try again.")
                return
            }
            self.navigateToFanHome()
        }
    }

    // Show alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Navigate to home screen
    private func navigateToFanHome() {
        let fanHomeVC = FanHomeViewController()
        navigationController?.pushViewController(fanHomeVC, animated: true)
    }
}

// MARK: - FanRegisterView
class FanRegisterView: UIView {

    private let nameLabel = UILabel()
    private let nameTextField = UITextField()
    private let genresLabel = UILabel()
    private let genresTextField = UITextField()
    private let addGenreButton = UIButton(type: .system)
    private let genresContainer = UIStackView()
    private let emailLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordLabel = UILabel()
    private let passwordTextField = UITextField()
    private let registerButton = UIButton(type: .system)
    private var genresArray: [String] = []

    weak var delegate: FanRegisterViewDelegate?

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

    // Set up UI elements
    private func setupUIElements() {
        backgroundColor = .clear

        let edgyFont = UIFont(name: "Chalkduster", size: 16) ?? UIFont.systemFont(ofSize: 16)

        // Name Label and TextField
        UIHelper.configureLabel(nameLabel, text: "Name", font: edgyFont)
        addSubview(nameLabel)

        UIHelper.configureTextField(nameTextField, placeholder: "Enter your name", font: edgyFont)
        addSubview(nameTextField)

        // Genres Label, TextField, and Add Genre Button
        UIHelper.configureLabel(genresLabel, text: "Genres", font: edgyFont)
        addSubview(genresLabel)

        UIHelper.configureTextField(genresTextField, placeholder: "Enter genre", font: edgyFont)
        addSubview(genresTextField)

        UIHelper.configureButton(addGenreButton, title: "+", font: edgyFont)
        addSubview(addGenreButton)

        genresContainer.axis = .vertical
        genresContainer.spacing = 8
        addSubview(genresContainer)

        // Email Label and TextField
        UIHelper.configureLabel(emailLabel, text: "Email", font: edgyFont)
        addSubview(emailLabel)

        UIHelper.configureTextField(emailTextField, placeholder: "Enter email", font: edgyFont)
        addSubview(emailTextField)

        // Password Label and TextField
        UIHelper.configureLabel(passwordLabel, text: "Password", font: edgyFont)
        addSubview(passwordLabel)

        UIHelper.configureTextField(passwordTextField, placeholder: "Enter password", font: edgyFont)
        passwordTextField.isSecureTextEntry = true
        addSubview(passwordTextField)

        // Register Button
        UIHelper.configureButton(registerButton, title: "Register", font: UIFont.systemFont(ofSize: 16))
        addSubview(registerButton)
    }


    // Set up constraints
    private func setupConstraints() {
        let subviews = [
            nameLabel, nameTextField,
            genresLabel, genresTextField, addGenreButton, genresContainer,
            emailLabel, emailTextField, passwordLabel, passwordTextField, registerButton
        ]
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            // Name Label and TextField
            nameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),

            // Genres Label, TextField, and Add Genre Button
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

            // Email Label and TextField
            emailLabel.topAnchor.constraint(equalTo: genresContainer.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),

            // Password Label and TextField
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

    // Set up actions
    private func setupActions() {
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        addGenreButton.addTarget(self, action: #selector(didTapAddGenre), for: .touchUpInside)
    }

    // Handle register button tap
    @objc private func didTapRegister() {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = emailTextField.text else { return }
        delegate?.didTapFanRegisterButton(firstName: name, email: email, password: password, genres: genresArray)
    }

    @objc private func didTapAddGenre() {
        guard let genre = genresTextField.text, !genre.isEmpty else { return }
        
        // Add the genre to the array
        genresArray.append(genre)
        genresTextField.text = ""

        // Create a genre tag using UIHelper
        let genreTag = UIHelper.createTagLabel(
            with: genre,
            font: UIFont.systemFont(ofSize: 14),
            backgroundColor: .white,
            textColor: .black,
            cornerRadius: 8,
            target: self,
            action: #selector(didTapRemoveGenre(_:))
        )
        
        // Add the tag to the genresContainer stack view
        genresContainer.addArrangedSubview(genreTag)
    }

    @objc private func didTapRemoveGenre(_ sender: UIButton) {
        // Find the container view of the sender button
        guard let genreContainer = sender.superview else { return }

        // Remove the genre from the array
        if let label = genreContainer.subviews.first(where: { $0 is UILabel }) as? UILabel,
           let genreText = label.text,
           let index = genresArray.firstIndex(of: genreText) {
            genresArray.remove(at: index)
        }

        // Remove the corresponding UI element
        genresContainer.removeArrangedSubview(genreContainer)
        genreContainer.removeFromSuperview()
    }
}
