import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// MARK: - Protocol
// Protocol to handle actions for band registration such as uploading logo and submitting details
protocol StarRegisterViewDelegate: AnyObject {
    func didTapStarBackButton()
    func didTapStarRegisterButton(bandName: String, email: String, password: String, genres: [String], members: [String], bandLogo: UIImage?)
    func didTapUploadBandLogo()
}

// MARK: - StarRegisterViewController
// ViewController to manage the registration process for Star users (bands)
class StarRegisterViewController: UIViewController, StarRegisterViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let db = Firestore.firestore()
    let storage = Storage.storage()

    // MARK: - View Lifecycle
    // Set up the view when the controller is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register Your Band"
        setupStarRegisterView()
    }

    // MARK: - Setup Methods
    // Set up the StarRegister view and add it to the view hierarchy
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

    // MARK: - StarRegisterViewDelegate Methods
    // Handle back button tap and navigate to the previous screen
    func didTapStarBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // Handle the register button tap, perform registration and upload the band logo if available
    func didTapStarRegisterButton(bandName: String, email: String, password: String, genres: [String], members: [String], bandLogo: UIImage?) {
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

            var bandLogoUrl: String? = nil
            if let bandLogo = bandLogo {
                self.uploadBandLogo(bandLogo) { url in
                    bandLogoUrl = url
                    self.saveUserData(uid: uid, bandName: bandName, genres: genres, members: members, bandLogoUrl: bandLogoUrl)
                }
            } else {
                self.saveUserData(uid: uid, bandName: bandName, genres: genres, members: members, bandLogoUrl: bandLogoUrl)
            }
        }
    }

    // Upload the band logo to Firebase Storage and return the URL
    private func uploadBandLogo(_ bandLogo: UIImage, completion: @escaping (String?) -> Void) {
        let storageRef = storage.reference().child("bandLogos/\(UUID().uuidString).jpg")
        guard let imageData = bandLogo.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading band logo: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                completion(url?.absoluteString)
            }
        }
    }

    // Save the user's data to Firestore
    private func saveUserData(uid: String, bandName: String, genres: [String], members: [String], bandLogoUrl: String?) {
        let userData: [String: Any] = [
            "userType": "Star",
            "bandName": bandName,
            "genres": genres,
            "members": members,
            "bandLogoUrl": bandLogoUrl ?? ""
        ]
        
        self.db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
                self.showAlert(message: "Failed to save user data. Please try again.")
                return
            }
            
            print("Registration successful!")
            self.navigateToStarHomeView()
        }
    }

    // Show an alert with a custom message
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Present the image picker to upload a band logo
    func didTapUploadBandLogo() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    // Handle the image selected from the image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            (view as? StarRegisterView)?.bandLogoImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    // Handle canceling the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    // Navigate to the StarHomeView after successful registration
    private func navigateToStarHomeView() {
        let starHomeVC = StarHomeViewController()
        navigationController?.pushViewController(starHomeVC, animated: true)
    }
}

// MARK: - StarRegisterView
// Custom view for the star user registration form
class StarRegisterView: UIView {

    // MARK: - UI Elements
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

    private var membersArray: [String] = []
    private var genresArray: [String] = []

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
        backgroundColor = .white

        bandLogoImageView.backgroundColor = .lightGray
        bandLogoImageView.contentMode = .scaleAspectFit
        bandLogoImageView.layer.cornerRadius = 10
        bandLogoImageView.clipsToBounds = true
        addSubview(bandLogoImageView)

        uploadImageButton.setTitle("Upload Image", for: .normal)
        uploadImageButton.setTitleColor(.systemBlue, for: .normal)
        addSubview(uploadImageButton)

        bandNameLabel.text = "Band Name"
        addSubview(bandNameLabel)

        bandNameTextField.placeholder = "Enter your band name"
        bandNameTextField.borderStyle = .roundedRect
        addSubview(bandNameTextField)

        membersLabel.text = "Add your members:"
        addSubview(membersLabel)

