import UIKit
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

/**
 `StarRegisterViewController` handles the registration of band accounts (Star users). Users can input their band name, email, password, genres, and members. A band logo can also be uploaded using the camera or gallery. On successful registration, user data is stored in Firestore, and the user is navigated to the Star Home screen.
 */
class StarRegisterViewController: UIViewController, StarRegisterViewDelegate, PHPickerViewControllerDelegate {

    // MARK: - Properties
    var pickedImage: UIImage?
    var pickedImageUrl: URL?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        print("")
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

        starRegisterView.uploadImageButton.menu = getMenuImagePicker()
        starRegisterView.uploadImageButton.showsMenuAsPrimaryAction = true
    }

    func didTapStarBackButton() {
        navigationController?.popViewController(animated: true)
    }

    func didTapStarRegisterButton(bandName: String, email: String, password: String, genres: [String], members: [String], bandLogo: UIImage?) {
        guard !bandName.isEmpty, !email.isEmpty, !password.isEmpty, !genres.isEmpty, !members.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in all fields.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error as NSError? {
                let message: String
                switch AuthErrorCode(rawValue: error.code) {
                case .emailAlreadyInUse:
                    message = "The email address is already in use."
                case .invalidEmail:
                    message = "The email address is invalid."
                default:
                    message = "An unexpected error occurred: \(error.localizedDescription)"
                }
                self.showAlert(title: "Registration Failed", message: message)
                return
            }

            guard let uid = authResult?.user.uid else {
                self.showAlert(title: "Error", message: "Unexpected error occurred. Please try again.")
                return
            }

            self.saveUserData(uid: uid, bandName: bandName, email: email, genres: genres, members: members, bandLogo: bandLogo)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func navigateToStarHome() {
        let starHomeVC = StarHomeViewController()
        navigationController?.pushViewController(starHomeVC, animated: true)
    }

    private func getMenuImagePicker() -> UIMenu {
        let menuItems = [
            UIAction(title: "Camera", handler: { _ in self.pickUsingCamera() }),
            UIAction(title: "Gallery", handler: { _ in self.pickPhotoFromGallery() })
        ]
        return UIMenu(title: "Select source", children: menuItems)
    }

    private func pickUsingCamera() {
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.allowsEditing = true
        cameraController.delegate = self
        present(cameraController, animated: true)
    }

    private func pickPhotoFromGallery() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let photoPicker = PHPickerViewController(configuration: configuration)
        photoPicker.delegate = self
        present(photoPicker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    if let starRegisterView = self.view.subviews.first(where: { $0 is StarRegisterView }) as? StarRegisterView {
                        starRegisterView.bandLogoImageView.image = image
                        self.pickedImage = image;
                    }
                }
            }
        }
    }
    
    // TODO :
    // below are current code and sakib's code.
    // should try to combine them
    
    // current code
    func uploadBandLogo(image: UIImage, completion: @escaping (String?) -> Void) {
        // Generate a unique file name for the image
        let uniqueFileName = "\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child("bandLogos/\(uniqueFileName)")
        
        // Convert the UIImage to JPEG data with compression quality
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to JPEG data.")
            completion(nil)
            return
        }
        
        // Upload the image data to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Retrieve the download URL for the uploaded image
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    completion(nil)
                } else if let url = url {
                    print("Successfully uploaded image. URL: \(url.absoluteString)")
                    completion(url.absoluteString)
                } else {
                    print("Unexpected error: URL is nil.")
                    completion(nil)
                }
            }
        }
    }
    
    
    // sakib code
    func uploadProfilePhotoToStorage(){
        let storage = Storage.storage()
        
        //MARK: Upload the profile photo if there is any...
        if let image = pickedImage{
            if let jpegData = image.jpegData(compressionQuality: 80){
                let storageRef = storage.reference()
                let imagesRepo = storageRef.child("bandLogos")
                let imageRef = imagesRepo.child("\(NSUUID().uuidString).jpg")
                
                let uploadTask = imageRef.putData(jpegData, completion: {(metadata, error) in
                    if error == nil{
                        imageRef.downloadURL(completion: {(url, error) in
                            if error == nil{
                                print("saved url")
                                print(url)
                                self.pickedImageUrl = url
                            }
                        })
                    }
                })
            }
        }
    }
    
    func uploadProfilePhotoToStorage(image: UIImage, completion: @escaping (String?) -> Void) {
        let storage = Storage.storage()
        
        // Ensure the image is valid
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            let storageRef = storage.reference()
            let imagesRepo = storageRef.child("bandLogos")
            let imageRef = imagesRepo.child("\(UUID().uuidString).jpg")
            
            // Upload the image
            imageRef.putData(jpegData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                // Get the download URL
                imageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error retrieving download URL: \(error.localizedDescription)")
                        completion(nil)
                    } else if let url = url {
                        print("Successfully uploaded image. URL: \(url.absoluteString)")
                        completion(url.absoluteString)
                    } else {
                        completion(nil)
                    }
                }
            }
        } else {
            print("Error: Unable to convert image to JPEG data.")
            completion(nil)
        }
    }

    
