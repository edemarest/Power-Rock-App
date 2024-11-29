import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - MainVC
// View controller for handling the main flow, checking authentication, and navigating based on user type
class MainVC: UIViewController {

    // MARK: - Properties
    let db = Firestore.firestore() // Firestore instance for fetching user data
    var userTitle: String? // User's title (Band name for Stars, First name for Fans)

    // MARK: - View Lifecycle
    // Check authentication status when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthentication() // Check if the user is authenticated
    }

    // MARK: - Methods
    // Check if a user is logged in and fetch user details
    private func checkAuthentication() {
        if let user = Auth.auth().currentUser {
            fetchUserDetails(for: user.uid) // Fetch user details if logged in
        } else {
            navigateToWelcomeScreen() // Navigate to welcome screen if not authenticated
        }
    }

    // Navigate to the welcome screen if the user is not authenticated
    func navigateToWelcomeScreen() {
        let welcomeVC = WelcomeViewController() // The welcome screen for new users
        if let navigationController = navigationController {
            navigationController.setViewControllers([welcomeVC], animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: welcomeVC)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }

    // Fetch user details from Firestore using the user ID
    private func fetchUserDetails(for uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            // Handle error in fetching user details
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                self.navigateToWelcomeScreen() // Navigate to the welcome screen if an error occurs
                return
            }

            // Process user data
            guard let data = snapshot?.data(),
                  let userType = data["userType"] as? String else {
                print("Invalid user data.")
                self.navigateToWelcomeScreen() // Navigate to welcome screen if data is invalid
                return
            }

            // Set the user title based on user type (Band name for Star, First name for Fan)
            self.userTitle = userType == "Star" ? data["bandName"] as? String : data["firstName"] as? String
            self.navigateBasedOnUserType(userType) // Navigate based on user type
        }
    }

    // Navigate to the correct screen based on user type
    private func navigateBasedOnUserType(_ userType: String) {
        if userType == "Star" {
            navigateToStarHomeView() // Navigate to Star home if user is a Star
        } else {
            navigateToFanHomeView() // Navigate to Fan home if user is a Fan
        }
    }

    // Navigate to the Fan home screen
    private func navigateToFanHomeView() {
        let fanHomeViewController = FanHomeViewController()
        navigationController?.pushViewController(fanHomeViewController, animated: true)
    }

    // Navigate to the Star home screen
    private func navigateToStarHomeView() {
        let starHomeVC = StarHomeViewController()
        navigationController?.pushViewController(starHomeVC, animated: true)
    }
}
