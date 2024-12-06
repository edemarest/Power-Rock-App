import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// MARK: - StarRegisterViewDelegate Protocol
protocol StarRegisterViewDelegate: AnyObject {
    func didTapStarBackButton()
    func didTapStarRegisterButton(bandName: String, email: String, password: String, genres: [String], members: [String], bandLogo: UIImage?)
    func didTapUploadBandLogo()
}

// MARK: - StarRegisterViewController
class StarRegisterViewController: UIViewController, StarRegisterViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register Your Band"
        setupNavbar()
        setupBackground()
        setupStarRegisterView()
    }

    private func setupNavbar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }

    private func setupBackground() {
        let baseView = UIView()
        baseView.backgroundColor = .black
        baseView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(baseView)

        let backgroundImageView = UIImageView(image: UIImage(named: "Background_2"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.3
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

    private func setupStarRegisterView() {
        let starRegisterView = StarRegisterView()
        starRegisterView.delegate = self
        starRegisterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(starRegisterView)

        NSLayoutConstraint.activate([
            starRegisterView.topAnchor.constraint(equalTo: view.topAnchor),
            starRegisterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            starRegisterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starRegisterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func didTapStarBackButton() {
        navigationController?.popViewController(animated: true)
    }

    func didTapStarRegisterButton(bandName: String, email: String, password: String, genres: [String], members: [String], bandLogo: UIImage?) {
        // Fetch the current band logo image from the StarRegisterView
        let bandLogo = (view as? StarRegisterView)?.bandLogoImageView.image ?? UIImage(named: "Default_Profile_Picture")
        
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

            self.uploadBandLogo(bandLogo!) { url in
                self.saveUserData(
                    uid: uid,
                    bandName: bandName,
                    genres: genres,
                    members: members,
                    bandLogoUrl: url
                )
            }
        }
    }

    private func uploadBandLogo(_ bandLogo: UIImage, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage().reference().child("bandLogos/\(UUID().uuidString).jpg")
        guard let imageData = bandLogo.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }

    private func saveUserData(uid: String, bandName: String, genres: [String], members: [String], bandLogoUrl: String?) {
        let userData: [String: Any] = [
            "userType": "Star",
            "bandName": bandName,
            "genres": genres,
            "members": members,
            "bandLogoUrl": bandLogoUrl ?? ""
        ]
        
        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            if let error = error {
                self.showAlert(message: "Failed to save user data. Please try again.")
                return
            }
            self.navigateToStarHomeView()
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

     func didTapUploadBandLogo() {
         let imagePicker = UIImagePickerController()
         imagePicker.delegate = self
         imagePicker.sourceType = .photoLibrary
         imagePicker.allowsEditing = true
         present(imagePicker, animated: true, completion: nil)
     }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            if let starRegisterView = view as? StarRegisterView {
                starRegisterView.bandLogoImageView.image = selectedImage
            }
        } else if let originalImage = info[.originalImage] as? UIImage {
            if let starRegisterView = view as? StarRegisterView {
                starRegisterView.bandLogoImageView.image = originalImage
            }
        } else {
            print("Error: Unable to retrieve selected image.")
        }
        dismiss(animated: true, completion: nil)
    }

     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         dismiss(animated: true, completion: nil)
     }

    private func navigateToStarHomeView() {
        let starHomeVC = StarHomeViewController()
        navigationController?.pushViewController(starHomeVC, animated: true)
    }
}

// MARK: - StarRegisterView
class StarRegisterView: UIView {

    // MARK: - UI Elements
    var bandLogoImageView = UIImageView()
    private var uploadImageButton = UIButton(type: .system)
    private var bandNameLabel = UILabel()
    private var bandNameTextField = UITextField()
    private var membersLabel = UILabel()
    private var membersTextField = UITextField()
    private var addMemberButton = UIButton(type: .system)
    private var membersContainer = UIStackView()
    private var genresLabel = UILabel()
    private var genresTextField = UITextField()
    private var addGenreButton = UIButton(type: .system)
    private var genresContainer = UIStackView()
    private var emailLabel = UILabel()
    private var emailTextField = UITextField()
    private var passwordLabel = UILabel()
    private var passwordTextField = UITextField()
    private var registerButton = UIButton(type: .system)

    // Arrays for members and genres
    var membersArray: [String] = []
    var genresArray: [String] = []

    weak var delegate: StarRegisterViewDelegate?

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

        let edgyFont = UIFont(name: "Chalkduster", size: 16) ?? UIFont.systemFont(ofSize: 16)

        // Band Logo
        bandLogoImageView.image = UIImage(named: "Default_Profile_Picture")
        bandLogoImageView.backgroundColor = .black
        bandLogoImageView.contentMode = .scaleAspectFit
        bandLogoImageView.layer.borderWidth = 1
        bandLogoImageView.layer.borderColor = UIColor.white.cgColor
        bandLogoImageView.layer.cornerRadius = 8
        bandLogoImageView.clipsToBounds = true
        addSubview(bandLogoImageView)
        
        UIHelper.configureButton(uploadImageButton, title: "Upload Logo", font: UIFont.systemFont(ofSize: 16))
        addSubview(uploadImageButton)

        // Band Name
        UIHelper.configureLabel(bandNameLabel, text: "Band Name", font: edgyFont)
        addSubview(bandNameLabel)

        UIHelper.configureTextField(bandNameTextField, placeholder: "Enter your band name", font: edgyFont)
        addSubview(bandNameTextField)

        // Members
        UIHelper.configureLabel(membersLabel, text: "Members", font: edgyFont)
        addSubview(membersLabel)

        UIHelper.configureTextField(membersTextField, placeholder: "Enter member name", font: edgyFont)
        addSubview(membersTextField)

        UIHelper.configureButton(addMemberButton, title: "+", font: edgyFont)
        addSubview(addMemberButton)

        membersContainer.axis = .vertical
        membersContainer.spacing = 8
        addSubview(membersContainer)

        // Genres
        UIHelper.configureLabel(genresLabel, text: "Genres", font: edgyFont)
        addSubview(genresLabel)

        UIHelper.configureTextField(genresTextField, placeholder: "Enter genre", font: edgyFont)
        addSubview(genresTextField)

        UIHelper.configureButton(addGenreButton, title: "+", font: edgyFont)
        addSubview(addGenreButton)

        genresContainer.axis = .vertical
        genresContainer.spacing = 8
        addSubview(genresContainer)

        // Email
        UIHelper.configureLabel(emailLabel, text: "Email", font: edgyFont)
        addSubview(emailLabel)

        UIHelper.configureTextField(emailTextField, placeholder: "Enter email", font: edgyFont)
        addSubview(emailTextField)

        // Password
        UIHelper.configureLabel(passwordLabel, text: "Password", font: edgyFont)
        addSubview(passwordLabel)

        UIHelper.configureTextField(passwordTextField, placeholder: "Enter password", font: edgyFont)
        passwordTextField.isSecureTextEntry = true
        addSubview(passwordTextField)

        // Register Button
        UIHelper.configureButton(registerButton, title: "Register", font: UIFont.systemFont(ofSize: 16)
)
        addSubview(registerButton)
    }

    
    private func setupConstraints() {
            let subviews = [
                bandLogoImageView, uploadImageButton, bandNameLabel, bandNameTextField, membersLabel,
                membersTextField, addMemberButton, membersContainer, genresLabel, genresTextField,
                addGenreButton, genresContainer, emailLabel, emailTextField, passwordLabel,
                passwordTextField, registerButton
            ]
            subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

            NSLayoutConstraint.activate([
                bandLogoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
                bandLogoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                bandLogoImageView.widthAnchor.constraint(equalToConstant: 100),
                bandLogoImageView.heightAnchor.constraint(equalToConstant: 100),

                uploadImageButton.topAnchor.constraint(equalTo: bandLogoImageView.bottomAnchor, constant: 10),
                uploadImageButton.centerXAnchor.constraint(equalTo: bandLogoImageView.centerXAnchor),

                bandNameLabel.topAnchor.constraint(equalTo: uploadImageButton.bottomAnchor, constant: 20),
                bandNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

                bandNameTextField.topAnchor.constraint(equalTo: bandNameLabel.bottomAnchor, constant: 5),
                bandNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                bandNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                bandNameTextField.heightAnchor.constraint(equalToConstant: 40),

                membersLabel.topAnchor.constraint(equalTo: bandNameTextField.bottomAnchor, constant: 20),
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


    // MARK: - Actions
    private func setupActions() {
        uploadImageButton.addTarget(self, action: #selector(didTapUploadLogo), for: .touchUpInside)
        addMemberButton.addTarget(self, action: #selector(didTapAddMember), for: .touchUpInside)
        addGenreButton.addTarget(self, action: #selector(didTapAddGenre), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    @objc private func didTapUploadLogo() {
        delegate?.didTapUploadBandLogo()
    }

    @objc private func didTapAddMember() {
        guard let member = membersTextField.text, !member.isEmpty else { return }
        membersArray.append(member)
        membersTextField.text = ""

        // Create a member tag using UIHelper
        let memberTag = UIHelper.createTagLabel(
            with: member,
            font: UIFont.systemFont(ofSize: 14),
            backgroundColor: .white,
            textColor: .black,
            cornerRadius: 10,
            target: self,
            action: #selector(didTapRemoveMember(_:))
        )
        
        membersContainer.addArrangedSubview(memberTag)
    }

    @objc private func didTapAddGenre() {
        guard let genre = genresTextField.text, !genre.isEmpty else { return }
        genresArray.append(genre)
        genresTextField.text = ""

        // Create a genre tag using UIHelper
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
    }

    @objc private func didTapRemoveMember(_ sender: UIButton) {
        // Find the container view of the sender button
        guard let memberContainer = sender.superview else { return }

        // Remove the member from the array
        if let label = memberContainer.subviews.first(where: { $0 is UILabel }) as? UILabel,
           let memberText = label.text,
           let index = membersArray.firstIndex(of: memberText) {
            membersArray.remove(at: index)
        }

        // Remove the corresponding UI element
        membersContainer.removeArrangedSubview(memberContainer)
        memberContainer.removeFromSuperview()
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


    @objc private func didTapRegister() {
        delegate?.didTapStarRegisterButton(
            bandName: bandNameTextField.text ?? "",
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? "",
            genres: genresArray,
            members: membersArray,
            bandLogo: bandLogoImageView.image
        )
    }
}
