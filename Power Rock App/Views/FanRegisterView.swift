import UIKit

protocol FanRegisterViewDelegate: AnyObject {
    func didTapRegisterButton(firstName: String, email: String, password: String, profileImage: UIImage?)
    func didTapBackButton()
}

class FanRegisterView: UIView {

    // UI Elements
    let backButton = UIButton(type: .system)
    let profileImageView = UIImageView()
    let firstNameLabel = UILabel()
    let firstNameTextField = UITextField()
    let emailLabel = UILabel()
    let emailTextField = UITextField()
    let passwordLabel = UILabel()
    let passwordTextField = UITextField()
    let registerButton = UIButton(type: .system)

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

    private func setupUIElements() {
        // Back Button
        backButton.setTitle("Back", for: .normal)
        addSubview(backButton)

        // Profile Image
        profileImageView.image = UIImage(named: "defaultProfilePic") // Replace with default image name
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 50
        addSubview(profileImageView)

        // First Name Label and TextField
        firstNameLabel.text = "First Name"
        firstNameLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(firstNameLabel)

        firstNameTextField.placeholder = "Enter your first name"
        firstNameTextField.borderStyle = .roundedRect
        firstNameTextField.autocapitalizationType = .words
        addSubview(firstNameTextField)

        // Email Label and TextField
        emailLabel.text = "Email"
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(emailLabel)

        emailTextField.placeholder = "Enter your email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        addSubview(emailTextField)

        // Password Label and TextField
        passwordLabel.text = "Password"
        passwordLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(passwordLabel)

        passwordTextField.placeholder = "Enter your password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        addSubview(passwordTextField)

        // Register Button
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        addSubview(registerButton)
    }

    private func setupConstraints() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),

            profileImageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            firstNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            firstNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            firstNameTextField.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor, constant: 5),
            firstNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            firstNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            firstNameTextField.heightAnchor.constraint(equalToConstant: 40),

            emailLabel.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 20),
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
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    @objc private func didTapBack() {
        delegate?.didTapBackButton()
    }

    @objc private func didTapRegister() {
        let firstName = firstNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let profileImage = profileImageView.image
        delegate?.didTapRegisterButton(firstName: firstName, email: email, password: password, profileImage: profileImage)
    }
}
