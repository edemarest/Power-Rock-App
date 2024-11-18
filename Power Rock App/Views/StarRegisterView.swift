import UIKit

protocol StarRegisterViewDelegate: AnyObject {
    func didTapStarBackButton()
    func didTapStarRegisterButton(bandName: String, email: String, password: String, genres: [String], members: [String], bandLogo: UIImage?)
    func didTapUploadBandLogo()
}

class StarRegisterView: UIView {

    // UI Elements
    let backButton = UIButton(type: .system)
    let titleLabel = UILabel()

    let bandLogoImageView = UIImageView()
    let uploadImageButton = UIButton(type: .system)

    let bandNameLabel = UILabel()
    let bandNameTextField = UITextField()

    let membersLabel = UILabel()
    let membersTextField = UITextField()
    let addMemberButton = UIButton(type: .system)
    let membersContainer = UIStackView()

    let genresLabel = UILabel()
    let genresTextField = UITextField()
    let addGenreButton = UIButton(type: .system)
    let genresContainer = UIStackView()

    let emailLabel = UILabel()
    let emailTextField = UITextField()

    let passwordLabel = UILabel()
    let passwordTextField = UITextField()

    let registerButton = UIButton(type: .system)

    // Data Storage
    private var membersArray: [String] = []
    private var genresArray: [String] = []

    weak var delegate: StarRegisterViewDelegate?

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
        // Set background color
        backgroundColor = .white

        // Back Button
        backButton.setTitle("Back", for: .normal)
        addSubview(backButton)

        // Title Label
        titleLabel.text = "Register your Band"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        // Band Logo Image View
        bandLogoImageView.backgroundColor = .lightGray
        bandLogoImageView.contentMode = .scaleAspectFit
        bandLogoImageView.layer.cornerRadius = 10
        bandLogoImageView.clipsToBounds = true
        addSubview(bandLogoImageView)

        uploadImageButton.setTitle("Upload Image", for: .normal)
        uploadImageButton.setTitleColor(.systemBlue, for: .normal)
        addSubview(uploadImageButton)

        // Band Name
        bandNameLabel.text = "Band Name"
        bandNameLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(bandNameLabel)

        bandNameTextField.placeholder = "Enter your band name"
        bandNameTextField.borderStyle = .roundedRect
        addSubview(bandNameTextField)

        // Band Members
        membersLabel.text = "Add your members:"
        membersLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(membersLabel)

        membersTextField.placeholder = "Enter member name"
        membersTextField.borderStyle = .roundedRect
        addSubview(membersTextField)

        addMemberButton.setTitle("+", for: .normal)
        addMemberButton.backgroundColor = .systemBlue
        addMemberButton.setTitleColor(.white, for: .normal)
        addMemberButton.layer.cornerRadius = 20 // Circular button
        addSubview(addMemberButton)

        membersContainer.axis = .vertical
        membersContainer.spacing = 8
        addSubview(membersContainer)

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
        addGenreButton.layer.cornerRadius = 20 // Circular button
        addSubview(addGenreButton)

        genresContainer.axis = .vertical
        genresContainer.spacing = 8
        addSubview(genresContainer)

        // Email
        emailLabel.text = "Email address linked to your band:"
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(emailLabel)

        emailTextField.placeholder = "Enter email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        addSubview(emailTextField)
        
        // Password
        passwordLabel.text = "Choose a password"
        passwordLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(passwordLabel)

        passwordTextField.placeholder = "Enter password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true // Mask password input
        passwordTextField.textContentType = .none
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

        bandLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageButton.translatesAutoresizingMaskIntoConstraints = false

        bandNameLabel.translatesAutoresizingMaskIntoConstraints = false
        bandNameTextField.translatesAutoresizingMaskIntoConstraints = false

        membersLabel.translatesAutoresizingMaskIntoConstraints = false
        membersTextField.translatesAutoresizingMaskIntoConstraints = false
        addMemberButton.translatesAutoresizingMaskIntoConstraints = false
        membersContainer.translatesAutoresizingMaskIntoConstraints = false

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

            // Band Logo and Name
            bandLogoImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            bandLogoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            bandLogoImageView.widthAnchor.constraint(equalToConstant: 100),
            bandLogoImageView.heightAnchor.constraint(equalToConstant: 100),

            uploadImageButton.topAnchor.constraint(equalTo: bandLogoImageView.bottomAnchor, constant: 10),
            uploadImageButton.centerXAnchor.constraint(equalTo: bandLogoImageView.centerXAnchor),

            bandNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            bandNameLabel.leadingAnchor.constraint(equalTo: bandLogoImageView.trailingAnchor, constant: 20),

            bandNameTextField.topAnchor.constraint(equalTo: bandNameLabel.bottomAnchor, constant: 5),
            bandNameTextField.leadingAnchor.constraint(equalTo: bandLogoImageView.trailingAnchor, constant: 20),
            bandNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            bandNameTextField.heightAnchor.constraint(equalToConstant: 40),

            // Members
            membersLabel.topAnchor.constraint(equalTo: uploadImageButton.bottomAnchor, constant: 20),
            membersLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            membersTextField.topAnchor.constraint(equalTo: membersLabel.bottomAnchor, constant: 5),
            membersTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            membersTextField.trailingAnchor.constraint(equalTo: addMemberButton.leadingAnchor, constant: -10),
            membersTextField.heightAnchor.constraint(equalToConstant: 40),

