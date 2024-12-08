import UIKit

// MARK: - SetTableViewCellDelegate
protocol SetTableViewCellDelegate: AnyObject {
    func didCompleteSet(at index: Int)
}

// MARK: - CreateSetViewControllerDelegate Protocol
protocol CreateSetViewControllerDelegate: AnyObject {
    func didAddSet(_ set: WorkoutSet)
}

// MARK: - SetCellDelegate Protocol
protocol SetCellDelegate: AnyObject {
    func didCompleteSet(_ set: WorkoutSet)
}

// MARK: - FanHomeViewDelegate Protocol
protocol FanHomeViewDelegate: AnyObject {
    func didTapWorkoutCell(with workout: Workout)
}

// MARK: - FanRegisterViewDelegate Protocol
protocol FanRegisterViewDelegate: AnyObject {
    func didTapFanBackButton()
    func didTapFanRegisterButton(firstName: String, email: String, password: String, genres: [String])
}

// MARK: - LoginViewDelegate Protocol
protocol LoginViewDelegate: AnyObject {
    func didTapLoginBackButton()
    func didTapLoginButton(email: String, password: String)
}

// MARK: - SearchWorkoutViewDelegate Protocol
protocol SearchWorkoutViewControllerDelegate: AnyObject {
    func updateFilteredWorkouts(with workouts: [Workout])
}

// MARK: - StarHomeViewDelegate Protocol
protocol StarHomeViewDelegate: AnyObject {
    func didTapLogout()
    func didTapAddWorkout()
    func didTapWorkoutCell(with workout: Workout)
}

// MARK: - StarRegisterViewDelegate Protocol
protocol StarRegisterViewDelegate: AnyObject {
    func didTapStarBackButton()
    func didTapStarRegisterButton(bandName: String, email: String, password: String, genres: [String], members: [String], bandLogo: UIImage?)
}

// MARK: - WelcomeViewDelegate
// Protocol defining methods for WelcomeView button interactions
protocol WelcomeViewDelegate: AnyObject {
    func didTapFanButton()
    func didTapStarButton()
    func didTapLoginButtonFromWelcome()
}

// MARK: - WorkoutDetailsDelegate Protocol
protocol WorkoutDetailsViewControllerDelegate: AnyObject {
    func didUpdateWorkouts()
}

// MARK: - CreateWorkoutViewControllerDelegate Protocol
protocol CreateWorkoutViewControllerDelegate: AnyObject {
    func didPublishWorkout()
}