        membersTextField.placeholder = "Enter member name"
        membersTextField.borderStyle = .roundedRect
        addSubview(membersTextField)

        addMemberButton.setTitle("+", for: .normal)
        addMemberButton.setTitleColor(.white, for: .normal)
        addMemberButton.backgroundColor = .systemBlue
        addMemberButton.layer.cornerRadius = 20
        addSubview(addMemberButton)

        membersContainer.axis = .vertical
        membersContainer.spacing = 8
        addSubview(membersContainer)

        genresLabel.text = "Genres:"
        addSubview(genresLabel)

        genresTextField.placeholder = "Enter genre"
        genresTextField.borderStyle = .roundedRect
        addSubview(genresTextField)

        addGenreButton.setTitle("+", for: .normal)
        addGenreButton.setTitleColor(.white, for: .normal)
        addGenreButton.backgroundColor = .systemBlue
        addGenreButton.layer.cornerRadius = 20
        addSubview(addGenreButton)

        genresContainer.axis = .vertical
        genresContainer.spacing = 8
        addSubview(genresContainer)

        emailLabel.text = "Email:"
        addSubview(emailLabel)

        emailTextField.placeholder = "Enter email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        addSubview(emailTextField)

        passwordLabel.text = "Password:"
        addSubview(passwordLabel)

        passwordTextField.placeholder = "Enter password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        addSubview(passwordTextField)

        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = .black
        registerButton.setTitleColor(.white, for: .normal)
        addSubview(registerButton)
    }

    private func setupConstraints() {
        let views = [bandLogoImageView, uploadImageButton, bandNameLabel, bandNameTextField, membersLabel,
                     membersTextField, addMemberButton, membersContainer, genresLabel, genresTextField,
                     addGenreButton, genresContainer, emailLabel, emailTextField, passwordLabel,
                     passwordTextField, registerButton]

        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

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

    private func setupActions() {
        uploadImageButton.addTarget(self, action: #selector(didTapUpload), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        addMemberButton.addTarget(self, action: #selector(didTapAddMember), for: .touchUpInside)
        addGenreButton.addTarget(self, action: #selector(didTapAddGenre), for: .touchUpInside)
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

    @objc private func didTapAddMember() {
        guard let member = membersTextField.text, !member.isEmpty else { return }
        membersArray.append(member)
        membersTextField.text = ""
        
        // Create label for the member and add to the container
        let memberLabel = UILabel()
        memberLabel.text = member
        memberLabel.backgroundColor = .lightGray
        memberLabel.layer.cornerRadius = 10
        memberLabel.clipsToBounds = true
        
        // Add remove "X" button to each member label
        let removeButton = UIButton(type: .system)
        removeButton.setTitle("X", for: .normal)
        removeButton.addTarget(self, action: #selector(didRemoveMember(_:)), for: .touchUpInside)
        
        let container = UIStackView(arrangedSubviews: [memberLabel, removeButton])
        container.axis = .horizontal
        container.spacing = 8
        membersContainer.addArrangedSubview(container)
    }

    @objc private func didRemoveMember(_ sender: UIButton) {
        guard let container = sender.superview as? UIStackView else { return }
        container.removeFromSuperview()
        
        if let memberLabel = container.arrangedSubviews.first as? UILabel {
            if let index = membersArray.firstIndex(of: memberLabel.text ?? "") {
                membersArray.remove(at: index)
            }
        }
    }

    @objc private func didTapAddGenre() {
        guard let genre = genresTextField.text, !genre.isEmpty else { return }
        genresArray.append(genre)
        genresTextField.text = ""
        
        // Create label for the genre and add to the container
        let genreLabel = UILabel()
        genreLabel.text = genre
        genreLabel.backgroundColor = .lightGray
        genreLabel.layer.cornerRadius = 10
        genreLabel.clipsToBounds = true
        
        genresContainer.addArrangedSubview(genreLabel)
    }
    
    @objc private func didTapUpload() {
        delegate?.didTapUploadBandLogo()
    }
}