            addMemberButton.centerYAnchor.constraint(equalTo: membersTextField.centerYAnchor),
            addMemberButton.widthAnchor.constraint(equalToConstant: 40),
            addMemberButton.heightAnchor.constraint(equalToConstant: 40),
            addMemberButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            membersContainer.topAnchor.constraint(equalTo: membersTextField.bottomAnchor, constant: 10),
            membersContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            membersContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            // Genres
            genresLabel.topAnchor.constraint(equalTo: membersContainer.bottomAnchor, constant: 20),
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
           addMemberButton.addTarget(self, action: #selector(didTapAddMember), for: .touchUpInside)
           addGenreButton.addTarget(self, action: #selector(didTapAddGenre), for: .touchUpInside)
           uploadImageButton.addTarget(self, action: #selector(didTapUploadBandLogo), for: .touchUpInside)
       }

    @objc private func didTapRegister() {
        guard validateFields() else { return }

        let bandName = bandNameTextField.text ?? "N/A"
        let email = emailTextField.text ?? "N/A"
        let password = passwordTextField.text ?? "N/A"

        print("""
        BAND NAME: \(bandName)
        EMAIL: \(email)
        PASSWORD: \(password)
        GENRES: \(genresArray)
        MEMBERS: \(membersArray)
        IMAGE SELECTED: \(bandLogoImageView.image != nil ? "Yes" : "No")
        """)

        delegate?.didTapStarRegisterButton(
            bandName: bandName,
            email: email,
            password: password,
            genres: genresArray,
            members: membersArray,
            bandLogo: bandLogoImageView.image
        )
    }


       private func validateFields() -> Bool {
           guard let email = emailTextField.text, isValidEmail(email) else {
               showAlert(message: "Please enter a valid email address.")
               return false
           }

           guard !membersArray.isEmpty, membersArray.allSatisfy(isValidName) else {
               showAlert(message: "Please enter valid band member names (letters only).")
               return false
           }

           guard !genresArray.isEmpty, genresArray.allSatisfy({ isValidName($0) && $0.count <= 20 }) else {
               showAlert(message: "Please enter valid genres (letters only, max 20 characters).")
               return false
           }

           return true
       }

       private func isValidEmail(_ email: String) -> Bool {
           let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
           return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
       }

       private func isValidName(_ name: String) -> Bool {
           let nameRegEx = "^[A-Za-z]+$"
           return NSPredicate(format: "SELF MATCHES %@", nameRegEx).evaluate(with: name)
       }

       private func showAlert(message: String) {
           guard let viewController = findTopViewController() else { return }

           let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           viewController.present(alert, animated: true)
       }

       private func findTopViewController() -> UIViewController? {
           var topController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
           while let presentedViewController = topController?.presentedViewController {
               topController = presentedViewController
           }
           return topController
       }

       @objc private func didTapUploadBandLogo() {
           delegate?.didTapUploadBandLogo()
       }

       @objc private func didTapBack() {
           delegate?.didTapStarBackButton()
       }

       @objc private func didTapAddMember() {
           guard let memberName = membersTextField.text, !memberName.isEmpty else { return }
           addTag(to: membersContainer, with: memberName, array: &membersArray)
           membersTextField.text = ""
       }

       @objc private func didTapAddGenre() {
           guard let genreName = genresTextField.text, !genreName.isEmpty else { return }
           addTag(to: genresContainer, with: genreName, array: &genresArray)
           genresTextField.text = ""
       }

       private func addTag(to container: UIStackView, with text: String, array: inout [String]) {
           array.append(text)

           let tagView = UIView()
           tagView.backgroundColor = .systemTeal.withAlphaComponent(0.8)
           tagView.layer.cornerRadius = 10
           tagView.translatesAutoresizingMaskIntoConstraints = false

           let label = UILabel()
           label.text = text
           label.font = UIFont.systemFont(ofSize: 14)
           label.translatesAutoresizingMaskIntoConstraints = false

           let removeButton = UIButton(type: .system)
           removeButton.setTitle("x", for: .normal)
           removeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
           removeButton.translatesAutoresizingMaskIntoConstraints = false
           removeButton.addTarget(self, action: #selector(didTapRemoveTag(_:)), for: .touchUpInside)

           tagView.addSubview(label)
           tagView.addSubview(removeButton)

           NSLayoutConstraint.activate([
               label.leadingAnchor.constraint(equalTo: tagView.leadingAnchor, constant: 8),
               label.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),

               removeButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
               removeButton.trailingAnchor.constraint(equalTo: tagView.trailingAnchor, constant: -8),
               removeButton.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),

               tagView.heightAnchor.constraint(equalToConstant: 40)
           ])

           container.addArrangedSubview(tagView)
           tagView.widthAnchor.constraint(equalTo: container.widthAnchor).isActive = true
       }

       @objc private func didTapRemoveTag(_ sender: UIButton) {
           guard let tagView = sender.superview else { return }
           if let container = tagView.superview as? UIStackView {
               if container == membersContainer, let index = membersContainer.arrangedSubviews.firstIndex(of: tagView) {
                   membersArray.remove(at: index)
               } else if container == genresContainer, let index = genresContainer.arrangedSubviews.firstIndex(of: tagView) {
                   genresArray.remove(at: index)
               }
               container.removeArrangedSubview(tagView)
               tagView.removeFromSuperview()
           }
       }
}
