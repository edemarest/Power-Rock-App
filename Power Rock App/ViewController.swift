import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ViewController: UIViewController, WelcomeViewDelegate, FanRegisterViewDelegate, StarRegisterViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Firebase Firestore instance
    let db = Firestore.firestore()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWelcomeView()
    }

    // MARK: - Welcome Screen Logic
    /*------------------------Welcome Logic-------------------*/
    private func setupWelcomeView() {
        // Clear all subviews to ensure no overlapping UI
        view.subviews.forEach { $0.removeFromSuperview() }

        let welcomeView = WelcomeView()
        welcomeView.delegate = self
        welcomeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeView)

        NSLayoutConstraint.activate([
            welcomeView.topAnchor.constraint(equalTo: view.topAnchor),
            welcomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            welcomeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            welcomeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func didTapFanButton() {
        navigateToFanRegister()
    }

    func didTapStarButton() {
        navigateToStarRegister()
    }

    func didTapLoginButton() {
        navigateToLogin()
    }

    private func navigateToLogin() {
        print("Navigate to Login")
    }

    // MARK: - Fan Register Logic
    /*------------------------Fan Register Logic-------------------*/
    private func navigateToFanRegister() {
        view.subviews.forEach { $0.removeFromSuperview() }

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

    func didTapFanRegisterButton(firstName: String, email: String, password: String, profileImage: UIImage?) {
        guard !firstName.isEmpty, !email.isEmpty, !password.isEmpty else {
            print("Error: All fields are required")
            return
        }

        print("Attempting to register user...")

        // Step 1: Create user with email and password
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }

            guard let uid = authResult?.user.uid else {
                print("Error: Unable to get user ID")
                return
            }

            print("User registered successfully with UID: \(uid)")

            // Step 2: Upload profile image if provided
            if let profileImage = profileImage, let imageData = profileImage.jpegData(compressionQuality: 0.8) {
                let storageRef = Storage.storage().reference().child("profileImages/\(uid).jpg")
                storageRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("Error uploading profile image: \(error.localizedDescription)")
                        return
                    }

                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error getting profile image URL: \(error.localizedDescription)")
                            return
                        }

                        guard let imageUrl = url?.absoluteString else { return }
                        print("Profile image uploaded successfully with URL: \(imageUrl)")

                        // Step 3: Save user data to Firestore
                        self.saveFanData(uid: uid, firstName: firstName, email: email, profileImageUrl: imageUrl)
                    }
                }
            } else {
                // No profile image provided, save user data with default image
                self.saveFanData(uid: uid, firstName: firstName, email: email, profileImageUrl: nil)
            }
        }
    }

    private func saveFanData(uid: String, firstName: String, email: String, profileImageUrl: String?) {
        let userData: [String: Any] = [
            "uid": uid,
            "firstName": firstName,
            "email": email,
            "profileImageUrl": profileImageUrl ?? "defaultProfileImageUrl",
            "userType": "Fan"
        ]

        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error saving user data to Firestore: \(error.localizedDescription)")
                return
            }

            print("User data saved successfully to Firestore!")
        }
    }

    func didTapFanBackButton() {
        print("Fan Register Back Button Tapped")
        setupWelcomeView()
    }

    // MARK: - Star Register Logic
    /*------------------------Star Register Logic-------------------*/
    private func navigateToStarRegister() {
        print("Navigate to Star Register Screen")
        view.subviews.forEach { $0.removeFromSuperview() }

        let starRegisterView = StarRegisterView() // Initialize your custom view
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

    func didTapStarRegisterButton(bandName: String, email: String, password: String, genres: [String], members: [String], bandLogo: UIImage?) {
        guard !bandName.isEmpty, !email.isEmpty, !password.isEmpty, !genres.isEmpty, !members.isEmpty, bandLogo != nil else {
            showAlert(message: "All fields are required, including a valid band logo.")
            return
        }

        print("Attempting to register band...")

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                self.showAlert(message: "Error registering the band: \(error.localizedDescription)")
                return
            }

            guard let uid = authResult?.user.uid else {
                print("Error: Unable to get user ID")
                self.showAlert(message: "Unexpected error occurred. Please try again.")
                return
            }

            print("User registered successfully with UID: \(uid)")

            // Upload band logo
            if let bandLogo = bandLogo, let imageData = bandLogo.jpegData(compressionQuality: 0.8) {
                let storageRef = Storage.storage().reference().child("bandLogos/\(uid).jpg")
                storageRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("Error uploading band logo: \(error.localizedDescription)")
                        self.showAlert(message: "Error uploading band logo. Please try again.")
                        return
                    }

                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error getting band logo URL: \(error.localizedDescription)")
                            self.showAlert(message: "Error retrieving band logo URL. Please try again.")
                            return
                        }

                        guard let logoUrl = url?.absoluteString else { return }
                        print("Band logo uploaded successfully with URL: \(logoUrl)")

                        // Save band data
                        self.saveBandData(uid: uid, bandName: bandName, email: email, genres: genres, members: members, logoUrl: logoUrl)
                    }
                }
            } else {
                self.saveBandData(uid: uid, bandName: bandName, email: email, genres: genres, members: members, logoUrl: nil)
            }
        }
    }

    private func saveBandData(uid: String, bandName: String, email: String, genres: [String], members: [String], logoUrl: String?) {
        let bandData: [String: Any] = [
            "uid": uid,
            "bandName": bandName,
            "email": email,
            "genres": genres,
            "members": members,
            "bandLogoUrl": logoUrl ?? "defaultBandLogoUrl",
        ]

        db.collection("bands").document(uid).setData(bandData) { error in
            if let error = error {
                print("Error saving band data to Firestore: \(error.localizedDescription)")
                self.showAlert(message: "Error saving band data. Please try again.")
                return
            }

            print("Band data saved successfully to Firestore!")
            self.showAlert(message: "Band registered successfully!")
        }
    }

    func didTapStarBackButton() {
        print("Back button tapped")
    }

    // MARK: - Image Picker Logic
    /*------------------------Image Picker Logic-------------------*/
    func didTapUploadImage() {
        let actionSheet = UIAlertController(title: "Upload Band Logo", message: "Choose an option", preferredStyle: .actionSheet)
        
        // Add Gallery Option
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        }))
        
        // Add Camera Option
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openImagePicker(sourceType: .camera)
            }))
        }
        
        // Add Cancel Option
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present Action Sheet
        self.present(actionSheet, animated: true, completion: nil)
    }

    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true // Allows cropping and editing
        
        self.present(imagePicker, animated: true, completion: nil)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // Get the selected image
        if let editedImage = info[.editedImage] as? UIImage {
            updateBandLogo(with: editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            updateBandLogo(with: originalImage)
        }
    }

    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    private func updateBandLogo(with image: UIImage) {
        // Assuming `starRegisterView` is the instance of StarRegisterView
        guard let starRegisterView = view.subviews.compactMap({ $0 as? StarRegisterView }).first else { return }
        starRegisterView.bandLogoImageView.image = image
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
