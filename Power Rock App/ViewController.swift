import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ViewController: UIViewController, WelcomeViewDelegate, FanRegisterViewDelegate, StarRegisterViewDelegate, StarHomeViewDelegate, CreateWorkoutViewDelegate, LoginViewDelegate, FanHomeViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Firebase Firestore instance
    let db = Firestore.firestore()
    let placeholderImage = UIImage(named: "Default_Profile_Picture.jpg")

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if user is already logged in
        if let user = Auth.auth().currentUser {
            fetchUserDetails(for: user.uid)
        } else {
            print("No user logged in. Redirecting to WelcomeView.")
            setupWelcomeView()
        }
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

    func didTapLoginButtonFromWelcome() {
        navigateToLogin()
    }
    
    func didTapLogin(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            showAlert(message: "Please fill in both fields.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                self.showAlert(message: "Login failed. Please check your credentials.")
                return
            }

            guard let uid = authResult?.user.uid else {
                print("Error: User ID not found after login.")
                self.showAlert(message: "Unexpected error occurred. Please try again.")
                return
            }

            print("Login success. Fetching user details...")
            self.fetchUserDetails(for: uid)
        }
    }


    func navigateToLogin() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let loginView = LoginView()
        loginView.delegate = self
        loginView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginView)

        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalTo: view.topAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    func didTapLoginBackButton() {
        setupWelcomeView()
    }
    
    func didTapLoginButton(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            showAlert(message: "Please fill in both fields.")
            return
        }

        // Sign in with Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                self.showAlert(message: "Login failed. Please check your credentials.")
                return
            }

            guard let uid = authResult?.user.uid else {
                print("Error: User ID not found after login.")
                self.showAlert(message: "Unexpected error occurred. Please try again.")
                return
            }

            // Fetch user details from Firestore
            self.db.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching user details: \(error.localizedDescription)")
                    self.showAlert(message: "Failed to fetch user details. Please try again.")
                    return
                }

                guard let data = snapshot?.data(), let userType = data["userType"] as? String else {
                    print("User data missing or malformed.")
                    self.showAlert(message: "Failed to identify user type. Please contact support.")
                    return
                }

                print("Login for \(userType) user type success!")

                // Retrieve additional data
                let firstName = data["firstName"] as? String ?? "User"
                let bandName = data["bandName"] as? String ?? "Band Name"

                // Dismiss LoginView and navigate to the respective home page
                self.dismiss(animated: true) {
                    if userType == "Fan" {
                        self.navigateToFanHome(firstName: firstName)
                    } else if userType == "Star" {
                        self.navigateToStarHome(bandName: bandName)
                    } else {
                        print("Unknown userType: \(userType)")
                        self.setupWelcomeView()
                    }
                }
            }
        }
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

    func didTapFanRegisterButton(firstName: String, email: String, password: String, genres: [String]) {
        guard !firstName.isEmpty, !email.isEmpty, !password.isEmpty, !genres.isEmpty else {
            print("Error: All fields are required")
            return
        }

        print("Attempting to register fan...")

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

            print("Fan registered successfully with UID: \(uid)")

            // Step 2: Save fan data to Firestore
            self.saveFanData(uid: uid, firstName: firstName, email: email, genres: genres) { success in
                if success {
                    self.navigateToFanHome(firstName: firstName)
                }
            }
        }
    }

    private func fetchUserDetails(for uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                self.showAlert(message: "Network error. Please check your connection and try again.")
                return
            }

            guard let data = snapshot?.data(),
                  let userType = data["userType"] as? String else {
                print("User data missing or malformed")
                self.setupWelcomeView() // Redirect to Welcome if no valid data
                return
            }

            // Retrieve `firstName` if the user is a Fan
            let firstName = data["firstName"] as? String ?? "User"

            // Navigate to the appropriate home based on userType
            if userType == "Star" {
                let bandName = data["bandName"] as? String ?? "Band Name"
                self.navigateToStarHome(bandName: bandName)
            } else if userType == "Fan" {
                print("Fan login successful.")
                self.navigateToFanHome(firstName: firstName) // Pass the firstName
            } else {
                print("Unknown userType: \(userType)")
                self.setupWelcomeView()
            }
        }
    }

    private func saveFanData(uid: String, firstName: String, email: String, genres: [String], completion: @escaping (Bool) -> Void) {
        let fanData: [String: Any] = [
            "uid": uid,
            "firstName": firstName,
            "email": email,
            "genres": genres,
            "userType": "Fan"
        ]

        db.collection("users").document(uid).setData(fanData) { error in
            if let error = error {
                print("Error saving fan data to Firestore: \(error.localizedDescription)")
                completion(false)
                return
            }

            print("Fan data saved successfully to Firestore!")
            completion(true)
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
        guard !bandName.isEmpty, !email.isEmpty, !password.isEmpty, !genres.isEmpty, !members.isEmpty else {
            print("All fields are required.")
            return
        }

        print("Attempting to register band...")

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

            // Step 2: Upload band logo if provided
            if let bandLogo = bandLogo, let imageData = bandLogo.jpegData(compressionQuality: 0.8) {
                let storageRef = Storage.storage().reference().child("bandLogos/\(uid).jpg")
                storageRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("Error uploading band logo: \(error.localizedDescription)")
                        self.saveStarData(uid: uid, bandName: bandName, email: email, genres: genres, members: members, logoUrl: nil)
                        self.navigateToStarHome(bandName: bandName)
                        return
                    }

                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error getting band logo URL: \(error.localizedDescription)")
                            self.saveStarData(uid: uid, bandName: bandName, email: email, genres: genres, members: members, logoUrl: nil)
                            self.navigateToStarHome(bandName: bandName)
                            return
                        }

                        guard let logoUrl = url?.absoluteString else {
                            self.saveStarData(uid: uid, bandName: bandName, email: email, genres: genres, members: members, logoUrl: nil)
                            self.navigateToStarHome(bandName: bandName)
                            return
                        }

                        print("Band logo uploaded successfully with URL: \(logoUrl)")
                        self.saveStarData(uid: uid, bandName: bandName, email: email, genres: genres, members: members, logoUrl: logoUrl)
                        self.navigateToStarHome(bandName: bandName)
                    }
                }
            } else {
                // Use default logo if none provided
                self.saveStarData(uid: uid, bandName: bandName, email: email, genres: genres, members: members, logoUrl: nil)
                self.navigateToStarHome(bandName: bandName)
            }
        }
    }

    
    private func navigateToStarHome(bandName: String) {
        let homeVC = StarHomeView()
        homeVC.delegate = self // Set the delegate to ViewController
        homeVC.navigationItem.title = bandName
        let navController = UINavigationController(rootViewController: homeVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

    private func saveStarData(uid: String, bandName: String, email: String, genres: [String], members: [String], logoUrl: String?) {
        let starData: [String: Any] = [
            "uid": uid,
            "bandName": bandName,
            "email": email,
            "genres": genres,
            "members": members,
            "bandLogoUrl": logoUrl ?? "Default_Profile_Picture",
            "userType": "Star"
        ]

        db.collection("users").document(uid).setData(starData) { error in
            if let error = error {
                print("Error saving star data to Firestore: \(error.localizedDescription)")
                self.showAlert(message: "Error saving band data. Please try again.")
                return
            }

            print("Star data saved successfully to Firestore!")
        }
    }


    func didTapStarBackButton() {
        setupWelcomeView()
    }

    
    func didTapLogout() {
        do {
            try Auth.auth().signOut()
            print("Star logged out successfully.")
            
            // Dismiss any presented view controllers, including navigation controllers
            self.dismiss(animated: true) { [weak self] in
                self?.setupWelcomeView()
            }
        } catch let error {
            print("Error logging out: \(error.localizedDescription)")
            showAlert(message: "Error logging out. Please try again.")
        }
    }


    // MARK: - Image Picker Logic
    /*------------------------Image Picker Logic-------------------*/
    // MARK: - Image Picker Logic
    func didTapUploadBandLogo() {
        presentImagePicker(for: 1) // Tag 1 for band logo
    }

    func didTapUploadWorkoutImage() {
        presentImagePicker(for: 2) // Tag 2 for workout image
    }

    private func presentImagePicker(for tag: Int) {
        let actionSheet = UIAlertController(title: tag == 1 ? "Upload Band Logo" : "Upload Workout Image", message: "Choose an option", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary, tag: tag)
        })

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.openImagePicker(sourceType: .camera, tag: tag)
            })
        }

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }

    private func openImagePicker(sourceType: UIImagePickerController.SourceType, tag: Int) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        imagePicker.view.tag = tag // Tag to differentiate band logo or workout image
        present(imagePicker, animated: true, completion: nil)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage

        if picker.view.tag == 1 {
            updateBandLogo(with: selectedImage)
        } else if picker.view.tag == 2 {
            updateWorkoutImage(with: selectedImage)
        }
    }

    private func updateBandLogo(with image: UIImage?) {
        guard let starRegisterView = view.subviews.compactMap({ $0 as? StarRegisterView }).first else { return }
        starRegisterView.bandLogoImageView.image = image
    }

    private func updateWorkoutImage(with image: UIImage?) {
        guard let createWorkoutView = view.subviews.compactMap({ $0 as? CreateWorkoutView }).first else { return }
        createWorkoutView.coverPhotoImageView.image = image
    }
    
    // MARK: - Navigation for '+' Button
        func didTapAddWorkout() {
            view.subviews.forEach { $0.removeFromSuperview() } // Clear all views before showing CreateWorkoutView
            
            let createWorkoutView = CreateWorkoutView()
            createWorkoutView.delegate = self // Set the delegate
            createWorkoutView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(createWorkoutView)
            
            NSLayoutConstraint.activate([
                createWorkoutView.topAnchor.constraint(equalTo: view.topAnchor),
                createWorkoutView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                createWorkoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                createWorkoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }

        // MARK: - CreateWorkoutViewDelegate Methods
        func didTapCreateWorkoutBackButton() {
            print("CreateWorkoutView Back Button Tapped")
            navigateToStarHome(bandName: "Your Band Name")
        }

        func didTapPublishButton(workout: Workout) {
            print("Publishing Workout: \(workout)")
            saveWorkoutToFirestore(workout)
            navigateToStarHome(bandName:"Band Name") // Navigate back to StarHomeView after publishing
        }

        private func saveWorkoutToFirestore(_ workout: Workout) {
            let workoutData: [String: Any] = [
                "title": workout.title,
                "difficulty": workout.difficulty,
                "selectedMembers": workout.selectedMembers,
                "sets": workout.sets
            ]
            
            if let imageData = workout.coverPhoto.jpegData(compressionQuality: 0.8) {
                let storageRef = Storage.storage().reference().child("workoutImages/\(UUID().uuidString).jpg")
                storageRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("Error uploading workout image: \(error.localizedDescription)")
                        return
                    }
                    
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error getting workout image URL: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let imageUrl = url?.absoluteString else { return }
                        var workoutWithImage = workoutData
                        workoutWithImage["coverPhotoUrl"] = imageUrl
                        
                        self.db.collection("workouts").addDocument(data: workoutWithImage) { error in
                            if let error = error {
                                print("Error saving workout: \(error.localizedDescription)")
                            } else {
                                print("Workout saved successfully!")
                            }
                        }
                    }
                }
            }
        }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func didTapAddSet() {
            // Logic to add a set
            print("Add Set Tapped")
            // Example: Show an alert or navigate to a screen to add a set
        }
        
    
    func didTapFanLogout() {
        do {
            try Auth.auth().signOut()
            print("Fan logged out successfully.")
            
            // Dismiss any presented view controllers, including navigation controllers
            self.dismiss(animated: true) { [weak self] in
                self?.setupWelcomeView()
            }
        } catch let error {
            print("Error logging out: \(error.localizedDescription)")
            showAlert(message: "Error logging out. Please try again.")
        }
    }

    
    private func navigateToFanHome(firstName: String) {
        let fanHomeVC = FanHomeView()
        fanHomeVC.delegate = self
        fanHomeVC.firstName = firstName // Pass data to FanHomeView
        let navController = UINavigationController(rootViewController: fanHomeVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}