//    private func saveUserData(uid: String, bandName: String, email: String, genres: [String], members: [String], bandLogo: UIImage?) {
//        print("saving user data")
//        print("bandLogoImage passed in: ")
//        print(bandLogo)
//        
//        // set picked image url using uploadProfilePhotoToStorage here
//        
//        let userData: [String: Any] = [
//            "userType": "Star",
//            "bandName": bandName,
//            "email": email,
//            "genres": genres,
//            "members": members,
//            "bandLogoUrl": "placeholder", // put picked image url
//        ]
//
//        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
//            if let error = error {
//                self.showAlert(title: "Error", message: "Failed to save user data. Please try again.")
//                return
//            }
//
//            self.navigateToStarHome()
//        }
//    }
    
    private func saveUserData(uid: String, bandName: String, email: String, genres: [String], members: [String], bandLogo: UIImage?) {
        print("Saving user data...")
        
        let dispatchGroup = DispatchGroup()
        var uploadedImageUrl: String? = nil
        
        if let bandLogo = bandLogo {
            // Enter the dispatch group before starting the upload
            dispatchGroup.enter()
            pickedImage = bandLogo // Assign the image to `pickedImage` for uploadProfilePhotoToStorage
            uploadProfilePhotoToStorage()
            
            // Wait for the URL to be set
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) { // Poll for the value of `pickedImageUrl`
                if let pickedImageUrl = self.pickedImageUrl?.absoluteString {
                    uploadedImageUrl = pickedImageUrl
                    print("Image URL obtained: \(pickedImageUrl)")
                    dispatchGroup.leave()
                } else {
                    print("Failed to obtain image URLFailed to obtain image URL.")
                    dispatchGroup.leave()
                }
            }
        }
        
        // Wait for the upload to finish before saving user data
        dispatchGroup.notify(queue: .main) {
            let userData: [String: Any] = [
                "userType": "Star",
                "bandName": bandName,
                "email": email,
                "genres": genres,
                "members": members,
                "bandLogoUrl": uploadedImageUrl ?? "",
            ]
            
            Firestore.firestore().collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to save user data. Please try again.")
                    return
                }
                
                print("User data saved successfully.")
                self.navigateToStarHome()
            }
        }
    }

    
//    private func saveUserData(uid: String, bandName: String, email: String, genres: [String], members: [String], bandLogo: UIImage?) {
//        print("Saving user data...")
//        
//        if let bandLogo = bandLogo {
//            // Upload the band logo and save the user data upon success
//            uploadProfilePhotoToStorage(image: bandLogo) { [weak self] bandLogoUrl in
//                guard let self = self else { return }
//                
//                if let bandLogoUrl = bandLogoUrl {
//                    print("Band logo uploaded successfully. URL: \(bandLogoUrl)")
//                    
//                    let userData: [String: Any] = [
//                        "userType": "Star",
//                        "bandName": bandName,
//                        "email": email,
//                        "genres": genres,
//                        "members": members,
//                        "bandLogoUrl": bandLogoUrl,
//                    ]
//                    
//                    // Save the user data to Firestore
//                    Firestore.firestore().collection("users").document(uid).setData(userData) { error in
//                        if let error = error {
//                            print("Error saving user data: \(error.localizedDescription)")
//                            self.showAlert(title: "Error", message: "Failed to save user data. Please try again.")
//                            return
//                        }
//                        
//                        print("User data saved successfully.")
//                        self.navigateToStarHome()
//                    }
//                } else {
//                    print("Failed to upload band logo. Cannot save user data.")
//                    self.showAlert(title: "Error", message: "Failed to upload band logo. Please try again.")
//                }
//            }
//        } else {
//            // Save user data without a band logo if none is provided
//            print("No band logo provided. Saving user data without logo...")
//            let userData: [String: Any] = [
//                "userType": "Star",
//                "bandName": bandName,
//                "email": email,
//                "genres": genres,
//                "members": members,
//                "bandLogoUrl": "",
//            ]
//            
//            Firestore.firestore().collection("users").document(uid).setData(userData) { error in
//                if let error = error {
//                    print("Error saving user data: \(error.localizedDescription)")
//                    self.showAlert(title: "Error", message: "Failed to save user data. Please try again.")
//                    return
//                }
//                
//                print("User data saved successfully without band logo.")
//                self.navigateToStarHome()
//            }
//        }
//    }

}

