import UIKit
import PhotosUI

// MARK: - StarRegisterViewDelegate Protocol
protocol StarRegisterViewDelegate: AnyObject {
    func didTapStarBackButton()
    func didTapStarRegisterButton(bandName: String, email: String, password: String, genres: [String], members: [String], bandLogo: UIImage?)
}

// MARK: - StarRegisterViewController
class StarRegisterViewController: UIViewController, StarRegisterViewDelegate {

    // MARK: - Properties
    var pickedImage: UIImage?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register Your Band"
        setupNavbar()
        setupBackground()
        setupStarRegisterView()
    }

    // MARK: - UI Setup
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

        starRegisterView.uploadImageButton.menu = getMenuImagePicker()
        starRegisterView.uploadImageButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - StarRegisterViewDelegate Methods
    func didTapStarBackButton() {
        navigationController?.popViewController(animated: true)
    }

    func didTapStarRegisterButton(bandName: String, email: String, password: String, genres: [String], members: [String], bandLogo: UIImage?) {
        let bandLogo = pickedImage ?? UIImage(named: "Default_Profile_Picture")
        print("Register button tapped with image: \(bandLogo)")
        // Implement registration logic as before
    }

    // MARK: - Menu Setup
    private func getMenuImagePicker() -> UIMenu {
        let menuItems = [
            UIAction(title: "Camera", handler: { _ in
                self.pickUsingCamera()
            }),
            UIAction(title: "Gallery", handler: { _ in
                self.pickPhotoFromGallery()
            })
        ]
        return UIMenu(title: "Select source", children: menuItems)
    }

    // MARK: - Picking Logic
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
}

// MARK: - PHPickerViewControllerDelegate
extension StarRegisterViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else {
            print("No valid image selected.")
            return
        }

        itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            if let error = error {
                print("Error loading image: \(error)")
            } else if let image = image as? UIImage {
                DispatchQueue.main.async {
                    (self.view as? StarRegisterView)?.bandLogoImageView.image = image
                    self.pickedImage = image
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension StarRegisterViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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


class StarRegisterView: UIView {

    // MARK: - UI Elements
    var bandLogoImageView = UIImageView()
    var uploadImageButton = UIButton(type: .system) // Changed to `internal` for accessibility
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

        // Configure Band Logo
        bandLogoImageView.image = UIImage(named: "Default_Profile_Picture")
        bandLogoImageView.backgroundColor = .black
        bandLogoImageView.contentMode = .scaleAspectFit
        bandLogoImageView.layer.borderWidth = 1
        bandLogoImageView.layer.borderColor = UIColor.white.cgColor
        bandLogoImageView.layer.cornerRadius = 8
        bandLogoImageView.clipsToBounds = true
        addSubview(bandLogoImageView)

        // Configure Upload Logo Button
        UIHelper.configureButton(uploadImageButton, title: "Upload Logo", font: defaultFont)
        uploadImageButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        addSubview(uploadImageButton)

        // Configure Labels and Buttons
        UIHelper.configureLabel(bandNameLabel, text: "Band Name", font: defaultFont)
        addSubview(bandNameLabel)
        addSubview(bandNameTextField)

        UIHelper.configureLabel(membersLabel, text: "Members", font: defaultFont)
        addSubview(membersLabel)
        addSubview(membersTextField)

        UIHelper.configureButton(addMemberButton, title: "+", font: defaultFont)
        addSubview(addMemberButton)

        membersContainer.axis = .vertical
        membersContainer.spacing = 8
        addSubview(membersContainer)

        UIHelper.configureLabel(genresLabel, text: "Genres", font: defaultFont)
        addSubview(genresLabel)
        addSubview(genresTextField)

        UIHelper.configureButton(addGenreButton, title: "+", font: defaultFont)
        addSubview(addGenreButton)

        genresContainer.axis = .vertical
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

    // MARK: - Actions Setup
    private func setupActions() {
        uploadImageButton.addTarget(self, action: #selector(didTapUploadLogo), for: .touchUpInside)
        addMemberButton.addTarget(self, action: #selector(didTapAddMember), for: .touchUpInside)
        addGenreButton.addTarget(self, action: #selector(didTapAddGenre), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }


    @objc private func didTapUploadLogo() {
        NotificationCenter.default.post(name: NSNotification.Name("UploadLogoTapped"), object: nil)
    }

    @objc private func didTapAddMember() {
        guard let member = membersTextField.text, !member.isEmpty else { return }
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
    }

    @objc private func didTapAddGenre() {
        guard let genre = genresTextField.text, !genre.isEmpty else { return }
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
