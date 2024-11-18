import UIKit

protocol FanRegisterViewDelegate: AnyObject {
    func didTapFanBackButton()
    func didTapFanRegisterButton(firstName: String, email: String, password: String, genres: [String])
}

class FanRegisterView: UIView {

    // MARK: - UI Elements
    let backButton = UIButton(type: .system)
    let titleLabel = UILabel()

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

    // MARK: - Data Storage
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
        backgroundColor = .white

        // Back Button
        backButton.setTitle("Back", for: .normal)
        addSubview(backButton)

        // Title Label
        titleLabel.text = "Register as a Fan"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        // Name
        nameLabel.text = "Name"
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(nameLabel)

        nameTextField.placeholder = "Enter your name"
        nameTextField.borderStyle = .roundedRect
        addSubview(nameTextField)

        // Genres
        genresLabel.text = "Genres:"
        genresLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(genresLabel)

        genresTextField.placeholder = "Enter genre"
        genresTextField.borderStyle = .roundedRect
        addSubview(genresTextField)

        addGenreButton.setTitle("+", for: .normal)
        addGenreButton.backgroundColor = .systemBlue
        addGenreButton.setTitleColor(.white, for: .normal)
        addGenreButton.layer.cornerRadius = 20
        addSubview(addGenreButton)

        genresContainer.axis = .vertical
        genresContainer.spacing = 8
        addSubview(genresContainer)

        // Email
        emailLabel.text = "Email"
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(emailLabel)

        emailTextField.placeholder = "Enter email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        addSubview(emailTextField)

        // Password
        passwordLabel.text = "Password"
        passwordLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(passwordLabel)

        passwordTextField.placeholder = "Enter password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.spellCheckingType = .no
        addSubview(passwordTextField)

        // Register Button
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        registerButton.backgroundColor = .black
        registerButton.setTitleColor(.white, for: .normal)
        addSubview(registerButton)
    }

    private func setupConstraints() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false

        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        genresTextField.translatesAutoresizingMaskIntoConstraints = false
        addGenreButton.translatesAutoresizingMaskIntoConstraints = false
        genresContainer.translatesAutoresizingMaskIntoConstraints = false

        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false

        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false

        registerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Back Button and Title
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            // Name
            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
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

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        addGenreButton.addTarget(self, action: #selector(didTapAddGenre), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func didTapRegister() {
        guard validateFields() else { return }

        let name = nameTextField.text ?? "N/A"
        let email = emailTextField.text ?? "N/A"
        let password = passwordTextField.text ?? "N/A"

        print("""
        NAME: \(name)
        EMAIL: \(email)
        PASSWORD: \(password)
        GENRES: \(genresArray)
        """)

        delegate?.didTapFanRegisterButton(
            firstName: name,
            email: email,
            password: password,
            genres: genresArray
        )
    }

    @objc private func didTapBack() {
        delegate?.didTapFanBackButton()
    }

    @objc private func didTapAddGenre() {
        guard let genre = genresTextField.text, !genre.isEmpty else { return }
        genresArray.append(genre)

        let tagView = createTagView(for: genre, in: &genresArray, container: genresContainer)
        genresContainer.addArrangedSubview(tagView)
        genresTextField.text = ""
    }

    private func validateFields() -> Bool {
        guard let email = emailTextField.text, isValidEmail(email) else {
            showAlert(message: "Please enter a valid email address.")
            return false
        }

        guard let password = passwordTextField.text, password.count >= 6 else {
            showAlert(message: "Password must be at least 6 characters long.")
            return false
        }

        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Name is required.")
            return false
        }

        guard !genresArray.isEmpty else {
            showAlert(message: "Please add at least one genre.")
            return false
        }

        return true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    private func showAlert(message: String) {
        guard let topVC = findTopViewController() else { return }
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        topVC.present(alert, animated: true)
    }

    private func findTopViewController() -> UIViewController? {
        var topVC = UIApplication.shared.windows.first?.rootViewController
        while let presentedVC = topVC?.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }
    
    private func createTagView(for text: String, in array: inout [String], container: UIStackView) -> UIView {
        // Tag view container
        let tagView = UIView()
        tagView.backgroundColor = .systemTeal.withAlphaComponent(0.8)
        tagView.layer.cornerRadius = 10
        tagView.translatesAutoresizingMaskIntoConstraints = false

        // Label for the tag
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        // Remove button for the tag
        let removeButton = UIButton(type: .system)
        removeButton.setTitle("x", for: .normal)
        removeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        removeButton.setTitleColor(.white, for: .normal)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.tag = container.arrangedSubviews.count // Use tag to identify index
        removeButton.addTarget(self, action: #selector(didTapRemoveTag(_:)), for: .touchUpInside)

        // Add label and remove button to the tag view
        tagView.addSubview(label)
        tagView.addSubview(removeButton)

        // Constraints for the tag view components
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: tagView.leadingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),

            removeButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            removeButton.trailingAnchor.constraint(equalTo: tagView.trailingAnchor, constant: -8),
            removeButton.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),

            tagView.heightAnchor.constraint(equalToConstant: 40)
        ])

        return tagView
    }

    @objc private func didTapRemoveTag(_ sender: UIButton) {
        guard let tagView = sender.superview else { return }
        guard let container = tagView.superview as? UIStackView else { return }

        if container == genresContainer, let index = container.arrangedSubviews.firstIndex(of: tagView) {
            genresArray.remove(at: index)
        }
        container.removeArrangedSubview(tagView)
        tagView.removeFromSuperview()
    }
}