// MARK: - UIImagePickerControllerDelegate
extension StarRegisterViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        print("imagePickerController")
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage {
            (view as? StarRegisterView)?.bandLogoImageView.image = image
            pickedImage = image
        } else if let image = info[.originalImage] as? UIImage {
            (view as? StarRegisterView)?.bandLogoImageView.image = image
            pickedImage = image
        }
    }
}
/**
 `StarRegisterView` is a custom UIView used for the band (Star) registration process. It contains fields for entering band details like band name, email, password, genres, and members, along with a band logo upload option.
 */
class StarRegisterView: UIView {

    // MARK: - UI Elements
    var bandLogoImageView = UIImageView()
    var uploadImageButton = UIButton(type: .system)
    private var bandNameLabel = UILabel()
    private lazy var bandNameTextField: UITextField = {
        UIHelper.createStyledTextField(placeholder: "Enter your band name")
    }()
    private var membersLabel = UILabel()
    private lazy var membersTextField: UITextField = {
        UIHelper.createStyledTextField(placeholder: "Enter member name")
    }()
    private var addMemberButton = UIButton(type: .system)
    private var membersContainer = UIStackView()
    private var genresLabel = UILabel()
    private lazy var genresTextField: UITextField = {
        UIHelper.createStyledTextField(placeholder: "Enter genre")
    }()
    private var addGenreButton = UIButton(type: .system)
    private var genresContainer = UIStackView()
    private var emailLabel = UILabel()
    private lazy var emailTextField: UITextField = {
        UIHelper.createStyledTextField(placeholder: "Enter email")
    }()
    private var passwordLabel = UILabel()
    private lazy var passwordTextField: UITextField = {
        let textField = UIHelper.createStyledTextField(placeholder: "Enter password")
        textField.isSecureTextEntry = true
        return textField
    }()
    private var registerButton = UIButton(type: .system)

    // MARK: - Properties
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

        let defaultFont = UIFont.systemFont(ofSize: 16)

        bandLogoImageView.image = UIImage(named: "Default_Workout_Icon")
        bandLogoImageView.backgroundColor = .black
        bandLogoImageView.contentMode = .scaleAspectFit
        bandLogoImageView.layer.borderWidth = 1
        bandLogoImageView.layer.borderColor = UIColor.white.cgColor
        bandLogoImageView.layer.cornerRadius = 8
        bandLogoImageView.clipsToBounds = true
        addSubview(bandLogoImageView)

        UIHelper.configureButton(uploadImageButton, title: "Upload Logo", font: defaultFont)
        uploadImageButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        addSubview(uploadImageButton)

        UIHelper.configureLabel(bandNameLabel, text: "Band Name", font: defaultFont)
        addSubview(bandNameLabel)
        addSubview(bandNameTextField)

        UIHelper.configureLabel(membersLabel, text: "Members", font: defaultFont)
        addSubview(membersLabel)
        addSubview(membersTextField)

        UIHelper.configureButton(addMemberButton, title: "+", font: defaultFont)
        addSubview(addMemberButton)

        membersContainer.axis = .horizontal
        membersContainer.alignment = .leading
        membersContainer.distribution = .fillProportionally
        membersContainer.spacing = 8
        addSubview(membersContainer)

        UIHelper.configureLabel(genresLabel, text: "Genres", font: defaultFont)
        addSubview(genresLabel)
        addSubview(genresTextField)

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

    // MARK: - Constraints Setup
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
            addMemberButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            membersContainer.topAnchor.constraint(equalTo: membersTextField.bottomAnchor, constant: 5),
            membersContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            membersContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            membersContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            genresLabel.topAnchor.constraint(equalTo: membersContainer.bottomAnchor, constant: 20),
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

    // MARK: - Actions Setup
    private func setupActions() {
        addMemberButton.addTarget(self, action: #selector(didTapAddMember), for: .touchUpInside)
        addGenreButton.addTarget(self, action: #selector(didTapAddGenre), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    @objc private func didTapAddMember() {
        guard let member = membersTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !member.isEmpty else {
            return
        }
        
        // Character limit check
        guard member.count <= 10 else {
            showAlert(title: "Input Too Long", message: "Member names cannot exceed 10 characters.")
            return
        }
        
        // Limit to 3 members
        guard membersArray.count < 3 else {
            showAlert(title: "Limit Reached", message: "You can only add up to 3 members.")
            return
        }

        membersArray.append(member)
        membersTextField.text = ""

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
        membersContainer.layoutIfNeeded()
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




    @objc private func didTapRemoveMember(_ sender: UIButton) {
        guard let memberContainer = sender.superview else { return }
        if let label = memberContainer.subviews.first(where: { $0 is UILabel }) as? UILabel,
           let memberText = label.text,
           let index = membersArray.firstIndex(of: memberText) {
            membersArray.remove(at: index)
        }
        membersContainer.removeArrangedSubview(memberContainer)
        memberContainer.removeFromSuperview()
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
