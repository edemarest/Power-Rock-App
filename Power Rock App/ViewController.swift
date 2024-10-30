import UIKit

class ViewController: UIViewController, WelcomeViewDelegate, FanRegisterViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWelcomeView()
    }

    private func setupWelcomeView() {
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

    // WelcomeViewDelegate Methods
    func didTapFanButton() {
        navigateToFanRegister()
    }

    func didTapStarButton() {
        navigateToStarRegister()
    }

    func didTapLoginButton() {
        navigateToLogin()
    }

    private func navigateToFanRegister() {
        let fanRegisterView = FanRegisterView()
        fanRegisterView.delegate = self
        fanRegisterView.translatesAutoresizingMaskIntoConstraints = false

        // Clear current view and add fan register view
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(fanRegisterView)

        NSLayoutConstraint.activate([
            fanRegisterView.topAnchor.constraint(equalTo: view.topAnchor),
            fanRegisterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fanRegisterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fanRegisterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // FanRegisterViewDelegate Methods
    func didTapRegisterButton(firstName: String, email: String, password: String, profileImage: UIImage?) {
        // Handle the registration logic (currently a placeholder)
        print("Registering Fan: \(firstName), Email: \(email), Password: \(password)")
    }

    func didTapBackButton() {
        setupWelcomeView()
    }

    private func navigateToStarRegister() {
        // Placeholder for Star Register screen navigation
        print("Navigate to Star Register")
    }

    private func navigateToLogin() {
        // Placeholder for Login screen navigation
        print("Navigate to Login")
    }
}
