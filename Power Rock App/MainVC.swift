import UIKit
import FirebaseAuth
import FirebaseFirestore

/**
 `MainVC` Handles the main flow, checks user authentication, and navigates based on user type.
 */
class MainVC: UIViewController {

    // MARK: - Properties
    let db = Firestore.firestore()
    var userTitle: String?
    private var isAuthenticating = false

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthentication()
    }

    // MARK: - Authentication
    private func checkAuthentication() {
        guard !isAuthenticating else {
            print("DEBUG: Already authenticating, skipping.")
            return
        }
        isAuthenticating = true

        if let user = Auth.auth().currentUser {
            print("DEBUG: User authenticated, fetching details.")
            fetchUserDetails(for: user.uid)
        } else {
            print("DEBUG: No authenticated user, setting WelcomeViewController as root.")
            setWelcomeAsRoot()
        }
        isAuthenticating = false
    }

    private func setWelcomeAsRoot() {
        print("DEBUG: Setting WelcomeViewController as the root view controller.")
        DispatchQueue.main.async {
            let welcomeVC = WelcomeViewController()
            if let navigationController = self.navigationController {
                if !(navigationController.viewControllers.first is WelcomeViewController) {
                    print("DEBUG: NavigationController exists, resetting stack to WelcomeViewController.")
                    navigationController.setViewControllers([welcomeVC], animated: false)
                }
            } else {
                print("DEBUG: No NavigationController found, creating a new one with WelcomeViewController.")
                let navController = UINavigationController(rootViewController: welcomeVC)
                navController.modalPresentationStyle = .fullScreen
                self.view.window?.rootViewController = navController
                self.view.window?.makeKeyAndVisible()
            }
        }
    }

    // MARK: - User Details
    private func fetchUserDetails(for uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                self.setWelcomeAsRoot()
                return
            }

            guard let data = snapshot?.data(),
                  let userType = data["userType"] as? String else {
                self.setWelcomeAsRoot()
                return
            }

            self.userTitle = userType == "Star" ? data["bandName"] as? String : data["firstName"] as? String
            self.navigateBasedOnUserType(userType)
        }
    }

    // MARK: - Navigation
    private func navigateBasedOnUserType(_ userType: String) {
        if userType == "Star" {
            navigateToStarHomeView()
        } else {
            navigateToFanHomeView()
        }
    }

    private func navigateToFanHomeView() {
        let fanHomeViewController = FanHomeViewController()
        navigationController?.pushViewController(fanHomeViewController, animated: true)
    }

    private func navigateToStarHomeView() {
        let starHomeVC = StarHomeViewController()
        navigationController?.pushViewController(starHomeVC, animated: true)
    }
}
